// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/map_handle.dart'
    if (dart.library.js_interop) 'web/map_handle.dart';
