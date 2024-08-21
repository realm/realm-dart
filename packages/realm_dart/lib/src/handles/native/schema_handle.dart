// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';
import 'package:realm_common/realm_common.dart';

import '../../configuration.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'to_native.dart';

import '../schema_handle.dart' as intf;

class SchemaHandle extends HandleBase<realm_schema> implements intf.SchemaHandle {
  SchemaHandle(Pointer<realm_schema> pointer) : super(pointer, 24);

  SchemaHandle.unowned(super.pointer) : super.unowned();

  factory SchemaHandle.from(Iterable<SchemaObject> schema) {
    return using((arena) {
      final classCount = schema.length;

      final schemaClasses = arena<realm_class_info_t>(classCount);
      final schemaProperties = arena<Pointer<realm_property_info_t>>(classCount);

      for (var i = 0; i < classCount; i++) {
        final schemaObject = schema.elementAt(i);
        final classInfo = (schemaClasses + i).ref;
        final propertiesCount = schemaObject.length;
        final computedCount = schemaObject.where((p) => p.isComputed).length;
        final persistedCount = propertiesCount - computedCount;

        classInfo.name = schemaObject.name.toCharPtr(arena);
        classInfo.primary_key = "".toCharPtr(arena);
        classInfo.num_properties = persistedCount;
        classInfo.num_computed_properties = computedCount;
        classInfo.key = RLM_INVALID_CLASS_KEY;
        classInfo.flags = schemaObject.baseType.flags;

        final properties = arena<realm_property_info_t>(propertiesCount);

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject[j];
          final propInfo = (properties + j).ref;
          propInfo.name = schemaProperty.mapTo.toCharPtr(arena);
          propInfo.public_name = (schemaProperty.mapTo != schemaProperty.name ? schemaProperty.name : '').toCharPtr(arena);
          propInfo.link_target = (schemaProperty.linkTarget ?? "").toCharPtr(arena);
          propInfo.link_origin_property_name = (schemaProperty.linkOriginProperty ?? "").toCharPtr(arena);
          propInfo.type = schemaProperty.propertyType.index;
          propInfo.collection_type = schemaProperty.collectionType.index;
          propInfo.flags = realm_property_flags.RLM_PROPERTY_NORMAL.value;

          if (schemaProperty.optional) {
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_NULLABLE.value;
          }

          switch (schemaProperty.indexType) {
            case RealmIndexType.regular:
              propInfo.flags |= realm_property_flags.RLM_PROPERTY_INDEXED.value;
              break;
            case RealmIndexType.fullText:
              propInfo.flags |= realm_property_flags.RLM_PROPERTY_FULLTEXT_INDEXED.value;
              break;
            default:
              break;
          }

          if (schemaProperty.primaryKey) {
            classInfo.primary_key = schemaProperty.mapTo.toCharPtr(arena);
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_PRIMARY_KEY.value;
          }
        }

        schemaProperties[i] = properties;
        (schemaProperties + i).value = properties;
      }

      return SchemaHandle(realmLib.realm_schema_new(schemaClasses, classCount, schemaProperties));
    });
  }
}

// From realm.h. Currently not exported from the shared library
// ignore: unused_field, constant_identifier_names
const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
// ignore: unused_field, constant_identifier_names
const int RLM_INVALID_PROPERTY_KEY = -1;
// ignore: unused_field, constant_identifier_names
const int RLM_INVALID_OBJECT_KEY = -1;
