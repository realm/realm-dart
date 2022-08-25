////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../app.dart';
import '../collections.dart';
import '../configuration.dart';
import '../credentials.dart';
import '../init.dart';
import '../list.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../results.dart';
import '../scheduler.dart';
import '../subscription.dart';
import '../user.dart';
import '../session.dart';
import 'realm_bindings.dart';

late RealmLibrary _realmLib;

final _RealmCore realmCore = _RealmCore();

class _RealmCore {
  // From realm.h. Currently not exported from the shared library
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  // ignore: unused_field
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  // ignore: unused_field
  static const int RLM_INVALID_OBJECT_KEY = -1;

  static Object noopUserdata = Object();

  // Hide the RealmCore class and make it a singleton
  static _RealmCore? _instance;
  late final int isolateKey;

  _RealmCore._() {
    final lib = initRealm();
    _realmLib = RealmLibrary(lib);
  }

  factory _RealmCore() {
    return _instance ??= _RealmCore._();
  }

  String get libraryVersion => '0.4.0+beta';

  LastError? getLastError(Allocator allocator) {
    final error = allocator<realm_error_t>();
    final success = _realmLib.realm_get_last_error(error);
    if (!success) {
      return null;
    }

    final message = error.ref.message.cast<Utf8>().toRealmDartString();

    return LastError(error.ref.error, message);
  }

  void throwLastError([String? errorMessage]) {
    using((Arena arena) {
      final lastError = getLastError(arena);
      throw RealmException('${errorMessage != null ? errorMessage + ". " : ""}${lastError ?? ""}');
    });
  }

