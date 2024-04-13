// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:crypto/crypto.dart';
// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:realm_common/realm_common.dart' as common show Decimal128;
import 'package:realm_common/realm_common.dart' hide Decimal128;

import '../app.dart';
import '../collections.dart';
import '../configuration.dart';
import '../credentials.dart';
import '../init.dart';
import '../list.dart';
import '../logging.dart';
import '../map.dart';
import '../migration.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../results.dart';
import '../scheduler.dart';
import '../session.dart';
import '../set.dart';
//import '../subscription.dart';
import '../user.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

// TODO: Use regular
part 'app_handle.dart';
part 'config_handle.dart';
part 'convert.dart';
part 'decimal128.dart';
part 'error_handling.dart';
part 'mutable_subscription_set_handle.dart';
part 'object_handle.dart';
part 'query_handle.dart';
part 'realm_handle.dart';
part 'results_handle.dart';
part 'rooted_handle.dart';
part 'schema_handle.dart';
part 'subscription_handle.dart';
part 'subscription_set_handle.dart';
part 'user_handle.dart';

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

void _guardSynchronousCallback(FutureOr<void> Function() callback, Pointer<Void> unlockCallbackFunc) async {
  Pointer<Void> user_error = nullptr;
  try {
    await callback();
  } catch (error) {
    user_error = error.toPersistentHandle();
  } finally {
    realmLib.realm_dart_invoke_unlock_callback(user_error, unlockCallbackFunc);
  }
}

bool should_compact_callback(Pointer<Void> userdata, int totalSize, int usedSize) {
  final config = userdata.toObject();

  if (config is LocalConfiguration) {
    return config.shouldCompactCallback!(totalSize, usedSize);
  } else if (config is FlexibleSyncConfiguration) {
    return config.shouldCompactCallback!(totalSize, usedSize);
  }

  return false;
}

bool migration_callback(Pointer<Void> userdata, Pointer<shared_realm> oldRealmHandle, Pointer<shared_realm> newRealmHandle, Pointer<realm_schema> schema) {
  final oldHandle = RealmHandle._unowned(oldRealmHandle);
  final newHandle = RealmHandle._unowned(newRealmHandle);
  try {
    final LocalConfiguration config = userdata.toObject();

    final oldSchemaVersion = realmLib.realm_get_schema_version(oldRealmHandle);
    final oldConfig = Configuration.local([], path: config.path, isReadOnly: true, schemaVersion: oldSchemaVersion);
    final oldRealm = RealmInternal.getUnowned(oldConfig, oldHandle, isInMigration: true);

    final newRealm = RealmInternal.getUnowned(config, newHandle, isInMigration: true);

    final migration = MigrationInternal.create(RealmInternal.getMigrationRealm(oldRealm), newRealm, SchemaHandle.unowned(schema));
    config.migrationCallback!(migration, oldSchemaVersion);
    return true;
  } catch (ex) {
    realmLib.realm_register_user_code_callback_error(ex.toPersistentHandle());
  } finally {
    oldHandle.release();
    newHandle.release();
  }

  return false;
}

void _syncErrorHandlerCallback(Object userdata, Pointer<realm_sync_session> session, realm_sync_error error) {
  final syncConfig = userdata as FlexibleSyncConfiguration;
  // TODO: Take the app from the session instead of from syncConfig after fixing issue https://github.com/realm/realm-dart/issues/633
  final syncError = SyncErrorInternal.createSyncError(error.toDart(), app: syncConfig.user.app);

  if (syncError is ClientResetError) {
    syncConfig.clientResetHandler.onManualReset?.call(syncError);
    return;
  }

  syncConfig.syncErrorHandler(syncError);
}

void _syncBeforeResetCallback(Object userdata, Pointer<shared_realm> realmHandle, Pointer<Void> unlockCallbackFunc) {
  _guardSynchronousCallback(() async {
    final syncConfig = userdata as FlexibleSyncConfiguration;
    var beforeResetCallback = syncConfig.clientResetHandler.onBeforeReset!;

    final realm = RealmInternal.getUnowned(syncConfig, RealmHandle._unowned(realmHandle));
    try {
      await beforeResetCallback(realm);
    } finally {
      realm.handle.release();
    }
  }, unlockCallbackFunc);
}

bool initial_data_callback(Pointer<Void> userdata, Pointer<shared_realm> realmPtr) {
  final realmHandle = RealmHandle._unowned(realmPtr);
  try {
    final LocalConfiguration config = userdata.toObject();
    final realm = RealmInternal.getUnowned(config, realmHandle);
    config.initialDataCallback!(realm);
    return true;
  } catch (ex) {
    realmLib.realm_register_user_code_callback_error(ex.toPersistentHandle());
  } finally {
    realmHandle.release();
  }

  return false;
}

Pointer<Void> _createAsyncUserCallbackUserdata(Completer<void> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_user>,
        Pointer<realm_app_error>,
      )>(_app_user_completion_callback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

void _app_api_key_completion_callback(Pointer<Void> userdata, Pointer<realm_app_user_apikey> apiKey, Pointer<realm_app_error> error) {
  final Completer<ApiKey> completer = userdata.toObject();
  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }
  completer.complete(apiKey.ref.toDart());
}

void _app_api_key_array_completion_callback(Pointer<Void> userdata, Pointer<realm_app_user_apikey> apiKey, int size, Pointer<realm_app_error> error) {
  final Completer<List<ApiKey>> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  final result = <ApiKey>[];
  for (var i = 0; i < size; i++) {
    result.add(apiKey[i].toDart());
  }

  completer.complete(result);
}

void _app_user_completion_callback(Pointer<Void> userdata, Pointer<realm_user> user, Pointer<realm_app_error> error) {
  final Completer<UserHandle> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  user = realmLib.realm_clone(user.cast()).cast(); // take an extra reference to the user object
  if (user == nullptr) {
    completer.completeError(RealmException("Error while cloning user object."));
    return;
  }

  completer.complete(UserHandle._(user.cast()));
}

void _void_completion_callback(Pointer<Void> userdata, Pointer<realm_app_error> error) {
  final Completer<void> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  completer.complete();
}

