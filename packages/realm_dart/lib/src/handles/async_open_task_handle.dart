// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/async_open_task_handle.dart'
    if (dart.library.js_interop) 'web/async_open_task_handle.dart';
