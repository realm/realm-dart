// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:ffi/ffi.dart';
import 'package:realm_dart/src/handles/native/scheduler_handle.dart';
import 'package:realm_dart/src/handles/native/to_native.dart';

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
  final _workerThreadCompleter = Completer<Pointer<realm_sync_socket>>();
  final Map<int, SyncSocket> _sockets = {};
  late final SendPort _workerThreadPort;

  Future<SyncSocketHandle> start() async {
    final port = ReceivePort();
    port.listen(_handleMessageFromWorker);
    await Isolate.spawn(SyncEventLoop.start, port.sendPort, debugName: 'Realm Websocket Worker');

    final syncSocketPointer = await _workerThreadCompleter.future;
    return SyncSocketHandle(syncSocketPointer);
  }

  void _handleMessageFromWorker(dynamic message) async {
    try {
      switch (message) {
        case WorkerThreadInitialized wti:
          if (_workerThreadCompleter.isCompleted) {
            throw RealmError('WebsocketHandler.start called more than once. $bugInTheSdkMessage');
          }

          _workerThreadPort = wti.workerThreadPort;
          _workerThreadCompleter.complete(wti.socket);
          break;
        case WebSocketConnectRequest connectRequest:
          _sockets[connectRequest.proxyId] = SyncSocket(_workerThreadPort, connectRequest.proxyId, connectRequest.uri, connectRequest.protocols);
          break;
        case WebSocketWriteRequest writeRequest:
          await _sockets[writeRequest.proxyId]!.write(writeRequest.bytes, writeRequest.callback);
          break;
        case WebSocketCloseRequest closeRequest:
          await _sockets[closeRequest.proxyId]!.close();
          _sockets.remove(closeRequest.proxyId);
          break;
        default:
          throw RealmError('Unexpected message: $message');
      }
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'An error occurred in WebSocketHandler._handleMessageFromWorker: $e');
      rethrow;
    }
  }
}

class SyncEventLoop {
  final SendPort sendPort;
  final receivePort = ReceivePort();
  final Map<int, SyncSocketProxy> _proxies = {};

  static int proxyIdCounter = 0;

  SyncEventLoop._(this.sendPort) {
    receivePort.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    try {
      switch (message) {
        case IWebSocketOperation response:
          _proxies[response.proxyId]?.messageReceived(response);
          break;
        default:
          throw RealmError('Unexpected message: $message');
      }
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'Error occurred in SyncEventLoop._handleMessage: $e');
      stop();
    }
  }

  void stop() {
    Realm.logger.log(LogLevel.trace, 'Exiting WebsocketHandler event loop.');
    Isolate.exit(sendPort);
  }

  static void start(SendPort sendPort) {
    Realm.logger.log(LogLevel.trace, 'Entering WebsocketHandler event loop.');

    try {
      final eventLoop = SyncEventLoop._(sendPort);

      final post = Pointer.fromFunction<Void Function(Pointer<Void>, Pointer<realm_sync_socket_post_callback_t>)>(_postWork);
      final createTimer = Pointer.fromFunction<Pointer<Void> Function(Pointer<Void>, Uint64, Pointer<realm_sync_socket_post_callback_t>)>(_createTimer);
      final cancelTimer = Pointer.fromFunction<Void Function(Pointer<Void>, Handle)>(_cancelTimer);
      final freeTimer = Pointer.fromFunction<Void Function(Pointer<Void>, Pointer<Void>)>(_freeTimer);
      final websocketConnect =
          Pointer.fromFunction<Pointer<Void> Function(Handle, realm_websocket_endpoint_t, Pointer<realm_websocket_observer_t>)>(_websocketConnect);

      final websocketWrite =
          Pointer.fromFunction<Void Function(Handle, Handle, Pointer<Uint8>, Size, Pointer<realm_sync_socket_write_callback_t>)>(_websocketWrite);

      final freeSocket = Pointer.fromFunction<Void Function(Pointer<Void> _, Pointer<Void>)>(_freeWebsocket);

      final nativeSyncSocket = realmLib.realm_dart_sync_socket_new(eventLoop.toPersistentHandle(), Pointer.fromFunction(_free), schedulerHandle.pointer, post,
          createTimer, cancelTimer.cast(), freeTimer, websocketConnect.cast(), websocketWrite.cast(), freeSocket);

      sendPort.send(WorkerThreadInitialized(eventLoop.receivePort.sendPort, nativeSyncSocket));
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'Failed to initialize WebsocketHandler event loop: $e');
    }
  }

  static void _free(Pointer<Void> userdata) {
    final eventLoop = userdata.toObject<SyncEventLoop>();
    realmLib.realm_dart_delete_persistent_handle(userdata);
    eventLoop.stop();
  }

  static void _postWork(Object _, Pointer<realm_sync_socket_post_callback_t> nativeCallback) {
    realmLib.realm_sync_socket_post_complete(nativeCallback, realm_sync_socket_callback_result.RLM_ERR_SYNC_SOCKET_SUCCESS, nullptr);
  }

  static Pointer<Void> _createTimer(Pointer<Void> _, int delay, Pointer<realm_sync_socket_post_callback_t> nativeCallback) {
    final timer = SyncTimer(Duration(milliseconds: delay), nativeCallback);
    return timer.toPersistentHandle();
  }

  static void _cancelTimer(Pointer<Void> _, Object timerUserData) {
    final timer = timerUserData as SyncTimer;
    timer.cancel();
  }

  static void _freeTimer(Pointer<Void> _, Pointer<Void> timerUserData) {
    realmLib.realm_dart_delete_persistent_handle(timerUserData);
  }

  static Pointer<Void> _websocketConnect(Object userData, realm_websocket_endpoint_t endpoint, Pointer<realm_websocket_observer_t> observer) {
    final eventLoop = userData as SyncEventLoop;

    final pathAndQuery = endpoint.path.cast<Utf8>().toRealmDartString()?.split('?');
    final path = pathAndQuery?.elementAtOrNull(0);
    final query = pathAndQuery?.elementAtOrNull(1);

    final uri = Uri(scheme: endpoint.is_ssl ? 'wss' : 'ws', host: endpoint.address.cast<Utf8>().toDartString(), port: endpoint.port, path: path, query: query);
    final protocols = <String>[];
    for (var i = 0; i < endpoint.num_protocols; i++) {
      protocols.add(endpoint.protocols[i].cast<Utf8>().toDartString());
    }

    final result = SyncSocketProxy(proxyIdCounter++, uri, protocols, eventLoop.sendPort, observer);
    Realm.logger.log(LogLevel.trace, 'Created socket ${result.id}');

    eventLoop._proxies[result.id] = result;
    return result.toPersistentHandle();
  }

  static void _websocketWrite(Object _, Object websocket, Pointer<Uint8> data, int size, Pointer<realm_sync_socket_write_callback_t> callback) {
    final socket = websocket as SyncSocketProxy;
    final bytes = data.asTypedList(size).toList();
    socket.requestWrite(bytes, callback);
  }

  static void _freeWebsocket(Pointer<Void> userData, Pointer<Void> websocket) {
    final eventLoop = userData.toObject<SyncEventLoop>();
    final socket = websocket.toObject<SyncSocketProxy>();
    eventLoop._proxies.remove(socket.id);

    Realm.logger.log(LogLevel.trace, 'Destroying socket ${socket.id}');

    socket.requestClose();

    realmLib.realm_dart_delete_persistent_handle(websocket);
  }
}

