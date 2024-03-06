part of 'realm_core.dart';

class SyncSocketProvider {
  late final receivePort = ReceivePort();
  late final Future<Isolate> _workThread;

  SyncSocketProvider._() {
    _workThread = Isolate.spawn((receivePort) async {
      await for (final message in receivePort) {
        print(message);
      }
    }, receivePort);
  }

  static SyncSocketHandle createHandle() {
    final provider = SyncSocketProvider._();
    final postWork = Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_socket_callback>)>(_postWork);
    final createTimer = Pointer.fromFunction<realm_sync_socket_timer_t Function(Handle, Uint64, Pointer<realm_sync_socket_callback>)>(_createTimer);
    final cancelTimer = Pointer.fromFunction<Void Function(Handle, Pointer<Void>)>(_cancelTimer);
    final freeTimer = Pointer.fromFunction<Void Function(Handle, Pointer<Void>)>(_freeTimer);
    final connect = Pointer.fromFunction<realm_sync_socket_websocket_t Function(Handle, realm_websocket_endpoint_t, Pointer<Void>)>(_connect);
    final write =
        Pointer.fromFunction<Void Function(Handle, realm_sync_socket_websocket_t, Pointer<Char>, Size, Pointer<realm_sync_socket_write_callback_t>)>(_write);
    final free = Pointer.fromFunction<Void Function(Handle, realm_sync_socket_websocket_t)>(_free);

    final socketPtr = _realmLib.realm_sync_socket_new(
      provider.toPersistentHandle(),
      _realmLib.addresses.realm_dart_delete_persistent_handle,
      postWork.cast(),
      createTimer.cast(),
      cancelTimer.cast(),
      freeTimer.cast(),
      connect.cast(),
      write.cast(),
      free.cast(),
    );

    return SyncSocketHandle._(socketPtr);
  }

  static void _postWork(Object userData, Pointer<realm_sync_socket_callback> callback) {}

  static realm_sync_socket_timer_t _createTimer(Object userData, int delayMilliseconds, Pointer<realm_sync_socket_callback> callback) {
    return nullptr;
  }

  static void _cancelTimer(Object userData, realm_sync_socket_timer_t timerUserData) {}

  static void _freeTimer(Object userData, realm_sync_socket_timer_t timerUserData) {}

  static realm_sync_socket_websocket_t _connect(Object userData, realm_websocket_endpoint_t endpoint, Pointer<Void> websocketObserver) {
    final provider = userData as SyncSocketProvider;

    final builder = UriBuilder()
      ..scheme = endpoint.is_ssl ? 'wss' : 'ws'
      ..port = endpoint.port
      ..host = endpoint.address.cast<Utf8>().toDartString();

    if (endpoint.path != nullptr) {
      final pathAndQuery = endpoint.path.cast<Utf8>().toDartString().split('?');
      builder.path = pathAndQuery.elementAtOrNull(0) ?? '';
      final query = pathAndQuery.elementAtOrNull(1);
      if (query != null) {
        builder.queryParameters = {for (var arg in query.split('&').map((e) => e.split('='))) arg[0]: arg[1]};
      }
    }

    final subprotocols = List.generate(endpoint.num_protocols, (index) => endpoint.protocols[index].cast<Utf8>().toDartString());

    final socket = SyncSocket(builder.build(), subprotocols, provider.receivePort.sendPort);

    return socket.toPersistentHandle();
  }

  static void _write(
      Object userdata, realm_sync_socket_websocket_t websocket, Pointer<Char> data, int size, Pointer<realm_sync_socket_write_callback_t> writeCallback) {}

  static void _free(Object userdata, realm_sync_socket_websocket_t websocket) {}
}

class SyncSocket {
  final SendPort sendPort;
  late final Future<void> readThread;

  SyncSocket(Uri uri, List<String> protocols, this.sendPort) {
    readThread = _start(uri, protocols);
  }

  Future<void> _start(Uri uri, List<String> protocols) async {
    late WebSocketChannel channel;
    try {
      channel = WebSocketChannel.connect(uri, protocols: protocols);
      await channel.ready;
    } catch (e) {
      // TODO: report
      return;
    }

    await for (final message in channel.stream) {
      sendPort.send(message);
    }
  }
}

class SyncSocketHandle extends HandleBase<realm_sync_socket> {
  SyncSocketHandle._(Pointer<realm_sync_socket> pointer) : super(pointer, 32); // TODO: what is the size here?
}
