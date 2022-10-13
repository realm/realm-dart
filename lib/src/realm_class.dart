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

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:realm_common/realm_common.dart';
import 'package:collection/collection.dart';
import 'package:cancellation_token/cancellation_token.dart';

import 'configuration.dart';
import 'list.dart';
import 'native/realm_core.dart';
import 'realm_object.dart';
import 'results.dart';
import 'scheduler.dart';
import 'subscription.dart';
import 'session.dart';

export 'package:cancellation_token/cancellation_token.dart' show CancellationToken, CancelledException;
export 'package:realm_common/realm_common.dart'
    show
        Ignored,
        Indexed,
        MapTo,
        PrimaryKey,
        RealmError,
        RealmClosedError,
        SyncError,
        SyncClientError,
        SyncClientResetError,
        SyncConnectionError,
        SyncSessionError,
        GeneralSyncError,
        SyncErrorCategory,
        GeneralSyncErrorCode,
        SyncClientErrorCode,
        SyncConnectionErrorCode,
        SyncSessionErrorCode,
        RealmModel,
        RealmUnsupportedSetError,
        RealmStateError,
        RealmCollectionType,
        RealmPropertyType,
        ObjectId,
        Uuid;

// always expose with `show` to explicitly control the public API surface
export 'app.dart' show AppConfiguration, MetadataPersistenceMode, App, AppException;
export "configuration.dart"
    show
        Configuration,
        DisconnectedSyncConfiguration,
        FlexibleSyncConfiguration,
        InitialDataCallback,
        InMemoryConfiguration,
        LocalConfiguration,
        MigrationCallback,
        RealmSchema,
        SchemaObject,
        ShouldCompactCallback,
        SyncErrorHandler,
        SyncClientResetErrorHandler;

export 'credentials.dart' show Credentials, AuthProviderType, EmailPasswordAuthProvider;
export 'list.dart' show RealmList, RealmListOfObject, RealmListChanges;
export 'realm_object.dart' show RealmEntity, RealmException, UserCallbackException, RealmObject, RealmObjectChanges, DynamicRealmObject;
export 'realm_property.dart';
export 'results.dart' show RealmResults, RealmResultsChanges;
export 'subscription.dart' show Subscription, SubscriptionSet, SubscriptionSetState, MutableSubscriptionSet;
export 'user.dart' show User, UserState, UserIdentity, ApiKeyClient, ApiKey;
export 'session.dart' show Session, SessionState, ConnectionState, ProgressDirection, ProgressMode, SyncProgress, ConnectionStateChange;
export 'migration.dart' show Migration;

/// A [Realm] instance represents a `Realm` database.
///
/// {@category Realm}
class Realm implements Finalizable {
  late final RealmMetadata _metadata;
  late final RealmHandle _handle;
  final bool _isInMigration;

  /// An object encompassing this `Realm` instance's dynamic API.
  late final DynamicRealm dynamic = DynamicRealm._(this);

  /// The [Configuration] object used to open this [Realm]
  final Configuration config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  late final RealmSchema schema;

  /// Gets a value indicating whether this [Realm] is frozen. Frozen Realms are immutable
  /// and will not update when writes are made to the database.
  late final bool isFrozen;

  /// Opens a `Realm` using a [Configuration] object.
  Realm(Configuration config) : this._(config);

  Realm._(this.config, [RealmHandle? handle, this._isInMigration = false]) : _handle = handle ?? _openRealmSync(config) {
    _populateMetadata();
    isFrozen = realmCore.isFrozen(this);
  }

