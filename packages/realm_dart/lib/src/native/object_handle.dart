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

/*
  Object? getProperty(int propertyKey) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_get_value(pointer, propertyKey, realmValue));
      return realmValue.toDartValue(
        object.realm,
        () => realmLib.realm_get_list(pointer, propertyKey),
        () => realmLib.realm_get_dictionary(pointer, propertyKey),
      );
    });
  }
*/  

  void setProperty(int propertyKey, Object? value, bool isDefault) {
    using((Arena arena) {
      final realmValue = _toRealmValue(value, arena);
      invokeGetBool(() => realmLib.realm_set_value(pointer, propertyKey, realmValue.ref, isDefault));
    });
  }

/*
  void objectSetCollection(int propertyKey, RealmValue value) {
    _createCollection(object.realm, value, () => realmLib.realm_set_list(pointer, propertyKey),
        () => realmLib.realm_set_dictionary(pointer, propertyKey));
  }
*/  

  String objectToString() {
    return realmLib.realm_object_to_string(pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  void delete() {
    invokeGetBool(() => realmLib.realm_object_delete(pointer));
  }
}
