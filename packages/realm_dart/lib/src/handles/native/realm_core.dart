// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/handles/native/realm_bindings.dart';

import 'convert_native.dart';
import 'error_handling.dart';
import 'ffi.dart';
import 'realm_library.dart';
import 'scheduler_handle.dart';

import '../realm_core.dart' as intf;

final _pluginLib = () {
  if (!isFlutterPlatform) {
    throw UnsupportedError("Realm plugin library used outside Flutter");
  }

  if (Platform.isIOS) {
    return DynamicLibrary.executable();
  }

  String plugin = Platform.isWindows
      ? 'realm_plugin.dll'
      : Platform.isMacOS
          ? 'realm.framework/realm' // use catalyst
          : Platform.isLinux
              ? "librealm_plugin.so"
              : throw UnsupportedError("Platform ${Platform.operatingSystem} is not supported");

  final pluginLib = DynamicLibrary.open(plugin);
  return pluginLib;
}();

const realmCore = RealmCore();

class RealmCore implements intf.RealmCore {
  const RealmCore();

  // For debugging
  @override
  int get threadId => realmLib.realm_dart_get_thread_id();

  // for debugging only. Enable in realm_dart.cpp
  // void invokeGC() {
  //   realmLib.realm_dart_gc();
  // }

  @override
  void deleteRealmFiles(String path) {
    using((arena) {
      final realmDeleted = arena<Bool>();
      realmLib.realm_delete_files(path.toCharPtr(arena), realmDeleted).raiseLastErrorIfFalse();
    });
  }

  @override
  List<String> getAllCategoryNames() {
    return using((arena) {
      final count = realmLib.realm_get_category_names(0, nullptr);
      final outValues = arena<Pointer<Char>>(count);
      realmLib.realm_get_category_names(count, outValues);
      return [for (int i = 0; i < count; i++) outValues[i].cast<Utf8>().toDartString()];
    });
  }

  @override
  String getAppDirectory() {
    try {
      if (!isFlutterPlatform || Platform.environment.containsKey('FLUTTER_TEST')) {
        return Directory.current.absolute.path; // dart or flutter test
      }

      // Flutter from here on..

      if (Platform.isAndroid || Platform.isIOS) {
        return _getFilesPath();
      }

      if (Platform.isLinux) {
        final appSupportDir = Platform.environment['XDG_DATA_HOME'] ?? Platform.environment['HOME'] ?? Directory.current.absolute.path;
        return path.join(appSupportDir, ".local/share", _getAppDirectoryFromPlugin());
      }

      if (Platform.isMacOS) {
        return _getAppDirectoryFromPlugin();
      }

      if (Platform.isWindows) {
        return _getAppDirectoryFromPlugin();
      }

      throw UnsupportedError("Platform ${Platform.operatingSystem} is not supported");
    } catch (e) {
      throw RealmException('Cannot get app directory. Error: $e');
    }
  }

  @override
  void loggerAttach() => realmLib.realm_dart_attach_logger(schedulerHandle.sendPort.nativePort);

  @override
  void loggerDetach() => realmLib.realm_dart_detach_logger(schedulerHandle.sendPort.nativePort);

  @override
  void logMessage(LogCategory category, LogLevel logLevel, String message) {
    return using((arena) {
      realmLib.realm_dart_log(logLevel.nativeLevel(), category.toString().toCharPtr(arena), message.toCharPtr(arena));
    });
  }

  @override
  void setLogLevel(LogLevel level, {required LogCategory category}) {
    using((arena) {
      realmLib.realm_set_log_level_category(category.toString().toCharPtr(arena), level.nativeLevel());
    });
  }

  String _getAppDirectoryFromPlugin() {
    assert(isFlutterPlatform);

    final getAppDirFunc = _pluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_app_directory");
    final dirNamePtr = getAppDirFunc();
    final dirName = Platform.isWindows ? dirNamePtr.cast<Utf16>().toDartString() : dirNamePtr.cast<Utf8>().toDartString();

    return dirName;
  }

  String _getFilesPath() {
    return realmLib.realm_dart_get_files_path().cast<Utf8>().toRealmDartString()!;
  }

  @override
  int setAndGetRLimit(int limit) {
    return using((arena) {
      final outLimit = arena<Long>();
      realmLib.realm_dart_set_and_get_rlimit(limit, outLimit).raiseLastErrorIfFalse();
      return outLimit.value;
    });
  }

  @override
  bool checkIfRealmExists(String path) {
    return File(path).existsSync(); // TODO: Should this not check that file is an actual realm file?
  }
}

extension on LogLevel {
  realm_log_level nativeLevel() => switch (this) {
        LogLevel.all => realm_log_level.RLM_LOG_LEVEL_ALL,
        LogLevel.debug => realm_log_level.RLM_LOG_LEVEL_DEBUG,
        LogLevel.detail => realm_log_level.RLM_LOG_LEVEL_DETAIL,
        LogLevel.trace => realm_log_level.RLM_LOG_LEVEL_TRACE,
        LogLevel.info => realm_log_level.RLM_LOG_LEVEL_INFO,
        LogLevel.warn => realm_log_level.RLM_LOG_LEVEL_WARNING,
        LogLevel.error => realm_log_level.RLM_LOG_LEVEL_ERROR,
        LogLevel.fatal => realm_log_level.RLM_LOG_LEVEL_FATAL,
        LogLevel.off => realm_log_level.RLM_LOG_LEVEL_OFF,
      };
}
