// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/logging.dart';

import 'ffi.dart';

import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'from_native.dart';

class SyncSocketHandle extends HandleBase<realm_sync_socket> {
  SyncSocketHandle(Pointer<realm_sync_socket> pointer) : super(pointer, 24); // TODO: what should this value be?
}

class WebsocketHandler {
  Completer<SyncSocketHandle>? _startCompleter;
  SendPort? _workerThreadPort;

  Future<SyncSocketHandle> start() async {
    if (_startCompleter == null) {
      _startCompleter = Completer();

      final port = ReceivePort();
      port.listen(_handleMessageFromWorker);
      await Isolate.spawn(_runBackgroundWorker, port.sendPort, debugName: 'Realm Websocket Worker');
    }

    return _startCompleter!.future;
  }

  void _handleMessageFromWorker(dynamic message) {
    switch (message) {
      case _SyncEventLoopSetupResponse setupMessage:
        final completer = _startCompleter;
        if (completer == null) {
          throw RealmError('WebsocketHandler.start called more than once. $bugInTheSdkMessage');
        }

        _workerThreadPort = setupMessage.sendPort;
        completer.complete(SyncSocketHandle(setupMessage.pointer));
        break;
      default:
        break;
    }
  }

  static Future<void> _runBackgroundWorker(SendPort sendPort) async {
    try {
      Realm.logger.log(LogLevel.trace, 'Starting WebsocketHandler event loop.');
      final streamController = StreamController<_IWork>();

      final receivePort = ReceivePort();
      receivePort.listen((message) {
        switch (message) {
          case _IWork work:
            streamController.add(work);
            break;
          default:
            Realm.logger.log(LogLevel.error, 'Unexpected message received: $message');
            break;
        }
      });

      final nativeSyncSocket = realmLib.realm_sync_socket_new(nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
      sendPort.send(_SyncEventLoopSetupResponse(nativeSyncSocket, receivePort.sendPort));
      await for (final workItem in streamController.stream) {
        workItem.execute();
      }
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'Error occurred in SyncSocketProvider event loop $e');
    }

    Realm.logger.log(LogLevel.trace, 'Exiting WebsocketHandler event loop.');
  }
}

abstract interface class _IWork {
  void execute();
}

class _SyncEventLoopSetupResponse {
  final int _pointerAsInt;
  final SendPort sendPort;

  Pointer<realm_sync_socket> get pointer {
    return Pointer.fromAddress(_pointerAsInt);
  }

  _SyncEventLoopSetupResponse(Pointer<realm_sync_socket> pointer, this.sendPort) : _pointerAsInt = pointer.address;
}

Pointer<Void> _connect(Object _, realm_websocket_endpoint_t endpoint, Pointer<realm_websocket_observer_t> observer) {
  final pathAndQuery = endpoint.path.cast<Utf8>().toRealmDartString()?.split('?');
  final path = pathAndQuery?.elementAtOrNull(0);
  final query = pathAndQuery?.elementAtOrNull(1);

  final uri = Uri(scheme: endpoint.is_ssl ? 'wss' : 'ws', host: endpoint.address.cast<Utf8>().toDartString(), port: endpoint.port, path: path, query: query);
  final protocols = <String>[];
  for (var i = 0; i < endpoint.num_protocols; i++) {
    protocols.add(endpoint.protocols[i].cast<Utf8>().toDartString());
  }

  final channel = WebSocketChannel.connect(uri, protocols: protocols);
  final websocket = _Websocket(channel, observer);
  return websocket.toPersistentHandle();
}

class _Websocket {
  final WebSocketChannel _channel;
  final Pointer<realm_websocket_observer_t> _observer;

  _Websocket(this._channel, this._observer);
}
