// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';

import 'handle_base.dart';

import 'native/scheduler_handle.dart' if (dart.library.js_interop) 'web/scheduler_handle.dart' as impl;

abstract interface class SchedulerHandle extends HandleBase {
  factory SchedulerHandle(int isolateId, SendPort port) = impl.SchedulerHandle;

  void invoke(int workQueue);
}
