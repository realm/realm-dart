// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:realm_dart/src/native/rooted_handle.dart';

import '../realm_class.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'realm_bindings.dart';

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
