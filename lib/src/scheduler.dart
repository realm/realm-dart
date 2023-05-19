////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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
import 'dart:isolate';

import 'native/realm_core.dart';

final _receivePortFinalizer = Finalizer<RawReceivePort>((p) => p.close());
final Scheduler scheduler = Scheduler._();

class Scheduler {
  late final SchedulerHandle handle;
  final RawReceivePort receivePort = RawReceivePort();

Scheduler._() {
    _receivePortFinalizer.attach(this, receivePort, detach: this);

    receivePort.handler = (dynamic message) {
      if (message is List) {
        realmCore.loggerLogMessage(message[0] as int, message[1] as String);
      } else {
        realmCore.invokeScheduler(handle);
      }
    };

    final sendPort = receivePort.sendPort;
    handle = realmCore.createScheduler(Isolate.current.hashCode, sendPort.nativePort);
  }

  void stop() {
    if (handle.released) {
      return;
    }

    receivePort.close();
    _receivePortFinalizer.detach(this);
    handle.release();
  }
}
