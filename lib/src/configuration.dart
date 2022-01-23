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

import 'dart:io';

import 'native/realm_core.dart';

import 'realm_object.dart';
import 'realm_property.dart';
import 'package:path/path.dart' as _path;

/// Configuration used to create a [Realm] instance
class Configuration {
  final ConfigHandle _handle;
  final RealmSchema _schema;

  static String? _defaultPath;

  /// The schema of the [Realm]. Use [Configuration] constructor to define the list of [SchemaObject].
  RealmSchema get schema => _schema;

  /// Creates schema definitions objects in [Realm].
  Configuration(List<SchemaObject> schemaObjects)
      : _schema = RealmSchema(schemaObjects),
        _handle = realmCore.createConfig() {
    schemaVersion = 0;
    path = defaultPath;
    realmCore.setSchema(this);
  }

  static String _initDefaultPath() {
    var path = "default.realm";
    if (Platform.isAndroid || Platform.isIOS) {
      path = _path.join(realmCore.getFilesPath(), path);
    }
    return path;
  }

  /// The platform dependent path to the default realm file. Should contain the name of the realm file.
  static String get defaultPath => _defaultPath ??= _initDefaultPath();
  static set defaultPath(String value) => _defaultPath = value;

  /// The platform dependent directory path used to store realm files
  ///
  /// On Android and iOS this is the application's data directory
  static String get filesPath {
    if (Platform.isAndroid || Platform.isIOS) {
      return realmCore.getFilesPath();
    }
    return "";
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

  ///The path to the file where the Realm database should be stored.
  ///
  /// If omitted the default Realm path for the platform will be used.
  String get path => realmCore.getConfigPath(this);
  set path(String value) => realmCore.setConfigPath(this, value);
}

/// Representation of [RealmModel] in the schema.
/// Defines schema object with its type and properties.
///
/// {@category Schema}
class SchemaObject {
  /// Schema object type.
  final Type type;

  /// Collection of the properties of this schema object.
  final List<SchemaProperty> properties;

  /// Returns the name of this schema type.
  String get name => type.toString();

  /// Creates schema instance with object type and collection of object's properties.
  const SchemaObject(this.type, this.properties);
}

/// Represents a collection of all realm objects schemеs [SchemaObject].
/// They could be iterated. RealmSchema is initialized in [Configuration] constructor.
///
/// {@category Schema}
class RealmSchema extends Iterable<SchemaObject> {
  ///@nodoc
  late final SchemaHandle handle;

  late final List<SchemaObject> _schema;

  /// Initializes [RealmSchema] instance representing ```schemaObjects``` collection
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

extension ConfigurationInternal on Configuration {
  ///@nodoc
  ConfigHandle get handle => _handle;
}
