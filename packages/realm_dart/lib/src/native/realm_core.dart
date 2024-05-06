// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

import '../app.dart';
import '../configuration.dart';
import '../init.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../scheduler.dart';
import '../user.dart';
import 'collection_changes_handle.dart';
import 'decimal128.dart';
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

extension ListEx on List<int> {
  Pointer<Char> toCharPtr(Allocator allocator) {
    return toUint8Ptr(allocator).cast();
  }

  Pointer<Uint8> toUint8Ptr(Allocator allocator) {
    final nativeSize = length + 1;
    final result = allocator<Uint8>(nativeSize);
    final Uint8List native = result.asTypedList(nativeSize);
    native.setAll(0, this); // copy
    native.last = 0; // zero terminate
    return result.cast();
  }
}

extension StringEx on String {
  Pointer<Char> toCharPtr(Allocator allocator) {
    final units = utf8.encode(this);
    return units.toCharPtr(allocator).cast();
  }

  Pointer<realm_string_t> toRealmString(Allocator allocator) {
    final realmString = allocator<realm_string_t>();
    final units = utf8.encode(this);
    realmString.ref.data = units.toCharPtr(allocator).cast();
    realmString.ref.size = units.length;
    return realmString;
  }
}

extension NullableObjectEx on Object? {
  Pointer<realm_value_t> toNative(Allocator allocator) {
    final self = this;
    final realmValue = allocator<realm_value_t>();
    if (self is RealmValue && self.type.isCollection) {
      throw RealmError(
          "Don't use _toPrimitiveValue if the value may contain collections. Use storeValue instead. This is a bug in the Realm Flutter SDK and should be reported to https://github.com/realm/realm-dart/issues/new");
    }
    _intoRealmValue(self, realmValue.ref, allocator);
    return realmValue;
  }
}

const int _microsecondsPerSecond = 1000 * 1000;
const int _nanosecondsPerMicrosecond = 1000;

void intoRealmQueryArg(Object? value, Pointer<realm_query_arg_t> realmQueryArg, Allocator allocator) {
  if (value is Iterable) {
    realmQueryArg.ref.nb_args = value.length;
    realmQueryArg.ref.is_list = true;
    realmQueryArg.ref.arg = allocator<realm_value>(value.length);
    int i = 0;
    for (var item in value) {
      _intoRealmValue(item, realmQueryArg.ref.arg[i], allocator);
      i++;
    }
  } else {
    realmQueryArg.ref.arg = allocator<realm_value_t>();
    realmQueryArg.ref.nb_args = 1;
    realmQueryArg.ref.is_list = false;
    _intoRealmValueHack(value, realmQueryArg.ref.arg.ref, allocator);
  }
}

void _intoRealmValueHack(Object? value, realm_value realmValue, Allocator allocator) {
  if (value is GeoShape) {
    _intoRealmValue(value.toString(), realmValue, allocator);
  } else if (value is RealmValueType) {
    _intoRealmValue(value.toQueryArgString(), realmValue, allocator);
  } else {
    _intoRealmValue(value, realmValue, allocator);
  }
}

