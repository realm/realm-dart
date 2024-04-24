// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class ResultsHandle extends RootedHandleBase<realm_results> {
  ResultsHandle._(Pointer<realm_results> pointer, RealmHandle root) : super(root, pointer, 872);

  ResultsHandle queryResults(String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_results(
              pointer,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          _root);
      return queryHandle.findAll();
    });
  }

  int find(Object? value) {
    return using((Arena arena) {
      final outIndex = arena<Size>();
      final outFound = arena<Bool>();

      // TODO: how should this behave for collections
      final realmValue = toRealmValue(value, arena);
      invokeGetBool(
        () => realmLib.realm_results_find(
          pointer,
          realmValue,
          outIndex,
          outFound,
        ),
      );
      return outFound.value ? outIndex.value : -1;
    });
  }

  ObjectHandle getObjectAt(int index) {
    final objectPointer = invokeGetPointer(() => realmLib.realm_results_get_object(pointer, index));
    return ObjectHandle._(objectPointer, _root);
  }

  int get count {
    return using((Arena arena) {
      final countPtr = arena<Size>();
      invokeGetBool(() => realmLib.realm_results_count(pointer, countPtr));
      return countPtr.value;
    });
  }

  bool isValid() {
    return using((arena) {
      final isValid = arena<Bool>();
      invokeGetBool(() => realmLib.realm_results_is_valid(pointer, isValid));
      return isValid.value;
    });
  }

  void deleteAll() {
    invokeGetBool(() => realmLib.realm_results_delete_all(pointer));
  }

  ResultsHandle snapshot() {
    final resultsPointer = invokeGetPointer(() => realmLib.realm_results_snapshot(pointer));
    return ResultsHandle._(resultsPointer, _root);
  }

  ResultsHandle resolveIn(RealmHandle realmHandle) {
    final ptr = invokeGetPointer(() => realmLib.realm_results_resolve_in(pointer, realmHandle.pointer));
    return ResultsHandle._(ptr, realmHandle);
  }

  Object? elementAt(Realm realm, int index) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_results_get(pointer, index, realmValue));
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_results_get_list(pointer, index),
        () => realmLib.realm_results_get_dictionary(pointer, index),
      );
    });
  }

  RealmNotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = invokeGetPointer(
      () => realmLib.realm_results_add_notification_callback(
        pointer,
        controller.toPersistentHandle(),
        realmLib.addresses.realm_dart_delete_persistent_handle,
        nullptr,
        Pointer.fromFunction(collectionChangeCallback),
      ),
    );
    return RealmNotificationTokenHandle._(ptr, _root);
  }
}
