// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../realm_dart.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'map_changes_handle.dart';
import 'notification_token_handle.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
// TODO: remove this import
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';

class MapHandle extends CollectionHandleBase<realm_dictionary> {
  MapHandle(Pointer<realm_dictionary> pointer, RealmHandle root) : super(root, pointer, 96); // TODO: check size

  int get size {
    return using((arena) {
      final outSize = arena<Size>();
      realmLib.realm_dictionary_size(pointer, outSize).raiseLastErrorIfFalse();
      return outSize.value;
    });
  }

  bool remove(String key) {
    return using((arena) {
      final keyNative = key.toNative(arena);
      final outErased = arena<Bool>();
      realmLib.realm_dictionary_erase(pointer, keyNative.ref, outErased).raiseLastErrorIfFalse();
      return outErased.value;
    });
  }

  // TODO: avoid taking the [realm] parameter
  Object? find(Realm realm, String key) {
    return using((arena) {
      final keyNative = key.toNative(arena);
      final outValue = arena<realm_value_t>();
      final outFound = arena<Bool>();
      realmLib.realm_dictionary_find(pointer, keyNative.ref, outValue, outFound).raiseLastErrorIfFalse();
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
    realmLib.realm_dictionary_clear(pointer).raiseLastErrorIfFalse();
  }

  ResultsHandle get keys {
    return using((arena) {
      final outSize = arena<Size>();
      final outKeys = arena<Pointer<realm_results>>();
      realmLib.realm_dictionary_get_keys(pointer, outSize, outKeys).raiseLastErrorIfFalse();
      return ResultsHandle(outKeys.value, root);
    });
  }

  ResultsHandle get values {
    return ResultsHandle(realmLib.realm_dictionary_to_results(pointer), root);
  }

  bool containsKey(String key) {
    return using((arena) {
      final keyNative = key.toNative(arena);
      final found = arena<Bool>();
      realmLib.realm_dictionary_contains_key(pointer, keyNative.ref, found).raiseLastErrorIfFalse();
      return found.value;
    });
  }

  int indexOf(Object? value) {
    return using((arena) {
      // TODO: how should this behave for collections
      final valueNative = value.toNative(arena);
      final index = arena<Size>();
      realmLib.realm_dictionary_contains_value(pointer, valueNative.ref, index).raiseLastErrorIfFalse();
      return index.value;
    });
  }

  bool containsValue(Object? value) => indexOf(value) > -1;

  ObjectHandle insertEmbedded(String key) {
    return using((arena) {
      final keyNative = key.toNative(arena);
      return ObjectHandle(realmLib.realm_dictionary_insert_embedded(pointer, keyNative.ref), root);
    });
  }

  void insert(String key, Object? value) {
    using((arena) {
      final keyNative = key.toNative(arena);
      final valueNative = value.toNative(arena);
      realmLib
          .realm_dictionary_insert(
            pointer,
            keyNative.ref,
            valueNative.ref,
            nullptr,
            nullptr,
          )
          .raiseLastErrorIfFalse();
    });
  }

  void insertCollection(Realm realm, String key, RealmValue value) {
    using((arena) {
      final keyNative = key.toNative(arena);
      createCollection(
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
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }

      final queryHandle = QueryHandle(
        realmLib.realm_query_parse_for_results(
          values.pointer,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
        root,
      );
      return queryHandle.findAll();
    });
  }

  MapHandle? resolveIn(RealmHandle frozenRealm) {
    return using((arena) {
      final resultPtr = arena<Pointer<realm_dictionary>>();
      realmLib.realm_dictionary_resolve_in(pointer, frozenRealm.pointer, resultPtr).raiseLastErrorIfFalse();
      return resultPtr == nullptr ? null : MapHandle(resultPtr.value, root);
    });
  }

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    return NotificationTokenHandle(
      realmLib.realm_dictionary_add_notification_callback(
        pointer,
        controller.toPersistentHandle(),
        realmLib.addresses.realm_dart_delete_persistent_handle,
        nullptr,
        Pointer.fromFunction(_mapChangeCallback),
      ),
      root,
    );
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

    final changesHandle = MapChangesHandle(clonedData.cast());
    controller.onChanges(changesHandle);
  } catch (e) {
    controller.onError(RealmError("Error handling change notifications. Error: $e"));
  }
}
