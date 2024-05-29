// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/handle_base.dart'
    if (dart.library.js_interop) 'web/handle_base.dart';
