// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import '../schema_handle.dart' as intf;

class SchemaHandle implements intf.SchemaHandle {
  factory SchemaHandle.from(Iterable<SchemaObject> schema) => throw UnsupportedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
