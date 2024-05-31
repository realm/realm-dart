// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../async_open_task_handle.dart' as intf;

class AsyncOpenTaskHandle implements intf.AsyncOpenTaskHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}

abstract class AsyncOpenTaskProgressNotificationTokenHandle implements intf.AsyncOpenTaskProgressNotificationTokenHandle {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
