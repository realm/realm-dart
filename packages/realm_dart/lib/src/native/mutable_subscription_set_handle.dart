// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../realm_dart.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'subscription_handle.dart';
import 'subscription_set_handle.dart';

class MutableSubscriptionSetHandle extends SubscriptionSetHandle {
  MutableSubscriptionSetHandle(Pointer<realm_flx_sync_mutable_subscription_set> pointer, RealmHandle root) : super(pointer.cast(), root);

  Pointer<realm_flx_sync_mutable_subscription_set> get _mutablePointer => super.pointer.cast();

  SubscriptionSetHandle commit() => SubscriptionSetHandle(realmLib.realm_sync_subscription_set_commit(_mutablePointer), root);

  SubscriptionHandle insertOrAssignSubscription(ResultsHandle results, String? name, bool update) {
    if (!update) {
      if (name != null && findByName(name) != null) {
        throw RealmException('Duplicate subscription with name: $name');
      }
    }
    return using((arena) {
      final outIndex = arena<Size>();
      final outInserted = arena<Bool>();
      realmLib
          .realm_sync_subscription_set_insert_or_assign_results(
            _mutablePointer,
            results.pointer,
            name?.toCharPtr(arena) ?? nullptr,
            outIndex,
            outInserted,
          )
          .raiseLastErrorIfFalse();
      return this[outIndex.value];
    });
  }

  bool erase(SubscriptionHandle subscription) {
    return using((arena) {
      final outErased = arena<Bool>();
      realmLib
          .realm_sync_subscription_set_erase_by_id(
            _mutablePointer,
            subscription.id.toNative(arena),
            outErased,
          )
          .raiseLastErrorIfFalse();
      return outErased.value;
    });
  }

  bool eraseByName(String name) {
    return using((arena) {
      final outErased = arena<Bool>();
      realmLib
          .realm_sync_subscription_set_erase_by_name(
            _mutablePointer,
            name.toCharPtr(arena),
            outErased,
          )
          .raiseLastErrorIfFalse();
      return outErased.value;
    });
  }

  bool eraseByResults(ResultsHandle results) {
    return using((arena) {
      final outErased = arena<Bool>();
      realmLib
          .realm_sync_subscription_set_erase_by_results(
            _mutablePointer,
            results.pointer,
            outErased,
          )
          .raiseLastErrorIfFalse();
      return outErased.value;
    });
  }

  void clear() => realmLib.realm_sync_subscription_set_clear(_mutablePointer).raiseLastErrorIfFalse();
}
