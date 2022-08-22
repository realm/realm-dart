////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'package:realm_common/realm_common.dart';

import 'dart_type_ex.dart';
import 'field_element_ex.dart';
import 'realm_field_info.dart';

class RealmModelInfo {
  final String name;
  final String modelName;
  final String realmName;
  final List<RealmFieldInfo> fields;

  RealmModelInfo(this.name, this.modelName, this.realmName, this.fields);

  Iterable<String> toCode() sync* {
    yield 'class $name extends $modelName with RealmEntity, RealmObject {';
    {
      final allExceptCollections = fields.where((f) => !f.type.isRealmCollection).toList();

      final hasDefaults = allExceptCollections.where((f) => f.hasDefaultValue).toList();
      if (hasDefaults.isNotEmpty) {
        yield 'static var _defaultsSet = false;';
        yield '';
      }

      yield '$name(';
      {
        final required = allExceptCollections.where((f) => f.isRequired || f.isPrimaryKey);
        yield* required.map((f) => '${f.mappedTypeName} ${f.name},');

        final notRequired = allExceptCollections.where((f) => !f.isRequired && !f.isPrimaryKey);
        final collections = fields.where((f) => f.type.isRealmCollection).toList();
        if (notRequired.isNotEmpty || collections.isNotEmpty) {
          yield '{';
          yield* notRequired.map((f) => '${f.mappedTypeName} ${f.name}${f.hasDefaultValue ? ' = ${f.fieldElement.initializerExpression}' : ''},');
          yield* collections.map((c) => 'Iterable<${c.type.basicMappedName}> ${c.name} = const [],');
          yield '}';
        }

        yield ') {';

        if (hasDefaults.isNotEmpty) {
          yield 'if (!_defaultsSet) {';
          yield '  _defaultsSet = RealmObject.setDefaults<$name>({';
          yield* hasDefaults.map((f) => "'${f.realmName}': ${f.fieldElement.initializerExpression},");
          yield '  });';
          yield '}';
        }

        yield* allExceptCollections.map((f) {
          return "RealmObject.set(this, '${f.realmName}', ${f.name});";
        });

        yield* collections.map((c) {
          return "RealmObject.set<${c.mappedTypeName}>(this, '${c.realmName}', ${c.mappedTypeName}(${c.name}));";
        });
      }
      yield '}';
      yield '';
      yield '$name._();';
      yield '';

      yield* fields.expand((f) => [
            ...f.toCode(),
            '',
          ]);

      yield '@override';
      yield 'Stream<RealmObjectChanges<$name>> get changes => RealmObject.getChanges<$name>(this);';
      yield '';

      yield 'static SchemaObject get schema => _schema ??= _initSchema();';
      yield 'static SchemaObject? _schema;';
      yield 'static SchemaObject _initSchema() {';
      {
        yield 'RealmObject.registerFactory($name._);';
        yield "return const SchemaObject($name, '$realmName', [";
        {
          yield* fields.map((f) {
            final namedArgs = {
              if (f.name != f.realmName) 'mapTo': f.realmName,
              if (f.optional) 'optional': f.optional,
              if (f.isPrimaryKey) 'primaryKey': f.isPrimaryKey,
              if (f.realmType == RealmPropertyType.object) 'linkTarget': f.basicRealmTypeName,
              if (f.realmCollectionType != RealmCollectionType.none) 'collectionType': f.realmCollectionType,
            };
            return "SchemaProperty('${f.realmName}', ${f.realmType}${namedArgs.isNotEmpty ? ', ${namedArgs.toArgsString()}' : ''}),";
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
