// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';

import 'package:realm_dart/src/logging.dart';

import 'handles/scheduler_handle.dart';
import 'realm_class.dart';

final _receivePortFinalizer = Finalizer<RawReceivePort>((p) => p.close());
final Scheduler scheduler = Scheduler._();

class Scheduler {
  late final SchedulerHandle handle;
  final RawReceivePort _receivePort = RawReceivePort();

  Scheduler._() {
    _receivePortFinalizer.attach(this, _receivePort, detach: this);
    // There be dragons here!!!
    //
    // As of Dart 3.4 (Flutter 3.22) we started seeing uncaught exceptions on
    // the receivePort handler (issue #1676), stating that:
    // "argument value for 'return_value' is null" in
    // RealmLibrary.realm_scheduler_perform_work, but obviously a void method
    // don't return anything, so this is really a Dart issue.
    //
    // However, by ensuring the callback happens in the current zone (as it
    // rightfully should), and using bindUnaryCallbackGuarded, we can avoid
    // these.
    _receivePort.handler = Zone.current.bindUnaryCallbackGuarded(_handle);
    final sendPort = _receivePort.sendPort;
    handle = SchedulerHandle(Isolate.current.hashCode, sendPort);
  }

  void _handle(dynamic message) {
    if (message is List) {
      // currently the only `message as List` is from the logger.
      final category = LogCategory.fromString(message[0] as String);
      final level = LogLevel.values[message[1] as int];
      final text = message[2] as String;
      Realm.logger.raise((category: category, level: level, message: text));
    } else if (message is int) {
      handle.invoke(message);
    } else {
      Realm.logger.log(LogLevel.error, 'Unexpected Scheduler message type: ${message.runtimeType} - $message');
    }
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
