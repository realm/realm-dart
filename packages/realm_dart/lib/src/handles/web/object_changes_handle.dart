// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../object_changes_handle.dart' as intf;

class ObjectChangesHandle implements intf.ObjectChangesHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
