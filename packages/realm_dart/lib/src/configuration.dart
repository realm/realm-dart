// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore: no_leading_underscores_for_library_prefixes
import 'package:collection/collection.dart';
import 'package:path/path.dart' as _path;

import 'handles/realm_core.dart';
import 'realm_dart.dart';

const encryptionKeySize = 64;

/// The signature of a callback used to determine if compaction
/// should be attempted.
///
/// The result of the callback decides if the `Realm` should be compacted
/// before being returned to the user.
///
/// The callback is given two arguments:
/// * the `totalSize` of the realm file (data + free space) in bytes, and
/// * the `usedSize`, which is the number bytes used by data in the file.
///
/// It should return true to indicate that an attempt to compact the file should be made.
/// The compaction will be skipped if another process is currently accessing the realm file.
typedef ShouldCompactCallback = bool Function(int totalSize, int usedSize);

/// The signature of a callback that will be executed only when the `Realm` is first created.
///
/// The `Realm` instance passed in the callback already has a write transaction opened, so you can
/// add some initial data that your app needs. The function will not execute for existing
/// Realms, even if all objects in the `Realm` are deleted.
typedef InitialDataCallback = void Function(Realm realm);

/// The signature of a callback that will be executed when the schema of the `Realm` changes.
///
/// The `migration` argument contains references to the `Realm` just before and just after the migration.
/// The `oldSchemaVersion` argument indicates the version from which the `Realm` migrates while
typedef MigrationCallback = void Function(Migration migration, int oldSchemaVersion);

/// Configuration used to create a `Realm` instance
/// {@category Configuration}
abstract class Configuration {
  /// The default realm filename to be used.
  static String get defaultRealmName => _path.basename(defaultRealmPath);
  static set defaultRealmName(String name) => defaultRealmPath = _path.join(_path.dirname(defaultRealmPath), _path.basename(name));

  /// A collection of [SchemaObject] that will be used to construct the
  /// [RealmSchema] once the `Realm` is opened.
  final Iterable<SchemaObject> schemaObjects;

