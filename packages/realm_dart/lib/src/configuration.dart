// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

// ignore: no_leading_underscores_for_library_prefixes
import 'package:collection/collection.dart';
import 'package:path/path.dart' as _path;

import 'app.dart';
import 'handles/realm_core.dart';
import 'logging.dart';
import 'realm_dart.dart';
import 'user.dart';

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

/// The signature of a callback that will be triggered when a Client Reset error happens in a synchronized `Realm`.
///
/// The [clientResetError] holds useful data to be used when trying to manually recover from a client reset.
typedef ClientResetCallback = FutureOr<void> Function(ClientResetError clientResetError);

/// Callback that indicates a Client Reset is about to happen.
///
/// The [beforeResetRealm] holds the frozen `Realm` just before the client reset happens.
///
/// The lifetime of [beforeResetRealm] is tied to the callback lifetime, so don't store references to the `Realm` or objects
/// obtained from it for use outside of the callback.
typedef BeforeResetCallback = FutureOr<void> Function(Realm beforeResetRealm);

/// Callback that indicates a Client Reset has just happened.
///
/// The [beforeResetRealm] holds the frozen `Realm` just before the client reset happened.
/// The [afterResetRealm] holds the live `Realm` just after the client reset happened.
///
/// The lifetime of the `Realm` instances supplied is tied to the callback, so don't store references to
/// the `Realm` or objects obtained from it for use outside of the callback.
typedef AfterResetCallback = FutureOr<void> Function(Realm beforeResetRealm, Realm afterResetRealm);

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

  /// Constructs a [FlexibleSyncConfiguration]
  static FlexibleSyncConfiguration flexibleSync(
    User user,
    List<SchemaObject> schemaObjects, {
    String? fifoFilesFallbackPath,
    String? path,
    List<int>? encryptionKey,
    SyncErrorHandler syncErrorHandler = defaultSyncErrorHandler,
    ClientResetHandler clientResetHandler = const RecoverOrDiscardUnsyncedChangesHandler(onManualResetFallback: _defaultClientResetHandler),
    int? maxNumberOfActiveVersions,
    ShouldCompactCallback? shouldCompactCallback,
    int schemaVersion = 0,
    bool cancelAsyncOperationsOnNonFatalErrors = false,
  }) =>
      FlexibleSyncConfiguration._(
        user,
        schemaObjects,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        path: path,
        encryptionKey: encryptionKey,
        syncErrorHandler: syncErrorHandler,
        clientResetHandler: clientResetHandler,
        maxNumberOfActiveVersions: maxNumberOfActiveVersions,
        shouldCompactCallback: shouldCompactCallback,
        schemaVersion: schemaVersion,
        cancelAsyncOperationsOnNonFatalErrors: cancelAsyncOperationsOnNonFatalErrors,
      );

  /// Constructs a [DisconnectedSyncConfiguration]
  static DisconnectedSyncConfiguration disconnectedSync(
    List<SchemaObject> schemaObjects, {
    required String path,
    String? fifoFilesFallbackPath,
    List<int>? encryptionKey,
    int? maxNumberOfActiveVersions,
  }) =>
      DisconnectedSyncConfiguration._(
        schemaObjects,
        path: path,
        fifoFilesFallbackPath: fifoFilesFallbackPath,
        encryptionKey: encryptionKey,
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

/// @nodoc
enum SessionStopPolicy {
  immediately, // Immediately stop the session as soon as all Realms/Sessions go out of scope.
  liveIndefinitely, // Never stop the session.
  afterChangesUploaded, // Once all Realms/Sessions go out of scope, wait for uploads to complete and stop.
}

/// The signature of a callback that will be invoked whenever a [SyncError] occurs for the synchronized realm.
///
/// Client reset errors will not be reported through this callback as they are handled by [ClientResetHandler].
typedef SyncErrorHandler = void Function(SyncError);

void defaultSyncErrorHandler(SyncError e) {
  Realm.logger.log(LogLevel.error, e);
}

void _defaultClientResetHandler(ClientResetError e) {
  Realm.logger.log(
      LogLevel.error,
      "A client reset error occurred but no handler was supplied. "
      "Synchronization is now paused and will resume automatically once the app is restarted and "
      "the server data is re-downloaded. Any un-synchronized changes the client has made or will "
      "make will be lost. To handle that scenario, pass in a non-null value to "
      "clientResetHandler when constructing Configuration.flexibleSync.");
}

/// [FlexibleSyncConfiguration] is used to open [Realm] instances that are synchronized
/// with MongoDB Atlas.
/// {@category Configuration}
class FlexibleSyncConfiguration extends Configuration {
  /// The [User] used to created this [FlexibleSyncConfiguration]
  final User user;

  SessionStopPolicy _sessionStopPolicy = SessionStopPolicy.afterChangesUploaded;

  /// Called when a [SyncError] occurs for this synchronized `Realm`.
  ///
  /// The default [SyncErrorHandler] prints to the console.
  final SyncErrorHandler syncErrorHandler;

  /// Called when a [ClientResetError] occurs for this synchronized `Realm`.
  ///
  /// The default [ClientResetHandler] logs a message using the current [Realm.logger].
  final ClientResetHandler clientResetHandler;

  /// Called when opening a `Realm` for the first time, after process start.
  final ShouldCompactCallback? shouldCompactCallback;

  /// The schema version for this Realm. This has to be a valid schema version on the server
  /// and the schema supplied in [schemaObjects] should match the one on the server.
  ///
  /// Note that unlike with [LocalConfiguration], changing the schema version will not execute
  /// any migrations locally as the data is migrated on the server.
  ///
  /// When changing the schema version, the Realm **must** be opened asynchronously - i.e.
  /// using [Realm.open] as migrating the data will require that first all the local changes
  /// are uploaded, and then, that a client reset is performed. When changing the schema version
  /// all subscriptions will be reset since they may not conform to the new schema.
  final int schemaVersion;

  /// Controls whether async operations such as [Realm.open], [Session.waitForUpload], and [Session.waitForDownload]
  /// should throw an error whenever a non-fatal error, such as timeout occurs.
  ///
  /// If set to `false`, non-fatal session errors will be ignored and sync will continue retrying the
  /// connection under in the background. This means that in cases where the devie is offline, these operations
  /// may take an indeterminate time to complete.
  final bool cancelAsyncOperationsOnNonFatalErrors;

  FlexibleSyncConfiguration._(
    this.user,
    super.schemaObjects, {
    super.fifoFilesFallbackPath,
    super.path,
    super.encryptionKey,
    this.syncErrorHandler = defaultSyncErrorHandler,
    this.clientResetHandler = const RecoverOrDiscardUnsyncedChangesHandler(onManualResetFallback: _defaultClientResetHandler),
    super.maxNumberOfActiveVersions,
    this.shouldCompactCallback,
    this.schemaVersion = 0,
    this.cancelAsyncOperationsOnNonFatalErrors = false,
  }) : super._();

  @override
  String get _defaultPath => user.handle.path;
}

extension FlexibleSyncConfigurationInternal on FlexibleSyncConfiguration {
  SessionStopPolicy get sessionStopPolicy => _sessionStopPolicy;
  set sessionStopPolicy(SessionStopPolicy value) => _sessionStopPolicy = value;
}

/// [DisconnectedSyncConfiguration] is used to open [Realm] instances that are synchronized
/// with MongoDB Atlas, without establishing a connection to [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/). This allows
/// for the synchronized realm to be opened in multiple processes concurrently, as long as
/// only one of them uses a [FlexibleSyncConfiguration] to sync changes.
/// {@category Configuration}
class DisconnectedSyncConfiguration extends Configuration {
  DisconnectedSyncConfiguration._(
    super.schemaObjects, {
    required super.path,
    super.fifoFilesFallbackPath,
    super.encryptionKey,
    super.maxNumberOfActiveVersions,
  }) : super._();

  @override
  String get _defaultPath => _path.dirname(path);
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

/// [ClientResetHandler] is triggered if the device and server cannot agree
/// on a common shared history for the realm file
/// or when it is impossible for the device to upload or receive any changes.
/// This can happen if the server is rolled back or restored from backup.
/// {@category Sync}
abstract class ClientResetHandler {
  // Defines what should happen in case of a client reset
  final ClientResyncModeInternal _mode;

  final BeforeResetCallback? _onBeforeReset;
  final AfterResetCallback? _onAfterDiscard;
  final AfterResetCallback? _onAfterRecovery;

  /// The callback that handles the [ClientResetError].
  final ClientResetCallback? onManualReset;

  const ClientResetHandler._(this._mode, this.onManualReset,
      {BeforeResetCallback? onBeforeReset, AfterResetCallback? onAfterDiscard, AfterResetCallback? onAfterRecovery})
      : _onBeforeReset = onBeforeReset,
        _onAfterDiscard = onAfterDiscard,
        _onAfterRecovery = onAfterRecovery;
}

/// A client reset strategy where the user needs to fully take care of a client reset.
///
/// If you set [ManualRecoveryHandler] callback as `clientResetHandler` argument of [Configuration.flexibleSync],
/// that will enable full control of moving any unsynced changes to the synchronized realm.
/// {@category Sync}
class ManualRecoveryHandler extends ClientResetHandler {
  /// Creates an instance of `ManualRecoveryHandler` with the supplied client reset handler.
  ///
  /// [onReset] callback is triggered when a manual client reset happens.
  const ManualRecoveryHandler(ClientResetCallback onReset) : super._(ClientResyncModeInternal.manual, onReset);
}

/// A client reset strategy where any not yet synchronized data is automatically
/// discarded and a fresh copy of the synchronized realm is obtained.
///
/// If you set [DiscardUnsyncedChangesHandler] callback as `clientResetHandler` argument of [Configuration.flexibleSync],
/// the local `Realm` will be discarded and replaced with the server side `Realm`.
/// All local changes will be lost.
/// {@category Sync}
class DiscardUnsyncedChangesHandler extends ClientResetHandler {
  /// The callback that will be executed just before the client reset happens.
  BeforeResetCallback? get onBeforeReset => _onBeforeReset;

  /// The callback that will be executed just after the client reset happens.
  AfterResetCallback? get onAfterReset => _onAfterDiscard;

  /// Creates an instance of `DiscardUnsyncedChangesHandler`.
  ///
  /// This strategy supplies three callbacks: [onBeforeReset], [onAfterReset] and [onManualResetFallback].
  /// The first two are invoked just before and after the client reset has happened,
  /// while the last one will be invoked in case an error occurs during the automated process and the system needs to fallback to a manual mode.
  /// The freshly downloaded copy of the synchronized Realm triggers all change notifications as a write transaction is internally simulated.
  const DiscardUnsyncedChangesHandler({BeforeResetCallback? onBeforeReset, AfterResetCallback? onAfterReset, ClientResetCallback? onManualResetFallback})
      : super._(ClientResyncModeInternal.discardLocal, onManualResetFallback, onAfterDiscard: onAfterReset, onBeforeReset: onBeforeReset);
}

/// A client reset strategy that attempts to automatically recover any unsynchronized changes.
///
/// If you set [RecoverUnsyncedChangesHandler] callback as `clientResetHandler` argument of [Configuration.flexibleSync],
/// `Realm` will compare the local `Realm` with the `Realm` on the server and automatically transfer
/// any changes from the local `Realm` that makes sense to the `Realm` provided by the server.
/// {@category Sync}
class RecoverUnsyncedChangesHandler extends ClientResetHandler {
  /// The callback that will be executed just before the client reset happens.
  BeforeResetCallback? get onBeforeReset => _onBeforeReset;

  /// The callback that will be executed just after the client reset happens.
  AfterResetCallback? get onAfterReset => _onAfterRecovery;

  /// Creates an instance of `RecoverUnsyncedChangesHandler`.
  ///
  /// This strategy supplies three callbacks: [onBeforeReset], [onAfterReset] and [onManualResetFallback].
  /// The first two are invoked just before and after the client reset has happened, while the last one is invoked
  /// in case an error occurs during the automated process and the system needs to fallback to a manual mode.
  const RecoverUnsyncedChangesHandler({BeforeResetCallback? onBeforeReset, AfterResetCallback? onAfterReset, ClientResetCallback? onManualResetFallback})
      : super._(ClientResyncModeInternal.recover, onManualResetFallback, onBeforeReset: onBeforeReset, onAfterRecovery: onAfterReset);
}

/// A client reset strategy that attempts to automatically recover any unsynchronized changes.
/// If that fails, this handler fallsback to the discard unsynced changes strategy.
///
/// If you set [RecoverOrDiscardUnsyncedChangesHandler] callback as `clientResetHandler` argument of [Configuration.flexibleSync],
/// `Realm` will compare the local `Realm` with the `Realm` on the server and automatically transfer
/// any changes from the local `Realm` that makes sense to the `Realm` provided by the server.
/// If that fails, the local changes will be discarded.
/// This is the default mode for fully synchronized Realms.
/// {@category Sync}
class RecoverOrDiscardUnsyncedChangesHandler extends ClientResetHandler {
  /// The callback that will be executed just before the client reset happens.
  BeforeResetCallback? get onBeforeReset => _onBeforeReset;

  /// The callback that will be executed just after the client reset happens if the local changes
  /// needed to be discarded.
  AfterResetCallback? get onAfterDiscard => _onAfterDiscard;

  /// The callback that will be executed just after the client reset happens if the local changes
  /// were successfully recovered.
  AfterResetCallback? get onAfterRecovery => _onAfterRecovery;

  /// Creates an instance of `RecoverOrDiscardUnsyncedChangesHandler`.
  ///
  /// This strategy will recover automatically any unsynchronized changes. If the recovery fails this strategy fallsback to the discard unsynced one.
  /// The automatic recovery mechanism creates write transactions meaning that all the changes that take place
  /// are properly propagated through the standard Realm's change notifications.
  /// This strategy supplies four callbacks: [onBeforeReset], [onAfterRecovery], [onAfterDiscard] and [onManualResetFallback].
  /// [onBeforeReset] is invoked just before the client reset happens.
  /// [onAfterRecovery] is invoke if and only if an automatic client reset succeeded. The callback is never called
  /// if the automatic client reset fails.
  /// [onAfterDiscard] is invoked if and only if an automatic client reset failed and instead the discard unsynced one succeded.
  /// The callback is never called if the discard unsynced client reset fails.
  /// [onManualResetFallback] is invoked whenever an error occurs in either of the recovery stragegies and the system needs to fallback to a manual mode.
  const RecoverOrDiscardUnsyncedChangesHandler(
      {BeforeResetCallback? onBeforeReset, AfterResetCallback? onAfterRecovery, AfterResetCallback? onAfterDiscard, ClientResetCallback? onManualResetFallback})
      : super._(ClientResyncModeInternal.recoverOrDiscard, onManualResetFallback,
            onBeforeReset: onBeforeReset, onAfterDiscard: onAfterDiscard, onAfterRecovery: onAfterRecovery);
}

/// @nodoc
extension ClientResetHandlerInternal on ClientResetHandler {
  ClientResyncModeInternal get clientResyncMode => _mode;

  BeforeResetCallback? get onBeforeReset => _onBeforeReset;
  AfterResetCallback? get onAfterDiscard => _onAfterDiscard;
  AfterResetCallback? get onAfterRecovery => _onAfterRecovery;
}

/// Enum describing what should happen in case of a Client Resync.
/// @nodoc
enum ClientResyncModeInternal {
  manual,
  discardLocal,
  recover,
  recoverOrDiscard,
}

/// An error type that describes a client reset error condition.
/// {@category Sync}
class ClientResetError extends SyncError {
  final App? _app;

  /// The path to the original copy of the realm when the client reset was triggered.
  /// This realm may contain unsynced changes.
  final String? originalFilePath;

  /// The path where the backup copy of the realm will be placed once the client reset process is complete.
  final String? backupFilePath;

  ClientResetError._(
    String message,
    SyncErrorCode code,
    this._app,
    Object? innerError, {
    this.backupFilePath,
    this.originalFilePath,
  }) : super._(message, code, innerError);

  @override
  String toString() {
    return "ClientResetError message: $message${innerError == null ? '' : ", inner error: '$innerError'"}";
  }

  /// Initiates the client reset process.
  ///
  /// Returns `true` if actions were run successfully, `false` otherwise.
  bool resetRealm() {
    if (_app == null) {
      throw RealmException("This `ClientResetError` does not have an `Application` instance.");
    }

    if (originalFilePath == null) {
      throw RealmException("Missing `originalFilePath`");
    }

    return _app.handle.resetRealm(originalFilePath!);
  }
}

/// Thrown when an error occurs during synchronization
/// This error or its subclasses will be returned to users through [FlexibleSyncConfiguration.syncErrorHandler]
/// and the exact reason must be found in the `message`.
/// {@category Sync}
class SyncError extends RealmError {
  /// The code that describes this error.
  final SyncErrorCode code;

  SyncError._(super.message, this.code, this.innerError);

  final Object? innerError;

  @override
  String toString() {
    return "Sync Error: $message";
  }
}

/// Contains the details for a compensating write performed by the server.
/// {@category Sync}
class CompensatingWriteInfo {
  /// The type of the object which was affected by the compensating write.
  final String objectType;

  /// The reason for the server to perform a compensating write.
  final String reason;

  /// The primary key of the object which was affected by the compensating write.
  final RealmValue primaryKey;

  const CompensatingWriteInfo(this.objectType, this.reason, this.primaryKey);

  @override
  String toString() {
    return "CompensatingWriteInfo: objectType: '$objectType' reason: '$reason' primaryKey: '$primaryKey'";
  }
}

/// An error type that describes a compensating write error,
/// which indicates that one more object changes have been reverted
/// by the server.
/// {@category Sync}
final class CompensatingWriteError extends SyncError {
  /// The list of the compensating writes performed by the server.
  late final List<CompensatingWriteInfo>? compensatingWrites;

  CompensatingWriteError._(
    String message,
    Object? innerError, {
    this.compensatingWrites,
  }) : super._(message, SyncErrorCode.compensatingWrite, innerError);

  @override
  String toString() {
    return "CompensatingWriteError: $message. ${compensatingWrites ?? ''}";
  }
}

/// @nodoc
class SyncErrorDetails {
  final String message;
  final SyncErrorCode code;
  final String? path;
  final bool isFatal;
  final bool isClientResetRequested;
  final String? originalFilePath;
  final String? backupFilePath;
  final List<CompensatingWriteInfo>? compensatingWrites;
  final Object? userError;

  SyncErrorDetails(
    this.message,
    this.code,
    this.userError, {
    this.path,
    this.isFatal = false,
    this.isClientResetRequested = false,
    this.originalFilePath,
    this.backupFilePath,
    this.compensatingWrites,
  });
}

/// @nodoc
extension SyncErrorInternal on SyncError {
  static SyncError createSyncError(SyncErrorDetails error, {App? app}) {
    //Client reset can be requested with isClientResetRequested disregarding the ErrorCode
    return switch (error.code) {
      SyncErrorCode.autoClientResetFailed => ClientResetError._(
          error.message,
          error.code,
          app,
          error.userError,
          originalFilePath: error.originalFilePath,
          backupFilePath: error.backupFilePath,
        ),
      SyncErrorCode.clientReset =>
        ClientResetError._(error.message, error.code, app, error.userError, originalFilePath: error.originalFilePath, backupFilePath: error.backupFilePath),
      SyncErrorCode.compensatingWrite => CompensatingWriteError._(
          error.message,
          error.userError,
          compensatingWrites: error.compensatingWrites,
        ),
      _ => SyncError._(error.message, error.code, error.userError),
    };
  }
}
