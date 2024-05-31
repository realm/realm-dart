// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_handle.dart' as intf;

class RealmHandle implements intf.RealmHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
