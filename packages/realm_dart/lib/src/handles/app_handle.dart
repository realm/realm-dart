// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/app_handle.dart'
    if (dart.library.js_interop) 'web/app_handle.dart';
