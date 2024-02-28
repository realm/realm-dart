// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';

import 'dart_type_ex.dart';
import 'field_element_ex.dart';
import 'realm_field_info.dart';

class RealmModelInfo {
  final String name;
  final String modelName;
  final String realmName;
  final List<RealmFieldInfo> fields;
  final ObjectType baseType;

  const RealmModelInfo(this.name, this.modelName, this.realmName, this.fields, this.baseType);

  Iterable<String> toCode() sync* {
    yield 'class $name extends $modelName with RealmEntity, RealmObjectBase, ${baseType.className} {';
    {
      final allSettable = fields.where((f) => !f.type.isRealmCollection && !f.isRealmBacklink).toList();

      final fieldsWithDefaultValue = allSettable.where((f) => f.hasDefaultValue && !f.type.isUint8List).toList();
      final shouldEmitDefaultsSet = fieldsWithDefaultValue.isNotEmpty;
      if (shouldEmitDefaultsSet) {
        yield 'static var _defaultsSet = false;';
        yield '';
      }

      // Constructor
      yield '@ejson';
      yield '$name(';
      {
        final required = allSettable.where((f) => f.isRequired || f.isPrimaryKey);
        yield* required.map((f) => '${f.mappedTypeName} ${f.name},');

        final notRequired = allSettable.where((f) => !f.isRequired && !f.isPrimaryKey);
        final lists = fields.where((f) => f.isDartCoreList).toList();
        final sets = fields.where((f) => f.isDartCoreSet).toList();
        final maps = fields.where((f) => f.isDartCoreMap).toList();
        if (notRequired.isNotEmpty || lists.isNotEmpty || sets.isNotEmpty || maps.isNotEmpty) {
          yield '{';
          yield* notRequired.map((f) {
            if (f.type.isUint8List && f.hasDefaultValue) {
              return '${f.mappedTypeName}? ${f.name},';
            }
            return '${f.mappedTypeName} ${f.name}${f.initializer},';
          });
          yield* lists.map((c) => 'Iterable<${c.type.basicMappedName}> ${c.name}${c.initializer},');
          yield* sets.map((c) => 'Set<${c.type.basicMappedName}> ${c.name}${c.initializer},');
          yield* maps.map((c) => 'Map<String, ${c.type.basicMappedName}> ${c.name}${c.initializer},');
          yield '}';
        }

        yield ') {';

        if (shouldEmitDefaultsSet) {
          yield 'if (!_defaultsSet) {';
          yield '  _defaultsSet = RealmObjectBase.setDefaults<$name>({';
          yield* fieldsWithDefaultValue.map((f) => "'${f.realmName}': ${f.fieldElement.initializerExpression},");
          yield '  });';
          yield '}';
        }

        yield* allSettable.map((f) {
          if (f.type.isUint8List && f.hasDefaultValue) {
            return "RealmObjectBase.set(this, '${f.realmName}', ${f.name} ?? ${f.fieldElement.initializerExpression});";
          }

          return "RealmObjectBase.set(this, '${f.realmName}', ${f.name});";
        });

        yield* lists.map((c) {
          return "RealmObjectBase.set<${c.mappedTypeName}>(this, '${c.realmName}', ${c.mappedTypeName}(${c.name}));";
        });

        yield* sets.map((c) {
          return "RealmObjectBase.set<${c.mappedTypeName}>(this, '${c.realmName}', ${c.mappedTypeName}(${c.name}));";
        });

        yield* maps.map((c) {
          return "RealmObjectBase.set<${c.mappedTypeName}>(this, '${c.realmName}', ${c.mappedTypeName}(${c.name}));";
        });
      }
      yield '}';
      yield '';
      yield '$name._();';
      yield '';

      // Properties
      yield* fields.expand((f) => [
            ...f.toCode(),
            '',
          ]);

      // Changes
      yield '@override';
      yield 'Stream<RealmObjectChanges<$name>> get changes => RealmObjectBase.getChanges<$name>(this);';
      yield '';

      // Freeze
      yield '@override';
      yield '$name freeze() => RealmObjectBase.freezeObject<$name>(this);';
      yield '';

      // Schema
      yield 'static SchemaObject get schema => _schema ??= _initSchema();';
      yield 'static SchemaObject? _schema;';
      yield 'static SchemaObject _initSchema() {';
      {
        yield 'RealmObjectBase.registerFactory($name._);';
        yield "return const SchemaObject(ObjectType.${baseType.name}, $name, '$realmName', [";
        {
          yield* fields.map((f) {
            final namedArgs = {
              if (f.name != f.realmName) 'mapTo': f.realmName,
              if (f.optional) 'optional': f.optional,
              if (f.isPrimaryKey) 'primaryKey': f.isPrimaryKey,
              if (f.indexType != null) 'indexType': f.indexType,
              if (f.realmType == RealmPropertyType.object) 'linkTarget': f.basicRealmTypeName,
              if (f.realmType == RealmPropertyType.linkingObjects) ...{
                'linkOriginProperty': f.linkOriginProperty!,
                'collectionType': RealmCollectionType.list,
                'linkTarget': f.basicRealmTypeName,
              },
              if (f.realmCollectionType != RealmCollectionType.none) 'collectionType': f.realmCollectionType,
            };
            return "SchemaProperty('${f.name}', ${f.realmType}${namedArgs.isNotEmpty ? ', ${namedArgs.toArgsString()}' : ''}),";
          });
        }
        yield ']);';
      }
      yield '}';
    }
    yield '}';
  }
}

extension<K, V> on Map<K, V> {
  String toArgsString() {
    return () sync* {
      for (final e in entries) {
        if (e.value is String) {
          yield "${e.key}: '${e.value}'";
        } else {
          yield '${e.key}: ${e.value}';
        }
      }
    }()
        .join(',');
  }
}
