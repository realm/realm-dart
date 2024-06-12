// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import '../async_open_task_handle.dart' as intf;
import 'handle_base.dart';

class AsyncOpenTaskHandle extends HandleBase implements intf.AsyncOpenTaskHandle {
  factory AsyncOpenTaskHandle.from(FlexibleSyncConfiguration config) => webNotSupported();

  @override
  noSuchMethod(Invocation invocation) => webNotSupported();
}

abstract class AsyncOpenTaskProgressNotificationTokenHandle implements intf.AsyncOpenTaskProgressNotificationTokenHandle {
  @override
  noSuchMethod(Invocation invocation) => webNotSupported();
}
