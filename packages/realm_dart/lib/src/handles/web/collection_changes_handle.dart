// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../collection_changes_handle.dart' as intf;

class CollectionChangesHandle implements intf.CollectionChangesHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
