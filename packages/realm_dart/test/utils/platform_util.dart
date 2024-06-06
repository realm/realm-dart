// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:realm_dart/realm.dart';

import 'native/platform_util.dart' if (dart.library.js_interop) 'web/platform_util.dart' as impl;

abstract interface class PlatformUtil {
  const factory PlatformUtil() = impl.PlatformUtil;

  String get systemTempPath;
  Future<String> createTempPath();
  String createTempPathSync();
  Future<int> sizeOnStorage(Configuration config);

  void printPlatformInfo();

  Future<void> copy(String fromPath, String toPath);
  Future<Uint8List> readAsBytes(String path);

  Map<String, String> get environment;

  int get maxInt;
  int get minInt;
}

const platformUtil = PlatformUtil();