  /// A method for asynchronously opening a [Realm].
  ///
  /// When the configuration is [FlexibleSyncConfiguration], the realm will be downloaded and fully
  /// synchronized with the server prior to the completion of the returned [Future].
  /// This method could be called also for opening a local [Realm] with [LocalConfiguration].
  ///
  /// * `config`- a configuration object that describes the realm.
  /// * `cancellationToken` - an optional [CancellationToken] used to cancel the operation.
  /// * `onProgressCallback` - a callback for receiving download progress notifications for synced [Realm]s.
  ///
  /// Returns `Future<Realm>` that completes with the [Realm] once the remote [Realm] is fully synchronized or with a [CancelledException] if operation is canceled.
  /// When the configuration is [LocalConfiguration] this completes right after the local [Realm] is opened or if the operation is canceled in advance.
  /// Since opening a local Realm is a synchronous operation, there is no benefit of using Realm.open over the constructor.
  static Future<Realm> open(Configuration config, {CancellationToken? cancellationToken, ProgressCallback? onProgressCallback}) async {
    if (cancellationToken?.isCancelled ?? false) {
	      return Future<Realm>.error(cancellationToken!.exception);
	    }
    final realm = Realm(config);
    try {
      if (config is FlexibleSyncConfiguration) {
        final session = realm.syncSession;
        await Future.wait<void>([
          session.waitForDownload(cancellationToken),
          if (onProgressCallback != null)
            session
                .getProgressStream(
                  ProgressDirection.download,
                  ProgressMode.forCurrentlyOutstandingWork,
                )
                .forEach(onProgressCallback)
                .asCancellable(cancellationToken),
        ]);
      }
      // handle cancellation even if we are not using flexible sync
      return await CancellableFuture.value(realm, cancellationToken);
    } catch (_) {
      realm.close();
      rethrow;
    }
  }

  static RealmHandle _openRealmSync(Configuration config) {
    var dir = File(config.path).parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return realmCore.openRealm(config);
  }

  void _populateMetadata() {
    schema = config.schemaObjects.isNotEmpty ? RealmSchema(config.schemaObjects) : realmCore.readSchema(this);
    _metadata = RealmMetadata._(schema.map((c) => realmCore.getObjectMetadata(this, c.name, c.type)));
  }

  /// Deletes all files associated with a `Realm` located at given [path]
  ///
  /// The `Realm` must not be open.
  static void deleteRealm(String path) {
    realmCore.deleteRealmFiles(path);
  }

  /// Synchronously checks whether a `Realm` exists at [path]
  static bool existsSync(String path) {
    try {
      final fileEntity = File(path);
      return fileEntity.existsSync();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at $path. Error: $e");
    }
  }

  /// Checks whether a `Realm` exists at [path].
  static Future<bool> exists(String path) async {
    try {
      final fileEntity = File(path);
      return await fileEntity.exists();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at $path. Error: $e");
    }
  }

  /// Adds a [RealmObject] to the `Realm`.
  ///
  /// This `Realm` will start managing the [RealmObject].
  /// A [RealmObject] instance can be managed only by one `Realm`.
  /// If the object is already managed by this `Realm`, this method does nothing.
  /// This method modifies the object in-place as it becomes managed. Managed instances are persisted and become live objects.
  /// Returns the same instance as managed. This is just meant as a convenience to enable fluent syntax scenarios.
  ///
  /// By setting the [update] flag you can update any existing object with the same primary key.
  /// Updating only makes sense for objects with primary keys, and is effectively ignored
  /// otherwise.
  ///
  /// Throws [RealmException] when trying to add objects with the same primary key.
  /// Throws [RealmException] if there is no write transaction created with [write].
  T add<T extends RealmObject>(T object, {bool update = false}) {
    if (object.isManaged) {
      return object;
    }

    final metadata = _metadata.getByType(object.runtimeType);
    final handle = _createObject(object, metadata, update);

    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    object.manage(this, handle, accessor, update);

    return object;
  }

  RealmObjectHandle _createObject(RealmObject object, RealmObjectMetadata metadata, bool update) {
    final key = metadata.classKey;
    final primaryKey = metadata.primaryKey;
    if (primaryKey == null) {
      return realmCore.createRealmObject(this, key);
    }
    if (update) {
      return realmCore.getOrCreateRealmObjectWithPrimaryKey(this, key, object.accessor.get(object, primaryKey));
    }
    return realmCore.createRealmObjectWithPrimaryKey(this, key, object.accessor.get(object, primaryKey));
  }

  /// Adds a collection [RealmObject]s to this `Realm`.
  ///
  /// If the collection contains items that are already managed by this `Realm`, they will be ignored.
  /// This method behaves as calling [add] multiple times.
  ///
  /// By setting the [update] flag you can update any existing object with the same primary key.
  /// Updating only makes sense for objects with primary keys, and is effectively ignored
  /// otherwise.
  void addAll<T extends RealmObject>(Iterable<T> items, {bool update = false}) {
    for (final i in items) {
      add(i, update: update);
    }
  }

  /// Deletes a [RealmObject] from this `Realm`.
  void delete<T extends RealmObject>(T object) => realmCore.deleteRealmObject(object);

