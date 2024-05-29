// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/from_native.dart'
    if (dart.library.js_interop) 'web/from_native.dart';
