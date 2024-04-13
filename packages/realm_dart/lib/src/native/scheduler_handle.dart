// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

class SchedulerHandle extends HandleBase<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer, 24);

  factory SchedulerHandle(int isolateId, int sendPort) {
    final schedulerPtr = realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }
}
