// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';

import 'package:cancellation_token/cancellation_token.dart';

import '../../../realm.dart';
import '../../logging.dart';
import 'ffi.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'from_native.dart';

class SyncSocketHandle extends HandleBase<realm_sync_socket> {
  SyncSocketHandle(Pointer<realm_sync_socket> pointer) : super(pointer, 24); // TODO: what should this value be?
}

class WebsocketHandler {
  SendPort? _workerThreadPort;

  SyncSocketHandle start() {
    final port = ReceivePort();
    port.listen(_handleMessageFromWorker);
    Isolate.spawn(SyncEventLoop.start, port.sendPort, debugName: 'Realm Websocket Worker');

    final post = Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_socket_post_callback_t>)>(_postWork);
    final createTimer = Pointer.fromFunction<Pointer<Void> Function(Handle, Uint64, Pointer<realm_sync_socket_post_callback_t>)>(_createTimer);
    final cancelTimer = Pointer.fromFunction<Void Function(Pointer<Void>, Handle)>(_cancelTimer);
    final freeTimer = Pointer.fromFunction<Void Function(Pointer<Void>, Pointer<Void>)>(_freeTimer);
    final websocketConnect =
        Pointer.fromFunction<Pointer<Void> Function(Handle, realm_websocket_endpoint_t, Pointer<realm_websocket_observer_t>)>(_websocketConnect);

    final websocketWrite =
        Pointer.fromFunction<Void Function(Handle, Handle, Pointer<Uint8>, Size, Pointer<realm_sync_socket_write_callback_t>)>(_websocketWrite);

    final freeSocket = Pointer.fromFunction<Void Function(Pointer<Void>, Pointer<Void>)>(_freeWebsocket);

    final nativeSyncSocket = realmLib.realm_sync_socket_new(toPersistentHandle(), realmLib.addresses.realm_dart_delete_persistent_handle, post.cast(),
        createTimer.cast(), cancelTimer.cast(), freeTimer, websocketConnect.cast(), websocketWrite.cast(), freeSocket);
    return SyncSocketHandle(nativeSyncSocket);
  }

  void _handleMessageFromWorker(dynamic message) {
    switch (message) {
      case SendPort sendPort:
        if (_workerThreadPort != null) {
          throw RealmError('WebsocketHandler.start called more than once. $bugInTheSdkMessage');
        }

        _workerThreadPort = sendPort;
        break;
      default:
        break;
    }
  }

  static void _postWork(Object userData, Pointer<realm_sync_socket_post_callback_t> nativeCallback) {
    final handler = userData as WebsocketHandler;

    handler._workerThreadPort!.send(EventLoopWork(nativeCallback));
  }

  static Pointer<Void> _createTimer(Object userData, int delay, Pointer<realm_sync_socket_post_callback_t> nativeCallback) {
    final handler = userData as WebsocketHandler;
    final timer = SyncTimer(Duration(milliseconds: delay), nativeCallback, handler);
    return timer.toPersistentHandle();
  }

  static void _cancelTimer(Object _, Object timerUserData) {
    final timer = timerUserData as SyncTimer;
    timer.cancel();
  }

  static void _freeTimer(Object _, Pointer<Void> timerUserData) {
    realmLib.realm_dart_delete_persistent_handle(timerUserData);
  }

  static Pointer<Void> _websocketConnect(Object userData, realm_websocket_endpoint_t endpoint, Pointer<realm_websocket_observer_t> observer) {
    final handler = userData as WebsocketHandler;

    final pathAndQuery = endpoint.path.cast<Utf8>().toRealmDartString()?.split('?');
    final path = pathAndQuery?.elementAtOrNull(0);
    final query = pathAndQuery?.elementAtOrNull(1);

    final uri = Uri(scheme: endpoint.is_ssl ? 'wss' : 'ws', host: endpoint.address.cast<Utf8>().toDartString(), port: endpoint.port, path: path, query: query);
    final protocols = <String>[];
    for (var i = 0; i < endpoint.num_protocols; i++) {
      protocols.add(endpoint.protocols[i].cast<Utf8>().toDartString());
    }

    final socket = SyncSocket(uri, protocols, handler._workerThreadPort!, observer);
    return socket.toPersistentHandle();
  }

  static void _websocketWrite(Object _, Object websocket, Pointer<Uint8> data, int size, Pointer<realm_sync_socket_write_callback_t> callback) {
    final socket = websocket as SyncSocket;
    final bytes = data.asTypedList(size).toList();
    socket.write(bytes, callback);
  }

  static void _freeWebsocket(Object _, Pointer<Void> websocket) {
    final socket = websocket.toObject<SyncSocket>();

    final _ = socket.close();

    realmLib.realm_dart_delete_persistent_handle(websocket);
  }
}

class SyncEventLoop {
  final SendPort sendPort;
  final receivePort = ReceivePort();

