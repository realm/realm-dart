// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class SchemaHandle extends HandleBase<realm_schema> {
  SchemaHandle._(Pointer<realm_schema> pointer) : super(pointer, 24);

  SchemaHandle.unowned(super.pointer) : super.unowned();

  factory SchemaHandle(Iterable<SchemaObject> schema) {
    return using((Arena arena) {
      final classCount = schema.length;

      final schemaClasses = arena<realm_class_info_t>(classCount);
      final schemaProperties = arena<Pointer<realm_property_info_t>>(classCount);

      for (var i = 0; i < classCount; i++) {
        final schemaObject = schema.elementAt(i);
        final classInfo = schemaClasses.elementAt(i).ref;
        final propertiesCount = schemaObject.length;
        final computedCount = schemaObject.where((p) => p.isComputed).length;
        final persistedCount = propertiesCount - computedCount;

        classInfo.name = schemaObject.name.toCharPtr(arena);
        classInfo.primary_key = "".toCharPtr(arena);
        classInfo.num_properties = persistedCount;
        classInfo.num_computed_properties = computedCount;
        classInfo.key = _RealmCore.RLM_INVALID_CLASS_KEY;
        classInfo.flags = schemaObject.baseType.flags;

        final properties = arena<realm_property_info_t>(propertiesCount);

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject[j];
          final propInfo = properties.elementAt(j).ref;
          propInfo.name = schemaProperty.mapTo.toCharPtr(arena);
          propInfo.public_name = (schemaProperty.mapTo != schemaProperty.name ? schemaProperty.name : '').toCharPtr(arena);
          propInfo.link_target = (schemaProperty.linkTarget ?? "").toCharPtr(arena);
          propInfo.link_origin_property_name = (schemaProperty.linkOriginProperty ?? "").toCharPtr(arena);
          propInfo.type = schemaProperty.propertyType.index;
          propInfo.collection_type = schemaProperty.collectionType.index;
          propInfo.flags = realm_property_flags.RLM_PROPERTY_NORMAL;

          if (schemaProperty.optional) {
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_NULLABLE;
          }

          switch (schemaProperty.indexType) {
            case RealmIndexType.regular:
              propInfo.flags |= realm_property_flags.RLM_PROPERTY_INDEXED;
              break;
            case RealmIndexType.fullText:
              propInfo.flags |= realm_property_flags.RLM_PROPERTY_FULLTEXT_INDEXED;
              break;
            default:
              break;
          }

          if (schemaProperty.primaryKey) {
            classInfo.primary_key = schemaProperty.mapTo.toCharPtr(arena);
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_PRIMARY_KEY;
          }
        }

        schemaProperties[i] = properties;
        schemaProperties.elementAt(i).value = properties;
      }

      final schemaPtr = invokeGetPointer(() => realmLib.realm_schema_new(schemaClasses, classCount, schemaProperties));
      return SchemaHandle._(schemaPtr);
    });
  }
}
