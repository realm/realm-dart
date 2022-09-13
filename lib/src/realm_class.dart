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

export 'package:realm_common/realm_common.dart'
    show
        Ignored,
        Indexed,
        MapTo,
        PrimaryKey,
        RealmError,
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
export 'app.dart' show AppConfiguration, MetadataPersistenceMode, App;
export "configuration.dart"
    show
        Configuration,
        FlexibleSyncConfiguration,
        InitialDataCallback,
        InMemoryConfiguration,
        LocalConfiguration,
        RealmSchema,
        SchemaObject,
        ShouldCompactCallback,
        SyncErrorHandler,
        SyncClientResetErrorHandler;

export 'credentials.dart' show Credentials, AuthProviderType, EmailPasswordAuthProvider;
export 'list.dart' show RealmList, RealmListOfObject, RealmListChanges;
export 'realm_object.dart' show RealmEntity, RealmException, RealmObject, RealmObjectChanges, DynamicRealmObject;
export 'realm_property.dart';
export 'results.dart' show RealmResults, RealmResultsChanges;
export 'subscription.dart' show Subscription, SubscriptionSet, SubscriptionSetState, MutableSubscriptionSet;
export 'user.dart' show User, UserState, UserIdentity;
export 'session.dart' show Session, SessionState, ConnectionState, ProgressDirection, ProgressMode, SyncProgress, ConnectionStateChange;

/// A [Realm] instance represents a `Realm` database.
///
/// {@category Realm}
class Realm implements Finalizable {
  late final RealmMetadata _metadata;
  late final RealmHandle _handle;

  /// An object encompassing this `Realm` instance's dynamic API.
  late final DynamicRealm dynamic = DynamicRealm._(this);

  /// The [Configuration] object used to open this [Realm]
  final Configuration config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  late final RealmSchema schema;

  /// Opens a `Realm` using a [Configuration] object.
  Realm(Configuration config) : this._(config);

  Realm._(this.config, [RealmHandle? handle]) : _handle = handle ?? _openRealmSync(config) {
    _populateMetadata();
  }

  /// A method for asynchronously obtaining and opening a [Realm].
  ///
  /// If the configuration is [FlexibleSyncConfiguration], the realm will be downloaded and fully
  /// synchronized with the server prior to the completion of the returned [Future].
  /// Otherwise this method will throw an exception.
  ///
  /// Open realm async arguments are:
  /// * `config`- a configuration object that describes the realm.
  /// * `cancelationController` - an initialized object of [RealmCancelationController] that is used to cancel the operation. It is not mandatory.
  /// * `onProgressCallback` - a function that is registered as a callback for receiving download progress notifications. It is not mandatory.
  ///
  /// The returned type is [Future<Realm?>] that is completed once the remote realm is fully synchronized or canceled.
  /// [RealmCancelationController] provides method [cancel] that cancels any current running download.
  /// If multiple [Realm.open] operations are all in the progress for the same Realm,
  /// then canceling one of them will cancel all of them.
  static Future<Realm> open(Configuration config, {RealmCancellationToken? cancellationToken, ProgressCallback? onProgressCallback}) async {
    CancelledException? exception;
    await _createFileDirectory(config.path);
    final realm = Realm(config);
    //Initial subscriptions to be loaded here
    try {
      if (config is FlexibleSyncConfiguration) {
        final session = realm.syncSession;
        if (onProgressCallback != null) {
          await session
              .getProgressStream(ProgressDirection.download, ProgressMode.forCurrentlyOutstandingWork)
              .forEach((s) => onProgressCallback.call(s.transferredBytes, s.transferableBytes))
              .asCancellable(cancellationToken?.token);
        } else {
          await session.waitForDownload().asCancellable(cancellationToken?.token);
        }
      }
    } on CancelledException catch (e) {
      exception = e;
    } catch (e) {
      rethrow;
    }
    if (cancellationToken?.token.isCancelled == true && exception != null) {
      throw exception;
    }
    return realm;

    //return await _open(config, onProgressCallback).asCancellable(cancellationToken?.token);
  }

