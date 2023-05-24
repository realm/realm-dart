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

import 'realm_class.dart';

final _receivePortFinalizer = Finalizer<RawReceivePort>((p) => p.close());
final Scheduler scheduler = Scheduler._();

class Scheduler {
  late final SchedulerHandle handle;
  final RawReceivePort _receivePort = RawReceivePort();

  int get nativePort => _receivePort.sendPort.nativePort;

  Scheduler._() {
    _receivePortFinalizer.attach(this, _receivePort, detach: this);

    _receivePort.handler = (dynamic message) {
      if (message is List) {
        // currently the only `message as List` is from the logger.
        final level = message[0] as int;
        final text = message[1] as String;
        Realm.logger.log(LevelExt.fromInt(level), text);
      } else {
        realmCore.invokeScheduler(handle);
      }
    };

    final sendPort = _receivePort.sendPort;
    handle = realmCore.createScheduler(Isolate.current.hashCode, sendPort.nativePort);
  }

  void stop() {
    if (handle.released) {
      return;
    }
    _receivePort.close();
    _receivePortFinalizer.detach(this);
    handle.release();
  }
}
