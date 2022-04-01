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
/// {@category Configuration}
class Configuration {
  final ConfigHandle _handle;
  final RealmSchema _schema;
  bool _isInUse = false;
  late bool Function(int totalSize, int usedSize) _onShouldCompactCallback;

  static String? _defaultPath;

  /// The [RealmSchema] for this [Configuration]
  RealmSchema get schema => _schema;

  /// Creates a [Configuration] with schema objects for opening a [Realm].
  ///
  /// [fifoFilesFallbackPath] enables FIFO special files.
  /// [readOnly] controls whether a [Realm] is opened as read-only.
  /// [inMemory] specifies if a [Realm] should be opened in-memory.
  Configuration(List<SchemaObject> schemaObjects, {String? fifoFilesFallbackPath, bool readOnly = false, bool inMemory = false})
      : _schema = RealmSchema(schemaObjects),
        _handle = realmCore.createConfig() {
    schemaVersion = 0;
    path = defaultPath;

    if (fifoFilesFallbackPath != null) {
      this.fifoFilesFallbackPath = fifoFilesFallbackPath;
    }

    if (readOnly) {
      isReadOnly = true;
    }
    if (inMemory) {
      isInMemory = true;
    }
    realmCore.setSchema(this);
  }

  static String _initDefaultPath() {
    var path = "default.realm";
    if (Platform.isAndroid || Platform.isIOS) {
      path = _path.join(realmCore.getFilesPath(), path);
    }
    return path;
  }

  /// The platform dependent path to the default realm file - `default.realm`.
  ///
  /// If set it should contain the name of the realm file. Ex. /mypath/myrealm.realm
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Configuration) return false;
    return realmCore.configurationEquals(this, other);
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

  ///The path where the Realm should be stored.
  ///
  /// If omitted the [defaultPath] for the platform will be used.
  String get path => realmCore.getConfigPath(this);
  set path(String value) => realmCore.setConfigPath(this, value);

  /// Gets or sets a value indicating whether a [Realm] is opened as readonly.
  /// This allows opening it from locked locations such as resources,
  /// bundled with an application.
  ///
  /// The realm file must already exists at [path]
  bool get isReadOnly => realmCore.getConfigReadOnly(this);
  set isReadOnly(bool value) => realmCore.setConfigReadOnly(this, value);

  /// Specifies if a [Realm] should be opened in-memory.
  ///
  /// This still requires a [path] (can be the default path) to identify the [Realm] so other processes can open the same [Realm].
  /// The file will also be used as swap space if the [Realm] becomes bigger than what fits in memory,
  /// but it is not persistent and will be removed when the last instance is closed.
  /// When all in-memory instance of [Realm] is closed all data in that [Realm] is deleted.
  bool get isInMemory => realmCore.getConfigInMemory(this);
  set isInMemory(bool value) => realmCore.setConfigInMemory(this, value);

  /// Gets or sets a value of FIFO special files location.
  /// Opening a [Realm] creates a number of FIFO special files in order to
  /// coordinate access to the [Realm] across threads and processes. If the [Realm] file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. FAT32 filesystems), then the [Realm] cannot be opened.
  /// In that case [Realm] needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main [Realm] file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  String get fifoFilesFallbackPath => realmCore.getConfigFifoPath(this);
  set fifoFilesFallbackPath(String value) => realmCore.setConfigFifoPath(this, value);

  set ShouldCompactOnLaunchFunction(bool Function(int totalSize, int usedSize) value) {
    _onShouldCompactCallback = value;
    realmCore.setConfigShouldCompactOnLaunch(this, value);
  }
}

/// A collection of properties describing the underlying schema of a [RealmObject].
///
/// {@category Configuration}
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

/// Describes the complete set of classes which may be stored in a `Realm`
///
/// {@category Configuration}
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

/// @nodoc
extension ConfigurationInternal on Configuration {
  ///@nodoc
  ConfigHandle get handle => _handle;
  bool Function(int totalSize, int usedSize) get onShouldCompactCallback => _onShouldCompactCallback;
  
  bool get isInUse => _isInUse;
  set isInUse(bool value) => _isInUse = value;
}