  /// The platform dependent path used to store realm files
  ///
  /// On Flutter Android and iOS this is the application's data directory.
  /// On Flutter Windows this is the `C:\Users\username\AppData\Roaming\app_name` directory.
  /// On Flutter macOS this is the `/Users/username/Library/Containers/app_name/Data/Library/Application Support` directory.
  /// On Flutter Linux this is the `/home/username/.local/share/app_name` directory.
  /// On Dart standalone Windows, macOS and Linux this is the current directory.
  static String get defaultStoragePath {
    return realmCore.getAppDirectory();
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
    this.encryptionKey,
    this.maxNumberOfActiveVersions,
  }) {
    _validateEncryptionKey(encryptionKey);
    this.path = path ?? _path.join(_path.dirname(_defaultPath), _path.basename(defaultRealmName));
  }

  // allow inheritors to override the _defaultPath value
  String get _defaultPath => Configuration.defaultRealmPath;

  /// Specifies the FIFO special files fallback location.
  ///
  /// Opening a `Realm` creates a number of FIFO special files in order to
  /// coordinate access to the `Realm` across threads and processes. If the realm file is stored in a location
  /// that does not allow the creation of FIFO special files (e.g. the FAT32 filesystem), then the `Realm` cannot be opened.
  /// In that case `Realm` needs a different location to store these files and this property defines that location.
  /// The FIFO special files are very lightweight and the main realm file will still be stored in the location defined
  /// by the [path] you  property. This property is ignored if the directory defined by [path] allow FIFO special files.
  final String? fifoFilesFallbackPath;

  /// The path where the `Realm` should be stored.
  ///
  /// If omitted the [defaultRealmPath] for the platform will be used.
  late final String path;

  /// The key used to encrypt the entire `Realm`.
  ///
  /// A full 64byte (512bit) key for AES-256 encryption.
  /// Once set, must be specified each time the file is used.
  /// If null encryption is not enabled.
  final List<int>? encryptionKey;

  /// Sets the maximum number of active versions allowed before an exception is thrown.
  ///
  /// Setting this will cause `Realm` to throw an exception if too many versions of the `Realm` data
  /// are live at the same time. Having too many versions can dramatically increase the filesize of the `Realm`.
  final int? maxNumberOfActiveVersions;

  /// Constructs a [LocalConfiguration]
  static LocalConfiguration local(
    List<SchemaObject> schemaObjects, {
    InitialDataCallback? initialDataCallback,
    int schemaVersion = 0,
    String? fifoFilesFallbackPath,
    String? path,
    List<int>? encryptionKey,
    bool disableFormatUpgrade = false,
    bool isReadOnly = false,
    ShouldCompactCallback? shouldCompactCallback,
    MigrationCallback? migrationCallback,
    int? maxNumberOfActiveVersions,
    bool shouldDeleteIfMigrationNeeded = false,
  }) =>
      LocalConfiguration._(schemaObjects,
          initialDataCallback: initialDataCallback,
          schemaVersion: schemaVersion,
          fifoFilesFallbackPath: fifoFilesFallbackPath,
          path: path,
          encryptionKey: encryptionKey,
          disableFormatUpgrade: disableFormatUpgrade,
          isReadOnly: isReadOnly,
          shouldCompactCallback: shouldCompactCallback,
          migrationCallback: migrationCallback,
          maxNumberOfActiveVersions: maxNumberOfActiveVersions,
          shouldDeleteIfMigrationNeeded: shouldDeleteIfMigrationNeeded);

  /// Constructs a [InMemoryConfiguration]
  static InMemoryConfiguration inMemory(
    List<SchemaObject> schemaObjects, {
    String? fifoFilesFallbackPath,
    String? path,
    int? maxNumberOfActiveVersions,
  }) =>
      InMemoryConfiguration._(
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
        maxNumberOfActiveVersions: maxNumberOfActiveVersions,
      );

  void _validateEncryptionKey(List<int>? key) {
    if (key == null) {
      return;
    }

    if (key.length != encryptionKeySize) {
      throw RealmException("Wrong encryption key size (must be $encryptionKeySize, but was ${key.length})");
    }

    int notAByteElement = key.firstWhere((e) => e > 255, orElse: () => -1);
    if (notAByteElement >= 0) {
      throw RealmException('''Encryption key must be a list of bytes with allowed values form 0 to 255.
      Invalid value $notAByteElement found at index ${key.indexOf(notAByteElement)}.''');
    }
  }
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
    super.encryptionKey,
    this.disableFormatUpgrade = false,
    this.isReadOnly = false,
    this.shouldCompactCallback,
    this.migrationCallback,
    super.maxNumberOfActiveVersions,
    this.shouldDeleteIfMigrationNeeded = false,
  }) : super._();

  /// The schema version used to open the `Realm`. If omitted, the default value is `0`.
  ///
  /// It is required to specify a schema version when initializing an existing
  /// Realm with a schema that contains objects that differ from their previous
  /// specification.
  ///
  /// If the schema was updated and the schemaVersion was not,
  /// a [RealmException] will be thrown.
  final int schemaVersion;

  /// Specifies whether a `Realm` should be opened as read-only.
  ///
  /// This allows opening it from locked locations such as resources,
  /// bundled with an application.
  ///
  /// The realm file must already exists at [path]
  final bool isReadOnly;

  /// Specifies if a realm file format should be automatically upgraded
  /// if it was created with an older version of the `Realm` library.
  /// An exception will be thrown if a file format upgrade is required.
  final bool disableFormatUpgrade;

  /// Called when opening a `Realm` for the first time, after process start.
  final ShouldCompactCallback? shouldCompactCallback;

  /// Called when opening a `Realm` for the very first time, when db file is created.
  final InitialDataCallback? initialDataCallback;

  /// Called when opening a `Realm` with a schema version that is newer than the one used to create the file.
  final MigrationCallback? migrationCallback;

  /// Specifies if a realm file should be deleted in case the schema on disk
  /// doesn't match the schema in code. Setting this to `true` can lead to
  /// data loss.
  final bool shouldDeleteIfMigrationNeeded;
}

/// [InMemoryConfiguration] is used to open [Realm] instances that
/// are temporary to running process.
/// {@category Configuration}
class InMemoryConfiguration extends Configuration {
  InMemoryConfiguration._(
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
    super.maxNumberOfActiveVersions,
  }) : super._();
}

/// A collection of properties describing the underlying schema of a [RealmObjectBase].
///
/// {@category Configuration}
class SchemaObject extends Iterable<SchemaProperty> {
  final List<SchemaProperty> _properties;

  /// Schema object type.
  final Type type;

  /// Returns the name of this schema type.
  final String name;

  /// Returns the base type of this schema object.
  final ObjectType baseType;

  /// Creates schema instance with object type and collection of object's properties.
  const SchemaObject(this.baseType, this.type, this.name, this._properties);

  @override
  Iterator<SchemaProperty> get iterator => _properties.iterator;

  @override
  int get length => _properties.length;

  SchemaProperty operator [](int index) => _properties[index];

  @override
  SchemaProperty elementAt(int index) => _properties.elementAt(index);

  SchemaProperty? get primaryKey => _properties.firstWhereOrNull((p) => p.primaryKey);
}

/// Describes the complete set of classes which may be stored in a `Realm`
///
/// {@category Configuration}
class RealmSchema extends Iterable<SchemaObject> {
  late final List<SchemaObject> _schema;

  /// Initializes [RealmSchema] instance representing ```schemaObjects``` collection
  RealmSchema(Iterable<SchemaObject> schemaObjects) {
    _schema = schemaObjects.toList();
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
extension SchemaObjectInternal on SchemaObject {
  bool get isGenericRealmObject => type == RealmObject || type == EmbeddedObject || type == RealmObjectBase;

  void add(SchemaProperty property) => _properties.add(property);
}

extension RealmSchemaInternal on RealmSchema {
  void add(SchemaObject obj) {
    _schema.add(obj);
  }
}
