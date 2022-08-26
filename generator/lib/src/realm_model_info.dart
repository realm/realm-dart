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

        yield* allExceptCollections.map((f) {
          return '_${f.name}Property.setValue(this, ${f.name});';
        });

        yield* collections.map((c) {
          return '_${c.name}Property.setValue(this, ${c.mappedTypeName}(${c.name}));';
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
      yield 'Stream<RealmObjectChanges<$name>> get changes => RealmObject.getChanges(this);';
      yield '';

      final primaryKey = fields.cast<RealmFieldInfo?>().firstWhere((element) => element!.isPrimaryKey, orElse: () => null);
      yield 'static const schema = SchemaObject<$name>(';
      {
        yield '$name._,';
        yield "'$realmName',";
        yield '{';
        {
          yield* fields.map((f) => "'${f.realmName}': _${f.name}Property,");
        }
        yield '},';
        if (primaryKey != null) yield '_${primaryKey.name}Property,';
      }
      yield ');';
      yield '@override';
      yield 'SchemaObject get instanceSchema => schema;';
    }
    yield '}';
  }
}