Pointer<Void> _createAsyncCallbackUserdata<T extends Function>(Completer<void> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_error>,
      )>(_void_completion_callback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

Pointer<Void> _createAsyncApikeyCallbackUserdata<T extends Function>(Completer<ApiKey> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_user_apikey>,
        Pointer<realm_app_error>,
      )>(_app_api_key_completion_callback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

Pointer<Void> _createAsyncApikeyListCallbackUserdata<T extends Function>(Completer<List<ApiKey>> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_user_apikey>,
        Size count,
        Pointer<realm_app_error>,
      )>(_app_api_key_array_completion_callback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

// All access to Realm Core functionality goes through this class
class _RealmCore {
  // From realm.h. Currently not exported from the shared library
  // ignore: unused_field, constant_identifier_names
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  // ignore: unused_field, constant_identifier_names
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  // ignore: unused_field, constant_identifier_names
  static const int RLM_INVALID_OBJECT_KEY = -1;

  // ignore: unused_field
  static late final _RealmCore _instance;

  _RealmCore() {
    // This disables creation of a second _RealmCore instance effectivelly making `realmCore` global variable readonly
    _instance = this;

    // This prevents reentrance if `realmCore` global variable is accessed during _RealmCore construction
    realmCore = this;

    realmLib.realm_dart_init_debug_logger();
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

  void raiseError(Session session, int errorCode, bool isFatal) {
    using((arena) {
      final message = "Simulated session error".toCharPtr(arena);
      realmLib.realm_sync_session_handle_error_for_testing(session.handle.pointer, errorCode, message, isFatal);
    });
  }

  SchedulerHandle createScheduler(int isolateId, int sendPort) {
    final schedulerPtr = realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invokeScheduler(int workQueue) {
    final queuePointer = Pointer<realm_work_queue>.fromAddress(workQueue);
    realmLib.realm_scheduler_perform_work(queuePointer);
  }

  RealmHandle openRealm(Configuration config) {
    final configHandle = ConfigHandle(config);
    final realmPtr = invokeGetPointer(() => realmLib.realm_open(configHandle.pointer), "Error opening realm at path ${config.path}");
    return RealmHandle._(realmPtr);
  }

  RealmAsyncOpenTaskHandle createRealmAsyncOpenTask(FlexibleSyncConfiguration config) {
    final configHandle = ConfigHandle(config);
    final asyncOpenTaskPtr = invokeGetPointer(() => realmLib.realm_open_synchronized(configHandle.pointer), "Error opening realm at path ${config.path}");
    return RealmAsyncOpenTaskHandle._(asyncOpenTaskPtr);
  }

  Future<RealmHandle> openRealmAsync(RealmAsyncOpenTaskHandle handle, CancellationToken? cancellationToken) {
    final completer = CancellableCompleter<RealmHandle>(cancellationToken);
    if (!completer.isCancelled) {
      final callback =
          Pointer.fromFunction<Void Function(Handle, Pointer<realm_thread_safe_reference> realm, Pointer<realm_async_error_t> error)>(_openRealmAsyncCallback);
      final userData = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_async_open_task_start(
        handle.pointer,
        realmLib.addresses.realm_dart_async_open_task_callback,
        userData.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      );
    }
    return completer.future;
  }

  static void _openRealmAsyncCallback(Object userData, Pointer<realm_thread_safe_reference> realmSafePtr, Pointer<realm_async_error_t> error) {
    return using((Arena arena) {
      final completer = userData as CancellableCompleter<RealmHandle>;
      if (completer.isCancelled) {
        return;
      }
      if (error != nullptr) {
        final err = arena<realm_error>();
        final lastError = realmLib.realm_get_async_error(error, err) ? err.ref.toDart() : null;
        completer.completeError(RealmException("Failed to open realm: ${lastError?.message ?? 'Error details missing.'}"));
        return;
      }

      final realmPtr = invokeGetPointer(() => realmLib.realm_from_thread_safe_reference(realmSafePtr, scheduler.handle.pointer));
      completer.complete(RealmHandle._(realmPtr));
    });
  }

  void cancelOpenRealmAsync(RealmAsyncOpenTaskHandle handle) {
    realmLib.realm_async_open_task_cancel(handle.pointer);
  }

  RealmAsyncOpenTaskProgressNotificationTokenHandle realmAsyncOpenRegisterAsyncOpenProgressNotifier(
      RealmAsyncOpenTaskHandle handle, RealmAsyncOpenProgressNotificationsController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64, Double)>(_syncProgressCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    final tokenPtr = invokeGetPointer(() => realmLib.realm_async_open_task_register_download_progress_notifier(
          handle.pointer,
          realmLib.addresses.realm_dart_sync_progress_callback,
          userdata.cast(),
          realmLib.addresses.realm_dart_userdata_async_free,
        ));
    return RealmAsyncOpenTaskProgressNotificationTokenHandle._(tokenPtr);
  }

  RealmSchema readSchema(Realm realm) {
    return using((Arena arena) {
      return _readSchema(realm, arena);
    });
  }

  RealmSchema _readSchema(Realm realm, Arena arena, {int expectedSize = 10}) {
    final classesPtr = arena<Uint32>(expectedSize);
    final actualCount = arena<Size>();
    invokeGetBool(() => realmLib.realm_get_class_keys(realm.handle.pointer, classesPtr, expectedSize, actualCount));
    if (expectedSize < actualCount.value) {
      arena.free(classesPtr);
      return _readSchema(realm, arena, expectedSize: actualCount.value);
    }

    final schemas = <SchemaObject>[];
    for (var i = 0; i < actualCount.value; i++) {
      final classInfo = arena<realm_class_info>();
      final classKey = classesPtr.elementAt(i).value;
      invokeGetBool(() => realmLib.realm_get_class(realm.handle.pointer, classKey, classInfo));

      final name = classInfo.ref.name.cast<Utf8>().toDartString();
      final baseType = ObjectType.values.firstWhere((element) => element.flags == classInfo.ref.flags,
          orElse: () => throw RealmError('No object type found for flags ${classInfo.ref.flags}'));
      final schema =
          _getSchemaForClassKey(realm, classKey, name, baseType, arena, expectedSize: classInfo.ref.num_properties + classInfo.ref.num_computed_properties);
      schemas.add(schema);
    }

    return RealmSchema(schemas);
  }

  SchemaObject _getSchemaForClassKey(Realm realm, int classKey, String name, ObjectType baseType, Arena arena, {int expectedSize = 10}) {
    final actualCount = arena<Size>();
    final propertiesPtr = arena<realm_property_info>(expectedSize);
    invokeGetBool(() => realmLib.realm_get_class_properties(realm.handle.pointer, classKey, propertiesPtr, expectedSize, actualCount));

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(propertiesPtr);
      return _getSchemaForClassKey(realm, classKey, name, baseType, arena, expectedSize: actualCount.value);
    }

    final result = <SchemaProperty>[];
    for (var i = 0; i < actualCount.value; i++) {
      final property = propertiesPtr.elementAt(i).ref.toSchemaProperty();
      result.add(property);
    }

    late Type type;
    switch (baseType) {
      case ObjectType.realmObject:
        type = RealmObject;
        break;
      case ObjectType.embeddedObject:
        type = EmbeddedObject;
        break;
      case ObjectType.asymmetricObject:
        type = AsymmetricObject;
        break;
      default:
        throw RealmError('$baseType is not supported yet');
    }

    return SchemaObject(baseType, type, name, result);
  }

  void deleteRealmFiles(String path) {
    using((Arena arena) {
      final realm_deleted = arena<Bool>();
      invokeGetBool(() => realmLib.realm_delete_files(path.toCharPtr(arena), realm_deleted), "Error deleting realm at path $path");
    });
  }

  RealmObjectMetadata getObjectMetadata(Realm realm, SchemaObject schema) {
    return using((Arena arena) {
      final found = arena<Bool>();
      final classInfo = arena<realm_class_info_t>();
      invokeGetBool(() => realmLib.realm_find_class(realm.handle.pointer, schema.name.toCharPtr(arena), found, classInfo),
          "Error getting class ${schema.name} from realm at ${realm.config.path}");

      if (!found.value) {
        throwLastError("Class ${schema.name} not found in ${realm.config.path}");
      }

      final primaryKey = classInfo.ref.primary_key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      return RealmObjectMetadata(schema, classInfo.ref.key, _getPropertiesMetadata(realm, classInfo.ref.key, primaryKey, arena));
    });
  }

  Map<String, RealmPropertyMetadata> getPropertiesMetadata(Realm realm, int classKey, String? primaryKeyName) {
    return using((Arena arena) {
      return _getPropertiesMetadata(realm, classKey, primaryKeyName, arena);
    });
  }

  Map<String, RealmPropertyMetadata> _getPropertiesMetadata(Realm realm, int classKey, String? primaryKeyName, Arena arena) {
    final propertyCountPtr = arena<Size>();
    invokeGetBool(() => realmLib.realm_get_property_keys(realm.handle.pointer, classKey, nullptr, 0, propertyCountPtr), "Error getting property count");

    var propertyCount = propertyCountPtr.value;
    final propertiesPtr = arena<realm_property_info_t>(propertyCount);
    invokeGetBool(() => realmLib.realm_get_class_properties(realm.handle.pointer, classKey, propertiesPtr, propertyCount, propertyCountPtr),
        "Error getting class properties.");

    propertyCount = propertyCountPtr.value;
    Map<String, RealmPropertyMetadata> result = <String, RealmPropertyMetadata>{};
    for (var i = 0; i < propertyCount; i++) {
      final property = propertiesPtr.elementAt(i);
      final propertyName = property.ref.name.cast<Utf8>().toRealmDartString()!;
      final objectType = property.ref.link_target.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      final linkOriginProperty = property.ref.link_origin_property_name.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      final isNullable = property.ref.flags & realm_property_flags.RLM_PROPERTY_NULLABLE != 0;
      final isPrimaryKey = propertyName == primaryKeyName;
      final propertyMeta = RealmPropertyMetadata(property.ref.key, objectType, linkOriginProperty, RealmPropertyType.values.elementAt(property.ref.type),
          isNullable, isPrimaryKey, RealmCollectionType.values.elementAt(property.ref.collection_type));
      result[propertyName] = propertyMeta;
    }
    return result;
  }

  (ObjectHandle, int) getEmbeddedParent(EmbeddedObject obj) {
    return using((Arena arena) {
      final parentPtr = arena<Pointer<realm_object>>();
      final classKeyPtr = arena<Uint32>();
      invokeGetBool(() => realmLib.realm_object_get_parent(obj.handle.pointer, parentPtr, classKeyPtr));

      final handle = ObjectHandle._(parentPtr.value, obj.realm.handle);

      return (handle, classKeyPtr.value);
    });
  }

  Object? getProperty(RealmObjectBase object, int propertyKey) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_get_value(object.handle.pointer, propertyKey, realm_value));
      return realm_value.toDartValue(object.realm, () => realmLib.realm_get_list(object.handle.pointer, propertyKey),
          () => realmLib.realm_get_dictionary(object.handle.pointer, propertyKey));
    });
  }

  void setProperty(RealmObjectBase object, int propertyKey, Object? value, bool isDefault) {
    using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      invokeGetBool(() => realmLib.realm_set_value(object.handle.pointer, propertyKey, realm_value.ref, isDefault));
    });
  }

  void objectSetCollection(RealmObjectBase object, int propertyKey, RealmValue value) {
    _createCollection(object.realm, value, () => realmLib.realm_set_list(object.handle.pointer, propertyKey),
        () => realmLib.realm_set_dictionary(object.handle.pointer, propertyKey));
  }

  String objectToString(RealmObjectBase object) {
    return realmLib.realm_object_to_string(object.handle.pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  // For debugging
  // ignore: unused_element
  int get _threadId => realmLib.realm_dart_get_thread_id();

  void deleteRealmObject(RealmObjectBase object) {
    invokeGetBool(() => realmLib.realm_object_delete(object.handle.pointer));
  }

  ResultsHandle queryList(RealmList target, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_list(
              target.handle.pointer,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          target.realm.handle);
      return queryHandle.findAll();
    });
  }

  ResultsHandle querySet(RealmSet target, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_set(
              target.handle.pointer,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          target.realm.handle);
      return queryHandle.findAll();
    });
  }

  ResultsHandle queryMap(ManagedRealmMap target, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }

      final results = mapGetValues(target);
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse_for_results(
              results.pointer,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          target.realm.handle);
      return queryHandle.findAll();
    });
  }

  ResultsHandle resultsFromList(RealmList list) {
    final pointer = invokeGetPointer(() => realmLib.realm_list_to_results(list.handle.pointer));
    return ResultsHandle._(pointer, list.realm.handle);
  }

  ResultsHandle resultsFromSet(RealmSet set) {
    final pointer = invokeGetPointer(() => realmLib.realm_set_to_results(set.handle.pointer));
    return ResultsHandle._(pointer, set.realm.handle);
  }

  Object? resultsGetElementAt(RealmResults results, int index) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_results_get(results.handle.pointer, index, realm_value));
      return realm_value.toDartValue(results.realm, () => realmLib.realm_results_get_list(results.handle.pointer, index),
          () => realmLib.realm_results_get_dictionary(results.handle.pointer, index));
    });
  }

  CollectionChanges getCollectionChanges(RealmCollectionChangesHandle changes) {
    return using((arena) {
      final out_num_deletions = arena<Size>();
      final out_num_insertions = arena<Size>();
      final out_num_modifications = arena<Size>();
      final out_num_moves = arena<Size>();
      final out_collection_cleared = arena<Bool>();
      final out_collection_was_deleted = arena<Bool>();
      realmLib.realm_collection_changes_get_num_changes(
        changes.pointer,
        out_num_deletions,
        out_num_insertions,
        out_num_modifications,
        out_num_moves,
        out_collection_cleared,
        out_collection_was_deleted,
      );

      final deletionsCount = out_num_deletions != nullptr ? out_num_deletions.value : 0;
      final insertionCount = out_num_insertions != nullptr ? out_num_insertions.value : 0;
      final modificationCount = out_num_modifications != nullptr ? out_num_modifications.value : 0;
      var moveCount = out_num_moves != nullptr ? out_num_moves.value : 0;

      final out_deletion_indexes = arena<Size>(deletionsCount);
      final out_insertion_indexes = arena<Size>(insertionCount);
      final out_modification_indexes = arena<Size>(modificationCount);
      final out_modification_indexes_after = arena<Size>(modificationCount);
      final out_moves = arena<realm_collection_move_t>(moveCount);

      realmLib.realm_collection_changes_get_changes(
        changes.pointer,
        out_deletion_indexes,
        deletionsCount,
        out_insertion_indexes,
        insertionCount,
        out_modification_indexes,
        modificationCount,
        out_modification_indexes_after,
        modificationCount,
        out_moves,
        moveCount,
      );

      var elementZero = out_moves.elementAt(0);
      List<Move> moves = List.filled(moveCount, Move(elementZero.ref.from, elementZero.ref.to));
      for (var i = 1; i < moveCount; i++) {
        final movePtr = out_moves.elementAt(i);
        moves[i] = Move(movePtr.ref.from, movePtr.ref.to);
      }

      return CollectionChanges(
        out_deletion_indexes.toIntList(deletionsCount),
        out_insertion_indexes.toIntList(insertionCount),
        out_modification_indexes.toIntList(modificationCount),
        out_modification_indexes_after.toIntList(modificationCount),
        moves,
        out_collection_cleared.value,
        out_collection_was_deleted.value,
      );
    });
  }

  MapChanges getMapChanges(RealmMapChangesHandle changes) {
    return using((arena) {
      final out_num_deletions = arena<Size>();
      final out_num_insertions = arena<Size>();
      final out_num_modifications = arena<Size>();
      final out_collection_was_deleted = arena<Bool>();
      realmLib.realm_dictionary_get_changes(
        changes.pointer,
        out_num_deletions,
        out_num_insertions,
        out_num_modifications,
        out_collection_was_deleted,
      );

      final deletionsCount = out_num_deletions != nullptr ? out_num_deletions.value : 0;
      final insertionCount = out_num_insertions != nullptr ? out_num_insertions.value : 0;
      final modificationCount = out_num_modifications != nullptr ? out_num_modifications.value : 0;

      final out_deletion_indexes = arena<realm_value>(deletionsCount);
      final out_insertion_indexes = arena<realm_value>(insertionCount);
      final out_modification_indexes = arena<realm_value>(modificationCount);
      final out_collection_was_cleared = arena<Bool>();

      realmLib.realm_dictionary_get_changed_keys(
        changes.pointer,
        out_deletion_indexes,
        out_num_deletions,
        out_insertion_indexes,
        out_num_insertions,
        out_modification_indexes,
        out_num_modifications,
        out_collection_was_cleared,
      );

      return MapChanges(out_deletion_indexes.toStringList(deletionsCount), out_insertion_indexes.toStringList(insertionCount),
          out_modification_indexes.toStringList(modificationCount), out_collection_was_cleared.value, out_collection_was_deleted.value);
    });
  }

  _RealmLinkHandle _getObjectAsLink(RealmObjectBase object) {
    final realmLink = realmLib.realm_object_as_link(object.handle.pointer);
    return _RealmLinkHandle._(realmLink);
  }

  ObjectHandle _getObject(Realm realm, int classKey, int objectKey) {
    final pointer = invokeGetPointer(() => realmLib.realm_get_object(realm.handle.pointer, classKey, objectKey));
    return ObjectHandle._(pointer, realm.handle);
  }

  RealmListHandle getListProperty(RealmObjectBase object, int propertyKey) {
    final pointer = invokeGetPointer(() => realmLib.realm_get_list(object.handle.pointer, propertyKey));
    return RealmListHandle._(pointer, object.realm.handle);
  }

  ResultsHandle getBacklinks(RealmObjectBase object, int sourceTableKey, int propertyKey) {
    final pointer = invokeGetPointer(() => realmLib.realm_get_backlinks(object.handle.pointer, sourceTableKey, propertyKey));
    return ResultsHandle._(pointer, object.realm.handle);
  }

  int getListSize(RealmListHandle handle) {
    return using((Arena arena) {
      final size = arena<Size>();
      invokeGetBool(() => realmLib.realm_list_size(handle.pointer, size));
      return size.value;
    });
  }

  Object? listGetElementAt(RealmList list, int index) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_list_get(list.handle.pointer, index, realm_value));
      return realm_value.toDartValue(
          list.realm, () => realmLib.realm_list_get_list(list.handle.pointer, index), () => realmLib.realm_list_get_dictionary(list.handle.pointer, index));
    });
  }

  void listAddElementAt(RealmListHandle handle, int index, Object? value, bool insert) {
    using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      invokeGetBool(() => (insert ? realmLib.realm_list_insert : realmLib.realm_list_set)(handle.pointer, index, realm_value.ref));
    });
  }

  void listAddCollectionAt(RealmListHandle handle, Realm realm, int index, RealmValue value, bool insert) {
    _createCollection(realm, value, () => (insert ? realmLib.realm_list_insert_list : realmLib.realm_list_set_list)(handle.pointer, index),
        () => (insert ? realmLib.realm_list_insert_dictionary : realmLib.realm_list_set_dictionary)(handle.pointer, index));
  }

  ObjectHandle listSetEmbeddedObjectAt(Realm realm, RealmListHandle handle, int index) {
    final ptr = invokeGetPointer(() => realmLib.realm_list_set_embedded(handle.pointer, index));
    return ObjectHandle._(ptr, realm.handle);
  }

  ObjectHandle listInsertEmbeddedObjectAt(Realm realm, RealmListHandle handle, int index) {
    final ptr = invokeGetPointer(() => realmLib.realm_list_insert_embedded(handle.pointer, index));
    return ObjectHandle._(ptr, realm.handle);
  }

  void listRemoveElementAt(RealmListHandle handle, int index) {
    invokeGetBool(() => realmLib.realm_list_erase(handle.pointer, index));
  }

  void listMoveElement(RealmListHandle handle, int from, int to) {
    invokeGetBool(() => realmLib.realm_list_move(handle.pointer, from, to));
  }

  void listDeleteAll(RealmList list) {
    invokeGetBool(() => realmLib.realm_list_remove_all(list.handle.pointer));
  }

  int listFind(RealmList list, Object? value) {
    return using((Arena arena) {
      final out_index = arena<Size>();
      final out_found = arena<Bool>();

      // TODO: how should this behave for collections
      final realm_value = _toRealmValue(value, arena);
      invokeGetBool(
        () => realmLib.realm_list_find(
          list.handle.pointer,
          realm_value,
          out_index,
          out_found,
        ),
      );
      return out_found.value ? out_index.value : -1;
    });
  }

  void listClear(RealmListHandle listHandle) {
    invokeGetBool(() => realmLib.realm_list_clear(listHandle.pointer));
  }

  RealmSetHandle getSetProperty(RealmObjectBase object, int propertyKey) {
    final pointer = invokeGetPointer(() => realmLib.realm_get_set(object.handle.pointer, propertyKey));
    return RealmSetHandle._(pointer, object.realm.handle);
  }

  bool realmSetInsert(RealmSetHandle handle, Object? value) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      final out_index = arena<Size>();
      final out_inserted = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_insert(handle.pointer, realm_value.ref, out_index, out_inserted));
      return out_inserted.value;
    });
  }

  Object? realmSetGetElementAt(RealmSet realmSet, int index) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_set_get(realmSet.handle.pointer, index, realm_value));
      final result = realm_value.toDartValue(
          realmSet.realm, () => throw RealmException('Sets cannot contain collections'), () => throw RealmException('Sets cannot contain collections'));
      return result;
    });
  }

  bool realmSetFind(RealmSet realmSet, Object? value) {
    return using((Arena arena) {
      // TODO: how should this behave for collections
      final realm_value = _toRealmValue(value, arena);
      final out_index = arena<Size>();
      final out_found = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_find(realmSet.handle.pointer, realm_value.ref, out_index, out_found));
      return out_found.value;
    });
  }

  bool realmSetErase(RealmSet realmSet, Object? value) {
    return using((Arena arena) {
      // TODO: do we support sets containing mixed collections
      final realm_value = _toRealmValue(value, arena);
      final out_erased = arena<Bool>();
      invokeGetBool(() => realmLib.realm_set_erase(realmSet.handle.pointer, realm_value.ref, out_erased));
      return out_erased.value;
    });
  }

  void realmSetClear(RealmSetHandle handle) {
    invokeGetBool(() => realmLib.realm_set_clear(handle.pointer));
  }

  int realmSetSize(RealmSet realmSet) {
    return using((Arena arena) {
      final out_size = arena<Size>();
      invokeGetBool(() => realmLib.realm_set_size(realmSet.handle.pointer, out_size));
      return out_size.value;
    });
  }

  bool realmSetIsValid(RealmSet realmSet) {
    return realmLib.realm_set_is_valid(realmSet.handle.pointer);
  }

  void realmSetRemoveAll(RealmSet realmSet) {
    invokeGetBool(() => realmLib.realm_set_remove_all(realmSet.handle.pointer));
  }

  RealmNotificationTokenHandle subscribeSetNotifications(RealmSet realmSet, NotificationsController controller) {
    final pointer = invokeGetPointer(() => realmLib.realm_set_add_notification_callback(
          realmSet.handle.pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
        ));

    return RealmNotificationTokenHandle._(pointer, realmSet.realm.handle);
  }

  int mapGetSize(RealmMapHandle handle) {
    return using((Arena arena) {
      final size = arena<Size>();
      invokeGetBool(() => realmLib.realm_dictionary_size(handle.pointer, size));
      return size.value;
    });
  }

  bool mapRemoveKey(RealmMapHandle handle, String key) {
    return using((Arena arena) {
      final keyValue = _toRealmValue(key, arena);
      final out_erased = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_erase(handle.pointer, keyValue.ref, out_erased));
      return out_erased.value;
    });
  }

  Object? mapGetElement(RealmMap map, String key) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      final key_value = _toRealmValue(key, arena);
      final out_found = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_find(map.handle.pointer, key_value.ref, realm_value, out_found));
      if (out_found.value) {
        return realm_value.toDartValue(map.realm, () => realmLib.realm_dictionary_get_list(map.handle.pointer, key_value.ref),
            () => realmLib.realm_dictionary_get_dictionary(map.handle.pointer, key_value.ref));
      }

      return null;
    });
  }

  bool mapIsValid(RealmMap map) {
    return realmLib.realm_dictionary_is_valid(map.handle.pointer);
  }

  void mapClear(RealmMapHandle mapHandle) {
    invokeGetBool(() => realmLib.realm_dictionary_clear(mapHandle.pointer));
  }

  ResultsHandle mapGetKeys(ManagedRealmMap map) {
    return using((Arena arena) {
      final out_size = arena<Size>();
      final out_keys = arena<Pointer<realm_results>>();
      invokeGetBool(() => realmLib.realm_dictionary_get_keys(map.handle.pointer, out_size, out_keys));
      return ResultsHandle._(out_keys.value, map.realm.handle);
    });
  }

  ResultsHandle mapGetValues(ManagedRealmMap map) {
    final result = invokeGetPointer(() => realmLib.realm_dictionary_to_results(map.handle.pointer));
    return ResultsHandle._(result, map.realm.handle);
  }

  bool mapContainsKey(ManagedRealmMap map, String key) {
    return using((Arena arena) {
      final key_value = _toRealmValue(key, arena);
      final out_found = arena<Bool>();
      invokeGetBool(() => realmLib.realm_dictionary_contains_key(map.handle.pointer, key_value.ref, out_found));
      return out_found.value;
    });
  }

  bool mapContainsValue(ManagedRealmMap map, Object? value) {
    return using((Arena arena) {
      // TODO: how should this behave for collections
      final value_value = _toRealmValue(value, arena);
      final out_index = arena<Size>();
      invokeGetBool(() => realmLib.realm_dictionary_contains_value(map.handle.pointer, value_value.ref, out_index));
      return out_index.value > -1;
    });
  }

  ObjectHandle mapInsertEmbeddedObject(Realm realm, RealmMapHandle handle, String key) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(key, arena);
      final ptr = invokeGetPointer(() => realmLib.realm_dictionary_insert_embedded(handle.pointer, realm_value.ref));
      return ObjectHandle._(ptr, realm.handle);
    });
  }

  void mapInsertValue(RealmMapHandle handle, String key, Object? value) {
    using((Arena arena) {
      final key_value = _toRealmValue(key, arena);
      final value_value = _toRealmValue(value, arena);
      invokeGetBool(() => realmLib.realm_dictionary_insert(handle.pointer, key_value.ref, value_value.ref, nullptr, nullptr));
    });
  }

  void mapInsertCollection(RealmMapHandle handle, Realm realm, String key, RealmValue value) {
    using((Arena arena) {
      final key_value = _toRealmValue(key, arena);
      _createCollection(realm, value, () => realmLib.realm_dictionary_insert_list(handle.pointer, key_value.ref),
          () => realmLib.realm_dictionary_insert_dictionary(handle.pointer, key_value.ref));
    });
  }

  RealmMapHandle getMapProperty(RealmObjectBase object, int propertyKey) {
    final pointer = invokeGetPointer(() => realmLib.realm_get_dictionary(object.handle.pointer, propertyKey));
    return RealmMapHandle._(pointer, object.realm.handle);
  }

  bool _equals<T extends NativeType>(HandleBase<T> first, HandleBase<T> second) {
    return realmLib.realm_equals(first.pointer.cast(), second.pointer.cast());
  }

  bool objectEquals(RealmObjectBase first, RealmObjectBase second) => _equals(first.handle, second.handle);
  bool realmEquals(Realm first, Realm second) => _equals(first.handle, second.handle);
  bool userEquals(User first, User second) => _equals(first.handle, second.handle);

  int objectGetHashCode(RealmObjectBase value) {
    final link = realmCore._getObjectAsLink(value);

    var hashCode = -986587137;
    hashCode = (hashCode * -1521134295) + link.classKey;
    hashCode = (hashCode * -1521134295) + link.targetKey;
    return hashCode;
  }

  bool objectIsValid(RealmObjectBase object) {
    return realmLib.realm_object_is_valid(object.handle.pointer);
  }

  bool listIsValid(RealmList list) {
    return realmLib.realm_list_is_valid(list.handle.pointer);
  }

  static void collection_change_callback(Pointer<Void> userdata, Pointer<realm_collection_changes> data) {
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

      final changesHandle = RealmCollectionChangesHandle._(clonedData.cast());
      controller.onChanges(changesHandle);
    } catch (e) {
      controller.onError(RealmError("Error handling change notifications. Error: $e"));
    }
  }

  static void object_change_callback(Pointer<Void> userdata, Pointer<realm_object_changes> data) {
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

      final changesHandle = RealmObjectChangesHandle._(clonedData.cast());
      controller.onChanges(changesHandle);
    } catch (e) {
      controller.onError(RealmError("Error handling change notifications. Error: $e"));
    }
  }

  static void map_change_callback(Pointer<Void> userdata, Pointer<realm_dictionary_changes> data) {
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

      final changesHandle = RealmMapChangesHandle._(clonedData.cast());
      controller.onChanges(changesHandle);
    } catch (e) {
      controller.onError(RealmError("Error handling change notifications. Error: $e"));
    }
  }

  static void user_change_callback(Object userdata, int data) {
    final controller = userdata as UserNotificationsController;

    controller.onUserChanged();
  }

  static void schema_change_callback(Pointer<Void> userdata, Pointer<realm_schema> data) {
    final Realm realm = userdata.toObject();
    try {
      realm.updateSchema();
    } catch (e) {
      Realm.logger.log(LogLevel.error, 'Failed to update Realm schema: $e');
    }
  }

  RealmNotificationTokenHandle subscribeResultsNotifications(RealmResults results, NotificationsController controller) {
    final pointer = invokeGetPointer(() => realmLib.realm_results_add_notification_callback(
          results.handle.pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
        ));

    return RealmNotificationTokenHandle._(pointer, results.realm.handle);
  }

  RealmNotificationTokenHandle subscribeListNotifications(RealmList list, NotificationsController controller) {
    final pointer = invokeGetPointer(() => realmLib.realm_list_add_notification_callback(
          list.handle.pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
        ));

    return RealmNotificationTokenHandle._(pointer, list.realm.handle);
  }

  RealmNotificationTokenHandle subscribeObjectNotifications(RealmObjectBase object, NotificationsController controller, [List<String>? keyPaths]) {
    return using((Arena arena) {
      final kpNative = buildAndVerifyKeyPath(object, keyPaths);
      final pointer = invokeGetPointer(() => realmLib.realm_object_add_notification_callback(
            object.handle._pointer,
            controller.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
            kpNative,
            Pointer.fromFunction(object_change_callback),
          ));

      return RealmNotificationTokenHandle._(pointer, object.realm.handle);
    });
  }

  Pointer<realm_key_path_array> buildAndVerifyKeyPath(RealmObjectBase object, [List<String>? keyPaths]) {
    return using((Arena arena) {
      if (keyPaths == null) {
        return nullptr;
      }

      final length = keyPaths.length;
      final keypathsNative = arena<Pointer<Char>>(length);
      final classKey = object.realm.metadata.getByName(object.objectSchema.name).classKey;

      for (int i = 0; i < length; i++) {
        keypathsNative[i] = keyPaths[i].toCharPtr(arena);
      }

      return invokeGetPointer(() => realmLib.realm_create_key_path_array(object.realm.handle._pointer, classKey, length, keypathsNative));
    });
  }

  RealmNotificationTokenHandle subscribeMapNotifications(RealmMap map, NotificationsController controller) {
    final pointer = invokeGetPointer(() => realmLib.realm_dictionary_add_notification_callback(
          map.handle.pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          nullptr,
          Pointer.fromFunction(map_change_callback),
        ));

    return RealmNotificationTokenHandle._(pointer, map.realm.handle);
  }

  UserNotificationTokenHandle subscribeUserNotifications(UserNotificationsController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Int32)>(user_change_callback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    final notification_token = realmLib.realm_sync_user_on_state_change_register_callback(
      controller.user.handle.pointer,
      realmLib.addresses.realm_dart_user_change_callback,
      userdata.cast(),
      realmLib.addresses.realm_dart_userdata_async_free,
    );
    return UserNotificationTokenHandle._(notification_token);
  }

  RealmCallbackTokenHandle subscribeForSchemaNotifications(Realm realm) {
    final pointer = invokeGetPointer(() => realmLib.realm_add_schema_changed_callback(realm.handle.pointer, Pointer.fromFunction(schema_change_callback),
        realm.toPersistentHandle(), realmLib.addresses.realm_dart_delete_persistent_handle));

    return RealmCallbackTokenHandle._(pointer, realm.handle);
  }

  bool getObjectChangesIsDeleted(RealmObjectChangesHandle handle) {
    return realmLib.realm_object_changes_is_deleted(handle.pointer);
  }

  List<int> getObjectChangesProperties(RealmObjectChangesHandle handle) {
    return using((arena) {
      final count = realmLib.realm_object_changes_get_num_modified_properties(handle.pointer);

      final out_modified = arena<realm_property_key_t>(count);
      realmLib.realm_object_changes_get_modified_properties(handle.pointer, out_modified, count);

      return out_modified.asTypedList(count).toList();
    });
  }

  AppConfigHandle _createAppConfig(AppConfiguration configuration, RealmHttpTransportHandle httpTransport) {
    return using((arena) {
      final app_id = configuration.appId.toCharPtr(arena);
      final handle = AppConfigHandle._(realmLib.realm_app_config_new(app_id, httpTransport.pointer));

      realmLib.realm_app_config_set_platform_version(handle.pointer, Platform.operatingSystemVersion.toCharPtr(arena));

      realmLib.realm_app_config_set_sdk(handle.pointer, 'Dart'.toCharPtr(arena));
      realmLib.realm_app_config_set_sdk_version(handle.pointer, libraryVersion.toCharPtr(arena));

      final deviceName = getDeviceName();
      realmLib.realm_app_config_set_device_name(handle.pointer, deviceName.toCharPtr(arena));

      final deviceVersion = getDeviceVersion();
      realmLib.realm_app_config_set_device_version(handle.pointer, deviceVersion.toCharPtr(arena));

      realmLib.realm_app_config_set_framework_name(handle.pointer, (isFlutterPlatform ? 'Flutter' : 'Dart VM').toCharPtr(arena));
      realmLib.realm_app_config_set_framework_version(handle.pointer, Platform.version.toCharPtr(arena));

      realmLib.realm_app_config_set_base_url(handle.pointer, configuration.baseUrl.toString().toCharPtr(arena));

      realmLib.realm_app_config_set_default_request_timeout(handle.pointer, configuration.defaultRequestTimeout.inMilliseconds);

      realmLib.realm_app_config_set_bundle_id(handle.pointer, getBundleId().toCharPtr(arena));

      _realmLib.realm_app_config_set_base_file_path(handle._pointer, configuration.baseFilePath.path.toCharPtr(arena));
      _realmLib.realm_app_config_set_metadata_mode(handle._pointer, configuration.metadataPersistenceMode.index);
      _realmLib.realm_app_config_set_default_request_timeout(handle._pointer, configuration.defaultRequestTimeout.inMilliseconds);
      if (configuration.metadataEncryptionKey != null && configuration.metadataPersistenceMode == MetadataPersistenceMode.encrypted) {
        _realmLib.realm_app_config_set_metadata_encryption_key(handle._pointer, configuration.metadataEncryptionKey!.toUint8Ptr(arena));
      }

      return handle;
    });
  }

  RealmAppCredentialsHandle createAppCredentialsAnonymous(bool reuseCredentials) {
    return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_anonymous(reuseCredentials));
  }

  RealmAppCredentialsHandle createAppCredentialsEmailPassword(String email, String password) {
    return using((arena) {
      final emailPtr = email.toCharPtr(arena);
      final passwordPtr = password.toRealmString(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_email_password(emailPtr, passwordPtr.ref));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsJwt(String token) {
    return using((arena) {
      final tokenPtr = token.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_jwt(tokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsApple(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_apple(idTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsFacebook(String accessToken) {
    return using((arena) {
      final accessTokenPtr = accessToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_facebook(accessTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsGoogleIdToken(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_google_id_token(idTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsGoogleAuthCode(String authCode) {
    return using((arena) {
      final authCodePtr = authCode.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_google_auth_code(authCodePtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsFunction(String payload) {
    return using((arena) {
      final payloadPtr = payload.toCharPtr(arena);
      final credentialsPtr = invokeGetPointer(() => realmLib.realm_app_credentials_new_function(payloadPtr));
      return RealmAppCredentialsHandle._(credentialsPtr);
    });
  }

  RealmAppCredentialsHandle createAppCredentialsApiKey(String key) {
    return using((arena) {
      final keyPtr = key.toCharPtr(arena);
      return RealmAppCredentialsHandle._(realmLib.realm_app_credentials_new_api_key(keyPtr));
    });
  }

  void logMessage(LogCategory category, LogLevel logLevel, String message) {
    return using((arena) {
      realmLib.realm_dart_log(logLevel.index, category.toString().toCharPtr(arena), message.toCharPtr(arena));
    });
  }

  String getDefaultBaseUrl() {
    return realmLib.realm_app_get_default_base_url().cast<Utf8>().toRealmDartString()!;
  }

  AppHandle? getApp(String id, String? baseUrl) {
    return using((arena) {
      final out_app = arena<Pointer<realm_app>>();
      invokeGetBool(() => realmLib.realm_app_get_cached(id.toCharPtr(arena), baseUrl == null ? nullptr : baseUrl.toCharPtr(arena), out_app));
      return out_app.value == nullptr ? null : AppHandle._(out_app.value);
    });
  }

  void clearCachedApps() {
    realmLib.realm_clear_cached_apps();
  }

  AuthProviderType userGetCredentialsProviderType(Credentials credentials) {
    final provider = realmLib.realm_auth_credentials_get_provider(credentials.handle.pointer);
    return AuthProviderTypeInternal.getByValue(provider);
  }

  String sessionGetPath(Session session) {
    return realmLib.realm_sync_session_get_file_path(session.handle.pointer).cast<Utf8>().toRealmDartString()!;
  }

  SessionState sessionGetState(Session session) {
    final value = realmLib.realm_sync_session_get_state(session.handle.pointer);
    return _convertCoreSessionState(value);
  }

  ConnectionState sessionGetConnectionState(Session session) {
    final value = realmLib.realm_sync_session_get_connection_state(session.handle.pointer);
    return ConnectionState.values[value];
  }

  UserHandle sessionGetUser(Session session) {
    return UserHandle._(realmLib.realm_sync_session_get_user(session.handle.pointer));
  }

  SessionState _convertCoreSessionState(int value) {
    switch (value) {
      case 0: // RLM_SYNC_SESSION_STATE_ACTIVE
      case 1: // RLM_SYNC_SESSION_STATE_DYING
        return SessionState.active;
      case 2: // RLM_SYNC_SESSION_STATE_INACTIVE
      case 3: // RLM_SYNC_SESSION_STATE_WAITING_FOR_ACCESS_TOKEN
      case 4: // RLM_SYNC_SESSION_STATE_PAUSED
        return SessionState.inactive;
      default:
        throw Exception("Unexpected SessionState: $value");
    }
  }

  void sessionPause(Session session) {
    realmLib.realm_sync_session_pause(session.handle.pointer);
  }

  void sessionResume(Session session) {
    realmLib.realm_sync_session_resume(session.handle.pointer);
  }

  RealmSyncSessionConnectionStateNotificationTokenHandle sessionRegisterProgressNotifier(
      Session session, ProgressDirection direction, ProgressMode mode, SessionProgressNotificationsController controller) {
    final isStreaming = mode == ProgressMode.reportIndefinitely;
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64, Double)>(_syncProgressCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    final tokenPtr = invokeGetPointer(() => realmLib.realm_sync_session_register_progress_notifier(
        session.handle.pointer,
        realmLib.addresses.realm_dart_sync_progress_callback,
        direction.index,
        isStreaming,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free));
    return RealmSyncSessionConnectionStateNotificationTokenHandle._(tokenPtr);
  }

  static void _syncProgressCallback(Object userdata, int transferred, int transferable, double estimate) {
    final controller = userdata as ProgressNotificationsController;

    controller.onProgress(transferred, transferable);
  }

  RealmSyncSessionConnectionStateNotificationTokenHandle sessionRegisterConnectionStateNotifier(Session session, SessionConnectionStateController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Int32, Int32)>(_onConnectionStateChange);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    final notification_token = realmLib.realm_sync_session_register_connection_state_change_callback(
      session.handle.pointer,
      realmLib.addresses.realm_dart_sync_connection_state_changed_callback,
      userdata.cast(),
      realmLib.addresses.realm_dart_userdata_async_free,
    );
    return RealmSyncSessionConnectionStateNotificationTokenHandle._(notification_token);
  }

  static void _onConnectionStateChange(Object userdata, int oldState, int newState) {
    final controller = userdata as SessionConnectionStateController;

    controller.onConnectionStateChange(ConnectionState.values[oldState], ConnectionState.values[newState]);
  }

  Future<void> sessionWaitForUpload(Session session, [CancellationToken? cancellationToken]) {
    final completer = CancellableCompleter<void>(cancellationToken);
    if (!completer.isCancelled) {
      final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_error_t>)>(_sessionWaitCompletionCallback);
      final userdata = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_sync_session_wait_for_upload_completion(session.handle.pointer, realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
          userdata.cast(), realmLib.addresses.realm_dart_userdata_async_free);
    }
    return completer.future;
  }

  Future<void> sessionWaitForDownload(Session session, [CancellationToken? cancellationToken]) {
    final completer = CancellableCompleter<void>(cancellationToken);
    if (!completer.isCancelled) {
      final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_error_t>)>(_sessionWaitCompletionCallback);
      final userdata = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_sync_session_wait_for_download_completion(session.handle.pointer, realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
          userdata.cast(), realmLib.addresses.realm_dart_userdata_async_free);
    }
    return completer.future;
  }

  static void _sessionWaitCompletionCallback(Object userdata, Pointer<realm_error_t> errorCode) {
    final completer = userdata as CancellableCompleter<void>;
    if (completer.isCancelled) {
      return;
    }
    if (errorCode != nullptr) {
      // Throw RealmException instead of RealmError to be recoverable by the user.
      completer.completeError(RealmException(errorCode.toDart().toString()));
    } else {
      completer.complete();
    }
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

  ResultsHandle resolveResults(RealmResults realmResults, Realm frozenRealm) => realmResults.handle.resolveIn(frozenRealm.handle);

  ObjectHandle? resolveObject(RealmObjectBase object, Realm frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_object>>();
      invokeGetBool(() => realmLib.realm_object_resolve_in(object.handle.pointer, frozenRealm.handle.pointer, resultPtr));
      return resultPtr == nullptr ? null : ObjectHandle._(resultPtr.value, frozenRealm.handle);
    });
  }

  RealmListHandle? resolveList(ManagedRealmList list, Realm frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_list>>();
      invokeGetBool(() => realmLib.realm_list_resolve_in(list.handle.pointer, frozenRealm.handle.pointer, resultPtr));
      return resultPtr == nullptr ? null : RealmListHandle._(resultPtr.value, frozenRealm.handle);
    });
  }

  RealmSetHandle? resolveSet(ManagedRealmSet set, Realm frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_set>>();
      invokeGetBool(() => realmLib.realm_set_resolve_in(set.handle.pointer, frozenRealm.handle.pointer, resultPtr));
      return resultPtr == nullptr ? null : RealmSetHandle._(resultPtr.value, frozenRealm.handle);
    });
  }

  RealmMapHandle? resolveMap(ManagedRealmMap map, Realm frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_dictionary>>();
      invokeGetBool(() => realmLib.realm_dictionary_resolve_in(map.handle.pointer, frozenRealm.handle.pointer, resultPtr));
      return resultPtr == nullptr ? null : RealmMapHandle._(resultPtr.value, frozenRealm.handle);
    });
  }

  Future<ApiKey> createApiKey(User user, String name) {
    return using((Arena arena) {
      final namePtr = name.toCharPtr(arena);
      final completer = Completer<ApiKey>();
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_create_apikey(
            user.app.handle.pointer,
            user.handle.pointer,
            namePtr,
            realmLib.addresses.realm_dart_apikey_callback,
            _createAsyncApikeyCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<ApiKey> fetchApiKey(User user, ObjectId id) {
    return using((Arena arena) {
      final completer = Completer<ApiKey>();
      final native_id = id.toNative(arena);
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_fetch_apikey(
            user.app.handle.pointer,
            user.handle.pointer,
            native_id.ref,
            realmLib.addresses.realm_dart_apikey_callback,
            _createAsyncApikeyCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<List<ApiKey>> fetchAllApiKeys(User user) {
    return using((Arena arena) {
      final completer = Completer<List<ApiKey>>();
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_fetch_apikeys(
            user.app.handle.pointer,
            user.handle.pointer,
            realmLib.addresses.realm_dart_apikey_list_callback,
            _createAsyncApikeyListCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<void> deleteApiKey(User user, ObjectId id) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final native_id = id.toNative(arena);
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_delete_apikey(
            user.app.handle.pointer,
            user.handle.pointer,
            native_id.ref,
            realmLib.addresses.realm_dart_void_completion_callback,
            _createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<void> disableApiKey(User user, ObjectId objectId) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final native_id = objectId.toNative(arena);

      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_disable_apikey(
            user.app.handle.pointer,
            user.handle.pointer,
            native_id.ref,
            realmLib.addresses.realm_dart_void_completion_callback,
            _createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<void> enableApiKey(User user, ObjectId objectId) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final native_id = objectId.toNative(arena);
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_enable_apikey(
            user.app.handle.pointer,
            user.handle.pointer,
            native_id.ref,
            realmLib.addresses.realm_dart_void_completion_callback,
            _createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  static void _call_app_function_callback(Pointer<Void> userdata, Pointer<Char> response, Pointer<realm_app_error> error) {
    final Completer<String> completer = userdata.toObject();

    if (error != nullptr) {
      completer.completeWithAppError(error);
      return;
    }

    final stringResponse = response.cast<Utf8>().toRealmDartString()!;
    completer.complete(stringResponse);
  }

  Pointer<Void> _createAsyncFunctionCallbackUserdata(Completer<String> completer) {
    final callback = Pointer.fromFunction<
        Void Function(
          Pointer<Void>,
          Pointer<Char>,
          Pointer<realm_app_error>,
        )>(_call_app_function_callback);

    final userdata = realmLib.realm_dart_userdata_async_new(
      completer,
      callback.cast(),
      scheduler.handle.pointer,
    );

    return userdata.cast();
  }

  Future<String> callAppFunction(App app, User user, String functionName, String? argsAsJSON) {
    return using((arena) {
      final completer = Completer<String>();
      invokeGetBool(() => realmLib.realm_app_call_function(
            app.handle.pointer,
            user.handle.pointer,
            functionName.toCharPtr(arena),
            argsAsJSON?.toCharPtr(arena) ?? nullptr,
            nullptr,
            realmLib.addresses.realm_dart_return_string_callback,
            _createAsyncFunctionCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));
      return completer.future;
    });
  }

  void _createCollection(Realm realm, RealmValue value, Pointer<realm_list> Function() createList, Pointer<realm_dictionary> Function() createMap) {
    CollectionHandleBase? collectionHandle;
    try {
      switch (value.collectionType) {
        case RealmCollectionType.list:
          final listPointer = invokeGetPointer(createList);
          final listHandle = RealmListHandle._(listPointer, realm.handle);
          collectionHandle = listHandle;

          final list = realm.createList<RealmValue>(listHandle, null);

          // Necessary since Core will not clear the collection if the value was already a collection
          list.clear();

          for (final item in value.value as List<RealmValue>) {
            list.add(item);
          }
        case RealmCollectionType.map:
          final mapPointer = invokeGetPointer(createMap);
          final mapHandle = RealmMapHandle._(mapPointer, realm.handle);
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

  void setLogLevel(LogLevel level, {required LogCategory category}) {
    using((arena) {
      realmLib.realm_set_log_level_category(category.toString().toCharPtr(arena), level.index);
    });
  }

  List<String> getAllCategoryNames() {
    return using((arena) {
      final count = realmLib.realm_get_category_names(0, nullptr);
      final out_values = arena<Pointer<Char>>(count);
      realmLib.realm_get_category_names(count, out_values);
      return [for (int i = 0; i < count; i++) out_values[i].cast<Utf8>().toDartString()];
    });
  }
}

class SchedulerHandle extends HandleBase<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer, 24);
}

class _RealmLinkHandle {
  final int targetKey;
  final int classKey;
  _RealmLinkHandle._(realm_link_t link)
      : targetKey = link.target,
        classKey = link.target_table;
}

class RealmListHandle extends CollectionHandleBase<realm_list> {
  RealmListHandle._(Pointer<realm_list> pointer, RealmHandle root) : super(root, pointer, 88);
}

class RealmSetHandle extends RootedHandleBase<realm_set> {
  RealmSetHandle._(Pointer<realm_set> pointer, RealmHandle root) : super(root, pointer, 96);
}

class RealmMapHandle extends CollectionHandleBase<realm_dictionary> {
  RealmMapHandle._(Pointer<realm_dictionary> pointer, RealmHandle root) : super(root, pointer, 96); // TODO: check size
}

class RealmCallbackTokenHandle extends RootedHandleBase<realm_callback_token> {
  RealmCallbackTokenHandle._(Pointer<realm_callback_token> pointer, RealmHandle root) : super(root, pointer, 32);
}

class RealmNotificationTokenHandle extends RootedHandleBase<realm_notification_token> {
  RealmNotificationTokenHandle._(Pointer<realm_notification_token> pointer, RealmHandle root) : super(root, pointer, 32);
}

class UserNotificationTokenHandle extends HandleBase<realm_app_user_subscription_token> {
  UserNotificationTokenHandle._(Pointer<realm_app_user_subscription_token> pointer) : super(pointer, 32);
}

class RealmSyncSessionConnectionStateNotificationTokenHandle extends HandleBase<realm_sync_session_connection_state_notification_token> {
  RealmSyncSessionConnectionStateNotificationTokenHandle._(Pointer<realm_sync_session_connection_state_notification_token> pointer) : super(pointer, 32);
}

class RealmCollectionChangesHandle extends HandleBase<realm_collection_changes> {
  RealmCollectionChangesHandle._(Pointer<realm_collection_changes> pointer) : super(pointer, 256);
}

class RealmMapChangesHandle extends HandleBase<realm_dictionary_changes> {
  RealmMapChangesHandle._(Pointer<realm_dictionary_changes> pointer) : super(pointer, 256);
}

class RealmObjectChangesHandle extends HandleBase<realm_object_changes> {
  RealmObjectChangesHandle._(Pointer<realm_object_changes> pointer) : super(pointer, 256);
}

class RealmAppCredentialsHandle extends HandleBase<realm_app_credentials> {
  RealmAppCredentialsHandle._(Pointer<realm_app_credentials> pointer) : super(pointer, 16);
}

class RealmHttpTransportHandle extends HandleBase<realm_http_transport> {
  RealmHttpTransportHandle._(Pointer<realm_http_transport> pointer) : super(pointer, 24);
}

class AppConfigHandle extends HandleBase<realm_app_config> {
  AppConfigHandle._(Pointer<realm_app_config> pointer) : super(pointer, 8);
}

class SyncClientConfigHandle extends HandleBase<realm_sync_client_config> {
  SyncClientConfigHandle._(Pointer<realm_sync_client_config> pointer) : super(pointer, 8);
}

class RealmAsyncOpenTaskHandle extends HandleBase<realm_async_open_task_t> {
  RealmAsyncOpenTaskHandle._(Pointer<realm_async_open_task_t> pointer) : super(pointer, 32);
}

class RealmAsyncOpenTaskProgressNotificationTokenHandle extends HandleBase<realm_async_open_task_progress_notification_token_t> {
  RealmAsyncOpenTaskProgressNotificationTokenHandle._(Pointer<realm_async_open_task_progress_notification_token_t> pointer) : super(pointer, 40);
}

class SessionHandle extends RootedHandleBase<realm_sync_session_t> {
  @override
  bool get shouldRoot => true;

  SessionHandle._(Pointer<realm_sync_session_t> pointer, RealmHandle root) : super(root, pointer, 24);
}

extension on List<int> {
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

extension _StringEx on String {
  Pointer<Char> toCharPtr(Allocator allocator) {
    final units = utf8.encode(this);
    return units.toCharPtr(allocator).cast();
  }

  Pointer<realm_string_t> toRealmString(Allocator allocator) {
    final realm_string = allocator<realm_string_t>();
    final units = utf8.encode(this);
    realm_string.ref.data = units.toCharPtr(allocator).cast();
    realm_string.ref.size = units.length;
    return realm_string;
  }
}

Pointer<realm_value_t> _toRealmValue(Object? value, Allocator allocator) {
  final realm_value = allocator<realm_value_t>();
  if (value is RealmValue && value.type.isCollection) {
    throw RealmError(
        "Don't use _toPrimitiveValue if the value may contain collections. Use storeValue instead. This is a bug in the Realm Flutter SDK and should be reported to https://github.com/realm/realm-dart/issues/new");
  }
  _intoRealmValue(value, realm_value.ref, allocator);
  return realm_value;
}

const int _microsecondsPerSecond = 1000 * 1000;
const int _nanosecondsPerMicrosecond = 1000;

void _intoRealmQueryArg(Object? value, Pointer<realm_query_arg_t> realm_query_arg, Allocator allocator) {
  if (value is Iterable) {
    realm_query_arg.ref.nb_args = value.length;
    realm_query_arg.ref.is_list = true;
    realm_query_arg.ref.arg = allocator<realm_value>(value.length);
    int i = 0;
    for (var item in value) {
      _intoRealmValue(item, realm_query_arg.ref.arg[i], allocator);
      i++;
    }
  } else {
    realm_query_arg.ref.arg = allocator<realm_value_t>();
    realm_query_arg.ref.nb_args = 1;
    realm_query_arg.ref.is_list = false;
    _intoRealmValueHack(value, realm_query_arg.ref.arg.ref, allocator);
  }
}

void _intoRealmValueHack(Object? value, realm_value realm_value, Allocator allocator) {
  if (value is GeoShape) {
    _intoRealmValue(value.toString(), realm_value, allocator);
  } else if (value is RealmValueType) {
    _intoRealmValue(value.toQueryArgString(), realm_value, allocator);
  } else {
    _intoRealmValue(value, realm_value, allocator);
  }
}

void _intoRealmValue(Object? value, realm_value realm_value, Allocator allocator) {
  if (value == null) {
    realm_value.type = realm_value_type.RLM_TYPE_NULL;
  } else if (value is RealmObjectBase) {
    // when converting a RealmObjectBase to realm_value.link we assume the object is managed
    final link = realmCore._getObjectAsLink(value);
    realm_value.values.link.target = link.targetKey;
    realm_value.values.link.target_table = link.classKey;
    realm_value.type = realm_value_type.RLM_TYPE_LINK;
  } else if (value is int) {
    realm_value.values.integer = value;
    realm_value.type = realm_value_type.RLM_TYPE_INT;
  } else if (value is bool) {
    realm_value.values.boolean = value;
    realm_value.type = realm_value_type.RLM_TYPE_BOOL;
  } else if (value is String) {
    String string = value;
    final units = utf8.encode(string);
    final result = allocator<Uint8>(units.length);
    final Uint8List nativeString = result.asTypedList(units.length);
    nativeString.setAll(0, units);
    realm_value.values.string.data = result.cast();
    realm_value.values.string.size = units.length;
    realm_value.type = realm_value_type.RLM_TYPE_STRING;
  } else if (value is double) {
    realm_value.values.dnum = value;
    realm_value.type = realm_value_type.RLM_TYPE_DOUBLE;
  } else if (value is ObjectId) {
    final bytes = value.bytes;
    for (var i = 0; i < 12; i++) {
      realm_value.values.object_id.bytes[i] = bytes[i];
    }
    realm_value.type = realm_value_type.RLM_TYPE_OBJECT_ID;
  } else if (value is Uuid) {
    final bytes = value.bytes.asUint8List();
    for (var i = 0; i < 16; i++) {
      realm_value.values.uuid.bytes[i] = bytes[i];
    }
    realm_value.type = realm_value_type.RLM_TYPE_UUID;
  } else if (value is DateTime) {
    final microseconds = value.toUtc().microsecondsSinceEpoch;
    final seconds = microseconds ~/ _microsecondsPerSecond;
    int nanoseconds = _nanosecondsPerMicrosecond * (microseconds % _microsecondsPerSecond);
    if (microseconds < 0 && nanoseconds != 0) {
      nanoseconds = nanoseconds - _nanosecondsPerMicrosecond * _microsecondsPerSecond;
    }
    realm_value.values.timestamp.seconds = seconds;
    realm_value.values.timestamp.nanoseconds = nanoseconds;
    realm_value.type = realm_value_type.RLM_TYPE_TIMESTAMP;
  } else if (value is Decimal128) {
    realm_value.values.decimal128 = value.value;
    realm_value.type = realm_value_type.RLM_TYPE_DECIMAL128;
  } else if (value is Uint8List) {
    realm_value.type = realm_value_type.RLM_TYPE_BINARY;
    realm_value.values.binary.size = value.length;
    realm_value.values.binary.data = allocator<Uint8>(value.length);
    realm_value.values.binary.data.asTypedList(value.length).setAll(0, value);
  } else if (value is RealmValue) {
    if (value.type == List<RealmValue>) {
      realm_value.type = realm_value_type.RLM_TYPE_LIST;
    } else if (value.type == Map<String, RealmValue>) {
      realm_value.type = realm_value_type.RLM_TYPE_DICTIONARY;
    } else {
      return _intoRealmValue(value.value, realm_value, allocator);
    }
  } else {
    throw RealmException("Property type ${value.runtimeType} not supported");
  }
}

extension on Pointer<realm_value_t> {
  Object? toDartValue(Realm realm, Pointer<realm_list_t> Function()? getList, Pointer<realm_dictionary_t> Function()? getMap) {
    if (this == nullptr) {
      throw RealmException("Can not convert nullptr realm_value to Dart value");
    }
    return ref.toDartValue(realm: realm, getList: getList, getMap: getMap);
  }
}

extension on realm_value_t {
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
        if (realm.metadata.getByClassKeyIfExists(classKey) == null) return null; // temprorary workaround to avoid crash on assertion
        return realmCore._getObject(realm, classKey, objectKey);
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

        final listPointer = invokeGetPointer(() => getList());
        final listHandle = RealmListHandle._(listPointer, realm.handle);
        return realm.createList<RealmValue>(listHandle, null);
      case realm_value_type.RLM_TYPE_DICTIONARY:
        if (getMap == null || realm == null) {
          throw RealmException('toDartValue called with a list argument but without a list getter');
        }

        final mapPointer = invokeGetPointer(() => getMap());
        final mapHandle = RealmMapHandle._(mapPointer, realm.handle);
        return realm.createMap<RealmValue>(mapHandle, null);
      default:
        throw RealmException("realm_value_type $type not supported");
    }
  }
}

extension on Array<Uint8> {
  List<int> toList(int count) {
    final result = <int>[];
    for (var i = 0; i < count; i++) {
      result.add(this[i]);
    }
    return result;
  }
}

extension on Pointer<Size> {
  List<int> toIntList(int count) {
    List<int> result = List.filled(count, elementAt(0).value);
    for (var i = 1; i < count; i++) {
      result[i] = elementAt(i).value;
    }
    return result;
  }
}

extension on Pointer<realm_value> {
  List<String> toStringList(int count) {
    final result = List.filled(count, '');
    for (var i = 0; i < count; i++) {
      final str_value = elementAt(i).ref.values.string;
      result[i] = str_value.data.cast<Utf8>().toRealmDartString(length: str_value.size)!;
    }

    return result;
  }
}

extension on Pointer<Void> {
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

extension on Pointer<Utf8> {
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

extension on realm_sync_error {
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

extension on Pointer<realm_sync_error_user_info> {
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

extension on Pointer<realm_sync_error_compensating_write_info> {
  List<CompensatingWriteInfo>? toList(int length) {
    if (this == nullptr || length == 0) {
      return null;
    }
    List<CompensatingWriteInfo> compensatingWrites = [];
    for (int i = 0; i < length; i++) {
      final compensatingWrite = this[i];
      final reason = compensatingWrite.reason.cast<Utf8>().toDartString();
      final object_name = compensatingWrite.object_name.cast<Utf8>().toDartString();
      final primary_key = compensatingWrite.primary_key.toPrimitiveValue();
      compensatingWrites.add(CompensatingWriteInfo(object_name, reason, RealmValue.from(primary_key)));
    }
    return compensatingWrites;
  }
}

extension on Pointer<realm_error_t> {
  SyncError toDart() {
    final message = ref.message.cast<Utf8>().toDartString();
    final details = SyncErrorDetails(message, ref.error, ref.user_code_error.toUserCodeError());
    return SyncErrorInternal.createSyncError(details);
  }
}

extension on Object {
  Pointer<Void> toPersistentHandle() {
    return realmLib.realm_dart_object_to_persistent_handle(this);
  }
}

extension on List<UserState> {
  UserState fromIndex(int index) {
    if (!UserState.values.any((value) => value.index == index)) {
      throw RealmError("Unknown user state $index");
    }

    return UserState.values[index];
  }
}

extension on realm_property_info {
  SchemaProperty toSchemaProperty() {
    final linkTarget = link_target == nullptr ? null : link_target.cast<Utf8>().toDartString();
    return SchemaProperty(name.cast<Utf8>().toDartString(), RealmPropertyType.values[type],
        optional: flags & realm_property_flags.RLM_PROPERTY_NULLABLE == realm_property_flags.RLM_PROPERTY_NULLABLE,
        primaryKey: flags & realm_property_flags.RLM_PROPERTY_PRIMARY_KEY == realm_property_flags.RLM_PROPERTY_PRIMARY_KEY,
        linkTarget: linkTarget == null || linkTarget.isEmpty ? null : linkTarget,
        collectionType: RealmCollectionType.values[collection_type]);
  }
}

extension<T> on Completer<T> {
  void completeWithAppError(Pointer<realm_app_error> error) {
    final message = error.ref.message.cast<Utf8>().toRealmDartString()!;
    final linkToLogs = error.ref.link_to_server_logs.cast<Utf8>().toRealmDartString();
    completeError(AppInternal.createException(message, linkToLogs, error.ref.http_status_code));
  }
}

enum _CustomErrorCode {
  noError(0),
  unknownHttp(998),
  unknown(999),
  timeout(1000);

  final int code;
  const _CustomErrorCode(this.code);
}

enum _HttpMethod {
  get,
  post,
  patch,
  put,
  delete,
}

extension on realm_timestamp_t {
  DateTime toDart() {
    return DateTime.fromMicrosecondsSinceEpoch(seconds * 1000000 + nanoseconds ~/ 1000, isUtc: true);
  }
}

extension on realm_string_t {
  String? toDart() => data.cast<Utf8>().toRealmDartString();
}

extension on ObjectId {
  Pointer<realm_object_id> toNative(Allocator allocator) {
    final result = allocator<realm_object_id>();
    for (var i = 0; i < 12; i++) {
      result.ref.bytes[i] = bytes[i];
    }
    return result;
  }
}

extension on realm_object_id {
  ObjectId toDart() {
    final buffer = Uint8List(12);
    for (int i = 0; i < 12; ++i) {
      buffer[i] = bytes[i];
    }
    return ObjectId.fromBytes(buffer);
  }
}

extension on realm_app_user_apikey {
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

extension on RealmValueType {
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
