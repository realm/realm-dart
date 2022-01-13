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
export 'realm_property.dart';
export 'helpers.dart';

/// A Realm instance represents a Realm database.
class Realm {
  final Configuration _config;
  final Map<Type, RealmMetadata> _metadata = <Type, RealmMetadata>{};
  late final RealmHandle _handle;
  late final _Scheduler _scheduler;

  /// The [Configuration] object of this [Realm]
  Configuration get config => _config;

  /// Opens a Realm using the default or a custom [Configuration] object
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

  static void deleteRealm(String path) {
    realmCore.deleteRealmFiles(path);
  }

  static bool existsSync(String path) {
    try {
      final fileEntity = File(path);
      return fileEntity.existsSync();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at ${path}. Error: $e");
    }
  }

  static Future<bool> exists(String path) async {
    try {
      final fileEntity = File(path);
      return await fileEntity.exists();
    } catch (e) {
      throw RealmException("Error while checking if Realm exists at ${path}. Error: $e");
    }
  }

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
        : realmCore.createRealmObjectWithPrimaryKey(this, metadata.class_.key, metadata.class_.primaryKey!);

    final accessor = RealmCoreAccessor(metadata);
    object.manage(this, handle, accessor);

    return object;
  }

  /// Delete given [RealmObject] from Realm database.
  /// Throws [RealmException] on error.
  void delete<T extends RealmObject>(T object) {
    try {
      realmCore.deleteRealmObject(object);
    } catch (e) {
      throw RealmException("Error deleting object from databse. Error: $e");
    }
  }

  /// Deletes [RealmObject] items in given collection from Realm database.
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

  void addAll<T extends RealmObject>(Iterable<T> items) {
    for (final i in items) {
      add(i);
    }
  }

  void remove<T extends RealmObject>(T object) {
    realmCore.deleteRealmObject(object);
  }

  bool get _isInTransaction => realmCore.getIsWritable(this);

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

  void close() {
    realmCore.closeRealm(this);
  }

  bool get isClosed => realmCore.isRealmClosed(this);

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

  RealmResults<T> all<T extends RealmObject>() {
    RealmMetadata metadata = _getMetadata(T);
    final handle = realmCore.findAll(this, metadata.class_.key);
    return RealmResultsInternal.create<T>(handle, this);
  }

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
