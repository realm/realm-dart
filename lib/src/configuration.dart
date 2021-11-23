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

import 'dart:collection';
import 'dart:typed_data';

import 'native/realm_core.dart';

import 'realm_object.dart';
import 'realm_property.dart';
import 'helpers.dart';

/// Configuration used to create a [Realm] instance
class Configuration {
  final ConfigHandle handle;
  final RealmSchema _schema;
  
  RealmSchema get schema => _schema;

  Configuration(List<SchemaObject> schemaObjects) : 
    _schema = RealmSchema(schemaObjects),  
    handle = realmCore.createConfig() {
    schemaVersion = 0;
    path = "default.realm";
    realmCore.setSchema(this);
  }

  /// The schema version used to open the [Realm]
  /// 
  /// If omitted the default value of `0` is used to open the [Realm]
  /// It is required to specify a schema version when initializing an existing 
  /// Realm with a schema that contains objects that differ from their previous 
  /// specification. If the schema was updated and the schemaVersion was not, 
  /// an [RealmException] will be thrown.
  int get schemaVersion => realmCore.getSchemaVersion(this);
  set schemaVersion(int value) => realmCore.setSchemaVersion(this, value);

  String get path => realmCore.getConfigPath(this);
  set path(String value) => realmCore.setConfigPath(this, value);
}

class SchemaObject {
  Type type;
  
  String get name => type.toString();

  List<SchemaProperty> properties = [];

  SchemaObject(this.type);
}

class RealmSchema extends Iterable<SchemaObject> {
  late final SchemaHandle handle;
  
  late final List<SchemaObject> _schema;

  RealmSchema(List<SchemaObject> schemaObjects) {
    if (schemaObjects.isEmpty) {
      throw RealmException("No schema specified");
    }

    _schema = schemaObjects;
    handle = realmCore.createSchema(schemaObjects);
  }

  @override
  Iterator<SchemaObject> get iterator => _schema.iterator;

  @override 
  int get length => _schema.length;

  SchemaObject operator [](int index) => _schema[index];

  @override
  SchemaObject elementAt(int index) => _schema.elementAt(index);
}
