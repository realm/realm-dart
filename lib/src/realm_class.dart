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
import 'dart:isolate';

import 'package:realm_common/realm_common.dart';
import 'package:collection/collection.dart';

import 'configuration.dart';
import 'list.dart';
import 'native/realm_core.dart';
import 'realm_object.dart';
import 'results.dart';

// always expose with `show` to explicitly control the public API surface
export 'app.dart' show AppConfiguration, MetadataPersistenceMode, App;
export 'package:realm_common/realm_common.dart'
    show
        Ignored,
        Indexed,
        MapTo,
        PrimaryKey,
        RealmError,
        RealmModel,
        RealmUnsupportedSetError,
        RealmStateError,
        RealmCollectionType,
        RealmPropertyType,
        ObjectId,
        Uuid;
export "configuration.dart" show Configuration, RealmSchema, SchemaObject;
export 'list.dart' show RealmList, RealmListOfObject, RealmListChanges;
export 'realm_object.dart' show RealmEntity, RealmException, RealmObject, RealmObjectChanges;
export 'realm_property.dart';
export 'results.dart' show RealmResults, RealmResultsChanges;
export 'credentials.dart' show Credentials, AuthProviderType, EmailPasswordAuthProvider;
export 'user.dart' show User;

/// A [Realm] instance represents a `Realm` database.
///
/// {@category Realm}
class Realm {
  final Configuration _config;
  late final RealmMetadata _metadata;
  late final RealmHandle _handle;
  late final Scheduler _scheduler;

  /// An object encompassing this `Realm` instance's dynamic API.
  late final DynamicRealm dynamic = DynamicRealm._(this);

  /// The [Configuration] object used to open this [Realm]
  Configuration get config => _config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  late final RealmSchema schema;

  /// Opens a `Realm` using a [Configuration] object.
  Realm(Configuration config) : _config = config {
    _scheduler = Scheduler(close);

    try {
      _handle = realmCore.openRealm(_config, _scheduler);
      _populateMetadata();
    } catch (e) {
      _scheduler.stop();
      rethrow;
    }
  }

  Realm._unowned(Configuration config, RealmHandle handle) : _config = config {
    _handle = handle;
    _populateMetadata();
  }

  void _populateMetadata() {
    schema = _config.schemaObjects.isNotEmpty ? RealmSchema(_config.schemaObjects) : realmCore.readSchema(this);
    _metadata = RealmMetadata._(schema.map((c) => realmCore.getObjectMedata(this, c.name, c.type)));
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

    final metadata = _metadata.getByType(object.runtimeType);
    final handle = metadata.primaryKey == null
        ? realmCore.createRealmObject(this, metadata.tableKey)
        : realmCore.createRealmObjectWithPrimaryKey(this, metadata.tableKey, object.accessor.get(object, metadata.primaryKey!)!);

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
    realmCore.closeRealm(this);
    _scheduler.stop();
  }

  /// Checks whether the `Realm` is closed.
  bool get isClosed => realmCore.isRealmClosed(this);

  /// Fast lookup for a [RealmObject] with the specified [primaryKey].
  T? find<T extends RealmObject>(Object primaryKey) {
    final metadata = _metadata.getByType(T);

    final handle = realmCore.find(this, metadata.tableKey, primaryKey);
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
    final handle = realmCore.findAll(this, metadata.tableKey);
    return RealmResultsInternal.create<T>(handle, this, metadata);
  }

  /// Returns all [RealmObject]s that match the specified [query].
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query<T extends RealmObject>(String query, [List<Object> args = const []]) {
    final metadata = _metadata.getByType(T);
    final handle = realmCore.queryClass(this, metadata.tableKey, query, args);
    return RealmResultsInternal.create<T>(handle, this, metadata);
  }

  /// Deletes all [RealmObject]s of type `T` in the `Realm`
  void deleteAll<T extends RealmObject>() => deleteMany(all<T>());

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Realm) return false;
    return realmCore.realmEquals(this, other);
  }
}

class Scheduler {
  // ignore: constant_identifier_names
  static const dynamic SCHEDULER_FINALIZE_OR_PROCESS_EXIT = 0;
  late final SchedulerHandle handle;
  final void Function() onFinalize;
  final RawReceivePort receivePort = RawReceivePort();

  Scheduler(this.onFinalize) {
    receivePort.handler = (dynamic message) {
      if (message == SCHEDULER_FINALIZE_OR_PROCESS_EXIT) {
        onFinalize();
        stop();
        return;
      }

      realmCore.invokeScheduler(handle);
    };

    final sendPort = receivePort.sendPort;
    handle = realmCore.createScheduler(Isolate.current.hashCode, sendPort.nativePort);
  }

  void stop() {
    receivePort.close();
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
  Scheduler get scheduler => _scheduler;

  static Realm getUnowned(Configuration config, RealmHandle handle) {
    return Realm._unowned(config, handle);
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

/// @nodoc
class RealmMetadata {
  final Map<Type, RealmObjectMetadata> _typeMap = <Type, RealmObjectMetadata>{};
  final Map<String, RealmObjectMetadata> _stringMap = <String, RealmObjectMetadata>{};

  RealmMetadata._(Iterable<RealmObjectMetadata> objects) {
    for (final meta in objects) {
      if (meta.type != RealmObject) {
        _typeMap[meta.type] = meta;
      } else {
        _stringMap[meta.name] = meta;
      }
    }
  }

  RealmObjectMetadata getByType(Type type) {
    final metadata = _typeMap[type];
    if (metadata == null) {
      throw RealmException("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
    }

    return metadata;
  }

  RealmObjectMetadata getByName(String type) {
    var metadata = _stringMap[type];
    if (metadata == null) {
      metadata = _typeMap.values.firstWhereOrNull((v) => v.name == type);
      if (metadata == null) {
        throw RealmException("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
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
    final handle = realmCore.findAll(_realm, metadata.tableKey);
    return RealmResultsInternal.create<RealmObject>(handle, _realm, metadata);
  }

  /// Fast lookup for a [RealmObject] of type [className] with the specified [primaryKey].
  RealmObject? find(String className, Object primaryKey) {
    final metadata = _realm._metadata.getByName(className);

    final handle = realmCore.find(_realm, metadata.tableKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata);
    return RealmObjectInternal.create(RealmObject, _realm, handle, accessor);
  }
}
