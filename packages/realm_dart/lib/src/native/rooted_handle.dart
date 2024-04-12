// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class FinalizationToken {
  final WeakReference<RealmHandle> root;
  final int id;

  FinalizationToken(RealmHandle handle, this.id) : root = WeakReference(handle);
}

// This finalizer is intended to prevent the list of children in the RealmHandle
// from growing endlessly. It's not intended to replace the native finalizer which
// will free the actual resources owned by the handle.
final rootedHandleFinalizer = Finalizer<FinalizationToken>((token) {
  token.root.target?.removeChild(token.id);
});

abstract class RootedHandleBase<T extends NativeType> extends HandleBase<T> {
  final RealmHandle _root;
  int? _id;

  bool get shouldRoot => _root.isUnowned;

  RootedHandleBase(this._root, Pointer<T> pointer, int size) : super(pointer, size) {
    if (shouldRoot) {
      _id = _root.addChild(this);
    }
  }

  @override
  void releaseCore() {
    if (_id != null) {
      _root.removeChild(_id!);
    }
  }
}

abstract class CollectionHandleBase<T extends NativeType> extends RootedHandleBase<T> {
  CollectionHandleBase(super.root, super.pointer, super.size);
}