  /// Deletes many [RealmObject]s from this `Realm`.
  ///
  /// Throws [RealmException] if there is no active write transaction.
  void deleteMany<T extends RealmObject>(Iterable<T> items) {
    if (items is RealmResults<T>) {
      realmCore.resultsDeleteAll(items);
    } else if (items is RealmList<T>) {
      realmCore.listDeleteAll(items);
    } else {
      for (T realmObject in items) {
        realmCore.deleteRealmObject(realmObject);
      }
    }
  }

  /// Checks whether the `Realm` is in write transaction.
  bool get isInTransaction => realmCore.getIsWritable(this);

  /// Synchronously calls the provided callback inside a write transaction.
  ///
  /// If no exception is thrown from within the callback, the transaction will be committed.
  /// It is more efficient to update several properties or even create multiple objects in a single write transaction.
  T write<T>(T Function() writeCallback) {
    final transaction = Transaction._(this);

    try {
      T result = writeCallback();
      transaction.commit();
      return result;
    } catch (e) {
      transaction.rollback();
      rethrow;
    }
  }

  /// Closes the `Realm`.
  ///
  /// All [RealmObject]s and `Realm ` collections are invalidated and can not be used.
  /// This method will not throw if called multiple times.
  void close() {
    if (isClosed) {
      return;
    }

    realmCore.closeRealm(this);
    handle.release();
  }

  /// Checks whether the `Realm` is closed.
  bool get isClosed => _handle.released || realmCore.isRealmClosed(this);

  /// Fast lookup for a [RealmObject] with the specified [primaryKey].
  T? find<T extends RealmObject>(Object? primaryKey) {
    final metadata = _metadata.getByType(T);

    final handle = realmCore.find(this, metadata.classKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    var object = RealmObjectInternal.create(T, this, handle, accessor);
    return object as T;
  }

  /// Returns all [RealmObject]s of type `T` in the `Realm`
  ///
  /// The returned [RealmResults] allows iterating all the values without further filtering.
  RealmResults<T> all<T extends RealmObject>() {
    final metadata = _metadata.getByType(T);
    final handle = realmCore.findAll(this, metadata.classKey);
    return RealmResultsInternal.create<T>(handle, this, metadata);
  }

  /// Returns all [RealmObject]s that match the specified [query].
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query<T extends RealmObject>(String query, [List<Object?> args = const []]) {
    final metadata = _metadata.getByType(T);
    final handle = realmCore.queryClass(this, metadata.classKey, query, args);
    return RealmResultsInternal.create<T>(handle, this, metadata);
  }

  /// Deletes all [RealmObject]s of type `T` in the `Realm`
  void deleteAll<T extends RealmObject>() => deleteMany(all<T>());

  /// Returns a frozen (immutable) snapshot of this Realm.
  ///
  /// A frozen Realm is an immutable snapshot view of a particular version of a
  /// Realm's data. Unlike normal [Realm] instances, it does not live-update to
  /// reflect writes made to the Realm. Writing to a frozen Realm is not allowed,
  /// and attempting to begin a write transaction will throw an exception.
  ///
  /// All objects and collections read from a frozen Realm will also be frozen.
  ///
  /// Note: Keeping a large number of frozen Realms with different versions alive can
  /// have a negative impact on the file size of the underlying database.
  Realm freeze() {
    if (isFrozen) {
      return this;
    }

    return Realm._(config, realmCore.freeze(this));
  }

  WeakReference<SubscriptionSet>? _subscriptions;

  /// The active [SubscriptionSet] for this [Realm]
  SubscriptionSet get subscriptions {
    if (config is! FlexibleSyncConfiguration) {
      throw RealmError('subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration');
    }

    var result = _subscriptions?.target;

    if (result == null || result.handle.released) {
      result = SubscriptionSetInternal.create(this, realmCore.getSubscriptions(this));
      realmCore.refreshSubscriptionSet(result);
      _subscriptions = WeakReference(result);
    }

    return result;
  }

  WeakReference<Session>? _syncSession;

  /// The [Session] for this [Realm]. The sync session is responsible for two-way synchronization
  /// with MongoDB Atlas. If the [Realm] is not synchronized, accessing this property will throw.
  Session get syncSession {
    if (config is! FlexibleSyncConfiguration) {
      throw RealmError('session is only valid on synchronized Realms (i.e. opened with FlexibleSyncConfiguration)');
    }

    var result = _syncSession?.target;

    if (result == null || result.handle.released) {
      result = SessionInternal.create(realmCore.realmGetSession(this));
      _syncSession = WeakReference(result);
    }

    return result;
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Realm) return false;
    return realmCore.realmEquals(this, other);
  }

