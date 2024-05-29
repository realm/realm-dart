// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/notification_token_handle.dart'
    if (dart.library.js_interop) 'web/notification_token_handle.dart';
