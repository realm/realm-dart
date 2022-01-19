import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;

import 'realm_bindings.dart';

typedef Callback = void Function(Pointer<Void>);
typedef _Callback = Void Function(Pointer<Void>, Pointer<Void>);
typedef StaticCallback = Pointer<NativeFunction<_Callback>>;

typedef Free = void Function();
typedef _Free = Void Function(Pointer<Void>);
typedef StaticFree = Pointer<NativeFunction<_Free>>;

typedef Error = void Function(Pointer<realm_async_error>);
typedef _Error = Void Function(Pointer<Void>, Pointer<realm_async_error>);
typedef StaticError = Pointer<NativeFunction<_Error>>;

class CallbackBridge {
  static final _bridges = <Pointer<Void>, WeakReference<CallbackBridge>>{}; // if only Expandos allowed ffi types as key :-/

  static Pointer<Void> create(Callback callback, {Free? free, Error? error}) {
    final bridge = CallbackBridge._(callback, free, error);
    final descriptor = calloc<Int64>().cast<Void>();
    _bridges[descriptor] = WeakReference(bridge);
    return descriptor;
  }

  static void __callback(Pointer<Void> descriptor, Pointer<Void> changes) {
    final bridge = _bridges[descriptor]!;
    bridge.target?._callback(changes);
  }

  static StaticCallback get callback => Pointer.fromFunction(__callback);

  // public until dart 2.17 has proper finalizers (see controller_builder.dart)
  // remove internal prefix when possible
  // ignore: non_constant_identifier_names
  static void internal__free(Pointer<Void> descriptor) {
    final bridge = _bridges.remove(descriptor);
    if (bridge != null) {
      // protect against double free
      bridge.target?._free?.call();
      calloc.free(descriptor);
    }
  }

  static StaticFree get free => Pointer.fromFunction(internal__free);

  static void __error(Pointer<Void> descriptor, Pointer<realm_async_error> error) {
    final bridge = _bridges[descriptor]!;
    bridge.target?._error?.call(error);
  }

  static StaticError get error => Pointer.fromFunction(__error);

  final Callback _callback;
  final Free? _free;
  final Error? _error;

  CallbackBridge._(this._callback, this._free, this._error);
}

// Pseudo WeakReference class. Doesn't actually work. True weak references not possible before dart 2.17
class WeakReference<T extends Object> {
  final Expando<T> _expando;

  WeakReference(T? target) : _expando = Expando<T>() {
    this.target = target;
  }

  T? get target => _expando[this];
  set target(T? value) => _expando[this] = value;
}
