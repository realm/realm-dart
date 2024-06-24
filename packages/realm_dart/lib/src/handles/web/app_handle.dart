// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../../../realm.dart';
import '../app_handle.dart' as intf;
import 'handle_base.dart';

class AppHandle extends HandleBase implements intf.AppHandle {
  static Future<AppHandle> from(AppConfiguration configuration) => webNotSupported();
  static AppHandle? get(String id, String? baseUrl) => webNotSupported();
}
