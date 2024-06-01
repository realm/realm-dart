// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

import 'init.dart';
import '../../realm_class.dart';
import '../../scheduler.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'ffi.dart';
import 'realm_library.dart';

final realmCore = RealmCore._();

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

class RealmCore {
  RealmCore._();

  // For debugging
  int get threadId => realmLib.realm_dart_get_thread_id();

  void clearCachedApps() {
    realmLib.realm_clear_cached_apps();
  }

  // for debugging only. Enable in realm_dart.cpp
  // void invokeGC() {
  //   realmLib.realm_dart_gc();
  // }

  void deleteRealmFiles(String path) {
    using((arena) {
      final realmDeleted = arena<Bool>();
      realmLib.realm_delete_files(path.toCharPtr(arena), realmDeleted).raiseLastErrorIfFalse();
    });
  }

  List<String> getAllCategoryNames() {
    return using((arena) {
      final count = realmLib.realm_get_category_names(0, nullptr);
      final outValues = arena<Pointer<Char>>(count);
      realmLib.realm_get_category_names(count, outValues);
      return [for (int i = 0; i < count; i++) outValues[i].cast<Utf8>().toDartString()];
    });
  }

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

  String getBundleId() {
    readBundleId() {
      try {
        if (!isFlutterPlatform || Platform.environment.containsKey('FLUTTER_TEST')) {
          var pubspecPath = path.join(path.current, 'pubspec.yaml');
          var pubspecFile = File(pubspecPath);

          if (pubspecFile.existsSync()) {
            final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
            return pubspec.name;
          }
        }

        if (Platform.isAndroid) {
          return realmLib.realm_dart_get_bundle_id().cast<Utf8>().toDartString();
        }

        final getBundleIdFunc = _pluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_bundle_id");
        final bundleIdPtr = getBundleIdFunc();
        return bundleIdPtr.cast<Utf8>().toDartString();
      } on Exception catch (_) {
        //Never fail on bundleId. Use fallback value.
      }

      //Fallback value
      return "realm_bundle_id";
    }

    String bundleId = readBundleId();
    const salt = [82, 101, 97, 108, 109, 32, 105, 115, 32, 103, 114, 101, 97, 116];
    return base64Encode(sha256.convert([...salt, ...utf8.encode(bundleId)]).bytes);
  }

  String getDefaultBaseUrl() {
    return realmLib.realm_app_get_default_base_url().cast<Utf8>().toRealmDartString()!;
  }

  String getDeviceName() {
    if (Platform.isAndroid || Platform.isIOS) {
      return realmLib.realm_dart_get_device_name().cast<Utf8>().toRealmDartString()!;
    }

    return "";
  }

  String getDeviceVersion() {
    if (Platform.isAndroid || Platform.isIOS) {
      return realmLib.realm_dart_get_device_version().cast<Utf8>().toRealmDartString()!;
    }

    return "";
  }

  String getRealmLibraryCpuArchitecture() {
    return realmLib.realm_get_library_cpu_arch().cast<Utf8>().toDartString();
  }

  void loggerAttach() => realmLib.realm_dart_attach_logger(scheduler.nativePort);

  void loggerDetach() => realmLib.realm_dart_detach_logger(scheduler.nativePort);

  void logMessage(LogCategory category, LogLevel logLevel, String message) {
    return using((arena) {
      realmLib.realm_dart_log(logLevel.index, category.toString().toCharPtr(arena), message.toCharPtr(arena));
    });
  }

  void setLogLevel(LogLevel level, {required LogCategory category}) {
    using((arena) {
      realmLib.realm_set_log_level_category(category.toString().toCharPtr(arena), level.index);
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

  int setAndGetRLimit(int limit) {
    return using((arena) {
      final outLimit = arena<Long>();
      realmLib.realm_dart_set_and_get_rlimit(limit, outLimit).raiseLastErrorIfFalse();
      return outLimit.value;
    });
  }

  bool checkIfRealmExists(String path) {
    return File(path).existsSync(); // TODO: Should this not check that file is an actual realm file?
  }
}
