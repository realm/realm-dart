// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../../realm_dart.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'notification_token_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';

import '../set_handle.dart' as intf;

class SetHandle extends RootedHandleBase<realm_set> implements intf.SetHandle {
  SetHandle(Pointer<realm_set> pointer, RealmHandle root) : super(root, pointer, 96);

  @override
  ResultsHandle get asResults {
    return ResultsHandle(realmLib.realm_set_to_results(pointer), root);
  }

  @override
  ResultsHandle query(String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle(
        realmLib.realm_query_parse_for_set(
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

  @override
  bool insert(Object? value) {
    return using((arena) {
      final realmValue = value.toNative(arena);
      final outIndex = arena<Size>();
      final outInserted = arena<Bool>();
      realmLib.realm_set_insert(pointer, realmValue.ref, outIndex, outInserted).raiseLastErrorIfFalse();
      return outInserted.value;
    });
  }

  // TODO: avoid taking the [realm] parameter
  @override
  Object? elementAt(Realm realm, int index) {
    return using((arena) {
      final realmValue = arena<realm_value_t>();
      realmLib.realm_set_get(pointer, index, realmValue).raiseLastErrorIfFalse();
      final result = realmValue.toDartValue(
        realm,
        () => throw RealmException('Sets cannot contain collections'),
        () => throw RealmException('Sets cannot contain collections'),
      );
      return result;
    });
  }

  @override
  bool find(Object? value) {
    return using((arena) {
      // TODO: how should this behave for collections
      final realmValue = value.toNative(arena);
      final outIndex = arena<Size>();
      final outFound = arena<Bool>();
      realmLib.realm_set_find(pointer, realmValue.ref, outIndex, outFound).raiseLastErrorIfFalse();
      return outFound.value;
    });
  }

  @override
  bool remove(Object? value) {
    return using((arena) {
      // TODO: do we support sets containing mixed collections
      final realmValue = value.toNative(arena);
      final outErased = arena<Bool>();
      realmLib.realm_set_erase(pointer, realmValue.ref, outErased).raiseLastErrorIfFalse();
      return outErased.value;
    });
  }

  @override
  void clear() {
    realmLib.realm_set_clear(pointer).raiseLastErrorIfFalse();
  }

  @override
  int get size {
    return using((arena) {
      final outSize = arena<Size>();
      realmLib.realm_set_size(pointer, outSize).raiseLastErrorIfFalse();
      return outSize.value;
    });
  }

  @override
  bool get isValid {
    return realmLib.realm_set_is_valid(pointer);
  }

  @override
  void deleteAll() {
    realmLib.realm_set_remove_all(pointer).raiseLastErrorIfFalse();
  }

  @override
  SetHandle? resolveIn(covariant RealmHandle frozenRealm) {
    return using((arena) {
      final resultPtr = arena<Pointer<realm_set>>();
      realmLib.realm_set_resolve_in(pointer, frozenRealm.pointer, resultPtr).raiseLastErrorIfFalse();
      return resultPtr == nullptr ? null : SetHandle(resultPtr.value, root);
    });
  }

  @override
  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, List<String>? keyPaths, int? classKey) {
    return using((Arena arena) {
      final kpNative = root.buildAndVerifyKeyPath(keyPaths, classKey);
      return NotificationTokenHandle(
        realmLib.realm_set_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          kpNative,
          Pointer.fromFunction(collectionChangeCallback),
        ),
        root,
      );
    });
  }
}
