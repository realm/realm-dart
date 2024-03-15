// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

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
      } else if (message is int) {
        realmCore.invokeScheduler(message);
      } else {
        Realm.logger.log(RealmLogLevel.error, 'Unexpected Scheduler message type: ${message.runtimeType} - $message');
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