  SchemaHandle _createSchema(Iterable<SchemaObject> schema) {
    return using((Arena arena) {
      final classCount = schema.length;

      final schemaClasses = arena<realm_class_info_t>(classCount);
      final schemaProperties = arena<Pointer<realm_property_info_t>>(classCount);

      for (var i = 0; i < classCount; i++) {
        final schemaObject = schema.elementAt(i);
        final classInfo = schemaClasses.elementAt(i).ref;

        classInfo.name = schemaObject.name.toCharPtr(arena);
        classInfo.primary_key = "".toCharPtr(arena);
        classInfo.num_properties = schemaObject.properties.length;
        classInfo.num_computed_properties = 0;
        classInfo.key = RLM_INVALID_CLASS_KEY;
        classInfo.flags = realm_class_flags.RLM_CLASS_NORMAL;

        final propertiesCount = schemaObject.properties.length;
        final properties = arena<realm_property_info_t>(propertiesCount);

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject.properties[j];
          final propInfo = properties.elementAt(j).ref;
          propInfo.name = schemaProperty.name.toCharPtr(arena);
          //TODO: Assign the correct public name value https://github.com/realm/realm-dart/issues/697
          propInfo.public_name = "".toCharPtr(arena);
          propInfo.link_target = (schemaProperty.linkTarget ?? "").toCharPtr(arena);
          propInfo.link_origin_property_name = "".toCharPtr(arena);
          propInfo.type = schemaProperty.propertyType.index;
          propInfo.collection_type = schemaProperty.collectionType.index;
          propInfo.flags = realm_property_flags.RLM_PROPERTY_NORMAL;

          if (schemaProperty.optional) {
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_NULLABLE;
          }

          if (schemaProperty.primaryKey) {
            classInfo.primary_key = schemaProperty.name.toCharPtr(arena);
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_PRIMARY_KEY;
          }
        }

        schemaProperties[i] = properties;
        schemaProperties.elementAt(i).value = properties;
      }

      final schemaPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_schema_new(schemaClasses, classCount, schemaProperties));
      return SchemaHandle._(schemaPtr);
    });
  }

  ConfigHandle _createConfig(Configuration config) {
    return using((Arena arena) {
      final configPtr = _realmLib.realm_config_new();
      final configHandle = ConfigHandle._(configPtr);

      if (config.schemaObjects.isNotEmpty) {
        final schemaHandle = _createSchema(config.schemaObjects);
        _realmLib.realm_config_set_schema(configHandle._pointer, schemaHandle._pointer);
      }

      _realmLib.realm_config_set_path(configHandle._pointer, config.path.toCharPtr(arena));
      _realmLib.realm_config_set_scheduler(configHandle._pointer, scheduler.handle._pointer);

      if (config.fifoFilesFallbackPath != null) {
        _realmLib.realm_config_set_fifo_path(configHandle._pointer, config.fifoFilesFallbackPath!.toCharPtr(arena));
      }

      // Setting schema version only makes sense for local realms, but core insists it is always set,
      // hence we set it to 0 in those cases.
      _realmLib.realm_config_set_schema_version(configHandle._pointer, config is LocalConfiguration ? config.schemaVersion : 0);

      if (config is LocalConfiguration) {
        if (config.initialDataCallback != null) {
          _realmLib.realm_config_set_data_initialization_function(
            configHandle._pointer,
            Pointer.fromFunction(initial_data_callback, false),
            config.toWeakHandle(),
            nullptr,
          );
        }
        if (config.isReadOnly) {
          _realmLib.realm_config_set_schema_mode(configHandle._pointer, realm_schema_mode.RLM_SCHEMA_MODE_IMMUTABLE);
        }
        if (config.disableFormatUpgrade) {
          _realmLib.realm_config_set_disable_format_upgrade(configHandle._pointer, config.disableFormatUpgrade);
        }
        if (config.shouldCompactCallback != null) {
          _realmLib.realm_config_set_should_compact_on_launch_function(
            configHandle._pointer,
            Pointer.fromFunction(should_compact_callback, false),
            config.toWeakHandle(),
            nullptr,
          );
        }
      } else if (config is InMemoryConfiguration) {
        _realmLib.realm_config_set_in_memory(configHandle._pointer, true);
      } else if (config is FlexibleSyncConfiguration) {
        final syncConfigPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_flx_sync_config_new(config.user.handle._pointer));
        try {
          _realmLib.realm_sync_config_set_session_stop_policy(syncConfigPtr, config.sessionStopPolicy.index);

          final errorHandlerCallback =
              Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_session_t>, realm_sync_error_t)>(_syncErrorHandlerCallback);
          final errorHandlerUserdata = _realmLib.realm_dart_userdata_async_new(config, errorHandlerCallback.cast(), scheduler.handle._pointer);
          _realmLib.realm_sync_config_set_error_handler(syncConfigPtr, _realmLib.addresses.realm_dart_sync_error_handler_callback, errorHandlerUserdata.cast(),
              _realmLib.addresses.realm_dart_userdata_async_free);

          _realmLib.realm_config_set_sync_config(configPtr, syncConfigPtr);
        } finally {
          _realmLib.realm_release(syncConfigPtr.cast());
        }
      } else if (config is DisconnectedSyncConfiguration) {
        _realmLib.realm_config_set_force_sync_history(configPtr, true);
      }

      return configHandle;
    });
  }

  String getPathForConfig(FlexibleSyncConfiguration config) {
    final syncConfigPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_flx_sync_config_new(config.user.handle._pointer));
    try {
      final path = _realmLib.realm_app_sync_client_get_default_file_path_for_realm(syncConfigPtr, nullptr);
      return path.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
    } finally {
      _realmLib.realm_release(syncConfigPtr.cast());
    }
  }

  ObjectId subscriptionId(Subscription subscription) {
    final id = _realmLib.realm_sync_subscription_id(subscription.handle._pointer);
    return id.toDart();
  }

  String? subscriptionName(Subscription subscription) {
    final name = _realmLib.realm_sync_subscription_name(subscription.handle._pointer);
    return name.toDart();
  }

  String subscriptionObjectClassName(Subscription subscription) {
    final objectClassName = _realmLib.realm_sync_subscription_object_class_name(subscription.handle._pointer);
    return objectClassName.toDart()!;
  }

  String subscriptionQueryString(Subscription subscription) {
    final queryString = _realmLib.realm_sync_subscription_query_string(subscription.handle._pointer);
    return queryString.toDart()!;
  }

  DateTime subscriptionCreatedAt(Subscription subscription) {
    final createdAt = _realmLib.realm_sync_subscription_created_at(subscription.handle._pointer);
    return createdAt.toDart();
  }

  DateTime subscriptionUpdatedAt(Subscription subscription) {
    final updatedAt = _realmLib.realm_sync_subscription_updated_at(subscription.handle._pointer);
    return updatedAt.toDart();
  }

  SubscriptionSetHandle getSubscriptions(Realm realm) {
    return SubscriptionSetHandle._(_realmLib.invokeGetPointer(() => _realmLib.realm_sync_get_active_subscription_set(realm.handle._pointer)));
  }

  void refreshSubscriptions(SubscriptionSet subscriptions) {
    _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_refresh(subscriptions.handle._pointer));
  }

  int getSubscriptionSetSize(SubscriptionSet subscriptions) {
    return _realmLib.realm_sync_subscription_set_size(subscriptions.handle._pointer);
  }

  Exception? getSubscriptionSetError(SubscriptionSet subscriptions) {
    final error = _realmLib.realm_sync_subscription_set_error_str(subscriptions.handle._pointer);
    final message = error.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
    return message == null ? null : RealmException(message);
  }

  SubscriptionHandle subscriptionAt(SubscriptionSet subscriptions, int index) {
    return SubscriptionHandle._(_realmLib.invokeGetPointer(() => _realmLib.realm_sync_subscription_at(
          subscriptions.handle._pointer,
          index,
        )));
  }

  SubscriptionHandle? findSubscriptionByName(SubscriptionSet subscriptions, String name) {
    return using((arena) {
      final result = _realmLib.realm_sync_find_subscription_by_name(
        subscriptions.handle._pointer,
        name.toCharPtr(arena),
      );
      return result == nullptr ? null : SubscriptionHandle._(result);
    });
  }

  SubscriptionHandle? findSubscriptionByResults(SubscriptionSet subscriptions, RealmResults results) {
    final result = _realmLib.realm_sync_find_subscription_by_results(
      subscriptions.handle._pointer,
      results.handle._pointer,
    );
    return result == nullptr ? null : SubscriptionHandle._(result);
  }

  static void _stateChangeCallback(Object userdata, int state) {
    final completer = userdata as Completer<SubscriptionSetState>;

    completer.complete(SubscriptionSetState.values[state]);
  }

  Future<SubscriptionSetState> waitForSubscriptionSetStateChange(SubscriptionSet subscriptions, SubscriptionSetState notifyWhen) {
    final completer = Completer<SubscriptionSetState>();
    final callback = Pointer.fromFunction<Void Function(Handle, Int32)>(_stateChangeCallback);
    final userdata = _realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle._pointer);
    _realmLib.realm_sync_on_subscription_set_state_change_async(subscriptions.handle._pointer, notifyWhen.index,
        _realmLib.addresses.realm_dart_sync_on_subscription_state_changed_callback, userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
    return completer.future;
  }

  int subscriptionSetGetVersion(SubscriptionSet subscriptions) {
    return _realmLib.realm_sync_subscription_set_version(subscriptions.handle._pointer);
  }

  SubscriptionSetState subscriptionSetGetState(SubscriptionSet subscriptions) {
    return SubscriptionSetState.values[_realmLib.realm_sync_subscription_set_state(subscriptions.handle._pointer)];
  }

  MutableSubscriptionSetHandle subscriptionSetMakeMutable(SubscriptionSet subscriptions) {
    return MutableSubscriptionSetHandle._(_realmLib.invokeGetPointer(() => _realmLib.realm_sync_make_subscription_set_mutable(subscriptions.handle._pointer)));
  }

  SubscriptionSetHandle subscriptionSetCommit(MutableSubscriptionSet subscriptions) {
    return SubscriptionSetHandle._(_realmLib.invokeGetPointer(() => _realmLib.realm_sync_subscription_set_commit(subscriptions.handle._mutablePointer)));
  }

  SubscriptionHandle insertOrAssignSubscription(MutableSubscriptionSet subscriptions, RealmResults results, String? name, bool update) {
    if (!update) {
      if (name != null && findSubscriptionByName(subscriptions, name) != null) {
        throw RealmException('Duplicate subscription with name: $name');
      }
    }
    return using((arena) {
      final out_index = arena<Size>();
      final out_inserted = arena<Bool>();
      _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_insert_or_assign_results(
            subscriptions.handle._mutablePointer,
            results.handle._pointer,
            name?.toCharPtr(arena) ?? nullptr,
            out_index,
            out_inserted,
          ));
      return subscriptionAt(subscriptions, out_index.value);
    });
  }

  bool eraseSubscriptionById(MutableSubscriptionSet subscriptions, Subscription subscription) {
    return using((arena) {
      final out_found = arena<Bool>();
      _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_erase_by_id(
            subscriptions.handle._mutablePointer,
            subscription.id.toNative(arena),
            out_found,
          ));
      return out_found.value;
    });
  }

  bool eraseSubscriptionByName(MutableSubscriptionSet subscriptions, String name) {
    return using((arena) {
      final out_found = arena<Bool>();
      _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_erase_by_name(
            subscriptions.handle._mutablePointer,
            name.toCharPtr(arena),
            out_found,
          ));
      return out_found.value;
    });
  }

  bool eraseSubscriptionByResults(MutableSubscriptionSet subscriptions, RealmResults results) {
    return using((arena) {
      final out_found = arena<Bool>();
      _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_erase_by_results(
            subscriptions.handle._mutablePointer,
            results.handle._pointer,
            out_found,
          ));
      return out_found.value;
    });
  }

  void clearSubscriptionSet(MutableSubscriptionSet subscriptions) {
    _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_clear(subscriptions.handle._mutablePointer));
  }

  void refreshSubscriptionSet(SubscriptionSet subscriptions) {
    _realmLib.invokeGetBool(() => _realmLib.realm_sync_subscription_set_refresh(subscriptions.handle._pointer));
  }

  static bool initial_data_callback(Pointer<Void> userdata, Pointer<shared_realm> realmHandle) {
    try {
      final LocalConfiguration? config = userdata.toObject();
      if (config == null) {
        return false;
      }
      final realm = RealmInternal.getUnowned(config, RealmHandle._unowned(realmHandle));
      config.initialDataCallback!(realm);
      return true;
    } catch (ex) {
      // TODO: Propagate error to Core in initial_data_callback https://github.com/realm/realm-dart/issues/698
      // Core issue: https://github.com/realm/realm-core/issues/5366
    }

    return false;
  }

  static bool should_compact_callback(Pointer<Void> userdata, int totalSize, int usedSize) {
    final LocalConfiguration? config = userdata.toObject();
    if (config == null) {
      return false;
    }

    return config.shouldCompactCallback!(totalSize, usedSize);
  }

  static void _syncErrorHandlerCallback(Object userdata, Pointer<realm_sync_session> session, realm_sync_error error) {
    final syncConfig = userdata as FlexibleSyncConfiguration;

    final syncError = error.toSyncError();

    if (syncError is SyncClientResetError) {
      syncConfig.syncClientResetErrorHandler.callback(syncError);
      return;
    }

    syncConfig.syncErrorHandler(syncError);
  }

  void raiseError(Session session, SyncErrorCategory category, int errorCode, bool isFatal) {
    using((arena) {
      final message = "Simulated session error".toCharPtr(arena);
      _realmLib.realm_sync_session_handle_error_for_testing(session.handle._pointer, errorCode, category.index, message, isFatal);
    });
  }

  SchedulerHandle createScheduler(int isolateId, int sendPort) {
    final schedulerPtr = _realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invokeScheduler(SchedulerHandle schedulerHandle) {
    _realmLib.realm_scheduler_perform_work(schedulerHandle._pointer);
  }

  RealmHandle openRealm(Configuration config) {
    final configHandle = _createConfig(config);
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_open(configHandle._pointer), "Error opening realm at path ${config.path}");
    return RealmHandle._(realmPtr);
  }

  RealmSchema readSchema(Realm realm) {
    return using((Arena arena) {
      return _readSchema(realm, arena);
    });
  }

  RealmSchema _readSchema(Realm realm, Arena arena, {int expectedSize = 10}) {
    final classesPtr = arena<Uint32>(expectedSize);
    final actualCount = arena<Size>();
    _realmLib.invokeGetBool(() => _realmLib.realm_get_class_keys(realm.handle._pointer, classesPtr, expectedSize, actualCount));
    if (expectedSize < actualCount.value) {
      arena.free(classesPtr);
      return _readSchema(realm, arena, expectedSize: actualCount.value);
    }

    final schemas = <SchemaObject>[];
    for (var i = 0; i < actualCount.value; i++) {
      final classInfo = arena<realm_class_info>();
      final classKey = classesPtr.elementAt(i).value;
      _realmLib.invokeGetBool(() => _realmLib.realm_get_class(realm.handle._pointer, classKey, classInfo));

      final name = classInfo.ref.name.cast<Utf8>().toDartString();
      final schema = _getSchemaForClassKey(realm, classKey, name, arena, expectedSize: classInfo.ref.num_properties + classInfo.ref.num_computed_properties);
      schemas.add(schema);
    }

    return RealmSchema(schemas);
  }

  SchemaObject _getSchemaForClassKey(Realm realm, int classKey, String name, Arena arena, {int expectedSize = 10}) {
    final actualCount = arena<Size>();
    final propertiesPtr = arena<realm_property_info>(expectedSize);
    _realmLib.invokeGetBool(() => _realmLib.realm_get_class_properties(realm.handle._pointer, classKey, propertiesPtr, expectedSize, actualCount));

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(propertiesPtr);
      return _getSchemaForClassKey(realm, classKey, name, arena, expectedSize: actualCount.value);
    }

    final result = <SchemaProperty>[];
    for (var i = 0; i < actualCount.value; i++) {
      final property = propertiesPtr.elementAt(i).ref.toSchemaProperty();
      result.add(property);
    }

    return SchemaObject(RealmObject, name, result);
  }

  void deleteRealmFiles(String path) {
    using((Arena arena) {
      final realm_deleted = arena<Bool>();
      _realmLib.invokeGetBool(() => _realmLib.realm_delete_files(path.toCharPtr(arena), realm_deleted), "Error deleting realm at path $path");
    });
  }

  String getFilesPath() {
    return _realmLib.realm_dart_get_files_path().cast<Utf8>().toRealmDartString()!;
  }

  void closeRealm(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_close(realm.handle._pointer), "Realm close failed");
  }

  bool isRealmClosed(Realm realm) {
    return _realmLib.realm_is_closed(realm.handle._pointer);
  }

  void beginWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_begin_write(realm.handle._pointer), "Could not begin write");
  }

  void commitWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_commit(realm.handle._pointer), "Could not commit write");
  }

  bool getIsWritable(Realm realm) {
    return _realmLib.realm_is_writable(realm.handle._pointer);
  }

  void rollbackWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_rollback(realm.handle._pointer), "Could not rollback write");
  }

  void realmRefresh(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_refresh(realm.handle._pointer), "Could not refresh");
  }

  RealmObjectMetadata getObjectMedata(Realm realm, String className, Type classType) {
    return using((Arena arena) {
      final found = arena<Bool>();
      final classInfo = arena<realm_class_info_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_find_class(realm.handle._pointer, className.toCharPtr(arena), found, classInfo),
          "Error getting class $className from realm at ${realm.config.path}");

      if (!found.value) {
        throwLastError("Class $className not found in ${realm.config.path}");
      }

      final primaryKey = classInfo.ref.primary_key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      return RealmObjectMetadata(className, classType, primaryKey, classInfo.ref.key, _getPropertyMetadata(realm, classInfo.ref.key));
    });
  }

  Map<String, RealmPropertyMetadata> _getPropertyMetadata(Realm realm, int classKey) {
    return using((Arena arena) {
      final propertyCountPtr = arena<Size>();
      _realmLib.invokeGetBool(
          () => _realmLib.realm_get_property_keys(realm.handle._pointer, classKey, nullptr, 0, propertyCountPtr), "Error getting property count");

      var propertyCount = propertyCountPtr.value;
      final propertiesPtr = arena<realm_property_info_t>(propertyCount);
      _realmLib.invokeGetBool(() => _realmLib.realm_get_class_properties(realm.handle._pointer, classKey, propertiesPtr, propertyCount, propertyCountPtr),
          "Error getting class properties.");

      propertyCount = propertyCountPtr.value;
      Map<String, RealmPropertyMetadata> result = <String, RealmPropertyMetadata>{};
      for (var i = 0; i < propertyCount; i++) {
        final property = propertiesPtr.elementAt(i);
        final propertyName = property.ref.name.cast<Utf8>().toRealmDartString()!;
        final objectType = property.ref.link_target.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
        final isNullable = property.ref.flags & realm_property_flags.RLM_PROPERTY_NULLABLE != 0;
        final propertyMeta = RealmPropertyMetadata(property.ref.key, objectType, RealmPropertyType.values.elementAt(property.ref.type), isNullable,
            RealmCollectionType.values.elementAt(property.ref.collection_type));
        result[propertyName] = propertyMeta;
      }
      return result;
    });
  }

  RealmObjectHandle createRealmObject(Realm realm, int classKey) {
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_object_create(realm.handle._pointer, classKey));
    return RealmObjectHandle._(realmPtr);
  }

  RealmObjectHandle getOrCreateRealmObjectWithPrimaryKey(Realm realm, int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(primaryKey, arena);
      final didCreate = arena<Bool>();
      final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_object_get_or_create_with_primary_key(
            realm.handle._pointer,
            classKey,
            realm_value.ref,
            didCreate,
          ));
      return RealmObjectHandle._(realmPtr);
    });
  }

  RealmObjectHandle createRealmObjectWithPrimaryKey(Realm realm, int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(primaryKey, arena);
      final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_object_create_with_primary_key(realm.handle._pointer, classKey, realm_value.ref));
      return RealmObjectHandle._(realmPtr);
    });
  }

  Object? getProperty(RealmObject object, int propertyKey) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_get_value(object.handle._pointer, propertyKey, realm_value));
      return realm_value.toDartValue(object.realm);
    });
  }

  void setProperty(RealmObject object, int propertyKey, Object? value, bool isDefault) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      _realmLib.invokeGetBool(() => _realmLib.realm_set_value(object.handle._pointer, propertyKey, realm_value.ref, isDefault));
    });
  }

  String objectToString(RealmObject object) {
    return _realmLib.realm_object_to_string(object.handle._pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  // For debugging
  // ignore: unused_element
  int get _threadId => _realmLib.realm_dart_get_thread_id();

  RealmObjectHandle? find(Realm realm, int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(primaryKey, arena);
      final pointer = _realmLib.realm_object_find_with_primary_key(realm.handle._pointer, classKey, realm_value.ref, nullptr);
      if (pointer == nullptr) {
        return null;
      }

      return RealmObjectHandle._(pointer);
    });
  }

  void deleteRealmObject(RealmObject object) {
    _realmLib.invokeGetBool(() => _realmLib.realm_object_delete(object.handle._pointer));
  }

  RealmResultsHandle findAll(Realm realm, int classKey) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_object_find_all(realm.handle._pointer, classKey));
    return RealmResultsHandle._(pointer);
  }

  RealmResultsHandle queryClass(Realm realm, int classKey, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse(
          realm.handle._pointer,
          classKey,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
      ));
      return _queryFindAll(queryHandle);
    });
  }

  RealmResultsHandle queryResults(RealmResults target, String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse_for_results(
          target.handle._pointer,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
      ));
      return _queryFindAll(queryHandle);
    });
  }

  RealmResultsHandle _queryFindAll(RealmQueryHandle queryHandle) {
    final resultsPointer = _realmLib.invokeGetPointer(() => _realmLib.realm_query_find_all(queryHandle._pointer));
    return RealmResultsHandle._(resultsPointer);
  }

  RealmResultsHandle queryList(RealmList target, String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse_for_list(
          target.handle._pointer,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
      ));
      return _queryFindAll(queryHandle);
    });
  }

  RealmObjectHandle getObjectAt(RealmResults results, int index) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_get_object(results.handle._pointer, index));
    return RealmObjectHandle._(pointer);
  }

  int getResultsCount(RealmResults results) {
    return using((Arena arena) {
      final countPtr = arena<Size>();
      _realmLib.invokeGetBool(() => _realmLib.realm_results_count(results.handle._pointer, countPtr));
      return countPtr.value;
    });
  }

  CollectionChanges getCollectionChanges(RealmCollectionChangesHandle changes) {
    return using((arena) {
      final out_num_deletions = arena<Size>();
      final out_num_insertions = arena<Size>();
      final out_num_modifications = arena<Size>();
      final out_num_moves = arena<Size>();
      _realmLib.realm_collection_changes_get_num_changes(
        changes._pointer,
        out_num_deletions,
        out_num_insertions,
        out_num_modifications,
        out_num_moves,
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

      _realmLib.realm_collection_changes_get_changes(
        changes._pointer,
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

      return CollectionChanges(out_deletion_indexes.toIntList(deletionsCount), out_insertion_indexes.toIntList(insertionCount),
          out_modification_indexes.toIntList(modificationCount), out_modification_indexes_after.toIntList(modificationCount), moves);
    });
  }

  RealmLinkHandle _getObjectAsLink(RealmObject object) {
    final realmLink = _realmLib.realm_object_as_link(object.handle._pointer);
    return RealmLinkHandle._(realmLink);
  }

  RealmObjectHandle _getObject(Realm realm, int classKey, int objectKey) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_get_object(realm.handle._pointer, classKey, objectKey));
    return RealmObjectHandle._(pointer);
  }

  RealmListHandle getListProperty(RealmObject object, int propertyKey) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_get_list(object.handle._pointer, propertyKey));
    return RealmListHandle._(pointer);
  }

  int getListSize(RealmListHandle handle) {
    return using((Arena arena) {
      final size = arena<Size>();
      _realmLib.invokeGetBool(() => _realmLib.realm_list_size(handle._pointer, size));
      return size.value;
    });
  }

  Object? listGetElementAt(RealmList list, int index) {
    return using((Arena arena) {
      final realm_value = arena<realm_value_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_list_get(list.handle._pointer, index, realm_value));
      return realm_value.toDartValue(list.realm);
    });
  }

  void listSetElementAt(RealmListHandle handle, int index, Object? value) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      _realmLib.invokeGetBool(() => _realmLib.realm_list_set(handle._pointer, index, realm_value.ref));
    });
  }

  void listInsertElementAt(RealmListHandle handle, int index, Object? value) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(value, arena);
      _realmLib.invokeGetBool(() => _realmLib.realm_list_insert(handle._pointer, index, realm_value.ref));
    });
  }

  void listDeleteAll(RealmList list) {
    _realmLib.invokeGetBool(() => _realmLib.realm_list_remove_all(list.handle._pointer));
  }

  void resultsDeleteAll(RealmResults results) {
    _realmLib.invokeGetBool(() => _realmLib.realm_results_delete_all(results.handle._pointer));
  }

  void listClear(RealmListHandle listHandle) {
    _realmLib.invokeGetBool(() => _realmLib.realm_list_clear(listHandle._pointer));
  }

  bool _equals<T extends NativeType>(HandleBase<T> first, HandleBase<T> second) {
    return _realmLib.realm_equals(first._pointer.cast(), second._pointer.cast());
  }

  bool objectEquals(RealmObject first, RealmObject second) => _equals(first.handle, second.handle);
  bool realmEquals(Realm first, Realm second) => _equals(first.handle, second.handle);
  bool userEquals(User first, User second) => _equals(first.handle, second.handle);
  bool subscriptionEquals(Subscription first, Subscription second) => _equals(first.handle, second.handle);

  RealmResultsHandle resultsSnapshot(RealmResults results) {
    final resultsPointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_snapshot(results.handle._pointer));
    return RealmResultsHandle._(resultsPointer);
  }

  bool objectIsValid(RealmObject object) {
    return _realmLib.realm_object_is_valid(object.handle._pointer);
  }

  bool listIsValid(RealmList list) {
    return _realmLib.realm_list_is_valid(list.handle._pointer);
  }

  static void collection_change_callback(Pointer<Void> userdata, Pointer<realm_collection_changes> data) {
    NotificationsController? controller = userdata.toObject();
    if (controller == null) {
      return;
    }

    if (data == nullptr) {
      controller.onError(RealmError("Invalid notifications data received"));
      return;
    }

    try {
      final clonedData = _realmLib.realm_clone(data.cast());
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
    NotificationsController? controller = userdata.toObject();
    if (controller == null) {
      return;
    }

    if (data == nullptr) {
      controller.onError(RealmError("Invalid notifications data received"));
      return;
    }

    try {
      final clonedData = _realmLib.realm_clone(data.cast());
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

  RealmNotificationTokenHandle subscribeResultsNotifications(RealmResults results, NotificationsController controller) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_add_notification_callback(
          results.handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
          nullptr,
        ));

    return RealmNotificationTokenHandle._(pointer);
  }

  RealmNotificationTokenHandle subscribeListNotifications(RealmList list, NotificationsController controller) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_list_add_notification_callback(
          list.handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
          nullptr,
        ));

    return RealmNotificationTokenHandle._(pointer);
  }

  RealmNotificationTokenHandle subscribeObjectNotifications(RealmObject object, NotificationsController controller) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_object_add_notification_callback(
          object.handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(object_change_callback),
          nullptr,
        ));

    return RealmNotificationTokenHandle._(pointer);
  }

  bool getObjectChangesIsDeleted(RealmObjectChangesHandle handle) {
    return _realmLib.realm_object_changes_is_deleted(handle._pointer);
  }

  List<int> getObjectChangesProperties(RealmObjectChangesHandle handle) {
    return using((arena) {
      final count = _realmLib.realm_object_changes_get_num_modified_properties(handle._pointer);

      final out_modified = arena<realm_property_key_t>(count);
      _realmLib.realm_object_changes_get_modified_properties(handle._pointer, out_modified, count);

      return out_modified.asTypedList(count).toList();
    });
  }

  AppConfigHandle _createAppConfig(AppConfiguration configuration, RealmHttpTransportHandle httpTransport) {
    return using((arena) {
      final app_id = configuration.appId.toCharPtr(arena);
      final handle = AppConfigHandle._(_realmLib.realm_app_config_new(app_id, httpTransport._pointer));

      _realmLib.realm_app_config_set_base_url(handle._pointer, configuration.baseUrl.toString().toCharPtr(arena));

      _realmLib.realm_app_config_set_default_request_timeout(handle._pointer, configuration.defaultRequestTimeout.inMilliseconds);

      if (configuration.localAppName != null) {
        _realmLib.realm_app_config_set_local_app_name(handle._pointer, configuration.localAppName!.toCharPtr(arena));
      }

      if (configuration.localAppVersion != null) {
        _realmLib.realm_app_config_set_local_app_version(handle._pointer, configuration.localAppVersion!.toCharPtr(arena));
      }

      _realmLib.realm_app_config_set_platform(handle._pointer, Platform.operatingSystem.toCharPtr(arena));
      _realmLib.realm_app_config_set_platform_version(handle._pointer, Platform.operatingSystemVersion.toCharPtr(arena));

      _realmLib.realm_app_config_set_sdk_version(handle._pointer, libraryVersion.toCharPtr(arena));

      return handle;
    });
  }

  RealmAppCredentialsHandle createAppCredentialsAnonymous(bool reuseCredentials) {
    return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_anonymous(reuseCredentials));
  }

  RealmAppCredentialsHandle createAppCredentialsEmailPassword(String email, String password) {
    return using((arena) {
      final emailPtr = email.toCharPtr(arena);
      final passwordPtr = password.toRealmString(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_email_password(emailPtr, passwordPtr.ref));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsJwt(String token) {
    return using((arena) {
      final tokenPtr = token.toCharPtr(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_jwt(tokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsApple(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_apple(idTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsFacebook(String accessToken) {
    return using((arena) {
      final accessTokenPtr = accessToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_facebook(accessTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsGoogleIdToken(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_google_id_token(idTokenPtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsGoogleAuthCode(String authCode) {
    return using((arena) {
      final authCodePtr = authCode.toCharPtr(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_google_auth_code(authCodePtr));
    });
  }

  RealmAppCredentialsHandle createAppCredentialsFunction(String payload) {
    return using((arena) {
      final payloadPtr = payload.toCharPtr(arena);
      final credentialsPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_app_credentials_new_function(payloadPtr));
      return RealmAppCredentialsHandle._(credentialsPtr);
    });
  }

  RealmHttpTransportHandle _createHttpTransport(HttpClient httpClient) {
    final requestCallback = Pointer.fromFunction<Void Function(Handle, realm_http_request, Pointer<Void>)>(_request_callback);
    final requestCallbackUserdata = _realmLib.realm_dart_userdata_async_new(httpClient, requestCallback.cast(), scheduler.handle._pointer);
    return RealmHttpTransportHandle._(_realmLib.realm_http_transport_new(
      _realmLib.addresses.realm_dart_http_request_callback,
      requestCallbackUserdata.cast(),
      _realmLib.addresses.realm_dart_userdata_async_free,
    ));
  }

  static void _request_callback(Object userData, realm_http_request request, Pointer<Void> request_context) {
    //
    // The request struct only survives until end-of-call, even though
    // we explicitly call realm_http_transport_complete_request to
    // mark request as completed later.
    //
    // Therefor we need to copy everything out of request before returning.
    // We cannot clone request on the native side with realm_clone,
    // since realm_http_request does not inherit from WrapC.

    final client = userData as HttpClient;

    client.connectionTimeout = Duration(milliseconds: request.timeout_ms);

    final url = Uri.parse(request.url.cast<Utf8>().toRealmDartString()!);

    final body = request.body.cast<Utf8>().toRealmDartString(length: request.body_size)!;

    final headers = <String, String>{};
    for (int i = 0; i < request.num_headers; ++i) {
      final header = request.headers[i];
      final name = header.name.cast<Utf8>().toRealmDartString()!;
      final value = header.value.cast<Utf8>().toRealmDartString()!;
      headers[name] = value;
    }

    _request_callback_async(client, request.method, url, body, headers, request_context);
    // The request struct dies here!
  }

  static void _request_callback_async(
    HttpClient client,
    int requestMethod,
    Uri url,
    String body,
    Map<String, String> headers,
    Pointer<Void> request_context,
  ) async {
    await using((arena) async {
      final response_pointer = arena<realm_http_response>();
      final responseRef = response_pointer.ref;
      try {
        // Build request
        late HttpClientRequest request;

        // this throws if requestMethod is unknown _HttpMethod
        final method = _HttpMethod.values[requestMethod];

        switch (method) {
          case _HttpMethod.delete:
            request = await client.deleteUrl(url);
            break;
          case _HttpMethod.put:
            request = await client.putUrl(url);
            break;
          case _HttpMethod.patch:
            request = await client.patchUrl(url);
            break;
          case _HttpMethod.post:
            request = await client.postUrl(url);
            break;
          case _HttpMethod.get:
            request = await client.getUrl(url);
            break;
        }

        for (final header in headers.entries) {
          request.headers.add(header.key, header.value);
        }

        request.add(utf8.encode(body));

        // Do the call..
        final response = await request.close();
        final responseBody = await response.fold<List<int>>([], (acc, l) => acc..addAll(l)); // gather response

        // Report back to core
        responseRef.status_code = response.statusCode;
        responseRef.body = responseBody.toCharPtr(arena);
        responseRef.body_size = responseBody.length;

        int headerCnt = 0;
        response.headers.forEach((name, values) {
          headerCnt += values.length;
        });

        responseRef.headers = arena<realm_http_header>(headerCnt);
        responseRef.num_headers = headerCnt;

        int index = 0;
        response.headers.forEach((name, values) {
          for (final value in values) {
            final headerRef = responseRef.headers.elementAt(index).ref;
            headerRef.name = name.toCharPtr(arena);
            headerRef.value = value.toCharPtr(arena);
            index++;
          }
        });

        responseRef.custom_status_code = _CustomErrorCode.noError.code;
      } on SocketException catch (_) {
        responseRef.custom_status_code = _CustomErrorCode.timeout.code;
      } on HttpException catch (_) {
        responseRef.custom_status_code = _CustomErrorCode.unknownHttp.code;
      } catch (_) {
        responseRef.custom_status_code = _CustomErrorCode.unknown.code;
      } finally {
        _realmLib.realm_http_transport_complete_request(request_context, response_pointer);
      }
    });
  }

  static void _logCallback(Object userdata, int levelAsInt, Pointer<Int8> message) {
    final logger = Realm.logger;
    final level = LevelExt.fromInt(levelAsInt);

    // Don't do expensive utf8 to utf16 conversion unless needed.
    if (logger.isLoggable(level)) {
      logger.log(level, message.cast<Utf8>().toDartString());
    }
  }

  SyncClientConfigHandle _createSyncClientConfig(AppConfiguration configuration) {
    return using((arena) {
      final handle = SyncClientConfigHandle._(_realmLib.realm_sync_client_config_new());

      _realmLib.realm_sync_client_config_set_base_file_path(handle._pointer, configuration.baseFilePath.path.toCharPtr(arena));
      _realmLib.realm_sync_client_config_set_metadata_mode(handle._pointer, configuration.metadataPersistenceMode.index);

      _realmLib.realm_sync_client_config_set_log_level(handle._pointer, Realm.logger.level.toInt());

      final logCallback = Pointer.fromFunction<Void Function(Handle, Int32, Pointer<Int8>)>(_logCallback);
      final logCallbackUserdata = _realmLib.realm_dart_userdata_async_new(noopUserdata, logCallback.cast(), scheduler.handle._pointer);
      _realmLib.realm_sync_client_config_set_log_callback(handle._pointer, _realmLib.addresses.realm_dart_sync_client_log_callback, logCallbackUserdata.cast(),
          _realmLib.addresses.realm_dart_userdata_async_free);

      _realmLib.realm_sync_client_config_set_connect_timeout(handle._pointer, configuration.maxConnectionTimeout.inMilliseconds);
      if (configuration.metadataEncryptionKey != null && configuration.metadataPersistenceMode == MetadataPersistenceMode.encrypted) {
        _realmLib.realm_sync_client_config_set_metadata_encryption_key(handle._pointer, configuration.metadataEncryptionKey!.toUint8Ptr(arena));
      }

      return handle;
    });
  }

  AppHandle createApp(AppConfiguration configuration) {
    final httpTransportHandle = _createHttpTransport(configuration.httpClient);
    final appConfigHandle = _createAppConfig(configuration, httpTransportHandle);
    final syncClientConfigHandle = _createSyncClientConfig(configuration);
    final realmAppPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_app_create(appConfigHandle._pointer, syncClientConfigHandle._pointer));
    return AppHandle._(realmAppPtr);
  }

  String appGetId(App app) {
    return _realmLib.realm_app_get_app_id(app.handle._pointer).cast<Utf8>().toRealmDartString()!;
  }

  static void _app_user_completion_callback(Pointer<Void> userdata, Pointer<realm_user> user, Pointer<realm_app_error> error) {
    final Completer<UserHandle>? completer = userdata.toObject(isPersistent: true);
    if (completer == null) {
      return;
    }

    if (error != nullptr) {
      final message = error.ref.message.cast<Utf8>().toRealmDartString()!;
      completer.completeError(RealmException(message));
      return;
    }

    var userClone = _realmLib.realm_clone(user.cast());
    if (userClone == nullptr) {
      completer.completeError(RealmException("Error while cloning user object."));
      return;
    }

    completer.complete(UserHandle._(userClone.cast()));
  }

  Future<UserHandle> logIn(App app, Credentials credentials) {
    final completer = Completer<UserHandle>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_log_in_with_credentials(
              app.handle._pointer,
              credentials.handle._pointer,
              Pointer.fromFunction(_app_user_completion_callback),
              completer.toPersistentHandle(),
              _realmLib.addresses.realm_dart_delete_persistent_handle,
            ),
        "Login failed");
    return completer.future;
  }

  static void void_completion_callback(Pointer<Void> userdata, Pointer<realm_app_error> error) {
    final Completer<void>? completer = userdata.toObject(isPersistent: true);
    if (completer == null) {
      return;
    }

    if (error != nullptr) {
      final message = error.ref.message.cast<Utf8>().toRealmDartString()!;
      completer.completeError(RealmException(message));
      return;
    }

    completer.complete();
  }

  Future<void> appEmailPasswordRegisterUser(App app, String email, String password) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_register_email(
            app.handle._pointer,
            email.toCharPtr(arena),
            password.toRealmString(arena).ref,
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordConfirmUser(App app, String token, String tokenId) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_confirm_user(
            app.handle._pointer,
            token.toCharPtr(arena),
            tokenId.toCharPtr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordResendUserConfirmation(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_resend_confirmation_email(
            app.handle._pointer,
            email.toCharPtr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordCompleteResetPassword(App app, String password, String token, String tokenId) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_reset_password(
            app.handle._pointer,
            password.toRealmString(arena).ref,
            token.toCharPtr(arena),
            tokenId.toCharPtr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordResetPassword(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_send_reset_password_email(
            app.handle._pointer,
            email.toCharPtr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordCallResetPasswordFunction(App app, String email, String password, String? argsAsJSON) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_call_reset_password_function(
            app.handle._pointer,
            email.toCharPtr(arena),
            password.toRealmString(arena).ref,
            argsAsJSON != null ? argsAsJSON.toCharPtr(arena) : nullptr,
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordRetryCustomConfirmationFunction(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_retry_custom_confirmation(
            app.handle._pointer,
            email.toCharPtr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _realmLib.addresses.realm_dart_delete_persistent_handle,
          ));
    });
    return completer.future;
  }

  UserHandle? getCurrentUser(AppHandle appHandle) {
    final userPtr = _realmLib.realm_app_get_current_user(appHandle._pointer);
    if (userPtr == nullptr) {
      return null;
    }
    return UserHandle._(userPtr);
  }

  static void _logOutCallback(Pointer<Void> userdata, Pointer<realm_app_error> error) {
    final Completer<void>? completer = userdata.toObject(isPersistent: true);
    if (completer == null) {
      return;
    }

    if (error != nullptr) {
      final message = error.ref.message.cast<Utf8>().toRealmDartString()!;
      completer.completeError(RealmException(message));
      return;
    }

    completer.complete();
  }

  Future<void> logOut(App application, User? user) {
    final completer = Completer<void>();
    if (user == null) {
      _realmLib.invokeGetBool(
          () => _realmLib.realm_app_log_out_current_user(
                application.handle._pointer,
                Pointer.fromFunction(_logOutCallback),
                completer.toPersistentHandle(),
                _realmLib.addresses.realm_dart_delete_persistent_handle,
              ),
          "Logout failed");
    } else {
      _realmLib.invokeGetBool(
          () => _realmLib.realm_app_log_out(
                application.handle._pointer,
                user.handle._pointer,
                Pointer.fromFunction(_logOutCallback),
                completer.toPersistentHandle(),
                _realmLib.addresses.realm_dart_delete_persistent_handle,
              ),
          "Logout failed");
    }
    return completer.future;
  }

  void clearCachedApps() {
    _realmLib.realm_clear_cached_apps();
  }

  List<UserHandle> getUsers(App app) {
    return using((arena) {
      return _getUsers(app, arena);
    });
  }

  List<UserHandle> _getUsers(App app, Arena arena, {int expectedSize = 2}) {
    final actualCount = arena<Size>();
    final usersPtr = arena<Pointer<realm_user>>(expectedSize);
    _realmLib.invokeGetBool(() => _realmLib.realm_app_get_all_users(app.handle._pointer, usersPtr, expectedSize, actualCount));

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(usersPtr);
      return _getUsers(app, arena, expectedSize: actualCount.value);
    }

    final result = <UserHandle>[];
    for (var i = 0; i < actualCount.value; i++) {
      result.add(UserHandle._(usersPtr.elementAt(i).value));
    }

    return result;
  }

  Future<void> removeUser(App app, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_remove_user(
              app.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(void_completion_callback),
              completer.toPersistentHandle(),
              _realmLib.addresses.realm_dart_delete_persistent_handle,
            ),
        "Remove user failed");
    return completer.future;
  }

  void switchUser(App application, User user) {
    return using((arena) {
      _realmLib.invokeGetBool(
          () => _realmLib.realm_app_switch_user(
                application.handle._pointer,
                user.handle._pointer,
                nullptr,
              ),
          "Switch user failed");
    });
  }

  String? userGetCustomData(User user) {
    final customDataPtr = _realmLib.realm_user_get_custom_data(user.handle._pointer);
    return customDataPtr.cast<Utf8>().toRealmDartString(freeRealmMemory: true, treatEmptyAsNull: true);
  }

  Future<void> userRefreshCustomData(App app, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_refresh_custom_data(
              app.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(void_completion_callback),
              completer.toPersistentHandle(),
              _realmLib.addresses.realm_dart_delete_persistent_handle,
            ),
        "Refresh custom data failed");
    return completer.future;
  }

  Future<UserHandle> userLinkCredentials(App app, User user, Credentials credentials) {
    final completer = Completer<UserHandle>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_link_user(
              app.handle._pointer,
              user.handle._pointer,
              credentials.handle._pointer,
              Pointer.fromFunction(_app_user_completion_callback),
              completer.toPersistentHandle(),
              _realmLib.addresses.realm_dart_delete_persistent_handle,
            ),
        "Link credentials failed");
    return completer.future;
  }

  UserState userGetState(User user) {
    final nativeUserState = _realmLib.realm_user_get_state(user.handle._pointer);
    return UserState.values.fromIndex(nativeUserState);
  }

  String userGetId(User user) {
    final idPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_user_get_identity(user.handle._pointer), "Error while getting user id");
    final userId = idPtr.cast<Utf8>().toDartString();
    return userId;
  }

  AppHandle userGetApp(UserHandle userHandle) {
    final appPtr = _realmLib.realm_user_get_app(userHandle._pointer);
    if (appPtr == nullptr) {
      throw RealmException('User does not have an associated app. This is likely due to the user being logged out.');
    }

    return AppHandle._(appPtr);
  }

  List<UserIdentity> userGetIdentities(User user) {
    return using((arena) {
      return _userGetIdentities(user, arena);
    });
  }

  List<UserIdentity> _userGetIdentities(User user, Arena arena, {int expectedSize = 2}) {
    final actualCount = arena<Size>();
    final identitiesPtr = arena<realm_user_identity_t>(expectedSize);
    _realmLib.invokeGetBool(() => _realmLib.realm_user_get_all_identities(user.handle._pointer, identitiesPtr, expectedSize, actualCount));

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(identitiesPtr);
      return _userGetIdentities(user, arena, expectedSize: actualCount.value);
    }

    final result = <UserIdentity>[];
    for (var i = 0; i < actualCount.value; i++) {
      final identity = identitiesPtr.elementAt(i).ref;

      result.add(UserIdentityInternal.create(
          identity.id.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!, AuthProviderType.values.fromIndex(identity.provider_type)));
    }

    return result;
  }

  Future<void> userLogOut(User user) {
    _realmLib.invokeGetBool(() => _realmLib.realm_user_log_out(user.handle._pointer), "Logout failed");
    return Future<void>.value();
  }

  String? userGetDeviceId(User user) {
    final deviceId = _realmLib.invokeGetPointer(() => _realmLib.realm_user_get_device_id(user.handle._pointer));
    return deviceId.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true, freeRealmMemory: true);
  }

  AuthProviderType userGetAuthProviderType(User user) {
    final provider = _realmLib.realm_user_get_auth_provider(user.handle._pointer);
    return AuthProviderType.values.fromIndex(provider);
  }

  UserProfile userGetProfileData(User user) {
    final data = _realmLib.invokeGetPointer(() => _realmLib.realm_user_get_profile_data(user.handle._pointer));
    final dynamic profileData = jsonDecode(data.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!);
    return UserProfile(profileData as Map<String, dynamic>);
  }

  SessionHandle realmGetSession(Realm realm) {
    return SessionHandle._(_realmLib.invokeGetPointer(() => _realmLib.realm_sync_session_get(realm.handle._pointer)));
  }

  String sessionGetPath(Session session) {
    return _realmLib.realm_sync_session_get_file_path(session.handle._pointer).cast<Utf8>().toRealmDartString()!;
  }

  SessionState sessionGetState(Session session) {
    final value = _realmLib.realm_sync_session_get_state(session.handle._pointer);
    return _convertCoreSessionState(value);
  }

  ConnectionState sessionGetConnectionState(Session session) {
    final value = _realmLib.realm_sync_session_get_connection_state(session.handle._pointer);
    return ConnectionState.values[value];
  }

  UserHandle sessionGetUser(Session session) {
    return UserHandle._(_realmLib.realm_sync_session_get_user(session.handle._pointer));
  }

  SessionState _convertCoreSessionState(int value) {
    switch (value) {
      case 0: // RLM_SYNC_SESSION_STATE_ACTIVE
      case 1: // RLM_SYNC_SESSION_STATE_DYING
        return SessionState.active;
      case 2: // RLM_SYNC_SESSION_STATE_INACTIVE
      case 3: // RLM_SYNC_SESSION_STATE_WAITING_FOR_ACCESS_TOKEN
        return SessionState.inactive;
      default:
        throw Exception("Unexpected SessionState: $value");
    }
  }

  void sessionPause(Session session) {
    _realmLib.realm_sync_session_pause(session.handle._pointer);
  }

  void sessionResume(Session session) {
    _realmLib.realm_sync_session_resume(session.handle._pointer);
  }

  int sessionRegisterProgressNotifier(Session session, ProgressDirection direction, ProgressMode mode, SessionProgressNotificationsController controller) {
    final isStreaming = mode == ProgressMode.reportIndefinitely;
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64)>(_progressCallback);
    final userdata = _realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle._pointer);
    return _realmLib.realm_sync_session_register_progress_notifier(session.handle._pointer, _realmLib.addresses.realm_dart_sync_progress_callback,
        direction.index, isStreaming, userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
  }

  void sessionUnregisterProgressNotifier(Session session, int token) {
    _realmLib.realm_sync_session_unregister_progress_notifier(session.handle._pointer, token);
  }

  static void _progressCallback(Object userdata, int transferred, int transferable) {
    final controller = userdata as SessionProgressNotificationsController;

    controller.onProgress(transferred, transferable);
  }

  int sessionRegisterConnectionStateNotifier(Session session, SessionConnectionStateController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Int32, Int32)>(_onConnectionStateChange);
    final userdata = _realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle._pointer);
    return _realmLib.realm_sync_session_register_connection_state_change_callback(session.handle._pointer,
        _realmLib.addresses.realm_dart_sync_connection_state_changed_callback, userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
  }

  void sessionUnregisterConnectionStateNotifier(Session session, int token) {
    _realmLib.realm_sync_session_unregister_connection_state_change_callback(session.handle._pointer, token);
  }

  static void _onConnectionStateChange(Object userdata, int oldState, int newState) {
    final controller = userdata as SessionConnectionStateController;

    controller.onConnectionStateChange(ConnectionState.values[oldState], ConnectionState.values[newState]);
  }

  Future<void> sessionWaitForUpload(Session session) {
    final completer = Completer<void>();
    final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_error_code_t>)>(_sessionWaitCompletionCallback);
    final userdata = _realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle._pointer);
    _realmLib.realm_sync_session_wait_for_upload_completion(session.handle._pointer, _realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
        userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
    return completer.future;
  }

  Future<void> sessionWaitForDownload(Session session) {
    final completer = Completer<void>();
    final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_error_code_t>)>(_sessionWaitCompletionCallback);
    final userdata = _realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle._pointer);
    _realmLib.realm_sync_session_wait_for_download_completion(session.handle._pointer, _realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
        userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
    return completer.future;
  }

  static void _sessionWaitCompletionCallback(Object userdata, Pointer<realm_sync_error_code_t> errorCode) {
    final completer = userdata as Completer<void>;

    if (errorCode != nullptr) {
      // Throw RealmException instead of RealmError to be recoverable by the user.
      completer.completeError(RealmException(errorCode.toSyncError().toString()));
    } else {
      completer.complete();
    }
  }

  static String? _appDir;

  String _getAppDirectory() {
    if (!isFlutterPlatform) {
      return path.basenameWithoutExtension(File.fromUri(Platform.script).absolute.path);
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      const String libName = 'realm_plugin';
      String binaryExt = Platform.isWindows
          ? ".dll"
          : Platform.isMacOS
              ? ".dylib"
              : ".so";
      String binaryNamePrefix = Platform.isWindows ? "" : "lib";
      final realmPluginLib =
          Platform.isMacOS == false ? DynamicLibrary.open("$binaryNamePrefix$libName$binaryExt") : DynamicLibrary.open('realm.framework/realm');
      final getAppDirFunc = realmPluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_app_directory");
      final dirNamePtr = getAppDirFunc();
      if (dirNamePtr == nullptr) {
        return "";
      }

      final dirName = Platform.isWindows ? dirNamePtr.cast<Utf16>().toDartString() : dirNamePtr.cast<Utf8>().toDartString();
      return dirName;
    }

    return "";
  }

  String getAppDirectory() {
    if (!isFlutterPlatform) {
      return Directory.current.absolute.path;
    }

    _appDir ??= _getAppDirectory();

    if (Platform.isAndroid || Platform.isIOS) {
      return path.join(getFilesPath(), _appDir);
    } else if (Platform.isWindows) {
      return _appDir ?? Directory.current.absolute.path;
    } else if (Platform.isLinux) {
      String appSupportDir =
          PlatformEx.fromEnvironment("XDG_DATA_HOME", defaultValue: PlatformEx.fromEnvironment("HOME", defaultValue: Directory.current.absolute.path));
      return path.join(appSupportDir, ".local/share", _appDir);
    } else if (Platform.isMacOS) {
      return _appDir ?? Directory.current.absolute.path;
    }

    throw UnsupportedError("Platform ${Platform.operatingSystem} is not supported");
  }

  Future<void> deleteUser(App app, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_delete_user(
              app.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(void_completion_callback),
              completer.toPersistentHandle(),
              _realmLib.addresses.realm_dart_delete_persistent_handle,
            ),
        "Delete user failed");
    return completer.future;
  }
}

class LastError {
  final int code;
  final String? message;

  LastError(this.code, [this.message]);

  @override
  String toString() {
    return "Error code: $code ${(message != null ? ". Message: $message" : "")}";
  }
}

// Flag to enable trace on finalization.
//
// Be aware that the trace is likely late, and it might in rare case be missing,
// as there are no absolute guarantees with Finalizer.
//
// It is often beneficial to also instrument the native realm_release to
// print the address released to get the exact time.
const _enableFinalizerTrace = false;

// Level used for finalization trace, if enabled.
const _finalizerTraceLevel = RealmLogLevel.trace;

void _traceFinalization(Object o) {
  Realm.logger.log(_finalizerTraceLevel, 'Finalizing: $o');
}

final _debugFinalizer = Finalizer<Object>(_traceFinalization);

void _setupFinalizationTrace(Object value, Object finalizationToken) {
  _debugFinalizer.attach(value, finalizationToken, detach: value);
}

void _tearDownFinalizationTrace(Object value, Object finalizationToken) {
  _debugFinalizer.detach(value);
  _traceFinalization(finalizationToken);
}

final _nativeFinalizer = NativeFinalizer(_realmLib.addresses.realm_release);

abstract class HandleBase<T extends NativeType> implements Finalizable {
  final Pointer<T> _pointer;

  @pragma('vm:never-inline')
  void keepAlive() {}

  HandleBase(this._pointer, int size) {
    _nativeFinalizer.attach(this, _pointer.cast(), detach: this, externalSize: size);
    if (_enableFinalizerTrace) _setupFinalizationTrace(this, _pointer);
  }

  HandleBase.unowned(this._pointer);

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<IntPtr>().value}";
}

class SchemaHandle extends HandleBase<realm_schema> {
  SchemaHandle._(Pointer<realm_schema> pointer) : super(pointer, 24);
}

class ConfigHandle extends HandleBase<realm_config> {
  ConfigHandle._(Pointer<realm_config> pointer) : super(pointer, 512);
}

class RealmHandle extends HandleBase<shared_realm> {
  RealmHandle._(Pointer<shared_realm> pointer) : super(pointer, 24);

  RealmHandle._unowned(Pointer<shared_realm> pointer) : super.unowned(pointer);
}

class SchedulerHandle extends HandleBase<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer, 24);
}

class RealmObjectHandle extends HandleBase<realm_object> {
  RealmObjectHandle._(Pointer<realm_object> pointer) : super(pointer, 112);
}

class RealmLinkHandle {
  final int targetKey;
  final int classKey;
  RealmLinkHandle._(realm_link_t link)
      : targetKey = link.target,
        classKey = link.target_table;
}

class RealmResultsHandle extends HandleBase<realm_results> {
  RealmResultsHandle._(Pointer<realm_results> pointer) : super(pointer, 872);
}

class RealmListHandle extends HandleBase<realm_list> {
  RealmListHandle._(Pointer<realm_list> pointer) : super(pointer, 88);
}

class RealmQueryHandle extends HandleBase<realm_query> {
  RealmQueryHandle._(Pointer<realm_query> pointer) : super(pointer, 256);
}

class ReleasableHandle<T extends NativeType> extends HandleBase<T> {
  bool released = false;
  ReleasableHandle(Pointer<T> pointer, int size) : super(pointer, size);
  void release() {
    if (released) {
      return;
    }
    _nativeFinalizer.detach(this);
    _realmLib.realm_release(_pointer.cast());
    released = true;
    if (_enableFinalizerTrace) _tearDownFinalizationTrace(this, _pointer);
  }
}

class RealmNotificationTokenHandle extends ReleasableHandle<realm_notification_token> {
  RealmNotificationTokenHandle._(Pointer<realm_notification_token> pointer) : super(pointer, 32);
}

class RealmCallbackTokenHandle extends ReleasableHandle<realm_callback_token> {
  RealmCallbackTokenHandle._(Pointer<realm_callback_token> pointer) : super(pointer, 24);
}

class RealmCollectionChangesHandle extends HandleBase<realm_collection_changes> {
  RealmCollectionChangesHandle._(Pointer<realm_collection_changes> pointer) : super(pointer, 256);
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

class AppHandle extends HandleBase<realm_app> {
  AppHandle._(Pointer<realm_app> pointer) : super(pointer, 16);
}

class UserHandle extends HandleBase<realm_user> {
  UserHandle._(Pointer<realm_user> pointer) : super(pointer, 24);
}

class SubscriptionHandle extends HandleBase<realm_flx_sync_subscription> {
  SubscriptionHandle._(Pointer<realm_flx_sync_subscription> pointer) : super(pointer, 184);
}

class SubscriptionSetHandle extends ReleasableHandle<realm_flx_sync_subscription_set> {
  SubscriptionSetHandle._(Pointer<realm_flx_sync_subscription_set> pointer) : super(pointer, 128);
}

class MutableSubscriptionSetHandle extends SubscriptionSetHandle {
  MutableSubscriptionSetHandle._(Pointer<realm_flx_sync_mutable_subscription_set> pointer) : super._(pointer.cast());

  Pointer<realm_flx_sync_mutable_subscription_set> get _mutablePointer => super._pointer.cast();
}

class SessionHandle extends ReleasableHandle<realm_sync_session_t> {
  SessionHandle._(Pointer<realm_sync_session_t> pointer) : super(pointer, 24);
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
    realm_string.ref.data = toCharPtr(allocator);
    final units = utf8.encode(this);
    realm_string.ref.size = units.length + 1;
    return realm_string;
  }
}

extension _RealmLibraryEx on RealmLibrary {
  void invokeGetBool(bool Function() callback, [String? errorMessage]) {
    bool success = callback();
    if (!success) {
      realmCore.throwLastError(errorMessage);
    }
  }

  Pointer<T> invokeGetPointer<T extends NativeType>(Pointer<T> Function() callback, [String? errorMessage]) {
    final result = callback();
    if (result == nullptr) {
      realmCore.throwLastError(errorMessage);
    }
    return result;
  }
}

Pointer<realm_value_t> _toRealmValue(Object? value, Allocator allocator) {
  final realm_value = allocator<realm_value_t>();
  _intoRealmValue(value, realm_value, allocator);
  return realm_value;
}

const int _microsecondsPerSecond = 1000 * 1000;
const int _nanosecondsPerMicrosecond = 1000;

void _intoRealmQueryArg(Object? value, Pointer<realm_query_arg_t> realm_query_arg, Allocator allocator) {
  realm_query_arg.ref.arg = allocator<realm_value_t>();
  realm_query_arg.ref.nb_args = 1;
  realm_query_arg.ref.is_list = false;
  _intoRealmValue(value, realm_query_arg.ref.arg, allocator);
}

void _intoRealmValue(Object? value, Pointer<realm_value_t> realm_value, Allocator allocator) {
  if (value == null) {
    realm_value.ref.type = realm_value_type.RLM_TYPE_NULL;
  } else if (value is RealmObject) {
    //when converting a RealmObject to realm_value.link we assume the object is managed
    final link = realmCore._getObjectAsLink(value);
    realm_value.ref.values.link.target = link.targetKey;
    realm_value.ref.values.link.target_table = link.classKey;
    realm_value.ref.type = realm_value_type.RLM_TYPE_LINK;
  } else {
    switch (value.runtimeType) {
      case int:
        realm_value.ref.values.integer = value as int;
        realm_value.ref.type = realm_value_type.RLM_TYPE_INT;
        break;
      case bool:
        realm_value.ref.values.boolean = value as bool;
        realm_value.ref.type = realm_value_type.RLM_TYPE_BOOL;
        break;
      case String:
        String string = value as String;
        final units = utf8.encode(string);
        final result = allocator<Uint8>(units.length);
        final Uint8List nativeString = result.asTypedList(units.length);
        nativeString.setAll(0, units);
        realm_value.ref.values.string.data = result.cast();
        realm_value.ref.values.string.size = units.length;
        realm_value.ref.type = realm_value_type.RLM_TYPE_STRING;
        break;
      case double:
        realm_value.ref.values.dnum = value as double;
        realm_value.ref.type = realm_value_type.RLM_TYPE_DOUBLE;
        break;
      case ObjectId:
        final bytes = (value as ObjectId).bytes;
        for (var i = 0; i < 12; i++) {
          realm_value.ref.values.object_id.bytes[i] = bytes[i];
        }
        realm_value.ref.type = realm_value_type.RLM_TYPE_OBJECT_ID;
        break;
      case Uuid:
        final bytes = (value as Uuid).bytes.asUint8List();
        for (var i = 0; i < 16; i++) {
          realm_value.ref.values.uuid.bytes[i] = bytes[i];
        }
        realm_value.ref.type = realm_value_type.RLM_TYPE_UUID;
        break;
      case DateTime:
        final microseconds = (value as DateTime).toUtc().microsecondsSinceEpoch;
        final seconds = microseconds ~/ _microsecondsPerSecond;
        int nanoseconds = _nanosecondsPerMicrosecond * (microseconds % _microsecondsPerSecond);
        if (microseconds < 0 && nanoseconds != 0) {
          nanoseconds = nanoseconds - _nanosecondsPerMicrosecond * _microsecondsPerSecond;
        }
        realm_value.ref.values.timestamp.seconds = seconds;
        realm_value.ref.values.timestamp.nanoseconds = nanoseconds;
        realm_value.ref.type = realm_value_type.RLM_TYPE_TIMESTAMP;
        break;
      default:
        throw RealmException("Property type ${value.runtimeType} not supported");
    }
  }
}

extension on Pointer<realm_value_t> {
  Object? toDartValue(Realm realm) {
    if (this == nullptr) {
      throw RealmException("Can not convert nullptr realm_value to Dart value");
    }

    switch (ref.type) {
      case realm_value_type.RLM_TYPE_NULL:
        return null;
      case realm_value_type.RLM_TYPE_INT:
        return ref.values.integer;
      case realm_value_type.RLM_TYPE_BOOL:
        return ref.values.boolean;
      case realm_value_type.RLM_TYPE_STRING:
        return ref.values.string.data.cast<Utf8>().toRealmDartString(length: ref.values.string.size)!;
      case realm_value_type.RLM_TYPE_FLOAT:
        return ref.values.fnum;
      case realm_value_type.RLM_TYPE_DOUBLE:
        return ref.values.dnum;
      case realm_value_type.RLM_TYPE_LINK:
        final objectKey = ref.values.link.target;
        final classKey = ref.values.link.target_table;
        RealmObjectHandle handle = realmCore._getObject(realm, classKey, objectKey);
        return handle;
      case realm_value_type.RLM_TYPE_BINARY:
        throw Exception("Not implemented");
      case realm_value_type.RLM_TYPE_TIMESTAMP:
        final seconds = ref.values.timestamp.seconds;
        final nanoseconds = ref.values.timestamp.nanoseconds;
        return DateTime.fromMicrosecondsSinceEpoch(seconds * _microsecondsPerSecond + nanoseconds ~/ _nanosecondsPerMicrosecond, isUtc: true);
      case realm_value_type.RLM_TYPE_DECIMAL128:
        throw Exception("Not implemented");
      case realm_value_type.RLM_TYPE_OBJECT_ID:
        return ObjectId.fromBytes(cast<Uint8>().asTypedList(12));
      case realm_value_type.RLM_TYPE_UUID:
        return Uuid.fromBytes(cast<Uint8>().asTypedList(16).buffer);
      default:
        throw RealmException("realm_value_type ${ref.type} not supported");
    }
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

extension on Pointer<Void> {
  T? toObject<T extends Object>({bool isPersistent = false}) {
    assert(this != nullptr, "Pointer<Void> is null");

    Object object = isPersistent ? _realmLib.realm_dart_persistent_handle_to_object(this) : _realmLib.realm_dart_weak_handle_to_object(this);

    assert(object is T, "$T expected");
    if (object is! T) {
      return null;
    }

    return object;
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
        _realmLib.realm_free(cast());
      }
    }
  }
}

extension on realm_sync_error {
  SyncError toSyncError() {
    final message = detailed_message.cast<Utf8>().toRealmDartString()!;
    final SyncErrorCategory category = SyncErrorCategory.values[error_code.category];

    //client reset can be requested with is_client_reset_requested disregarding the error_code.value
    if (is_client_reset_requested) {
      return SyncClientResetError(message);
    }

    return SyncError.create(message, category, error_code.value, isFatal: is_fatal);
  }
}

extension on Pointer<realm_sync_error_code_t> {
  SyncError toSyncError() {
    final message = ref.message.cast<Utf8>().toDartString();
    return SyncError.create(message, SyncErrorCategory.values[ref.category], ref.value, isFatal: false);
  }
}

extension on Object {
  Pointer<Void> toWeakHandle() {
    return _realmLib.realm_dart_object_to_weak_handle(this);
  }

  Pointer<Void> toPersistentHandle() {
    return _realmLib.realm_dart_object_to_persistent_handle(this);
  }
}

extension on List<AuthProviderType> {
  AuthProviderType fromIndex(int index) {
    if (!AuthProviderType.values.any((value) => value.index == index)) {
      throw RealmError("Unknown AuthProviderType $index");
    }

    return AuthProviderType.values[index];
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

extension LevelExt on Level {
  int toInt() {
    if (this == Level.ALL) {
      return 0;
    } else if (name == "TRACE") {
      return 1;
    } else if (name == "DEBUG") {
      return 2;
    } else if (name == "DETAIL") {
      return 3;
    } else if (this == Level.INFO) {
      return 4;
    } else if (this == Level.WARNING) {
      return 5;
    } else if (name == "ERROR") {
      return 6;
    } else if (name == "FATAL") {
      return 7;
    } else if (this == Level.OFF) {
      return 8;
    } else {
      // if unknown logging is off
      return 8;
    }
  }

  static Level fromInt(int value) {
    switch (value) {
      case 0:
        return RealmLogLevel.all;
      case 1:
        return RealmLogLevel.trace;
      case 2:
        return RealmLogLevel.debug;
      case 3:
        return RealmLogLevel.detail;
      case 4:
        return RealmLogLevel.info;
      case 5:
        return RealmLogLevel.warn;
      case 6:
        return RealmLogLevel.error;
      case 7:
        return RealmLogLevel.fatal;
      case 8:
      default:
        // if unknown logging is off
        return RealmLogLevel.off;
    }
  }
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
