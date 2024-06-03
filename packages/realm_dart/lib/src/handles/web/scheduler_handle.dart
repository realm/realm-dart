// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';

import '../scheduler_handle.dart' as intf;

class SchedulerHandle  implements intf.SchedulerHandle {
  factory SchedulerHandle(int isolateId, SendPort sendPort) => throw UnsupportedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}


