// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';

import 'handle_base.dart';

abstract interface class SubscriptionHandle extends HandleBase {
  ObjectId get id;
  String? get name;
  String get objectClassName;
  String get queryString;
  DateTime get createdAt;
  DateTime get updatedAt;
  bool equalTo(SubscriptionHandle other);
}
