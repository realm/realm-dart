// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import '../../realm_class.dart';
import 'from_native.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

import '../subscription_handle.dart' as intf;
class SubscriptionHandle extends HandleBase<realm_flx_sync_subscription> implements intf.SubscriptionHandle{
  SubscriptionHandle(Pointer<realm_flx_sync_subscription> pointer) : super(pointer, 184);

  @override
  ObjectId get id => realmLib.realm_sync_subscription_id(pointer).toDart();

  @override
  String? get name => realmLib.realm_sync_subscription_name(pointer).toDart();

  @override
  String get objectClassName => realmLib.realm_sync_subscription_object_class_name(pointer).toDart()!;

  @override
  String get queryString => realmLib.realm_sync_subscription_query_string(pointer).toDart()!;

  @override
  DateTime get createdAt => realmLib.realm_sync_subscription_created_at(pointer).toDart();

  @override
  DateTime get updatedAt => realmLib.realm_sync_subscription_updated_at(pointer).toDart();

  @override
  bool equalTo(covariant SubscriptionHandle other) => realmLib.realm_equals(pointer.cast(), other.pointer.cast());
}
