// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../subscription_set_handle.dart' as intf;

class SubscriptionSetHandle implements intf.SubscriptionSetHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
