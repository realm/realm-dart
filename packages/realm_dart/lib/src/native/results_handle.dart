// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../realm_dart.dart';
import 'error_handling.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'rooted_handle.dart';

class ResultsHandle extends RootedHandleBase<realm_results> {
  ResultsHandle(Pointer<realm_results> pointer, RealmHandle root) : super(root, pointer, 872);

  ResultsHandle queryResults(String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle(
          realmLib
              .realm_query_parse_for_results(
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

  int find(Object? value) {
    return using((Arena arena) {
      final outIndex = arena<Size>();
      final outFound = arena<Bool>();

      // TODO: how should this behave for collections
      final realmValue = value.toNative(arena);
      realmLib
          .realm_results_find(
            pointer,
            realmValue,
            outIndex,
            outFound,
          )
          .raiseIfFalse();
      return outFound.value ? outIndex.value : -1;
    });
  }

  ObjectHandle getObjectAt(int index) {
    final objectPointer = realmLib.realm_results_get_object(pointer, index).raiseIfNull();
    return ObjectHandle(objectPointer, root);
  }

  int get count {
    return using((Arena arena) {
      final countPtr = arena<Size>();
      realmLib.realm_results_count(pointer, countPtr).raiseIfFalse();
      return countPtr.value;
    });
  }

  bool isValid() {
    return using((arena) {
      final isValid = arena<Bool>();
      realmLib.realm_results_is_valid(pointer, isValid).raiseIfFalse();
      return isValid.value;
    });
  }

  void deleteAll() {
    realmLib.realm_results_delete_all(pointer).raiseIfFalse();
  }

  ResultsHandle snapshot() {
    final resultsPointer = realmLib.realm_results_snapshot(pointer).raiseIfNull();
    return ResultsHandle(resultsPointer, root);
  }

  ResultsHandle resolveIn(RealmHandle realmHandle) {
    final ptr = realmLib.realm_results_resolve_in(pointer, realmHandle.pointer).raiseIfNull();
    return ResultsHandle(ptr, realmHandle);
  }

  Object? elementAt(Realm realm, int index) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      realmLib.realm_results_get(pointer, index, realmValue).raiseIfFalse();
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_results_get_list(pointer, index),
        () => realmLib.realm_results_get_dictionary(pointer, index),
      );
    });
  }

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = realmLib
        .realm_results_add_notification_callback(
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
