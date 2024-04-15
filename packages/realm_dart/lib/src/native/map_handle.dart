// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class MapHandle extends CollectionHandleBase<realm_dictionary> {
  MapHandle._(Pointer<realm_dictionary> pointer, RealmHandle root) : super(root, pointer, 96); // TODO: check size

  int get size {
    return using((Arena arena) {
      final outSize = arena<Size>();
      invokeGetBool(() => realmLib.realm_dictionary_size(pointer, outSize));
      return outSize.value;
    });
  }

  bool remove(String key) {
    return using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      final outErased = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_erase(pointer, keyNative.ref, outErased));
      return outErased.value;
    });
  }

  // TODO: avoid taking the [realm] parameter
  Object? find(Realm realm, String key) {
    return using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      final outValue = arena<realm_value_t>();
      final outFound = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_find(pointer, keyNative.ref, outValue, outFound));
      if (outFound.value) {
        return outValue.toDartValue(
          realm,
          () => realmLib.realm_dictionary_get_list(pointer, keyNative.ref),
          () => realmLib.realm_dictionary_get_dictionary(pointer, keyNative.ref),
        );
      }
      return null;
    });
  }

  bool get isValid {
    return realmLib.realm_dictionary_is_valid(pointer);
  }

  void clear() {
    invokeGetBool(() => realmLib.realm_dictionary_clear(pointer));
  }

  ResultsHandle get keys {
    return using((Arena arena) {
      final outSize = arena<Size>();
      final outKeys = arena<Pointer<realm_results>>();
      invokeGetBool(() => realmLib.realm_dictionary_get_keys(pointer, outSize, outKeys));
      return ResultsHandle._(outKeys.value, _root);
    });
  }

  ResultsHandle get values {
    final ptr = invokeGetPointer(() => realmLib.realm_dictionary_to_results(pointer));
    return ResultsHandle._(ptr, _root);
  }

  bool containsKey(String key) {
    return using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      final found = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_contains_key(pointer, keyNative.ref, found));
      return found.value;
    });
  }

  int indexOf(Object? value) {
    return using((Arena arena) {
      // TODO: how should this behave for collections
      final valueNative = _toRealmValue(value, arena);
      final index = arena<Size>();
      invokeGetBool(() => realmLib.realm_dictionary_contains_value(pointer, valueNative.ref, index));
      return index.value;
    });
  }

  bool containsValue(Object? value) => indexOf(value) > -1;

  ObjectHandle insertEmbedded(String key) {
    return using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      final ptr = invokeGetPointer(() => realmLib.realm_dictionary_insert_embedded(pointer, keyNative.ref));
      return ObjectHandle._(ptr, _root);
    });
  }

  void insert(String key, Object? value) {
    using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      final valueNative = _toRealmValue(value, arena);
      invokeGetBool(
        () => realmLib.realm_dictionary_insert(
          pointer,
          keyNative.ref,
          valueNative.ref,
          nullptr,
          nullptr,
        ),
      );
    });
  }

  void insertCollection(Realm realm, String key, RealmValue value) {
    using((Arena arena) {
      final keyNative = _toRealmValue(key, arena);
      _createCollection(
        realm,
        value,
        () => realmLib.realm_dictionary_insert_list(pointer, keyNative.ref),
        () => realmLib.realm_dictionary_insert_dictionary(pointer, keyNative.ref),
      );
    });
  }

  RealmNotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = invokeGetPointer(() => realmLib.realm_dictionary_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(map_change_callback),
        ));
    return RealmNotificationTokenHandle._(ptr, _root);
  }
}
