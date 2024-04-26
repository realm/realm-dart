// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../realm_dart.dart';
import 'error_handling.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
import 'realm_core.dart'; // TODO: Remove this import
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';

class ListHandle extends CollectionHandleBase<realm_list> {
  ListHandle(Pointer<realm_list> pointer, RealmHandle root) : super(root, pointer, 88);

  bool get isValid => realmLib.realm_list_is_valid(pointer);

  ResultsHandle asResults() {
    final ptr = realmLib.realm_list_to_results(pointer).raiseIfNull();
    return ResultsHandle(ptr, root);
  }

  int get size {
    return using((Arena arena) {
      final size = arena<Size>();
      realmLib.realm_list_size(pointer, size).raiseIfFalse();
      return size.value;
    });
  }

  void removeAt(int index) {
    realmLib.realm_list_erase(pointer, index).raiseIfFalse();
  }

  void move(int from, int to) {
    realmLib.realm_list_move(pointer, from, to).raiseIfFalse();
  }

  void deleteAll() {
    realmLib.realm_list_remove_all(pointer).raiseIfFalse();
  }

  int indexOf(Object? value) {
    return using((Arena arena) {
      final outIndex = arena<Size>();
      final outFound = arena<Bool>();

      // TODO: how should this behave for collections
      final realmValue = value.toNative(arena);
      realmLib
          .realm_list_find(
            pointer,
            realmValue,
            outIndex,
            outFound,
          )
          .raiseIfFalse();
      return outFound.value ? outIndex.value : -1;
    });
  }

  void clear() {
    realmLib.realm_list_clear(pointer).raiseIfFalse();
  }

  // TODO: avoid taking the [realm] parameter
  Object? elementAt(Realm realm, int index) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      realmLib.realm_list_get(pointer, index, realmValue).raiseIfFalse();
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_list_get_list(pointer, index),
        () => realmLib.realm_list_get_dictionary(pointer, index),
      );
    });
  }

  ListHandle? resolveIn(RealmHandle frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_list>>();
      realmLib.realm_list_resolve_in(pointer, frozenRealm.pointer, resultPtr).raiseIfFalse();
      return resultPtr == nullptr ? null : ListHandle(resultPtr.value, root);
    });
  }

  // TODO: Consider splitting into two methods
  void addOrUpdateAt(int index, Object? value, bool insert) {
    using((Arena arena) {
      final realmValue = value.toNative(arena);
      (insert ? realmLib.realm_list_insert : realmLib.realm_list_set)(pointer, index, realmValue.ref).raiseIfFalse();
    });
  }

  // TODO: avoid taking the [realm] parameter
  void addOrUpdateCollectionAt(Realm realm, int index, RealmValue value, bool insert) {
    createCollection(realm, value, () => (insert ? realmLib.realm_list_insert_list : realmLib.realm_list_set_list)(pointer, index),
        () => (insert ? realmLib.realm_list_insert_dictionary : realmLib.realm_list_set_dictionary)(pointer, index));
  }

  ObjectHandle setEmbeddedAt(int index) {
    final ptr = realmLib.realm_list_set_embedded(pointer, index).raiseIfNull();
    return ObjectHandle(ptr, root);
  }

  ObjectHandle insertEmbeddedAt(int index) {
    final ptr = realmLib.realm_list_insert_embedded(pointer, index).raiseIfNull();
    return ObjectHandle(ptr, root);
  }

  ResultsHandle query(String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle(
          realmLib
              .realm_query_parse_for_list(
                pointer,
                query.toCharPtr(arena),
                length,
                argsPointer,
              )
              .raiseIfNull(),
          root);
      return queryHandle.findAll();
    });
  }

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = realmLib
        .realm_list_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(collectionChangeCallback),
        )
        .raiseIfNull();
    return NotificationTokenHandle(ptr, root);
  }
}
