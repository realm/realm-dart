// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../../realm_dart.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'notification_token_handle.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
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
        realmLib.realm_query_parse_for_results(
          pointer,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
        root,
      );
      return queryHandle.findAll();
    });
  }

  int find(Object? value) {
    return using((arena) {
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
          .raiseLastErrorIfFalse();
      return outFound.value ? outIndex.value : -1;
    });
  }

  ObjectHandle getObjectAt(int index) {
    return ObjectHandle(realmLib.realm_results_get_object(pointer, index), root);
  }

  int get count {
    return using((arena) {
      final countPtr = arena<Size>();
      realmLib.realm_results_count(pointer, countPtr).raiseLastErrorIfFalse();
      return countPtr.value;
    });
  }

  bool isValid() {
    return using((arena) {
      final isValid = arena<Bool>();
      realmLib.realm_results_is_valid(pointer, isValid).raiseLastErrorIfFalse();
      return isValid.value;
    });
  }

  void deleteAll() {
    realmLib.realm_results_delete_all(pointer).raiseLastErrorIfFalse();
  }

  ResultsHandle snapshot() {
    return ResultsHandle(realmLib.realm_results_snapshot(pointer), root);
  }

  ResultsHandle resolveIn(RealmHandle realmHandle) {
    return ResultsHandle(realmLib.realm_results_resolve_in(pointer, realmHandle.pointer), realmHandle);
  }

  Object? elementAt(Realm realm, int index) {
    return using((arena) {
      final realmValue = arena<realm_value_t>();
      realmLib.realm_results_get(pointer, index, realmValue).raiseLastErrorIfFalse();
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_results_get_list(pointer, index),
        () => realmLib.realm_results_get_dictionary(pointer, index),
      );
    });
  }

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    return NotificationTokenHandle(
      realmLib.realm_results_add_notification_callback(
        pointer,
        controller.toPersistentHandle(),
        realmLib.addresses.realm_dart_delete_persistent_handle,
        nullptr,
        Pointer.fromFunction(collectionChangeCallback),
      ),
      root,
    );
  }
}
