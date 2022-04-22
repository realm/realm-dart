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
import 'realm_class.dart';

/// Configuration used to create a [Realm] instance
/// {@category Configuration}
class Configuration {
  static String? _defaultPath;

  /// The [RealmSchema] for this [Configuration]
  final RealmSchema schema;

  /// Creates a [Configuration] with schema objects for opening a [Realm].
  Configuration(List<SchemaObject> schemaObjects,
      {String? path,
      this.fifoFilesFallbackPath,
      this.isReadOnly = false,
      this.isInMemory = false,
      this.schemaVersion = 0,
      this.disableFormatUpgrade = false,
      this.initialDataCallback,
      this.shouldCompactCallback})
      : schema = RealmSchema(schemaObjects),
        path = path ?? defaultPath;

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
    return Directory.current.absolute.path;
  }

  /// The schema version used to open the [Realm]
  ///
  /// If omitted the default value of `0` is used to open the [Realm]
  /// It is required to specify a schema version when initializing an existing
  /// Realm with a schema that contains objects that differ from their previous
  /// specification. If the schema was updated and the schemaVersion was not,
  /// an [RealmException] will be thrown.
  final int schemaVersion;

  /// The path where the Realm should be stored.
  ///
  /// If omitted the [defaultPath] for the platform will be used.
  final String path;

  /// Specifies whether a [Realm] should be opened as read-only.
  /// This allows opening it from locked locations such as resources,
  /// bundled with an application.
  ///
  /// The realm file must already exists at [path]
  final bool isReadOnly;

  /// Specifies whether a [Realm] should be opened in-memory.
  ///
  /// This still requires a [path] (can be the default path) to identify the [Realm] so other processes can open the same [Realm].
  /// The file will also be used as swap space if the [Realm] becomes bigger than what fits in memory,
  /// but it is not persistent and will be removed when the last instance is closed.
  /// When all in-memory instance of [Realm] is closed all data in that [Realm] is deleted.
  final bool isInMemory;

  /// Specifies the FIFO special files fallback location.
  /// Opening a [Realm] creates a number of FIFO special files in order to
  /// coordinate access to the [Realm] across threads and processes. If the [Realm] file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. FAT32 filesystems), then the [Realm] cannot be opened.
  /// In that case [Realm] needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main [Realm] file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  final String? fifoFilesFallbackPath;

  /// Specifies if a [Realm] file format should be automatically upgraded
  /// if it was created with an older version of the [Realm] library.
  /// An exception will be thrown if a file format upgrade is required.
  final bool disableFormatUpgrade;

  /// A function that will be executed only when the Realm is first created.
  ///
  /// The Realm instance passed in the callback already has a write transaction opened, so you can
  /// add some initial data that your app needs. The function will not execute for existing
  /// Realms, even if all objects in the Realm are deleted.
  final Function(Realm realm)? initialDataCallback;

  /// The function called when opening a Realm for the first time
  /// during the life of a process to determine if it should be compacted
  /// before being returned to the user.
  ///
  /// [totalSize] - The total file size (data + free space)
  /// [usedSize] - The total bytes used by data in the file.
  /// It returns true to indicate that an attempt to compact the file should be made.
  /// The compaction will be skipped if another process is currently accessing the realm file.
  final bool Function(int totalSize, int usedSize)? shouldCompactCallback;
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
  final String name;

  /// Creates schema instance with object type and collection of object's properties.
  const SchemaObject(this.type, this.name, this.properties);
}

/// Describes the complete set of classes which may be stored in a `Realm`
///
/// {@category Configuration}
class RealmSchema extends Iterable<SchemaObject> {
  late final List<SchemaObject> _schema;

  /// Initializes [RealmSchema] instance representing ```schemaObjects``` collection
  RealmSchema(List<SchemaObject> schemaObjects) {
    if (schemaObjects.isEmpty) {
      throw RealmException("No schema specified");
    }

    _schema = schemaObjects;
  }

  @override
  Iterator<SchemaObject> get iterator => _schema.iterator;

  @override
  int get length => _schema.length;

  SchemaObject operator [](int index) => _schema[index];

  @override
  SchemaObject elementAt(int index) => _schema.elementAt(index);
}
