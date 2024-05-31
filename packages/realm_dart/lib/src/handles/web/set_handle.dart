// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../set_handle.dart' as intf;

class SetHandle implements intf.SetHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
