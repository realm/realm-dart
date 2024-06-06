// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_class.dart';
import 'handle_base.dart';
import 'native/async_open_task_handle.dart' if (dart.library.js_interop) 'web/async_open_task_handle.dart' as impl;
import 'realm_handle.dart';

abstract interface class AsyncOpenTaskHandle extends HandleBase {
  factory AsyncOpenTaskHandle.from(FlexibleSyncConfiguration config) = impl.AsyncOpenTaskHandle.from;

  Future<RealmHandle> openAsync(CancellationToken? cancellationToken);
  void cancel();

  AsyncOpenTaskProgressNotificationTokenHandle registerProgressNotifier(
    RealmAsyncOpenProgressNotificationsController controller,
  );
}

abstract class AsyncOpenTaskProgressNotificationTokenHandle extends HandleBase {}