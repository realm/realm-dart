// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/collection_changes_handle.dart'
    if (dart.library.js_interop) 'web/collection_changes_handle.dart';
