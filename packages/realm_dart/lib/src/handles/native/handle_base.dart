// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:realm_dart/realm.dart';

import 'error_handling.dart';
import 'realm_library.dart';

import '../handle_base.dart' as intf;

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

abstract class HandleBase<T extends NativeType> implements Finalizable, intf.HandleBase {
  late Pointer<Void> _finalizableHandle;
  Pointer<T> _pointer;
  Pointer<T> get pointer {
    if (released) throw RealmError('Trying to access a released handle');
    return _pointer;
  }

  @override
  bool get released => _pointer == nullptr;
  @override
  final bool isUnowned;

  HandleBase(this._pointer, int size) : isUnowned = false {
    _pointer.raiseLastErrorIfNull();
    _finalizableHandle = realmLib.realm_attach_finalizer(this, pointer.cast(), size);

    if (_enableFinalizerTrace) {
      _setupFinalizationTrace(this, _pointer);
    }
  }

  HandleBase.unowned(this._pointer) : isUnowned = true {
    _pointer.raiseLastErrorIfNull();
  }

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<IntPtr>().value}${isUnowned ? ' (unowned)' : ''}";

  /// @nodoc
  /// A method that will be invoked just before the handle is released. Allows to cleanup
  /// any custom data that inheritors are storing.
  @override
  void releaseCore() {}

  @override
  void release() {
    if (released) {
      return;
    }

    releaseCore();

    if (!isUnowned) {
      realmLib.realm_detach_finalizer(_finalizableHandle, this);

      realmLib.realm_release(_pointer.cast());
    }

    _pointer = nullptr;

    if (_enableFinalizerTrace) {
      _tearDownFinalizationTrace(this, _pointer);
    }
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => other is HandleBase<T>
      ? _pointer == other._pointer
          ? true
          : realmLib.realm_equals(_pointer.cast(), other._pointer.cast())
      : false;
}
