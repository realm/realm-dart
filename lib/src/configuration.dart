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
import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as _path;

import 'native/realm_core.dart';
import 'realm_class.dart';
import 'init.dart';
import 'type_utils.dart';
import 'user.dart';

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

/// Configuration used to create a [Realm] instance
/// {@category Configuration}
abstract class Configuration implements Finalizable {
  /// The default realm filename to be used.
  static String get defaultRealmName => _path.basename(defaultRealmPath);
  static set defaultRealmName(String name) => defaultRealmPath = _path.join(_path.dirname(defaultRealmPath), _path.basename(name));

  /// A collection of [SchemaObject] that will be used to construct the
  /// [RealmSchema] once the Realm is opened.
  final Iterable<SchemaObject> schemaObjects;

  /// The platform dependent path used to store realm files
  ///
  /// On Flutter Android and iOS this is the application's data directory.
  /// On Flutter Windows this is the `C:\Users\username\AppData\Roaming\app_name` directory.
  /// On Flutter macOS this is the `/Users/username/Library/Containers/app_name/Data/Library/Application Support` directory.
  /// On Flutter Linux this is the `/home/username/.local/share/app_name` directory.
  /// On Dart standalone Windows, macOS and Linux this is the current directory.
  static String get defaultStoragePath {
    if (isFlutterPlatform) {
      return realmCore.getAppDirectory();
    }

    return Directory.current.path;
  }

  /// The platform dependent path to the default realm file.
  ///
  /// If set it should contain the path and the name of the realm file. Ex. "~/my_path/my_realm.realm"
  /// [defaultStoragePath] can be used to build this path.
  static String defaultRealmPath = _path.join(defaultStoragePath, 'default.realm');

  Configuration._(
    this.schemaObjects, {
    String? path,
    this.fifoFilesFallbackPath,
  }) {
    this.path = path ?? _path.join(_path.dirname(_defaultPath), _path.basename(defaultRealmName));
  }

  // allow inheritors to override the _defaultPath value
  String get _defaultPath => Configuration.defaultRealmPath;

  /// Specifies the FIFO special files fallback location.
  ///
  /// Opening a [Realm] creates a number of FIFO special files in order to
  /// coordinate access to the [Realm] across threads and processes. If the [Realm] file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. the FAT32 filesystem), then the [Realm] cannot be opened.
  /// In that case [Realm] needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main [Realm] file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  final String? fifoFilesFallbackPath;

  /// The path where the Realm should be stored.
  ///
  /// If omitted the [defaultPath] for the platform will be used.
  late final String path;

  //TODO: Config: Support encryption keys. https://github.com/realm/realm-dart/issues/88
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
    SyncErrorHandler syncErrorHandler = defaultSyncErrorHandler,
    SyncClientResetErrorHandler syncClientResetErrorHandler = const ManualSyncClientResetHandler(_defaultSyncClientResetHandler),
  }) =>
      FlexibleSyncConfiguration._(
        user,
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
        syncErrorHandler: syncErrorHandler,
        syncClientResetErrorHandler: syncClientResetErrorHandler,
      );

  /// Constructs a [DisconnectedSyncConfiguration]
  static DisconnectedSyncConfiguration disconnectedSync(
    List<SchemaObject> schemaObjects, {
    String? fifoFilesFallbackPath,
    String? path,
  }) =>
      DisconnectedSyncConfiguration._(
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
      );
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

///The signature of a callback that will be invoked whenever a [SyncError] occurs for the synchronized Realm.
///
/// Client reset errors will not be reported through this callback as they are handled by [SyncClientResetErrorHandler].
typedef SyncErrorHandler = void Function(SyncError);

void defaultSyncErrorHandler(SyncError e) {
  Realm.logger.log(RealmLogLevel.error, e);
}

void _defaultSyncClientResetHandler(SyncError e) {
  Realm.logger.log(
      RealmLogLevel.error,
      "A client reset error occurred but no handler was supplied. "
      "Synchronization is now paused and will resume automatically once the app is restarted and "
      "the server data is re-downloaded. Any un-synchronized changes the client has made or will "
      "make will be lost. To handle that scenario, pass in a non-null value to "
      "syncClientResetErrorHandler when constructing Configuration.flexibleSync.");
}

