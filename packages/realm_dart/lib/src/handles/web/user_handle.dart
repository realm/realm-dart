// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../user_handle.dart' as intf;

class UserHandle implements intf.UserHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
