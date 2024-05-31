// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../../../realm.dart';
import '../app_handle.dart' as intf;

class AppHandle implements intf.AppHandle {
  factory AppHandle.from(AppConfiguration configuration) => throw UnsupportedError('web not supported');
  static AppHandle? get(String id, String? baseUrl) => throw UnsupportedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
