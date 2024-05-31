// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../notification_token_handle.dart' as intf;

class NotificationTokenHandle implements intf.NotificationTokenHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
