// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class SubscriptionHandle extends HandleBase<realm_flx_sync_subscription> {
  SubscriptionHandle._(Pointer<realm_flx_sync_subscription> pointer) : super(pointer, 184);

  ObjectId get id => _realmLib.realm_sync_subscription_id(_pointer).toDart();

  String? get name => _realmLib.realm_sync_subscription_name(_pointer).toDart();

  String get objectClassName => _realmLib.realm_sync_subscription_object_class_name(_pointer).toDart()!;

  String get queryString => _realmLib.realm_sync_subscription_query_string(_pointer).toDart()!;

  DateTime get createdAt => _realmLib.realm_sync_subscription_created_at(_pointer).toDart();

  DateTime get updatedAt => _realmLib.realm_sync_subscription_updated_at(_pointer).toDart();

  bool equalTo(SubscriptionHandle other) => _realmLib.realm_equals(_pointer.cast(), other._pointer.cast());
}