/// [FlexibleSyncConfiguration] is used to open [Realm] instances that are synchronized
/// with MongoDB Atlas.
/// {@category Configuration}
class FlexibleSyncConfiguration extends Configuration {
  /// The [User] used to created this [FlexibleSyncConfiguration]
  final User user;

  SessionStopPolicy _sessionStopPolicy = SessionStopPolicy.afterChangesUploaded;

  /// Called when a [SyncError] occurs for this synchronized [Realm].
  ///
  /// The default [SyncErrorHandler] prints to the console
  final SyncErrorHandler syncErrorHandler;

  /// Called when a [SyncClientResetError] occurs for this synchronized [Realm]
  ///
  /// The default [SyncClientResetErrorHandler] logs a message using the current Realm.logger
  final SyncClientResetErrorHandler syncClientResetErrorHandler;

  FlexibleSyncConfiguration._(
    this.user,
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
    this.syncErrorHandler = defaultSyncErrorHandler,
    this.syncClientResetErrorHandler = const ManualSyncClientResetHandler(_defaultSyncClientResetHandler),
  }) : super._();

  @override
  String get _defaultPath => realmCore.getPathForConfig(this);
}

extension FlexibleSyncConfigurationInternal on FlexibleSyncConfiguration {
  @pragma('vm:never-inline')
  void keepAlive() {
    user.keepAlive();
  }

  SessionStopPolicy get sessionStopPolicy => _sessionStopPolicy;
  set sessionStopPolicy(SessionStopPolicy value) => _sessionStopPolicy = value;
}

/// [DisconnectedSyncConfiguration] is used to open [Realm] instances that are synchronized
/// with MongoDB Atlas, without establishing a connection to Atlas App Services. This allows
/// for the synchronized realm to be opened in multiple processes concurrently, as long as
/// only one of them uses a [FlexibleSyncConfiguration] to sync changes.
/// {@category Configuration}
class DisconnectedSyncConfiguration extends Configuration {
  DisconnectedSyncConfiguration._(
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
  }) : super._();
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

/// A collection of properties describing the underlying schema of a [RealmObjectBase].
///
/// {@category Configuration}
class SchemaObject<T extends Object?> with IterableMixin<SchemaProperty> {
  /// Collection of the properties of this schema object.
  final Map<String, SchemaProperty> properties;

  /// Schema object type.
  Type get type => T;
  Type get nullableType => typeOf<T?>();

  final T Function() objectFactory;

  /// Returns the name of this schema type.
  final String name;

  final ObjectType baseType;

  SchemaProperty operator [](String propertyName) =>
      properties[propertyName] ?? (throw RealmException("Property '$propertyName' does not exist on class '$name'"));

  /// Primary key property, if any
  final SchemaProperty? primaryKey;

  /// Creates schema instance with object type and collection of object's properties.
  const SchemaObject(this.baseType, this.objectFactory, this.name, this.properties, [this.primaryKey]);

  @override
  Iterator<SchemaProperty> get iterator => properties.values.iterator;
}

/// Describes the complete set of classes which may be stored in a `Realm`
///
/// {@category Configuration}
class RealmSchema extends MapView<String, SchemaObject> {
  final Map<Type, SchemaObject> _byType;

  /// Initializes [RealmSchema] instance representing ```schemaObjects``` collection
  RealmSchema(super.map)
      : _byType = {
          for (final s in map.values)
            if (s.type != RealmObjectBase) s.nullableType: s // only register subtypes (the nullable form)
        };

  SchemaObject<T>? getByType<T extends Object?>() => _byType[typeOf<T?>()] as SchemaObject<T>?;
}

/// The signature of a callback that will be invoked if a client reset error occurs for this [Realm].
///
/// Currently, Flexible Sync supports only the [ManualSyncClientResetHandler].
class SyncClientResetErrorHandler {
  /// The callback that handles the [SyncClientResetError].
  final void Function(SyncClientResetError code) callback;

  /// Initializes a new instance of of [SyncClientResetErrorHandler].
  const SyncClientResetErrorHandler(this.callback);
}

/// A client reset strategy where the user needs to fully take care of a client reset.
typedef ManualSyncClientResetHandler = SyncClientResetErrorHandler;
