// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:http/http.dart';

import 'native/default_client.dart' if (dart.library.js_interop) 'web/default_client.dart' as impl;

final Client defaultClient = impl.defaultClient();
