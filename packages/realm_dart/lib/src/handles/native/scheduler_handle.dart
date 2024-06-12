// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:isolate';

import '../../scheduler.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

import '../scheduler_handle.dart' as intf;

class SchedulerHandle extends HandleBase<realm_scheduler> implements intf.SchedulerHandle {
  final SendPort sendPort;
  SchedulerHandle._(this.sendPort, Pointer<realm_scheduler> pointer) : super(pointer, 24);

  factory SchedulerHandle(int isolateId, SendPort sendPort) {
    final schedulerPtr = realmLib.realm_dart_create_scheduler(isolateId, sendPort.nativePort);
    return SchedulerHandle._(sendPort, schedulerPtr);
  }

  @override
  void invoke(int workQueue) {
    final queuePointer = Pointer<realm_work_queue>.fromAddress(workQueue);
    realmLib.realm_scheduler_perform_work(queuePointer);
  }
}

final schedulerHandle = scheduler.handle as SchedulerHandle;