  static Future<Realm> _open(Configuration config, ProgressCallback? onProgressCallback) async {
    await _createFileDirectory(config.path);
    final realm = Realm(config);
    //Initial subscriptions to be loaded here
    if (config is FlexibleSyncConfiguration) {
      // final session = realm.syncSession;
      // if (onProgressCallback != null) {
      //   await session
      //       .getProgressStream(ProgressDirection.download, ProgressMode.forCurrentlyOutstandingWork)
      //       .forEach((s) => onProgressCallback.call(s.transferredBytes, s.transferableBytes));
      // } else {
      //   await session.waitForDownload();
      // }
    }
    return realm;
  }

  static RealmHandle _openRealmSync(Configuration config) {
    Future<void>.sync(() => _createFileDirectory(config.path));
    return realmCore.openRealm(config);
  }

  static Future<void> _createFileDirectory(String filePath) async {
    var dir = File(filePath).parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
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

    final accessor = RealmCoreAccessor(metadata);
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
    _syncSession?.handle.release();
    _syncSession = null;

    _subscriptions?.handle.release();
    _subscriptions = null;

    realmCore.closeRealm(this);
  }

  /// Checks whether the `Realm` is closed.
  bool get isClosed => realmCore.isRealmClosed(this);

  /// Fast lookup for a [RealmObject] with the specified [primaryKey].
  T? find<T extends RealmObject>(Object? primaryKey) {
    final metadata = _metadata.getByType(T);

    final handle = realmCore.find(this, metadata.classKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata);
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

  SubscriptionSet? _subscriptions;

  /// The active [SubscriptionSet] for this [Realm]
  SubscriptionSet get subscriptions {
    if (config is! FlexibleSyncConfiguration) {
      throw RealmError('subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration');
    }

    _subscriptions ??= SubscriptionSetInternal.create(this, realmCore.getSubscriptions(this));
    realmCore.refreshSubscriptionSet(_subscriptions!);
    return _subscriptions!;
  }

  Session? _syncSession;

  /// The [Session] for this [Realm]. The sync session is responsible for two-way synchronization
  /// with MongoDB Atlas. If the [Realm] is not synchronized, accessing this property will throw.
  Session get syncSession {
    if (config is! FlexibleSyncConfiguration) {
      throw RealmError('session is only valid on synchronized Realms (i.e. opened with FlexibleSyncConfiguration)');
    }

    _syncSession ??= SessionInternal.create(realmCore.realmGetSession(this));
    return _syncSession!;
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

  RealmHandle get handle => _handle;

  static Realm getUnowned(Configuration config, RealmHandle handle) {
    return Realm._(config, handle);
  }

  RealmObject createObject(Type type, RealmObjectHandle handle, RealmObjectMetadata metadata) {
    final accessor = RealmCoreAccessor(metadata);
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
    if (handle == null) {
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

    final accessor = RealmCoreAccessor(metadata);
    return RealmObjectInternal.create(RealmObject, _realm, handle, accessor);
  }
}

/// The signature of a callback that will be executed while the Realm is opened asynchronously with [Realm.open].
/// This is the registered callback onProgressCallback to receive progress notifications while the download is in progress.
///
/// It is called with the following arguments:
/// * `transferredBytes` - the current number of bytes already transferred
/// * `totalBytes` - the total number of transferable bytes (the number of bytes already transferred plus the number of bytes pending transfer)
/// {@category Realm}
typedef ProgressCallback = void Function(int transferredBytes, int totalBytes);

class RealmCancelledException implements CancelledException {
  final Exception _exception;
  RealmCancelledException(Exception exception) : _exception = exception;
  String get message => (_exception is CancelledException) ? (_exception as CancelledException).cancellationReason ?? "" : _exception.toString();

  @override
  String? get cancellationReason => message;
}

class RealmCancellationToken {
  final token = CancellationToken();

  void cancel() {
    token.cancel(RealmCancelledException(CancelledException(cancellationReason: "Operation cancelled request")));
  }
}
