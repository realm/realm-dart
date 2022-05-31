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

/// The signature of a callback used to determine if compaction
/// should be attempted.
///
/// The result of the callback decides if the [Realm] should be compacted
/// before being returned to the user.
///
/// The callback is given two arguments:
/// * the `totalSize` of the realm file (data + free space) in bytes, and
/// * the `usedSize`, which is the number bytes used by data in the file.
///
/// It should return true to indicate that an attempt to compact the file should be made.
/// The compaction will be skipped if another process is currently accessing the realm file.
typedef ShouldCompactCallback = bool Function(int totalSize, int usedSize);

/// The signature of a callback that will be executed only when the Realm is first created.
///
/// The Realm instance passed in the callback already has a write transaction opened, so you can
/// add some initial data that your app needs. The function will not execute for existing
/// Realms, even if all objects in the Realm are deleted.
typedef InitialDataCallback = void Function(Realm realm);

///The signature of a callback that will be invoked whenever a [SessionError] occurs for the synchronized Realm.
///
/// Client reset errors will not be reported through this callback as they are handled by [ClientResetHandler].
typedef SessionErrorHandler = void Function(SessionError error);

/// Configuration used to create a [Realm] instance
/// {@category Configuration}
abstract class Configuration {
  static const String _defaultRealmName = 'default.realm';

  static String get _defaultStorageFolder {
    if (Platform.isAndroid || Platform.isIOS) {
      return realmCore.getFilesPath();
    }

    return Directory.current.path;
  }

  static String? _defaultPath;

  Configuration._(
    List<SchemaObject> schemaObjects, {
    String? path,
    this.fifoFilesFallbackPath,
  }) : schema = RealmSchema(schemaObjects) {
    this.path = _getPath(path);
  }

  String _getPath(String? path) {
    return path ?? _defaultPath ?? _path.join(_defaultStorageFolder, _defaultRealmName);
  }

  /// Specifies the FIFO special files fallback location.
  ///
  /// Opening a [Realm] creates a number of FIFO special files in order to
  /// coordinate access to the [Realm] across threads and processes. If the [Realm] file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. FAT32 filesystems), then the [Realm] cannot be opened.
  /// In that case [Realm] needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main [Realm] file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  final String? fifoFilesFallbackPath;

  /// The path where the Realm should be stored.
  ///
  /// If omitted the [defaultPath] for the platform will be used.
  late final String path;

  /// The [RealmSchema] for this [Configuration]
  final RealmSchema schema;

  //TODO: Not supported yet.
  // /// The key used to encrypt the entire [Realm].
  // ///
  // /// A full 64byte (512bit) key for AES-256 encryption.
  // /// Once set, must be specified each time the file is used.
  // final List<int>? encryptionKey;

  /// Constructs a [LocalConfiguration]
  static LocalConfiguration local(
    List<SchemaObject> schemaObjects, {
    InitialDataCallback? initialDataCallback,
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
    bool disableFormatUpgrade = false,
    bool isReadOnly = false,
    ShouldCompactCallback? shouldCompactCallback,
  }) =>
      LocalConfiguration._(
        schemaObjects,
        initialDataCallback: initialDataCallback,
        schemaVersion: schemaVersion,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
        disableFormatUpgrade: disableFormatUpgrade,
        isReadOnly: isReadOnly,
        shouldCompactCallback: shouldCompactCallback,
      );

  /// Constructs a [InMemoryConfiguration]
  static InMemoryConfiguration inMemory(
    List<SchemaObject> schemaObjects, {
    String? fifoFilesFallbackPath,
    String? path,
  }) =>
      InMemoryConfiguration._(
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
      );

  /// Constructs a [FlexibleSyncConfiguration]
  static FlexibleSyncConfiguration flexibleSync(
    User user,
    List<SchemaObject> schemaObjects, {
    String? fifoFilesFallbackPath,
    String? path,
    SessionErrorHandler? sessionErrorHandler,
  }) =>
      FlexibleSyncConfiguration._(
        user,
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
        sessionErrorHandler: sessionErrorHandler,
      );
}

extension ConfigurationInternal on Configuration {
  static String? get defaultPath => Configuration._defaultPath;
  static set defaultPath(String? value) => Configuration._defaultPath = value;

  static String get defaultStorageFolder => Configuration._defaultStorageFolder;
}

/// [LocalConfiguration] is used to open local [Realm] instances,
/// that are persisted across runs.
/// {@category Configuration}
class LocalConfiguration extends Configuration {
  LocalConfiguration._(
    super.schemaObjects, {
    this.initialDataCallback,
    this.schemaVersion = 0,
    super.fifoFilesFallbackPath,
    super.path,
    this.disableFormatUpgrade = false,
    this.isReadOnly = false,
    this.shouldCompactCallback,
  }) : super._();

  /// The schema version used to open the [Realm]. If omitted, the default value is `0`.
  ///
  /// It is required to specify a schema version when initializing an existing
  /// Realm with a schema that contains objects that differ from their previous
  /// specification.
  ///
  /// If the schema was updated and the schemaVersion was not,
  /// a [RealmException] will be thrown.
  final int schemaVersion;

  /// Specifies whether a [Realm] should be opened as read-only.
  ///
  /// This allows opening it from locked locations such as resources,
  /// bundled with an application.
  ///
  /// The realm file must already exists at [path]
  final bool isReadOnly;

  /// Specifies if a [Realm] file format should be automatically upgraded
  /// if it was created with an older version of the [Realm] library.
  /// An exception will be thrown if a file format upgrade is required.
  final bool disableFormatUpgrade;

  /// Called when opening a [Realm] for the first time, after process start.
  final ShouldCompactCallback? shouldCompactCallback;

  /// Called when opening a [Realm] for the very first time, when db file is created.
  final InitialDataCallback? initialDataCallback;
}

/// @nodoc
enum SessionStopPolicy {
  immediately, // Immediately stop the session as soon as all Realms/Sessions go out of scope.
  liveIndefinitely, // Never stop the session.
  afterChangesUploaded, // Once all Realms/Sessions go out of scope, wait for uploads to complete and stop.
}

/// [FlexibleSyncConfiguration] is used to open [Realm] instances that are synchronized
/// with MongoDB Realm.
/// {@category Configuration}
class FlexibleSyncConfiguration extends Configuration {
  final User user;

  SessionStopPolicy _sessionStopPolicy = SessionStopPolicy.afterChangesUploaded;

  /// Called when a [SessionError] occurs for the synchronized Realm.
  final SessionErrorHandler? sessionErrorHandler;

  FlexibleSyncConfiguration._(
    this.user,
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
    this.sessionErrorHandler,
  }) : super._();

  @override
  String _getPath(String? path) {
    return path ?? realmCore.getPathForConfig(this);
  }
}

extension FlexibleSyncConfigurationInternal on FlexibleSyncConfiguration {
  SessionStopPolicy get sessionStopPolicy => _sessionStopPolicy;
  set sessionStopPolicy(SessionStopPolicy value) => _sessionStopPolicy = value;
}

/// [InMemoryConfiguration] is used to open [Realm] instances that
/// are temporary to running process.
/// {@category Configuration}
class InMemoryConfiguration extends Configuration {
  InMemoryConfiguration._(
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
  }) : super._();
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
