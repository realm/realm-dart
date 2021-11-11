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
export 'realm_object.dart';
export "configuration.dart";
export 'realm_property.dart';
export 'helpers.dart';

void setRealmLib(DynamicLibrary realmLibrary) => setRealmLibrary(realmLibrary);

/// A Realm instance represents a Realm database.
class Realm {
  /// The [Configuration] object of this [Realm]
  Configuration get config => throw RealmException("not implemented");
  late RealmHandle _realm;
  late final _Scheduler _scheduler;

  /// Opens a Realm using the default or a custom [Configuration] object
  Realm(Configuration config) {
    if (!config.schema.isEmpty) {
      realmCore.validateSchema(config.schema);
    }

    this._scheduler = _Scheduler(config);
    this._realm = realmCore.openRealm(config);
  }
  
  static String get version => realmCore.libraryVersion;
}

/// An exception being thrown when a Realm operation or Realm object access fails
class RealmException implements Exception  {
  final String message;

  RealmException(this.message);

  String toString() {
    return "RealmException: $message";
  }
}

class _Scheduler {
  static const SCHEDULER_FINALIZE = null;
  late final SchedulerHandle handle;

  _Scheduler(Configuration config) {
    RawReceivePort receivePort = RawReceivePort();
    receivePort.handler = (message) {
      if (message != SCHEDULER_FINALIZE) {
        realmCore.invokeScheduler(message);
      }

      receivePort.close();
    };

    final sendPort = receivePort.sendPort;
    handle = realmCore.createScheduler(sendPort.nativePort);

    //we use this to receive a notification on process exit to close the receivePort or the process with hang
    Isolate.spawn(handler, 2, onExit: sendPort);

    realmCore.setScheduler(config, this.handle);
  }

  static void handler(int message) {}
}
