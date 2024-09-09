// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import 'native/realm_core.dart' if (dart.library.js_interop) 'web/realm_core.dart' as impl;

abstract interface class RealmCore {
  int get threadId;

  String getAppDirectory();

  void loggerAttach();
  void loggerDetach();
  List<String> getAllCategoryNames();
  void setLogLevel(LogLevel level, {required LogCategory category});
  void logMessage(LogCategory category, LogLevel logLevel, String message);

  int setAndGetRLimit(int limit);

  bool checkIfRealmExists(String path);
  void deleteRealmFiles(String path);
}

const realmCore = impl.RealmCore();
