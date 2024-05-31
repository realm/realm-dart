// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../mutable_subscription_set_handle.dart' as intf;

class MutableSubscriptionSetHandle implements intf.MutableSubscriptionSetHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