  /// The logger to use for logging
  static Logger logger = Logger.detached('Realm')
    ..level = RealmLogLevel.info
    ..onRecord.listen((event) => print(event));

  /// Used to shutdown Realm and allow the process to correctly release native resources and exit.
  ///
  /// Disclaimer: This method is mostly needed on Dart standalone and if not called the Dart program will hang and not exit.
  /// This is a workaround of a Dart VM bug and will be removed in a future version of the SDK.
  static void shutdown() => scheduler.stop();
}

/// @nodoc
class Transaction {
  Realm? _realm;

  Transaction._(Realm realm) {
    _realm = realm;
    realmCore.beginWrite(realm);
  }

  void commit() {
    if (_realm == null) {
      throw RealmException('Transaction was already closed. Cannot commit');
    }

    realmCore.commitWrite(_realm!);
    _realm = null;
  }

  void rollback() {
    if (_realm == null) {
      throw RealmException('Transaction was already closed. Cannot rollback');
    }

    realmCore.rollbackWrite(_realm!);
    _realm = null;
  }
}

/// @nodoc
extension RealmInternal on Realm {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
    final c = config;
    if (c is FlexibleSyncConfiguration) {
      c.keepAlive();
    }
  }

  RealmHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access realm that has been closed');
    }

    return _handle;
  }

  static Realm getUnowned(Configuration config, RealmHandle handle, {bool isInMigration = false}) {
    return Realm._(config, handle, isInMigration);
  }

  RealmObject createObject(Type type, RealmObjectHandle handle, RealmObjectMetadata metadata) {
    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    return RealmObjectInternal.create(type, this, handle, accessor);
  }

  RealmList<T> createList<T extends Object?>(RealmListHandle handle, RealmObjectMetadata? metadata) {
    return RealmListInternal.create<T>(handle, this, metadata);
  }

  List<String> getPropertyNames(Type type, List<int> propertyKeys) {
    final metadata = _metadata.getByType(type);
    final result = <String>[];
    for (var key in propertyKeys) {
      final name = metadata.getPropertyName(key);
      if (name != null) {
        result.add(name);
      }
    }
    return result;
  }

  RealmMetadata get metadata => _metadata;

  T? resolveObject<T extends RealmObject>(T object) {
    if (!object.isManaged) {
      throw RealmStateError("Can't resolve unmanaged objects");
    }

    if (!object.isValid) {
      throw RealmStateError("Can't resolve invalidated (deleted) objects");
    }

    final handle = realmCore.resolveObject(object, this);
    if (handle == null) {
      return null;
    }

    final metadata = (object.accessor as RealmCoreAccessor).metadata;

    return RealmObjectInternal.create(T, this, handle, RealmCoreAccessor(metadata, _isInMigration)) as T;
  }

  RealmList<T>? resolveList<T extends Object?>(ManagedRealmList<T> list) {
    final handle = realmCore.resolveList(list, this);
    if (handle == null) {
      return null;
    }

    return createList<T>(handle, list.metadata);
  }

  RealmResults<T> resolveResults<T extends RealmObject>(RealmResults<T> results) {
    final handle = realmCore.resolveResults(results, this);
    return RealmResultsInternal.create<T>(handle, this, results.metadata);
  }

  static MigrationRealm getMigrationRealm(Realm realm) => MigrationRealm._(realm);
}

/// @nodoc
abstract class NotificationsController implements Finalizable {
  RealmNotificationTokenHandle? handle;

  RealmNotificationTokenHandle subscribe();
  void onChanges(HandleBase changesHandle);
  void onError(RealmError error);

  void start() {
    if (handle != null) {
      throw RealmStateError("Realm notifications subscription already started");
    }

    handle = subscribe();
  }

  void stop() {
    // If handle is null or released, no-op
    if (handle?.released != false) {
      return;
    }

    handle!.release();
    handle = null;
  }
}

