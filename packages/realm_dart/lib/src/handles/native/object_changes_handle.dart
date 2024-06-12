// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

import '../object_changes_handle.dart' as intf;

class ObjectChangesHandle extends HandleBase<realm_object_changes> implements intf.ObjectChangesHandle {
  ObjectChangesHandle(Pointer<realm_object_changes> pointer) : super(pointer, 256);

  @override
  bool get isDeleted {
    return realmLib.realm_object_changes_is_deleted(pointer);
  }

  @override
  List<int> get properties {
    return using((arena) {
      final count = realmLib.realm_object_changes_get_num_modified_properties(pointer);

      final outModified = arena<realm_property_key_t>(count);
      realmLib.realm_object_changes_get_modified_properties(pointer, outModified, count);

      return outModified.asTypedList(count).toList();
    });
  }
}
