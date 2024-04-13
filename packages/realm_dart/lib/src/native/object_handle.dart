// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class ObjectHandle extends RootedHandleBase<realm_object> {
  ObjectHandle._(Pointer<realm_object> pointer, RealmHandle root) : super(root, pointer, 112);

  ObjectHandle createEmbedded(int propertyKey) {
    final objectPtr = invokeGetPointer(() => realmLib.realm_set_embedded(pointer, propertyKey));
    return ObjectHandle._(objectPtr, _root);
  }

  int getClassKey() => realmLib.realm_object_get_table(pointer);
}