class SyncTimer {
  final CancellationToken _cancellationToken = CancellationToken();

  SyncTimer(Duration duration, Pointer<realm_sync_socket_post_callback_t> nativeCallback) {
    Realm.logger.log(LogLevel.trace, 'Creating timer with delay $duration and target $nativeCallback.');
    CancellableFuture.delayed<void>(duration, _cancellationToken, () {
      Realm.logger.log(LogLevel.trace, 'Timer with target $nativeCallback completed.');
      realmLib.realm_sync_socket_timer_complete(nativeCallback, realm_sync_socket_callback_result.RLM_ERR_SYNC_SOCKET_SUCCESS, nullptr);
    }).onError((err, _) {
      Realm.logger.log(LogLevel.trace, 'Timer with target $nativeCallback was canceled.');
      realmLib.realm_sync_socket_timer_canceled(nativeCallback);
    });
  }

  void cancel() {
    _cancellationToken.cancel();
  }
}

abstract interface class IWebSocketOperation {
  final int proxyId;

  IWebSocketOperation._(this.proxyId);
}

class WebSocketConnectRequest extends IWebSocketOperation {
  final Uri uri;
  final List<String> protocols;

  WebSocketConnectRequest(super.proxyId, this.uri, this.protocols) : super._();
}

class WebSocketConnected extends IWebSocketOperation {
  final String protocol;

  WebSocketConnected(super.proxyId, this.protocol) : super._();
}

class WebSocketCloseRequest extends IWebSocketOperation {
  WebSocketCloseRequest(super.proxyId) : super._();
}

class WebSocketClosed extends IWebSocketOperation {
  final bool clean;
  final String description;
  final int closeCode;
  WebSocketClosed(super.proxyId, this.clean, this.closeCode, this.description) : super._();
}

class WebSocketDataReceived extends IWebSocketOperation {
  final List<int> message;

  WebSocketDataReceived(super.proxyId, this.message) : super._();
}

class WebSocketWriteRequest extends IWebSocketOperation {
  List<int> bytes;
  Pointer<realm_sync_socket_callback> callback;

  WebSocketWriteRequest(super.proxyId, this.bytes, this.callback) : super._();
}

class WebSocketDataSent extends IWebSocketOperation {
  final Pointer<realm_sync_socket_write_callback_t> callback;
  final int statusCode;
  final String? error;

  WebSocketDataSent.ok(super.proxyId, this.callback)
      : statusCode = realm_sync_socket_callback_result.RLM_ERR_SYNC_SOCKET_SUCCESS,
        error = null,
        super._();

  WebSocketDataSent.error(super.proxyId, this.callback, this.statusCode, String errorMessage)
      : error = errorMessage,
        super._();
}

