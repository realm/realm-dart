// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'from_native.dart';

class SyncSocketHandle extends HandleBase<realm_sync_socket> {
  SyncSocketHandle(Pointer<realm_sync_socket> pointer) : super(pointer, 24); // TODO: what should this value be?

  factory SyncSocketHandle.create() {
    final connectCallback = Pointer.fromFunction<Pointer<Void> Function(Handle, realm_websocket_endpoint_t, Pointer<realm_websocket_observer_t>)>(_connect);

    return SyncSocketHandle(realmLib.realm_sync_socket_new(nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, connectCallback.cast(), nullptr, nullptr));
  }
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
