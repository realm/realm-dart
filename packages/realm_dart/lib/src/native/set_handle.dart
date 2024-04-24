// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class SetHandle extends RootedHandleBase<realm_set> {
  SetHandle._(Pointer<realm_set> pointer, RealmHandle root) : super(root, pointer, 96);

  ResultsHandle get asResults {
    final ptr = invokeGetPointer(() => realmLib.realm_set_to_results(pointer));
    return ResultsHandle._(ptr, _root);
  }

  ResultsHandle query(String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_set(
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

  bool insert(Object? value) {
    return using((Arena arena) {
      final realmValue = toRealmValue(value, arena);
      final outIndex = arena<Size>();
      final outInserted = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_insert(pointer, realmValue.ref, outIndex, outInserted));
      return outInserted.value;
    });
  }

  // TODO: avoid taking the [realm] parameter
  Object? elementAt(Realm realm, int index) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_set_get(pointer, index, realmValue));
      final result = realmValue.toDartValue(
        realm,
        () => throw RealmException('Sets cannot contain collections'),
        () => throw RealmException('Sets cannot contain collections'),
      );
      return result;
    });
  }

  bool find(Object? value) {
    return using((Arena arena) {
      // TODO: how should this behave for collections
      final realmValue = toRealmValue(value, arena);
      final outIndex = arena<Size>();
      final outFound = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_find(pointer, realmValue.ref, outIndex, outFound));
      return outFound.value;
    });
  }

  bool remove(Object? value) {
    return using((Arena arena) {
      // TODO: do we support sets containing mixed collections
      final realmValue = toRealmValue(value, arena);
      final outErased = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_erase(pointer, realmValue.ref, outErased));
      return outErased.value;
    });
  }

  void clear() {
    invokeGetBool(() => realmLib.realm_set_clear(pointer));
  }

  int get size {
    return using((Arena arena) {
      final outSize = arena<Size>();
      invokeGetBool(() => realmLib.realm_set_size(pointer, outSize));
      return outSize.value;
    });
  }

  bool get isValid {
    return realmLib.realm_set_is_valid(pointer);
  }

  void deleteAll() {
    invokeGetBool(() => realmLib.realm_set_remove_all(pointer));
  }

  SetHandle? resolveIn(RealmHandle frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_set>>();
      invokeGetBool(() => realmLib.realm_set_resolve_in(pointer, frozenRealm.pointer, resultPtr));
      return resultPtr == nullptr ? null : SetHandle._(resultPtr.value, _root);
    });
  }

  RealmNotificationTokenHandle subscribeForNotifications(NotificationsController controller) {
    final ptr = invokeGetPointer(() => realmLib.realm_set_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(collectionChangeCallback),
        ));
    return RealmNotificationTokenHandle._(ptr, _root);
  }
}
