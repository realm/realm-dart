// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../map_changes_handle.dart' as intf;

abstract class MapChangesHandle implements intf.MapChangesHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}