// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../configuration.dart';
import 'handle_base.dart';

import 'native/schema_handle.dart' if (dart.library.js_interop) 'web/schema_handle.dart' as impl;

abstract interface class SchemaHandle extends HandleBase {
  factory SchemaHandle.from(Iterable<SchemaObject> schema) = impl.SchemaHandle.from;
}
