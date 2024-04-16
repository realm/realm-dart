// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class ObjectHandle extends RootedHandleBase<realm_object> {
  ObjectHandle._(Pointer<realm_object> pointer, RealmHandle root) : super(root, pointer, 112);

  ObjectHandle createEmbedded(int propertyKey) {
    final objectPtr = invokeGetPointer(() => realmLib.realm_set_embedded(pointer, propertyKey));
    return ObjectHandle._(objectPtr, _root);
  }

  int get classKey => realmLib.realm_object_get_table(pointer);

  bool get isValid => realmLib.realm_object_is_valid(pointer);

  // TODO: avoid taking the [realm] parameter
  Object? getValue(Realm realm, int propertyKey) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_get_value(pointer, propertyKey, realmValue));
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_get_list(pointer, propertyKey),
        () => realmLib.realm_get_dictionary(pointer, propertyKey),
      );
    });
  }

  // TODO: value should be RealmValue, and perhaps this method should be combined
  // with setCollection?
  void setValue(int propertyKey, Object? value, bool isDefault) {
    using((Arena arena) {
      final realmValue = _toRealmValue(value, arena);
      invokeGetBool(
        () => realmLib.realm_set_value(
          pointer,
          propertyKey,
          realmValue.ref,
          isDefault,
        ),
      );
    });
  }

  ListHandle getList(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_list(pointer, propertyKey));
    return ListHandle._(ptr, _root);
  }

  SetHandle getSet(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_set(pointer, propertyKey));
    return SetHandle._(ptr, _root);
  }

  MapHandle getMap(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_dictionary(pointer, propertyKey));
    return MapHandle._(ptr, _root);
  }

  ResultsHandle getBacklinks(int sourceTableKey, int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_backlinks(pointer, sourceTableKey, propertyKey));
    return ResultsHandle._(ptr, _root);
  }

  void setCollection(Realm realm, int propertyKey, RealmValue value) {
    _createCollection(
      realm,
      value,
      () => realmLib.realm_set_list(pointer, propertyKey),
      () => realmLib.realm_set_dictionary(pointer, propertyKey),
    );
  }

  String objectToString() {
    return realmLib.realm_object_to_string(pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  void delete() {
    invokeGetBool(() => realmLib.realm_object_delete(pointer));
  }

  ObjectHandle? resolveIn(RealmHandle frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_object>>();
      invokeGetBool(() => realmLib.realm_object_resolve_in(pointer, frozenRealm.pointer, resultPtr));
      return resultPtr == nullptr ? null : ObjectHandle._(resultPtr.value, frozenRealm);
    });
  }

  RealmNotificationTokenHandle subscribeForNotifications(NotificationsController controller, [List<String>? keyPaths]) {
    return using((Arena arena) {
      final kpNative = buildAndVerifyKeyPath(keyPaths);
      final ptr = invokeGetPointer(() => realmLib.realm_object_add_notification_callback(
            pointer,
            controller.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
            kpNative,
            Pointer.fromFunction(object_change_callback),
          ));

      return RealmNotificationTokenHandle._(ptr, _root);
    });
  }

  Pointer<realm_key_path_array> buildAndVerifyKeyPath(List<String>? keyPaths) {
    return using((Arena arena) {
      if (keyPaths == null) {
        return nullptr;
      }

      final length = keyPaths.length;
      final keypathsNative = arena<Pointer<Char>>(length);

      for (int i = 0; i < length; i++) {
        keypathsNative[i] = keyPaths[i].toCharPtr(arena);
      }
      // TODO(kn):
      // call to classKey getter involves a native call, which is not ideal
      return invokeGetPointer(() => realmLib.realm_create_key_path_array(_root.pointer, classKey, length, keypathsNative));
    });
  }
}
