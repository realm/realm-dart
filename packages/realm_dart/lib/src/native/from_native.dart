import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'ffi.dart';

import '../app.dart';
import '../configuration.dart';
import '../realm_class.dart';
import '../user.dart';
import 'decimal128.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

// TODO: Duplicated in to_native.dart
const int _microsecondsPerSecond = 1000 * 1000;
const int _nanosecondsPerMicrosecond = 1000;

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
    return DateTime.fromMicrosecondsSinceEpoch(seconds * _microsecondsPerSecond + nanoseconds ~/ 1000, isUtc: true);
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
