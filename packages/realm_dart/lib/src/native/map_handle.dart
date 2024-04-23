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

  ResultsHandle query(String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer + i, arena);
      }

      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_results(
              values.pointer,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          _root);
      return queryHandle.findAll();
    });
  }

  MapHandle? resolveIn(RealmHandle frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_dictionary>>();
      invokeGetBool(() => realmLib.realm_dictionary_resolve_in(pointer, frozenRealm.pointer, resultPtr));
      return resultPtr == nullptr ? null : MapHandle._(resultPtr.value, _root);
    });
  }

  RealmNotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = invokeGetPointer(() => realmLib.realm_dictionary_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(_mapChangeCallback),
        ));
    return RealmNotificationTokenHandle._(ptr, _root);
  }
}

void _mapChangeCallback(Pointer<Void> userdata, Pointer<realm_dictionary_changes> data) {
  final NotificationsController controller = userdata.toObject();

  if (data == nullptr) {
    controller.onError(RealmError("Invalid notifications data received"));
    return;
  }

  try {
    final clonedData = realmLib.realm_clone(data.cast());
    if (clonedData == nullptr) {
      controller.onError(RealmError("Error while cloning notifications data"));
      return;
    }

    final changesHandle = RealmMapChangesHandle._(clonedData.cast());
    controller.onChanges(changesHandle);
  } catch (e) {
    controller.onError(RealmError("Error handling change notifications. Error: $e"));
  }
}