class WorkerThreadInitialized {
  final SendPort workerThreadPort;
  final Pointer<realm_sync_socket> socket;

  WorkerThreadInitialized(this.workerThreadPort, this.socket);
}

class SyncSocketProxy {
  final int id;
  final Uri _uri;
  final List<String> _protocols;
  final SendPort _sendPort;
  final Pointer<realm_websocket_observer_t> _observer;

  SyncSocketProxy(this.id, this._uri, this._protocols, this._sendPort, this._observer) {
    _sendPort.send(WebSocketConnectRequest(id, _uri, _protocols));
  }

  void messageReceived(IWebSocketOperation message) {
    using((Arena arena) {
      switch (message) {
        case WebSocketConnected connected:
          realmLib.realm_sync_socket_websocket_connected(_observer, connected.protocol.toCharPtr(arena));
          break;
        case WebSocketClosed socketClosed:
          realmLib.realm_sync_socket_websocket_closed(_observer, socketClosed.clean, socketClosed.closeCode, socketClosed.description.toCharPtr(arena));
          break;
        case WebSocketDataReceived dataReceived:
          realmLib.realm_sync_socket_websocket_message(_observer, dataReceived.message.toCharPtr(arena), dataReceived.message.length);
          break;
        case WebSocketDataSent dataSent:
          realmLib.realm_sync_socket_write_complete(dataSent.callback, dataSent.statusCode, dataSent.error?.toCharPtr(arena) ?? nullptr);
          break;
      }
    });
  }

  void requestWrite(List<int> bytes, Pointer<realm_sync_socket_write_callback_t> callback) {
    _sendPort.send(WebSocketWriteRequest(id, bytes, callback));
  }

  void requestClose() {
    _sendPort.send(WebSocketCloseRequest(id));
  }
}

class SyncSocket {
  final SendPort sendPort;
  final int proxyId;

  late final Future<void> _readThread;

  late final WebSocket _webSocket;

  SyncSocket(this.sendPort, this.proxyId, Uri uri, List<String> protocols) {
    _readThread = _socketRead(uri, protocols);
  }

  Future<void> _socketRead(Uri uri, List<String> protocols) async {
    _log(LogLevel.trace, 'Entering WebSocket event loop');

    try {
      _webSocket = await WebSocket.connect(uri.toString(), protocols: protocols);
      sendPort.send(WebSocketConnected(proxyId, _webSocket.protocol!));
    } catch (e) {
      _log(LogLevel.error, "Error establishing WebSocket connection: $e");
      sendPort.send(WebSocketClosed(proxyId, false, realm_web_socket_errno.RLM_ERR_WEBSOCKET_CONNECTION_FAILED, e.toString()));
      return;
    }

    final stream = _webSocket.listen((message) {
      switch (message) {
        case List<int> binary:
          sendPort.send(WebSocketDataReceived(proxyId, binary));
          break;
        default:
          _log(LogLevel.warn, 'Received unexpected websocket message: $message');
          break;
      }
    });

    try {
      await stream.asFuture<void>();
      _log(LogLevel.trace, 'WebSocket closed with status: ${_webSocket.closeCode} and description ${_webSocket.closeReason}');
      sendPort.send(WebSocketClosed(proxyId, true, _webSocket.closeCode!, _webSocket.closeReason!));
    } catch (error, stacktrace) {
      _log(LogLevel.error, 'Error reading from WebSocket: $error');
      _log(LogLevel.trace, 'Error reading from WebSocket: $stacktrace');
      sendPort.send(WebSocketClosed(proxyId, false, realm_web_socket_errno.RLM_ERR_WEBSOCKET_READ_ERROR, error.toString()));
    }
  }

  Future<void> write(List<int> bytes, Pointer<realm_sync_socket_write_callback_t> callback) async {
    if (_webSocket.closeCode != null) {
      sendPort.send(WebSocketDataSent.error(
          proxyId, callback, realm_sync_socket_callback_result.RLM_ERR_SYNC_SOCKET_CONNECTION_CLOSED, "Connection closed: ${_webSocket.closeReason}"));
      return;
    }

    try {
      await _webSocket.addStream(Stream.value(bytes));
      sendPort.send(WebSocketDataSent.ok(proxyId, callback));
    } catch (e) {
      _log(LogLevel.error, "Error writing to WebSocket: $e");

      sendPort.send(WebSocketDataSent.error(proxyId, callback, realm_sync_socket_callback_result.RLM_ERR_SYNC_SOCKET_RUNTIME, e.toString()));
      _webSocket.close(realm_web_socket_errno.RLM_ERR_WEBSOCKET_WRITE_ERROR, e.toString());
    }
  }

  Future<void> close() async {
    _log(LogLevel.trace, "Closing WebSocket.");

    if (_webSocket.closeCode == null) {
      await _webSocket.close(realm_web_socket_errno.RLM_ERR_WEBSOCKET_OK);
    }

    await _readThread;

    _log(LogLevel.trace, "Closed WebSocket.");
  }

  void _log(LogLevel level, Object message) {
    Realm.logger.log(level, 'WebSocket $proxyId: $message');
  }
}
