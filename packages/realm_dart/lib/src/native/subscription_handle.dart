// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import '../realm_class.dart'; // TODO: Remove this import
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_core.dart'; // TODO: Remove this import
import 'realm_library.dart';

class SubscriptionHandle extends HandleBase<realm_flx_sync_subscription> {
  SubscriptionHandle(Pointer<realm_flx_sync_subscription> pointer) : super(pointer, 184);

  ObjectId get id => realmLib.realm_sync_subscription_id(pointer).toDart();

  String? get name => realmLib.realm_sync_subscription_name(pointer).toDart();

  String get objectClassName => realmLib.realm_sync_subscription_object_class_name(pointer).toDart()!;

  String get queryString => realmLib.realm_sync_subscription_query_string(pointer).toDart()!;

  DateTime get createdAt => realmLib.realm_sync_subscription_created_at(pointer).toDart();

  DateTime get updatedAt => realmLib.realm_sync_subscription_updated_at(pointer).toDart();

  bool equalTo(SubscriptionHandle other) => realmLib.realm_equals(pointer.cast(), other.pointer.cast());
}
