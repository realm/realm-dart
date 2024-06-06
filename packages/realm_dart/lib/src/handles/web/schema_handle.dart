// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import '../schema_handle.dart' as intf;
import 'handle_base.dart';

class SchemaHandle extends HandleBase implements intf.SchemaHandle {
  factory SchemaHandle.from(Iterable<SchemaObject> schema) => webNotSupported();
}