/// Specifies the criticality level above which messages will be logged
/// by the default sync client logger.
/// {@category Realm}
class RealmLogLevel {
  /// Log everything. This will seriously harm the performance of the
  /// sync client and should never be used in production scenarios.
  ///
  /// Same as [Level.ALL]
  static const all = Level.ALL;

  /// A version of [debug] that allows for very high volume output.
  /// This may seriously affect the performance of the sync client.
  ///
  /// Same as [Level.FINEST]
  static const trace = Level('TRACE', 300);

  /// Reveal information that can aid debugging, no longer paying
  /// attention to efficiency.
  ///
  /// Same as [Level.FINER]
  static const debug = Level('DEBUG', 400);

  /// Same as [info], but prioritize completeness over minimalism.
  ///
  /// Same as [Level.FINE];
  static const detail = Level('DETAIL', 500);

  /// Log operational sync client messages, but in a minimalist fashion to
  /// avoid general overhead from logging and to keep volume down.
  ///
  /// Same as [Level.INFO];
  static const info = Level.INFO;

  /// Log errors and warnings.
  ///
  /// Same as [Level.WARNING];
  static const warn = Level.WARNING;

  /// Log errors only.
  ///
  /// Same as [Level.SEVERE];
  static const error = Level('ERROR', 1000);

  /// Log only fatal errors.
  ///
  /// Same as [Level.SHOUT];
  static const fatal = Level('FATAL', 1200);

  /// Turn off logging.
  ///
  /// Same as [Level.OFF];
  static const off = Level.OFF;
}

/// @nodoc
class RealmMetadata {
  final Map<Type, RealmObjectMetadata> _typeMap = <Type, RealmObjectMetadata>{};
  final Map<String, RealmObjectMetadata> _stringMap = <String, RealmObjectMetadata>{};

  RealmMetadata._(Iterable<RealmObjectMetadata> objectMetadatas) {
    for (final metadata in objectMetadatas) {
      if (metadata.type != RealmObject) {
        _typeMap[metadata.type] = metadata;
      } else {
        _stringMap[metadata.name] = metadata;
      }
    }
  }

  RealmObjectMetadata getByType(Type type) {
    final metadata = _typeMap[type];
    if (metadata == null) {
      throw RealmError("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
    }

    return metadata;
  }

  RealmObjectMetadata getByName(String type) {
    var metadata = _stringMap[type];
    if (metadata == null) {
      metadata = _typeMap.values.firstWhereOrNull((v) => v.name == type);
      if (metadata == null) {
        throw RealmError("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
      }

      _stringMap[type] = metadata;
    }

    return metadata;
  }
}

/// Exposes a set of dynamic methods on the Realm object. These don't use strongly typed
/// classes and instead lookup objects by string name.
///
/// {@category Realm}
class DynamicRealm {
  final Realm _realm;

  DynamicRealm._(this._realm);

  /// Returns all [RealmObject]s of type [className] in the `Realm`
  ///
  /// The returned [RealmResults] allows iterating all the values without further filtering.
  RealmResults<RealmObject> all(String className) {
    final metadata = _realm._metadata.getByName(className);
    final handle = realmCore.findAll(_realm, metadata.classKey);
    return RealmResultsInternal.create<RealmObject>(handle, _realm, metadata);
  }

  /// Fast lookup for a [RealmObject] of type [className] with the specified [primaryKey].
  RealmObject? find(String className, Object primaryKey) {
    final metadata = _realm._metadata.getByName(className);

    final handle = realmCore.find(_realm, metadata.classKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, _realm._isInMigration);
    return RealmObjectInternal.create(RealmObject, _realm, handle, accessor);
  }
}

/// A class used during a migration callback. It exposes a set of dynamic API as
/// well as the Realm config and schema.
///
/// {@category Realm}
class MigrationRealm extends DynamicRealm {
  /// The [Configuration] object used to open this [Realm]
  Configuration get config => _realm.config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  RealmSchema get schema => _realm.schema;

  MigrationRealm._(Realm realm) : super._(realm);
}

/// The signature of a callback that will be executed while the Realm is opened asynchronously with [Realm.open].
/// This is the registered callback onProgressCallback to receive progress notifications while the download is in progress.
///
/// * syncProgress - an object of [SyncProgress] that contains `transferredBytes` and `transferableBytes`.
/// {@category Realm}
typedef ProgressCallback = void Function(SyncProgress syncProgress);
