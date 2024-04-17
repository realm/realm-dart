// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';

import 'dart_type_ex.dart';
import 'field_element_ex.dart';
import 'realm_field_info.dart';

extension<T> on Iterable<T> {
  Iterable<T> except(bool Function(T) test) => where((e) => !test(e));
}

extension on String {
  String nonPrivate() => startsWith('_') ? substring(1) : this;
}

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
      final allSettable = fields.where((f) => !f.isComputed).toList();

      final fieldsWithRealmDefaults = allSettable.where((f) => f.hasDefaultValue && !f.isRealmCollection).toList();
      final shouldEmitDefaultsSet = fieldsWithRealmDefaults.isNotEmpty;
      if (shouldEmitDefaultsSet) {
        yield 'static var _defaultsSet = false;';
        yield '';
      }

      bool required(RealmFieldInfo f) => f.isRequired || f.isPrimaryKey;
      bool usePositional(RealmFieldInfo f) => required(f);
      String paramName(RealmFieldInfo f) => usePositional(f) ? f.name : f.name.nonPrivate();
      final positional = allSettable.where(usePositional);
      final named = allSettable.except(usePositional);

      // Constructor
      yield '$name(';
      {
        yield* positional.map((f) => '${f.mappedTypeName} ${paramName(f)},');
        if (named.isNotEmpty) {
          yield '{';
          yield* named.map((f) {
            final requiredPrefix = required(f) ? 'required ' : '';
            final param = paramName(f);
            final collectionPrefix = switch(f) {
              _ when f.isDartCoreList => 'Iterable<',
              _ when f.isDartCoreSet => 'Set<',
              _ when f.isDartCoreMap => 'Map<String,',
              _ => '',
            }; 
            final typePrefix = f.isRealmCollection ? '$collectionPrefix${f.type.basicMappedName}>' : f.mappedTypeName;
            return '$requiredPrefix$typePrefix $param${f.initializer},';
          });
          yield '}';
        }

        yield ') {';

        if (shouldEmitDefaultsSet) {
          yield 'if (!_defaultsSet) {';
          yield '  _defaultsSet = RealmObjectBase.setDefaults<$name>({';
          yield* fieldsWithRealmDefaults.map((f) => "'${f.realmName}': ${f.fieldElement.initializerExpression},");
          yield '  });';
          yield '}';
        }

        yield* allSettable.map((f) {
          final param = paramName(f);
          if (f.type.isUint8List && f.hasDefaultValue) {
            return "RealmObjectBase.set(this, '${f.realmName}', $param ?? ${f.fieldElement.initializerExpression});";
          }
          if (f.isRealmCollection) {
            return "RealmObjectBase.set<${f.mappedTypeName}>(this, '${f.realmName}', ${f.mappedTypeName}($param));";
          }
          return "RealmObjectBase.set(this, '${f.realmName}', $param);";
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

      yield '@override';
      yield 'Stream<RealmObjectChanges<$name>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<$name>(this, keyPaths);';
      yield '';

      // Freeze
      yield '@override';
      yield '$name freeze() => RealmObjectBase.freezeObject<$name>(this);';
      yield '';

      // Encode
      yield 'EJsonValue toEJson() {';
      {
        yield 'return <String, dynamic>{';
        {
          yield* allSettable.map((f) {
            return "'${f.realmName}': ${f.name}.toEJson(),";
          });
        }
        yield '};';
      }
      yield '}';

      yield 'static EJsonValue _toEJson($name value) => value.toEJson();';

      // Decode
      yield 'static $name _fromEJson(EJsonValue ejson) {';
      {
        yield 'return switch (ejson) {';
        {
          yield '{';
          {
            yield* allSettable.map((f) {
              return "'${f.realmName}': EJsonValue ${f.name},";
            });
          }
          yield '} => $name(';
          {
            yield* positional.map((f) => 'fromEJson(${f.name}),');
            yield* named.map((f) => '${f.name}: fromEJson(${f.name}),');
          }
          yield '),';
          yield '_ => raiseInvalidEJson(ejson),';
        }
        yield '};';
      }
      yield '}';

      // Schema
      yield 'static final schema = () {';
      {
        yield 'RealmObjectBase.registerFactory($name._);';
        yield 'register(_toEJson, _fromEJson);';
        yield "return SchemaObject(ObjectType.${baseType.name}, $name, '$realmName', [";
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
      yield '}();';
      yield '';
      yield '@override';
      yield 'SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;';
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