void _intoRealmValue(Object? value, realm_value realmValue, Allocator allocator) {
  if (value == null) {
    realmValue.type = realm_value_type.RLM_TYPE_NULL;
  } else if (value is RealmObjectBase) {
    // when converting a RealmObjectBase to realm_value.link we assume the object is managed
    final link = value.handle.asLink;
    realmValue.values.link.target = link.targetKey;
    realmValue.values.link.target_table = link.classKey;
    realmValue.type = realm_value_type.RLM_TYPE_LINK;
  } else if (value is int) {
    realmValue.values.integer = value;
    realmValue.type = realm_value_type.RLM_TYPE_INT;
  } else if (value is bool) {
    realmValue.values.boolean = value;
    realmValue.type = realm_value_type.RLM_TYPE_BOOL;
  } else if (value is String) {
    String string = value;
    final units = utf8.encode(string);
    final result = allocator<Uint8>(units.length);
    final Uint8List nativeString = result.asTypedList(units.length);
    nativeString.setAll(0, units);
    realmValue.values.string.data = result.cast();
    realmValue.values.string.size = units.length;
    realmValue.type = realm_value_type.RLM_TYPE_STRING;
  } else if (value is double) {
    realmValue.values.dnum = value;
    realmValue.type = realm_value_type.RLM_TYPE_DOUBLE;
  } else if (value is ObjectId) {
    final bytes = value.bytes;
    for (var i = 0; i < 12; i++) {
      realmValue.values.object_id.bytes[i] = bytes[i];
    }
    realmValue.type = realm_value_type.RLM_TYPE_OBJECT_ID;
  } else if (value is Uuid) {
    final bytes = value.bytes.asUint8List();
    for (var i = 0; i < 16; i++) {
      realmValue.values.uuid.bytes[i] = bytes[i];
    }
    realmValue.type = realm_value_type.RLM_TYPE_UUID;
  } else if (value is DateTime) {
    final microseconds = value.toUtc().microsecondsSinceEpoch;
    final seconds = microseconds ~/ _microsecondsPerSecond;
    int nanoseconds = _nanosecondsPerMicrosecond * (microseconds % _microsecondsPerSecond);
    if (microseconds < 0 && nanoseconds != 0) {
      nanoseconds = nanoseconds - _nanosecondsPerMicrosecond * _microsecondsPerSecond;
    }
    realmValue.values.timestamp.seconds = seconds;
    realmValue.values.timestamp.nanoseconds = nanoseconds;
    realmValue.type = realm_value_type.RLM_TYPE_TIMESTAMP;
  } else if (value is Decimal128) {
    realmValue.values.decimal128 = value.value;
    realmValue.type = realm_value_type.RLM_TYPE_DECIMAL128;
  } else if (value is Uint8List) {
    realmValue.type = realm_value_type.RLM_TYPE_BINARY;
    realmValue.values.binary.size = value.length;
    realmValue.values.binary.data = allocator<Uint8>(value.length);
    realmValue.values.binary.data.asTypedList(value.length).setAll(0, value);
  } else if (value is RealmValue) {
    if (value is List<RealmValue>) {
      realmValue.type = realm_value_type.RLM_TYPE_LIST;
    } else if (value is Map<String, RealmValue>) {
      realmValue.type = realm_value_type.RLM_TYPE_DICTIONARY;
    } else {
      return _intoRealmValue(value.value, realmValue, allocator);
    }
  } else {
    throw RealmException("Property type ${value.runtimeType} not supported");
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

extension RealmValueEx on realm_value_t {
  Object? toPrimitiveValue() => toDartValue(realm: null, getList: null, getMap: null);

  Object? toDartValue({required Realm? realm, required Pointer<realm_list_t> Function()? getList, required Pointer<realm_dictionary_t> Function()? getMap}) {
    switch (type) {
      case realm_value_type.RLM_TYPE_NULL:
        return null;
      case realm_value_type.RLM_TYPE_INT:
        return values.integer;
      case realm_value_type.RLM_TYPE_BOOL:
        return values.boolean;
      case realm_value_type.RLM_TYPE_STRING:
        return values.string.data.cast<Utf8>().toRealmDartString(length: values.string.size)!;
      case realm_value_type.RLM_TYPE_FLOAT:
        return values.fnum;
      case realm_value_type.RLM_TYPE_DOUBLE:
        return values.dnum;
      case realm_value_type.RLM_TYPE_LINK:
        if (realm == null) {
          throw RealmError("A realm instance is required to resolve Backlinks");
        }
        final objectKey = values.link.target;
        final classKey = values.link.target_table;
        if (realm.metadata.getByClassKeyIfExists(classKey) == null) return null; // temporary workaround to avoid crash on assertion
        return realm.handle.getObject(classKey, objectKey);
      case realm_value_type.RLM_TYPE_BINARY:
        return Uint8List.fromList(values.binary.data.asTypedList(values.binary.size));
      case realm_value_type.RLM_TYPE_TIMESTAMP:
        final seconds = values.timestamp.seconds;
        final nanoseconds = values.timestamp.nanoseconds;
        return DateTime.fromMicrosecondsSinceEpoch(seconds * _microsecondsPerSecond + nanoseconds ~/ _nanosecondsPerMicrosecond, isUtc: true);
      case realm_value_type.RLM_TYPE_DECIMAL128:
        var decimal = values.decimal128; // NOTE: Does not copy the struct!
        decimal = realmLib.realm_dart_decimal128_copy(decimal); // This is a workaround to that
        return Decimal128Internal.fromNative(decimal);
      case realm_value_type.RLM_TYPE_OBJECT_ID:
        return ObjectId.fromBytes(values.object_id.bytes.toList(12));
      case realm_value_type.RLM_TYPE_UUID:
        final listInt = values.uuid.bytes.toList(16);
        return Uuid.fromBytes(Uint8List.fromList(listInt).buffer);
      case realm_value_type.RLM_TYPE_LIST:
        if (getList == null || realm == null) {
          throw RealmException('toDartValue called with a list argument but without a list getter');
        }

        final listHandle = ListHandle(getList(), realm.handle);
        return realm.createList<RealmValue>(listHandle, null);
      case realm_value_type.RLM_TYPE_DICTIONARY:
        if (getMap == null || realm == null) {
          throw RealmException('toDartValue called with a list argument but without a list getter');
        }

        final mapHandle = MapHandle(getMap(), realm.handle);
        return realm.createMap<RealmValue>(mapHandle, null);
      default:
        throw RealmException("realm_value_type $type not supported");
    }
  }
}

extension ArrayUint8Ex on Array<Uint8> {
  List<int> toList(int count) {
    final result = <int>[];
    for (var i = 0; i < count; i++) {
      result.add(this[i]);
    }
    return result;
  }
}

extension PointerSizeEx on Pointer<Size> {
  List<int> toIntList(int count) {
    List<int> result = List.filled(count, value);
    for (var i = 1; i < count; i++) {
      result[i] = (this + i).value;
    }
    return result;
  }
}

extension PointerVoidEx on Pointer<Void> {
  T toObject<T extends Object>() {
    assert(this != nullptr, "Pointer<Void> is null");

    Object object = realmLib.realm_dart_persistent_handle_to_object(this);

    assert(object is T, "$T expected");
    return object as T;
  }

  Object? toUserCodeError() {
    if (this != nullptr) {
      final result = toObject();
      realmLib.realm_dart_delete_persistent_handle(this);
      return result;
    }

    return null;
  }
}

extension PointerUtf8Ex on Pointer<Utf8> {
  String? toRealmDartString({bool treatEmptyAsNull = false, int? length, bool freeRealmMemory = false}) {
    if (this == nullptr) {
      return null;
    }

    try {
      final result = toDartString(length: length);

      if (treatEmptyAsNull && result == '') {
        return null;
      }
      return result;
    } finally {
      if (freeRealmMemory) {
        realmLib.realm_free(cast());
      }
    }
  }
}

extension RealmSyncErrorEx on realm_sync_error {
  SyncErrorDetails toDart() {
    final message = status.message.cast<Utf8>().toRealmDartString()!;
    final userInfoMap = user_info_map.toDart(user_info_length);
    final originalFilePathKey = c_original_file_path_key.cast<Utf8>().toRealmDartString();
    final recoveryFilePathKey = c_recovery_file_path_key.cast<Utf8>().toRealmDartString();

    return SyncErrorDetails(
      message,
      status.error,
      user_code_error.toUserCodeError(),
      isFatal: is_fatal,
      isClientResetRequested: is_client_reset_requested,
      originalFilePath: userInfoMap?[originalFilePathKey],
      backupFilePath: userInfoMap?[recoveryFilePathKey],
      compensatingWrites: compensating_writes.toList(compensating_writes_length),
    );
  }
}

extension PointerRealmSyncErrorUserInfoEx on Pointer<realm_sync_error_user_info> {
  Map<String, String>? toDart(int length) {
    if (this == nullptr) {
      return null;
    }
    Map<String, String> userInfoMap = {};
    for (int i = 0; i < length; i++) {
      final userInfoItem = this[i];
      final key = userInfoItem.key.cast<Utf8>().toDartString();
      final value = userInfoItem.value.cast<Utf8>().toDartString();
      userInfoMap[key] = value;
    }
    return userInfoMap;
  }
}

extension PointerRealmSyncErrorCompensatingWriteInfoEx on Pointer<realm_sync_error_compensating_write_info> {
  List<CompensatingWriteInfo>? toList(int length) {
    if (this == nullptr || length == 0) {
      return null;
    }
    List<CompensatingWriteInfo> compensatingWrites = [];
    for (int i = 0; i < length; i++) {
      final compensatingWrite = this[i];
      final reason = compensatingWrite.reason.cast<Utf8>().toDartString();
      final objectName = compensatingWrite.object_name.cast<Utf8>().toDartString();
      final primaryKey = compensatingWrite.primary_key.toPrimitiveValue();
      compensatingWrites.add(CompensatingWriteInfo(objectName, reason, RealmValue.from(primaryKey)));
    }
    return compensatingWrites;
  }
}

extension PointerRealmErrorEx on Pointer<realm_error_t> {
  SyncError toDart() {
    final message = ref.message.cast<Utf8>().toDartString();
    final details = SyncErrorDetails(message, ref.error, ref.user_code_error.toUserCodeError());
    return SyncErrorInternal.createSyncError(details);
  }
}

extension ObjectEx on Object {
  Pointer<Void> toPersistentHandle() {
    return realmLib.realm_dart_object_to_persistent_handle(this);
  }
}

extension ListUserStateEx on List<UserState> {
  UserState fromIndex(int index) {
    if (!UserState.values.any((value) => value.index == index)) {
      throw RealmError("Unknown user state $index");
    }

    return UserState.values[index];
  }
}

extension RealmPropertyInfoEx on realm_property_info {
  SchemaProperty toSchemaProperty() {
    final linkTarget = link_target == nullptr ? null : link_target.cast<Utf8>().toDartString();
    return SchemaProperty(name.cast<Utf8>().toDartString(), RealmPropertyType.values[type],
        optional: flags & realm_property_flags.RLM_PROPERTY_NULLABLE == realm_property_flags.RLM_PROPERTY_NULLABLE,
        primaryKey: flags & realm_property_flags.RLM_PROPERTY_PRIMARY_KEY == realm_property_flags.RLM_PROPERTY_PRIMARY_KEY,
        linkTarget: linkTarget == null || linkTarget.isEmpty ? null : linkTarget,
        collectionType: RealmCollectionType.values[collection_type]);
  }
}

extension CompleterEx<T> on Completer<T> {
  void completeFrom(FutureOr<T> Function() action) {
    try {
      complete(action());
    } catch (error, stackTrace) {
      completeError(error, stackTrace);
    }
  }

  void completeWithAppError(Pointer<realm_app_error> error) {
    final message = error.ref.message.cast<Utf8>().toRealmDartString()!;
    final linkToLogs = error.ref.link_to_server_logs.cast<Utf8>().toRealmDartString();
    completeError(AppInternal.createException(message, linkToLogs, error.ref.http_status_code));
  }
}

enum CustomErrorCode {
  noError(0),
  unknownHttp(998),
  unknown(999),
  timeout(1000);

  final int code;
  const CustomErrorCode(this.code);
}

enum HttpMethod {
  get,
  post,
  patch,
  put,
  delete,
}

extension RealmTimestampEx on realm_timestamp_t {
  DateTime toDart() {
    return DateTime.fromMicrosecondsSinceEpoch(seconds * 1000000 + nanoseconds ~/ 1000, isUtc: true);
  }
}

extension RealmStringEx on realm_string_t {
  String? toDart() => data.cast<Utf8>().toRealmDartString();
}

extension ObjectIdEx on ObjectId {
  Pointer<realm_object_id> toNative(Allocator allocator) {
    final result = allocator<realm_object_id>();
    for (var i = 0; i < 12; i++) {
      result.ref.bytes[i] = bytes[i];
    }
    return result;
  }
}

extension RealmObjectIdEx on realm_object_id {
  ObjectId toDart() {
    final buffer = Uint8List(12);
    for (int i = 0; i < 12; ++i) {
      buffer[i] = bytes[i];
    }
    return ObjectId.fromBytes(buffer);
  }
}

extension RealmAppUserApikeyEx on realm_app_user_apikey {
  ApiKey toDart() => UserInternal.createApiKey(
        id.toDart(),
        name.cast<Utf8>().toDartString(),
        key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true),
        !disabled,
      );
}

extension PlatformEx on Platform {
  static String fromEnvironment(String name, {String defaultValue = ""}) {
    final result = Platform.environment[name];
    if (result == null) {
      return defaultValue;
    }

    return result;
  }
}

/// @nodoc
class SyncErrorDetails {
  final String message;
  final int code;
  final String? path;
  final bool isFatal;
  final bool isClientResetRequested;
  final String? originalFilePath;
  final String? backupFilePath;
  final List<CompensatingWriteInfo>? compensatingWrites;
  final Object? userError;

  SyncErrorDetails(
    this.message,
    this.code,
    this.userError, {
    this.path,
    this.isFatal = false,
    this.isClientResetRequested = false,
    this.originalFilePath,
    this.backupFilePath,
    this.compensatingWrites,
  });
}

extension RealmValueTypeEx on RealmValueType {
  String toQueryArgString() {
    return switch (this) {
      RealmValueType.nullValue => 'null',
      RealmValueType.boolean => 'bool',
      RealmValueType.string => 'string',
      RealmValueType.int => 'int',
      RealmValueType.double => 'double',
      RealmValueType.object => 'link',
      RealmValueType.objectId => 'objectid',
      RealmValueType.dateTime => 'date',
      RealmValueType.decimal => 'decimal',
      RealmValueType.uuid => 'uuid',
      RealmValueType.binary => 'binary',
      RealmValueType.list => 'array',
      RealmValueType.map => 'object',
    };
  }
}
