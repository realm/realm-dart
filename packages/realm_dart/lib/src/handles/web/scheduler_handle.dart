// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';

import '../scheduler_handle.dart' as intf;
import 'handle_base.dart';

class SchedulerHandle extends HandleBase implements intf.SchedulerHandle {
  factory SchedulerHandle(int isolateId, SendPort sendPort) => webNotSupported();
}
