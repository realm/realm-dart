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

import 'package:path/path.dart' as _path;

import 'native/realm_core.dart';
import 'realm_class.dart';

abstract class Configuration {
  /// The default filename of a [Realm] database
  static const String defaultRealmName = "default.realm";

  static String _initDefaultPath() {
    var path = defaultRealmName;
    if (Platform.isAndroid || Platform.isIOS) {
      path = _path.join(realmCore.getFilesPath(), path);
    }
    return path;
  }

  /// The platform dependent path to the default realm file - `default.realm`.
  ///
  /// If set it should contain the name of the realm file. Ex. /mypath/myrealm.realm
  static late String defaultPath = _initDefaultPath();

  /// The platform dependent directory path used to store realm files
  ///
  /// On Android and iOS this is the application's data directory
  static String get filesPath {
    if (Platform.isAndroid || Platform.isIOS) {
      return realmCore.getFilesPath();
    }
    return Directory.current.absolute.path;
  }

  String? get fifoFilesFallbackPath;
  String get path;
  RealmSchema get schema;
  int get schemaVersion;
  List<int>? get encryptionKey;

  @Deprecated('Use Configuration.local instead')
  factory Configuration(
    List<SchemaObject> schemaObjects, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion,
    String? fifoFilesFallbackPath,
    String? path,
    bool disableFormatUpgrade,
    bool isReadOnly,
    bool Function(int totalSize, int usedSize)? shouldCompactCallback,
  }) = LocalConfiguration;

  factory Configuration.local(
    List<SchemaObject> schemaObjects, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion,
    String? fifoFilesFallbackPath,
    String? path,
    bool disableFormatUpgrade,
    bool isReadOnly,
    bool Function(int totalSize, int usedSize)? shouldCompactCallback,
  }) = LocalConfiguration;

  factory Configuration.inMemory(
    List<SchemaObject> schemaObjects,
    String identifier, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion,
    String? fifoFilesFallbackPath,
    String? path,
  }) = InMemoryConfiguration;

  factory Configuration.flexibleSync(
    User user,
    List<SchemaObject> schemaObjects, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion,
    String? fifoFilesFallbackPath,
    String? path,
  }) = FlexibleSyncConfiguration;
}

/// Configuration used to create a [Realm] instance
/// {@category Configuration}
class _ConfigurationBase implements Configuration {
  /// Creates a [Configuration] with schema objects for opening a [Realm].
  _ConfigurationBase(
    List<SchemaObject> schemaObjects, {
    String? path,
    this.fifoFilesFallbackPath,
    this.schemaVersion = 0,
    this.encryptionKey,
  })  : schema = RealmSchema(schemaObjects),
        path = path ?? Configuration.defaultPath;

  /// The [RealmSchema] for this [Configuration]
  @override
  final RealmSchema schema;

  /// The schema version used to open the [Realm]
  ///
  /// If omitted the default value of `0` is used to open the [Realm]
  /// It is required to specify a schema version when initializing an existing
  /// Realm with a schema that contains objects that differ from their previous
  /// specification. If the schema was updated and the schemaVersion was not,
  /// an [RealmException] will be thrown.
  @override
  final int schemaVersion;

  /// The path where the Realm should be stored.
  ///
  /// If omitted the [defaultPath] for the platform will be used.
  @override
  final String path;

  /// Specifies the FIFO special files fallback location.
  /// Opening a [Realm] creates a number of FIFO special files in order to
  /// coordinate access to the [Realm] across threads and processes. If the [Realm] file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. FAT32 filesystems), then the [Realm] cannot be opened.
  /// In that case [Realm] needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main [Realm] file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  @override
  final String? fifoFilesFallbackPath;

  @override
  final List<int>? encryptionKey;
}

class LocalConfiguration extends _ConfigurationBase {
  LocalConfiguration(
    List<SchemaObject> schemaObjects, {
    this.initialDataCallback,
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
    this.disableFormatUpgrade = false,
    this.isInMemory = false,
    this.isReadOnly = false,
    this.shouldCompactCallback,
  }) : super(
          schemaObjects,
          path: path,
          fifoFilesFallbackPath: fifoFilesFallbackPath,
          schemaVersion: schemaVersion,
        );

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
  final bool isInMemory; // TODO: Get rid of this!

  /// Specifies if a [Realm] file format should be automatically upgraded
  /// if it was created with an older version of the [Realm] library.
  /// An exception will be thrown if a file format upgrade is required.
  final bool disableFormatUpgrade;

  /// The function called when opening a Realm for the first time
  /// during the life of a process to determine if it should be compacted
  /// before being returned to the user.
  ///
  /// [totalSize] - The total file size (data + free space)
  /// [usedSize] - The total bytes used by data in the file.
  /// It returns true to indicate that an attempt to compact the file should be made.
  /// The compaction will be skipped if another process is currently accessing the realm file.
  final bool Function(int totalSize, int usedSize)? shouldCompactCallback;

  /// A function that will be executed only when the Realm is first created.
  ///
  /// The Realm instance passed in the callback already has a write transaction opened, so you can
  /// add some initial data that your app needs. The function will not execute for existing
  /// Realms, even if all objects in the Realm are deleted.
  final Function(Realm realm)? initialDataCallback;
}

class _SyncConfigurationBase extends _ConfigurationBase {
  final User user;
  _SyncConfigurationBase(
    this.user,
    List<SchemaObject> schemaObjects, {
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
  }) : super(
          schemaObjects,
          schemaVersion: schemaVersion,
          fifoFilesFallbackPath: fifoFilesFallbackPath,
          path: path,
        );
}

enum SessionStopPolicy {
  immediately, // Immediately stop the session as soon as all Realms/Sessions go out of scope.
  liveIndefinitely, // Never stop the session.
  afterChangesUploaded, // Once all Realms/Sessions go out of scope, wait for uploads to complete and stop.
}

class FlexibleSyncConfiguration extends _SyncConfigurationBase {
  SessionStopPolicy _sessionStopPolicy = SessionStopPolicy.afterChangesUploaded;

  FlexibleSyncConfiguration(
    User user,
    List<SchemaObject> schemaObjects, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
  }) : super(
          user,
          schemaObjects,
          schemaVersion: schemaVersion,
          fifoFilesFallbackPath: fifoFilesFallbackPath,
          path: path,
        );
}

extension FlexibleSyncConfigurationInternal on FlexibleSyncConfiguration {
  SessionStopPolicy get sessionStopPolicy => _sessionStopPolicy;
  set sessionStopPolicy(SessionStopPolicy value) => _sessionStopPolicy = value;
}

class InMemoryConfiguration extends _ConfigurationBase {
  InMemoryConfiguration(
    List<SchemaObject> schemaObjects,
    this.identifier, {
    Function(Realm realm)? initialDataCallback,
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
  }) : super(
          schemaObjects,
          schemaVersion: schemaVersion,
          fifoFilesFallbackPath: fifoFilesFallbackPath,
          path: path,
        );

  final String identifier;
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
