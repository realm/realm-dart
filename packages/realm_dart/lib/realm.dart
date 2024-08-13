// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// dart.library.cli is available only on dart desktop
export 'src/realm_flutter.dart' if (dart.library.cli) 'src/realm_dart.dart';
export 'package:ejson/ejson.dart';