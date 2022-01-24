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

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'results.dart';
import 'configuration.dart';
import 'realm_object.dart';
import 'native/realm_core.dart';
import 'list.dart';

export 'list.dart' hide RealmListInternal;
export 'results.dart' hide RealmResultsInternal;
export 'realm_object.dart'
    hide RealmObjectInternal, RealmAccessor, RealmValuesAccessor, RealmMetadata, RealmCoreAccessor, RealmClassMetadata, RealmPropertyMetadata;
export "configuration.dart" hide ConfigurationInternal;
export 'package:realm_common/realm_common.dart' show RealmModel, PrimaryKey, Ignored, MapTo, Indexed, RealmPropertyType, RealmCollectionType;
export 'realm_property.dart';
export 'helpers.dart';

/// A [Realm] instance represents a Realm database.
///
/// [Realm] instance provides methods for
/// adding, deleting, editing and searching objects in realm database.
/// [Realm] static methods allows managing Ream database file.
///
/// {@category Realm API}
class Realm {
  final Configuration _config;
  final Map<Type, RealmMetadata> _metadata = <Type, RealmMetadata>{};
  late final RealmHandle _handle;
  late final _Scheduler _scheduler;

  /// The [Configuration] object that controls this [Realm]'s path and other settings.
  Configuration get config => _config;

  /// Opens a Realm using the default or a custom [Configuration] object.
  Realm(Configuration config) : _config = config {
    _scheduler = _Scheduler(config, close);

    try {
      _handle = realmCore.openRealm(config);

      for (var realmClass in config.schema) {
        final classMeta = realmCore.getClassMetadata(this, realmClass.name, realmClass.type);
        final propertyMeta = realmCore.getPropertyMetadata(this, classMeta.key);
        final metadata = RealmMetadata(classMeta, propertyMeta);
        _metadata[realmClass.type] = metadata;
      }
    } catch (e) {
      _scheduler.stop();
      rethrow;
    }
  }

  /// Deletes all files associated with a Realm located at given [path]
  /// if the Realm exists and is not open.
  ///
  /// The Realm file must not be open on other process.
  /// All but the .lock file will be deleted by this.
  static void deleteRealm(String path) {
    realmCore.deleteRealmFiles(path);
  }

  /// Returns `true` if a Realm already exists on [path].
  /// Realm [path], must be a valid full path for the current platform,
  /// relative subdirectory, or just filename.
  static bool existsSync(String path) {
    try {
      final fileEntity = File(path);
      return fileEntity.existsSync();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at $path. Error: $e");
    }
  }

  /// Checks whether a Realm file with this [path] exists.
  ///
  /// Returns a Future<bool> that completes with the result.
  static Future<bool> exists(String path) async {
    try {
      final fileEntity = File(path);
      return await fileEntity.exists();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at $path. Error: $e");
    }
  }

  ///Adds new [RealmObject] to Realm.
  ///
  /// Throws [RealmExceprion] when trying to add objects with the same primary key.
  /// This [Realm] will start managing a [RealmObject] which has been created as a standalone object.
  /// If you invoke this when there is no write transaction active on the [Realm]
  /// an RealmException will be thrown.
  /// You can't manage an object with more than one [Realm].
  /// If the object is already managed by this [Realm], this method does nothing.
  /// This method modifies the object in-place, meaning that after it has run, <c>obj</c> will be managed.
  /// Returning it is just meant as a convenience to enable fluent syntax scenarios.
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

  /// Adds a collection of standalone [RealmObject]s to this [Realm].
  ///
  /// If the collection contains items that are already managed by this [Realm],
  /// they will be ignored. This method modifies the objects in-place,
  /// meaning that after it has run, all items in the collection will be managed.
  void addAll<T extends RealmObject>(Iterable<T> items) {
    for (final i in items) {
      add(i);
    }
  }

  /// Deletes given [RealmObject] from this [Realm].
  void delete<T extends RealmObject>(T object) {
    try {
      realmCore.deleteRealmObject(object);
    } catch (e) {
      throw RealmException("Error deleting object from databse. Error: $e");
    }
  }

