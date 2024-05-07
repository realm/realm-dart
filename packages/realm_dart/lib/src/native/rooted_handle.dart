// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import '../realm_class.dart';
import 'handle_base.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';

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
  final RealmHandle root;
  int? _id;

  bool get shouldRoot => root.isUnowned;

  RootedHandleBase(this.root, Pointer<T> pointer, int size) : super(pointer, size) {
    if (shouldRoot) {
      _id = root.addChild(this);
    }
  }

  @override
  void releaseCore() {
    if (_id != null) {
      root.removeChild(_id!);
    }
  }
}

abstract class CollectionHandleBase<T extends NativeType> extends RootedHandleBase<T> {
  CollectionHandleBase(super.root, super.pointer, super.size);
}

void createCollection(Realm realm, RealmValue value, Pointer<realm_list> Function() createList, Pointer<realm_dictionary> Function() createMap) {
  CollectionHandleBase? collectionHandle;
  try {
    switch (value.collectionType) {
      case RealmCollectionType.list:
        final listHandle = ListHandle(createList(), realm.handle);
        collectionHandle = listHandle;

        final list = realm.createList<RealmValue>(listHandle, null);

        // Necessary since Core will not clear the collection if the value was already a collection
        list.clear();

        for (final item in value.value as List<RealmValue>) {
          list.add(item);
        }
      case RealmCollectionType.map:
        final mapHandle = MapHandle(createMap(), realm.handle);
        collectionHandle = mapHandle;

        final map = realm.createMap<RealmValue>(mapHandle, null);

        // Necessary since Core will not clear the collection if the value was already a collection
        map.clear();

        for (final kvp in (value.value as Map<String, RealmValue>).entries) {
          map[kvp.key] = kvp.value;
        }
      default:
        throw RealmStateError('_createCollection invoked with type that is not list or map.');
    }
  } finally {
    collectionHandle?.release();
  }
}
