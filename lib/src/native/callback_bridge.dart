import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'realm_bindings.dart';

typedef Callback = void Function(Pointer<Void>);
typedef _Callback = Void Function(Pointer<Void>, Pointer<Void>);
typedef Free = void Function();
typedef _Free = Void Function(Pointer<Void>);
typedef Error = void Function(Pointer<realm_async_error>);
typedef _Error = Void Function(Pointer<Void>, Pointer<realm_async_error>);

class CallbackBridge {
  static final _bridges = <int, CallbackBridge>{};

  static Pointer<Void> create(Callback callback, {Free? free, Error? error}) {
    final bridge = CallbackBridge._(callback, free, error);
    final descriptor = calloc<Int64>();
    final hash = bridge.hashCode;
    descriptor.value = bridge.hashCode;
    _bridges[hash] = bridge;
    return descriptor.cast();
  }

  static void __callback(Pointer<Void> descriptor, Pointer<Void> changes) {
    final bridge = _bridges[descriptor.cast<Int64>().value]!;
    bridge._callback(changes);
  }

  static Pointer<NativeFunction<_Callback>> get callback => Pointer.fromFunction(__callback);

  static void __free(Pointer<Void> descriptor) {
    final bridge = _bridges.remove(descriptor.cast<Int64>().value)!;
    bridge._free?.call();
    calloc.free(descriptor);
  }

  static Pointer<NativeFunction<_Free>> get free => Pointer.fromFunction(__free);

  static void __error(Pointer<Void> descriptor, Pointer<realm_async_error> error) {
    final bridge = _bridges[descriptor.cast<Int64>().value]!;
    bridge._error?.call(error);
  }

  static Pointer<NativeFunction<_Error>> get error => Pointer.fromFunction(__error);

  final Callback _callback;
  final Free? _free;
  final Error? _error;

  CallbackBridge._(this._callback, this._free, this._error);
}