  SyncEventLoop._(this.sendPort) {
    receivePort.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    try {
      switch (message) {
        case _IWork work:
          work.execute();
          break;
        default:
          Realm.logger.log(LogLevel.error, 'Unexpected message received: $message');
          break;
      }
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'Error occurred in SyncSocketProvider event loop $e');
      _stop();
    }

    Realm.logger.log(LogLevel.trace, 'Exiting WebsocketHandler event loop.');
  }

  void _stop() {
    // TODO
    Isolate.exit(sendPort);
  }

  static void start(SendPort sendPort) {
    final eventLoop = SyncEventLoop._(sendPort);
    sendPort.send(eventLoop.receivePort.sendPort);
  }
}

abstract interface class _IWork {
  void execute();
}

abstract class WebSocketWork extends _IWork {
  final int _nativeObserver;

  Pointer<realm_websocket_observer_t> get observer => Pointer.fromAddress(_nativeObserver);

  WebSocketWork(Pointer<realm_websocket_observer_t> observer) : _nativeObserver = observer.address;

  @override
  void execute() {
    throw "aaa: $observer";
  }
}

class EventLoopWork extends _IWork {
  final int _nativeCallback;
  final Status status;

  Pointer<realm_sync_socket_post_callback_t> get pointer => Pointer.fromAddress(_nativeCallback);

  EventLoopWork(Pointer<realm_sync_socket_post_callback_t> pointer, {this.status = Status.ok}) : _nativeCallback = pointer.address;

  @override
  void execute() {
    throw "aaa: $pointer, $status";
  }
}

class SyncTimer {
  final CancellationToken _cancellationToken = CancellationToken();

  SyncTimer(Duration duration, Pointer<realm_sync_socket_post_callback_t> nativeCallback, WebsocketHandler handler) {
    Realm.logger.log(LogLevel.trace, 'Creating timer with delay $duration and target $nativeCallback.');
    Future<void>.delayed(duration, () {
      final status = _cancellationToken.isCancelled ? Status(ErrorCode.operationAborted, reason: 'Timer canceled') : Status.ok;
      handler._workerThreadPort!.send(EventLoopWork(nativeCallback, status: status));
    }).asCancellable(_cancellationToken);
  }

  void cancel() {
    _cancellationToken.cancel();
  }
}

class WebSocketConnectedWork extends WebSocketWork {
  final String _protocol;

  WebSocketConnectedWork(this._protocol, Pointer<realm_websocket_observer_t> observer) : super(observer);
}

class WebSocketClosedWork extends WebSocketWork {
  final bool _clean;
  final String _description;
  final int _closeCode;
  WebSocketClosedWork(this._clean, this._description, this._closeCode, Pointer<realm_websocket_observer_t> observer) : super(observer);
}

class SyncSocket {
  final Uri _uri;
  final List<String> _protocols;
  final SendPort _sendPort;
  final Pointer<realm_websocket_observer_t> _observer;

  WebSocket? _webSocket;

  SyncSocket(this._uri, this._protocols, this._sendPort, this._observer) {
    final _ = _socketRead();
  }

  Future<void> _socketRead() async {
    Realm.logger.log(LogLevel.trace, 'Entering WebSocket event loop.');

    try {
      _webSocket = await WebSocket.connect(_uri.toString(), protocols: _protocols);
      _sendPort.send(WebSocketConnectedWork(_webSocket!.protocol!, _observer));
    } catch (e) {
      Realm.logger.log(LogLevel.error, "Error establishing WebSocket connection: $e");
      _sendPort.send(WebSocketClosedWork(false, e.toString(), realm_web_socket_errno.RLM_ERR_WEBSOCKET_CONNECTION_FAILED, _observer));
      return;
    }

    // TODO: implement reading
    throw "Not implemented";
  }

  Future<void> write(List<int> bytes, Pointer<realm_sync_socket_callback> callback) async {
    final socket = _webSocket;
    if (socket == null || socket.closeCode != null) {
      // TODO: delete callback
      return;
    }

    try {
      await _webSocket!.addStream(Stream.value(bytes));
    } catch (e) {
      Realm.logger.log(LogLevel.error, "Error writing to WebSocket: $e");
      _sendPort.send(WebSocketClosedWork(false, e.toString(), realm_web_socket_errno.RLM_ERR_WEBSOCKET_WRITE_ERROR, _observer));

      // TODO: delete callback
      return;
    }

    _sendPort.send(EventLoopWork(callback));
  }

  Future<void> close() async {
    final socket = _webSocket;
    if (socket != null && socket.closeCode == null) {
      await socket.close(realm_web_socket_errno.RLM_ERR_WEBSOCKET_OK);
    }

    Realm.logger.log(LogLevel.trace, "Disposing WebSocket.");

    // TODO: wait for read thread to finish
  }
}

enum ErrorCode {
  ok(0),
  runtimeError(1000),
  operationAborted(1027);

  final int rawValue;

  const ErrorCode(this.rawValue);
}

class Status {
  final ErrorCode code;
  final String? reason;

  static const Status ok = Status._(ErrorCode.ok);

  Status(this.code, {this.reason});

  const Status._(this.code) : reason = null;
}
