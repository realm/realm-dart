// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

import '../init.dart';
import '../realm_class.dart';
import '../scheduler.dart';
import 'collection_changes_handle.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'rooted_handle.dart';

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

var realmCore = _RealmCore();

const encryptionKeySize = 64;
String getFilesPath() {
  return realmLib.realm_dart_get_files_path().cast<Utf8>().toRealmDartString()!;
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

void createCollection(Realm realm, RealmValue value, Pointer<realm_list> Function() createList, Pointer<realm_dictionary> Function() createMap) {
  CollectionHandleBase? collectionHandle;
  try {
    switch (value.collectionType) {
      case RealmCollectionType.list:
        final listHandle = ListHandle(createList(), realm.handle);
        collectionHandle = listHandle;

        final list = realm.createList<RealmValue>(listHandle, null);

        // Necessary since Core will not clear the collection if the value was already a collection
        list.clear();

        for (final item in value.value as List<RealmValue>) {
          list.add(item);
        }
      case RealmCollectionType.map:
        final mapHandle = MapHandle(createMap(), realm.handle);
        collectionHandle = mapHandle;

        final map = realm.createMap<RealmValue>(mapHandle, null);

        // Necessary since Core will not clear the collection if the value was already a collection
        map.clear();

        for (final kvp in (value.value as Map<String, RealmValue>).entries) {
          map[kvp.key] = kvp.value;
        }
      default:
        throw RealmStateError('_createCollection invoked with type that is not list or map.');
    }
  } finally {
    collectionHandle?.release();
  }
}

void collectionChangeCallback(Pointer<Void> userdata, Pointer<realm_collection_changes> data) {
  final NotificationsController controller = userdata.toObject();

  if (data == nullptr) {
    controller.onError(RealmError("Invalid notifications data received"));
    return;
  }

  try {
    final clonedData = realmLib.realm_clone(data.cast());
    if (clonedData == nullptr) {
      controller.onError(RealmError("Error while cloning notifications data"));
      return;
    }

    final changesHandle = CollectionChangesHandle(clonedData.cast());
    controller.onChanges(changesHandle);
  } catch (e) {
    controller.onError(RealmError("Error handling change notifications. Error: $e"));
  }
}

// All access to Realm Core functionality goes through this class
class _RealmCore {
  // ignore: unused_field
  static late final _RealmCore _instance;

  _RealmCore() {
    // This disables creation of a second _RealmCore instance effectively making `realmCore` global variable readonly
    _instance = this;

    // This prevents reentrance if `realmCore` global variable is accessed during _RealmCore construction
    realmCore = this;
  }

  void loggerAttach() {
    realmLib.realm_dart_attach_logger(scheduler.nativePort);
  }

  void loggerDetach() {
    realmLib.realm_dart_detach_logger(scheduler.nativePort);
  }

  // for debugging only. Enable in realm_dart.cpp
  // void invokeGC() {
  //   realmLib.realm_dart_gc();
  // }

  void invokeScheduler(int workQueue) {
    final queuePointer = Pointer<realm_work_queue>.fromAddress(workQueue);
    realmLib.realm_scheduler_perform_work(queuePointer);
  }

  void deleteRealmFiles(String path) {
    using((arena) {
      final realmDeleted = arena<Bool>();
      realmLib.realm_delete_files(path.toCharPtr(arena), realmDeleted).raiseLastErrorIfFalse("Error deleting realm at path $path");
    });
  }

  // For debugging
  // ignore: unused_element
  int get _threadId => realmLib.realm_dart_get_thread_id();

  void logMessage(LogCategory category, LogLevel logLevel, String message) {
    return using((arena) {
      realmLib.realm_dart_log(logLevel.index, category.toString().toCharPtr(arena), message.toCharPtr(arena));
    });
  }

  String getDefaultBaseUrl() {
    return realmLib.realm_app_get_default_base_url().cast<Utf8>().toRealmDartString()!;
  }

  void clearCachedApps() {
    realmLib.realm_clear_cached_apps();
  }

  String _getAppDirectoryFromPlugin() {
    assert(isFlutterPlatform);

    final getAppDirFunc = _pluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_app_directory");
    final dirNamePtr = getAppDirFunc();
    final dirName = Platform.isWindows ? dirNamePtr.cast<Utf16>().toDartString() : dirNamePtr.cast<Utf8>().toDartString();

    return dirName;
  }

  String getAppDirectory() {
    try {
      if (!isFlutterPlatform || Platform.environment.containsKey('FLUTTER_TEST')) {
        return Directory.current.absolute.path; // dart or flutter test
      }

      // Flutter from here on..

      if (Platform.isAndroid || Platform.isIOS) {
        return getFilesPath();
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

  void setLogLevel(LogLevel level, {required LogCategory category}) {
    using((arena) {
      realmLib.realm_set_log_level_category(category.toString().toCharPtr(arena), level.index);
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
}

extension PointerRealmValueEx on Pointer<realm_value_t> {
  Object? toDartValue(Realm realm, Pointer<realm_list_t> Function()? getList, Pointer<realm_dictionary_t> Function()? getMap) {
    if (this == nullptr) {
      throw RealmException("Can not convert nullptr realm_value to Dart value");
    }
    return ref.toDartValue(realm: realm, getList: getList, getMap: getMap);
  }

  List<String> toStringList(int count) {
    final result = List.filled(count, '');
    for (var i = 0; i < count; i++) {
      final strValue = (this + i).ref.values.string;
      result[i] = strValue.data.cast<Utf8>().toRealmDartString(length: strValue.size)!;
    }

    return result;
  }
}

