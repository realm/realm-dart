// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

class SchedulerHandle extends HandleBase<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer, 24);

  factory SchedulerHandle(int isolateId, int sendPort) {
    final schedulerPtr = realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invoke(int workQueue) {
    final queuePointer = Pointer<realm_work_queue>.fromAddress(workQueue);
    realmLib.realm_scheduler_perform_work(queuePointer);
  }
}