  /// Deletes [RealmObject] items in given collection from this [Realm].
  ///
  /// Throws [RealmException] if you invoke this
  /// when there is no write transaction active on the [Realm].
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

  /// Returns `true` if there is an opened transaction using `realm.Write`.
  bool get _isInTransaction => realmCore.getIsWritable(this);

  /// Execute a delegate inside a temporary transaction.
  ///
  /// If no exception is thrown, the transaction will be committed.
  /// Creates its own temporary transaction and commits it after passed function completes.
  /// Be careful of wrapping multiple single property updates in multiple `write` calls.
  /// It is more efficient to update several properties or even create multiple objects in a single `write`,
  /// unless you need to guarantee finer-grained updates.
  void write(void Function() writeCallback) {
    try {
      realmCore.beginWrite(this);
      writeCallback();
      realmCore.commitWrite(this);
    } catch (e) {
      if (_isInTransaction) {
        realmCore.rollbackWrite(this);
      }
      rethrow;
    }
  }

  /// Closes the native Realm if this is the last remaining
  /// instance holding a reference to it
  ///
  /// After closing Realm, all [RealmObject] are invalidated.
  /// They can not be changed or read until the Realm is reopened.
  void close() {
    realmCore.closeRealm(this);
  }

  /// Checks whether the Realm is closed.
  bool get isClosed => realmCore.isRealmClosed(this);

  ///Fast lookup of an object from a class which has a PrimaryKey property.
  T? find<T extends RealmObject>(String primaryKey) {
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

  /// Extracts an iterable set of objects for direct use or further query.
  ///
  /// Returns a queryable collection that without further filtering,
  /// allows iterating all the [RealmObject]s, in this [Realm].
  RealmResults<T> all<T extends RealmObject>() {
    RealmMetadata metadata = _getMetadata(T);
    final handle = realmCore.findAll(this, metadata.class_.key);
    return RealmResultsInternal.create<T>(handle, this);
  }

  /// Returns from Realm all the [RealmObject]s that matches the query.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query<T extends RealmObject>(String query, [List<Object> args = const []]) {
    RealmMetadata metadata = _getMetadata(T);
    final handle = realmCore.queryClass(this, metadata.class_.key, query, args);
    return RealmResultsInternal.create<T>(handle, this);
  }
}

class _Scheduler {
  // ignore: constant_identifier_names
  static const dynamic SCHEDULER_FINALIZE_OR_PROCESS_EXIT = null;
  late final SchedulerHandle handle;
  final void Function() onFinalize;
  final RawReceivePort receivePort = RawReceivePort();

  _Scheduler(Configuration config, this.onFinalize) {
    receivePort.handler = (dynamic message) {
      if (message == SCHEDULER_FINALIZE_OR_PROCESS_EXIT) {
        onFinalize();
        stop();
        return;
      }

      realmCore.invokeScheduler(Isolate.current.hashCode, message as int);
    };

    final sendPort = receivePort.sendPort;
    handle = realmCore.createScheduler(Isolate.current.hashCode, sendPort.nativePort);

    //We use this to receive a SCHEDULER_FINALIZE_OR_PROCESS_EXIT notification on process exit to close the receivePort or the process with hang.
    Isolate.spawn(_handler, 2, onExit: sendPort);

    realmCore.setScheduler(config, handle);
  }

  void stop() {
    receivePort.close();
  }

  static void _handler(int message) {}
}

///@nodoc
extension RealmInternal on Realm {
  RealmHandle get handle => _handle;

  RealmObject createObject(Type type, RealmObjectHandle handle) {
    RealmMetadata metadata = _getMetadata(type);

    final accessor = RealmCoreAccessor(metadata);
    var object = RealmObjectInternal.create(type, this, handle, accessor);
    return object;
  }

  RealmList<T> createList<T extends Object>(RealmListHandle handle) {
    return RealmListInternal.create(handle, this);
  }
}
