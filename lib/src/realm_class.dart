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
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:realm_common/realm_common.dart';

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
        SessionError,
        SyncError,
        SyncErrorCategory,
        RealmModel,
        RealmUnsupportedSetError,
        RealmStateError,
        RealmCollectionType,
        RealmPropertyType,
        ObjectId,
        Uuid;

// always expose with `show` to explicitly control the public API surface
export 'app.dart' show AppConfiguration, MetadataPersistenceMode, LogLevel, App;
export "configuration.dart"
    show
        Configuration,
        FlexibleSyncConfiguration,
        InitialDataCallback,
        InMemoryConfiguration,
        LocalConfiguration,
        RealmSchema,
        SchemaObject,
        ShouldCompactCallback;

export 'credentials.dart' show Credentials, AuthProviderType, EmailPasswordAuthProvider;
export 'list.dart' show RealmList, RealmListOfObject, RealmListChanges;
export 'realm_object.dart' show RealmEntity, RealmException, RealmObject, RealmObjectChanges;
export 'realm_property.dart';
export 'results.dart' show RealmResults, RealmResultsChanges;
export 'subscription.dart' show Subscription, SubscriptionSet, SubscriptionSetState, MutableSubscriptionSet;
export 'user.dart' show User, UserState, UserIdentity;
export 'session.dart' show Session, SessionState, ConnectionState, ProgressDirection, ProgressMode, SyncProgress;

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

  /// Log nothing.
  ///
  /// Same as [Level.OFF];
  static const off = Level.OFF;

  static const levels = [
    all,
    trace,
    debug,
    detail,
    info,
    warn,
    error,
    fatal,
    off,
  ];
}

/// A [Realm] instance represents a `Realm` database.
///
/// {@category Realm}
class Realm {
  final Map<Type, RealmMetadata> _metadata = <Type, RealmMetadata>{};
  final RealmHandle _handle;

  /// The logger to use.
  ///
  /// Defaults to printing info or worse to the console
  static late var logger = Logger.detached('Realm')
    ..level = RealmLogLevel.info
    ..onRecord.listen((event) => print(event));

  /// Shutdown.
  static void shutdown() => scheduler.stop();

  /// The [Configuration] object used to open this [Realm]
  final Configuration config;

  /// Opens a `Realm` using a [Configuration] object.
  Realm(Configuration config) : this._(config);

  Realm._(this.config, [RealmHandle? handle]) : _handle = handle ?? realmCore.openRealm(config) {
    _populateMetadata();
  }

  void _populateMetadata() {
    for (var realmClass in config.schema) {
      final classMeta = realmCore.getClassMetadata(this, realmClass.name, realmClass.type);
      final propertyMeta = realmCore.getPropertyMetadata(this, classMeta.key);
      final metadata = RealmMetadata(classMeta, propertyMeta);
      _metadata[realmClass.type] = metadata;
    }
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
  /// Throws [RealmException] when trying to add objects with the same primary key.
  /// Throws [RealmException] if there is no write transaction created with [write].
  T add<T extends RealmObject>(T object) {
    if (object.isManaged) {
      return object;
    }

    final metadata = _metadata[object.runtimeType];
    if (metadata == null) {
      throw RealmException("Object type ${object.runtimeType} not configured in the current Realm's schema."
          " Add type ${object.runtimeType} to your config before opening the Realm");
    }

    final handle = metadata.class_.primaryKey == null
        ? realmCore.createRealmObject(this, metadata.class_.key)
        : realmCore.createRealmObjectWithPrimaryKey(this, metadata.class_.key, object.accessor.get(object, metadata.class_.primaryKey!)!);

    final accessor = RealmCoreAccessor(metadata);
    object.manage(this, handle, accessor);

    return object;
  }

  /// Adds a collection [RealmObject]s to this `Realm`.
  ///
  /// If the collection contains items that are already managed by this `Realm`, they will be ignored.
  /// This method behaves as calling [add] multiple times.
  void addAll<T extends RealmObject>(Iterable<T> items) {
    for (final i in items) {
      add(i);
    }
  }

  /// Deletes a [RealmObject] from this `Realm`.
  void delete<T extends RealmObject>(T object) {
    try {
      realmCore.deleteRealmObject(object);
    } catch (e) {
      throw RealmException("Error deleting object from databse. Error: $e");
    }
  }

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
  T? find<T extends RealmObject>(Object primaryKey) {
    RealmMetadata metadata = _getMetadata(T);

    final handle = realmCore.find(this, metadata.class_.key, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata);
    var object = RealmObjectInternal.create(T, this, handle, accessor);
    return object as T;
  }

  RealmMetadata _getMetadata(Type type) {
    final metadata = _metadata[type];
    if (metadata == null) {
      throw RealmException("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
    }

    return metadata;
  }

  /// Returns all [RealmObject]s of type `T` in the `Realm`
  ///
  /// The returned [RealmResults] allows iterating all the values without further filtering.
  RealmResults<T> all<T extends RealmObject>() {
    RealmMetadata metadata = _getMetadata(T);
    final handle = realmCore.findAll(this, metadata.class_.key);
    return RealmResultsInternal.create<T>(handle, this);
  }

  /// Returns all [RealmObject]s that match the specified [query].
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query<T extends RealmObject>(String query, [List<Object> args = const []]) {
    RealmMetadata metadata = _getMetadata(T);
    final handle = realmCore.queryClass(this, metadata.class_.key, query, args);
    return RealmResultsInternal.create<T>(handle, this);
  }

  /// Deletes all [RealmObject]s of type `T` in the `Realm`
  void deleteAll<T extends RealmObject>() => deleteMany(all<T>());

  SubscriptionSet? _subscriptions;

  /// The active [SubscriptionSet] for this [Realm]
  SubscriptionSet get subscriptions {
    if (config is! FlexibleSyncConfiguration) throw RealmError('subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration');
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
  RealmHandle get handle => _handle;

  static Realm getUnowned(Configuration config, RealmHandle handle) {
    return Realm._(config, handle);
  }

  RealmObject createObject(Type type, RealmObjectHandle handle) {
    RealmMetadata metadata = _getMetadata(type);

    final accessor = RealmCoreAccessor(metadata);
    var object = RealmObjectInternal.create(type, this, handle, accessor);
    return object;
  }

  RealmList<T> createList<T extends Object>(RealmListHandle handle) {
    return RealmListInternal.create(handle, this);
  }

  List<String> getPropertyNames(Type type, List<int> propertyKeys) {
    RealmMetadata metadata = _getMetadata(type);
    final result = <String>[];
    for (var key in propertyKeys) {
      final name = metadata.getPropertyName(key);
      if (name != null) {
        result.add(name);
      }
    }
    return result;
  }
}

/// @nodoc
abstract class NotificationsController {
  RealmNotificationTokenHandle? handle;

  RealmNotificationTokenHandle subscribe();
  void onChanges(Handle changesHandle);
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
