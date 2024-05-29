// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

export 'native/decimal128.dart'
    if (dart.library.js) 'web/decimal128.dart';
