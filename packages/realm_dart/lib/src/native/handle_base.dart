// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'realm_library.dart';

// Flag to enable trace on finalization.
//
// Be aware that the trace is likely late, and it might in rare case be missing,
// as there are no absolute guarantees with Finalizer.
//
// It is often beneficial to also instrument the native realm_release to
// print the address released to get the exact time.
//
// This is const to allow the compiler to remove the trace code if not enabled.
const _enableFinalizerTrace = false;

void _traceFinalization(Object o) {
  print('Finalizing: $o');
}

final _debugFinalizer = Finalizer<Object>(_traceFinalization);

void _setupFinalizationTrace(Object value, Object finalizationToken) {
  _debugFinalizer.attach(value, finalizationToken, detach: value);
}

void _tearDownFinalizationTrace(Object value, Object finalizationToken) {
  _debugFinalizer.detach(value);
  _traceFinalization(finalizationToken);
}

abstract class HandleBase<T extends NativeType> implements Finalizable {
  late Pointer<Void> _finalizableHandle;
  Pointer<T> pointer;
  bool get released => pointer == nullptr;
  final bool isUnowned;

  @pragma('vm:never-inline')
  void keepAlive() {}

  HandleBase(this.pointer, int size) : isUnowned = false {
    _finalizableHandle = realmLib.realm_attach_finalizer(this, pointer.cast(), size);

    if (_enableFinalizerTrace) {
      _setupFinalizationTrace(this, pointer);
    }
  }

  HandleBase.unowned(this.pointer) : isUnowned = true;

  @override
  String toString() => "${pointer.toString()} value=${pointer.cast<IntPtr>().value}${isUnowned ? ' (unowned)' : ''}";

  /// @nodoc
  /// A method that will be invoked just before the handle is released. Allows to cleanup
  /// any custom data that inheritors are storing.
  void releaseCore() {}

  void release() {
    if (released) {
      return;
    }

    releaseCore();

    if (!isUnowned) {
      realmLib.realm_detach_finalizer(_finalizableHandle, this);

      realmLib.realm_release(pointer.cast());
    }

    pointer = nullptr;

    if (_enableFinalizerTrace) {
      _tearDownFinalizationTrace(this, pointer);
    }
  }
}
