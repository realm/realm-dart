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
import 'collection.dart';
import "helpers.dart";
import 'realm_property.dart';
import 'native/realm_core.dart';

export 'collection.dart';
export 'list.dart';
export 'results.dart';
export 'realm_object.dart' hide RealmObjectInternal, RealmAccessor, RealmValuesAccessor, RealmMetadata, RealmCoreAccessor;
export "configuration.dart" hide ConfigurationInternal;
export 'realm_property.dart';
export 'helpers.dart';

void setRealmLib(DynamicLibrary realmLibrary) => setRealmLibrary(realmLibrary);

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
        final classKey = realmCore.getClassKey(this, realmClass.name);
        final propertyKeys = realmCore.getPropertyKeys(this, classKey);
        final metadata = RealmMetadata(realmClass.type, classKey, propertyKeys);
        _metadata[realmClass.type] = metadata;
      }
    } catch (e) {
      _scheduler.stop();
      rethrow;
    }
  }

  T add<T extends RealmObject>(T object) {
    final metadata = _metadata[object.runtimeType];
    if (metadata == null) {
      throw RealmException(
          "Object type ${object.runtimeType} not configured in the current Realm's schema. Add type ${object.runtimeType} to your config before opening the Realm");
    }

    final handle = realmCore.createRealmObject(this, metadata.classKey);
    final accessor = RealmCoreAccessor(metadata);
    object.manage(handle, accessor);

    return object;
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
}

class _Scheduler {
  // ignore: constant_identifier_names
  static const dynamic SCHEDULER_FINALIZE_OR_PROCESS_EXIT = null;
  static Isolate? exitIsolate;
  static Future<Isolate>? initExitIsolate;

  late final SchedulerHandle handle;
  final void Function() onFinalize;
  final RawReceivePort receivePort = RawReceivePort();

  _Scheduler(Configuration config, this.onFinalize) {
    receivePort.handler = (dynamic message) {
      if (message == SCHEDULER_FINALIZE_OR_PROCESS_EXIT) {
        //We close the realm when the scheduler is finalized. Is this really needed?
        onFinalize();
        stop();
        return;
      }

      realmCore.invokeScheduler(Isolate.current.hashCode, message as int);
    };

    final sendPort = receivePort.sendPort;
    handle = realmCore.createScheduler(Isolate.current.hashCode, sendPort.nativePort);

    //We use this to receive a SCHEDULER_FINALIZE_OR_PROCESS_EXIT notification on process exit to close the receivePort or the process with hang.
    addOnExitListener(sendPort);
    
    realmCore.setScheduler(config, handle);
  }

  void stop() {
    removeOnExitListener(receivePort.sendPort);
    receivePort.close();
  }

  static void addOnExitListener(SendPort port) async {
    if (exitIsolate == null) {
      if (initExitIsolate == null) {
        initExitIsolate = Isolate.spawn(handler, 1, onExit: port);
        exitIsolate = await initExitIsolate;
        //already subscribed for onExit
        return;
      } 
        
      //The isolate is already being initialized by another call. Wait for the init
      await initExitIsolate;
    }
    
    exitIsolate!.addOnExitListener(port);
  }

  static void removeOnExitListener(SendPort port) {
    final isolate = exitIsolate!;
    isolate.removeOnExitListener(port);
  }

  static void handler(int message) {}
}

extension RealmInternal on Realm {
  RealmHandle get handle => _handle;
}
