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

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;

import '../app.dart';
import '../credentials.dart';
import '../collections.dart';
import '../init.dart';
import '../list.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../results.dart';
import 'realm_bindings.dart';
import '../user.dart';

late RealmLibrary _realmLib;

final _RealmCore realmCore = _RealmCore();

class _RealmCore {
  // From realm.h. Currently not exported from the shared library
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  // ignore: unused_field
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  // ignore: unused_field
  static const int RLM_INVALID_OBJECT_KEY = -1;

  static const int TRUE = 1;
  static const int FALSE = 0;

  // Hide the RealmCore class and make it a singleton
  static _RealmCore? _instance;
  late final int isolateKey;

  late final Pointer<NativeFunction<Void Function(Pointer<Void>)>> _deletePersistentHandleFuncPtr;

  _RealmCore._() {
    final lib = initRealm();
    _realmLib = RealmLibrary(lib);

    _deletePersistentHandleFuncPtr = lib.lookup<NativeFunction<Void Function(Pointer<Void>)>>('delete_persistent_handle');
  }

  factory _RealmCore() {
    return _instance ??= _RealmCore._();
  }

  String get libraryVersion => '0.3.0+alpha';

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

        classInfo.name = schemaObject.name.toUtf8Ptr(arena);
        classInfo.primary_key = "".toUtf8Ptr(arena);
        classInfo.num_properties = schemaObject.properties.length;
        classInfo.num_computed_properties = 0;
        classInfo.key = RLM_INVALID_CLASS_KEY;
        classInfo.flags = realm_class_flags.RLM_CLASS_NORMAL;

        final propertiesCount = schemaObject.properties.length;
        final properties = arena<realm_property_info_t>(propertiesCount);

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject.properties[j];
          final propInfo = properties.elementAt(j).ref;
          propInfo.name = schemaProperty.name.toUtf8Ptr(arena);
          //TODO: assign the correct public name value.
          propInfo.public_name = "".toUtf8Ptr(arena);
          propInfo.link_target = (schemaProperty.linkTarget ?? "").toUtf8Ptr(arena);
          propInfo.link_origin_property_name = "".toUtf8Ptr(arena);
          propInfo.type = schemaProperty.propertyType.index;
          propInfo.collection_type = schemaProperty.collectionType.index;
          propInfo.flags = realm_property_flags.RLM_PROPERTY_NORMAL;

          if (schemaProperty.optional) {
            propInfo.flags |= realm_property_flags.RLM_PROPERTY_NULLABLE;
          }

          if (schemaProperty.primaryKey) {
            classInfo.primary_key = schemaProperty.name.toUtf8Ptr(arena);
            propInfo.flags = realm_property_flags.RLM_PROPERTY_PRIMARY_KEY;
          }
        }

        schemaProperties[i] = properties;
        schemaProperties.elementAt(i).value = properties;
      }

      final schemaPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_schema_new(schemaClasses, classCount, schemaProperties));
      return SchemaHandle._(schemaPtr);
    });
  }

  ConfigHandle _createConfig(Configuration config, SchedulerHandle schedulerHandle) {
    return using((Arena arena) {
      final schemaHandle = _createSchema(config.schema);
      final configPtr = _realmLib.realm_config_new();
      final configHandle = ConfigHandle._(configPtr);
      _realmLib.realm_config_set_schema(configHandle._pointer, schemaHandle._pointer);
      _realmLib.realm_config_set_schema_version(configHandle._pointer, config.schemaVersion);
      _realmLib.realm_config_set_path(configHandle._pointer, config.path.toUtf8Ptr(arena));
      _realmLib.realm_config_set_scheduler(configHandle._pointer, schedulerHandle._pointer);
      if (config.isReadOnly) {
        _realmLib.realm_config_set_schema_mode(configHandle._pointer, realm_schema_mode.RLM_SCHEMA_MODE_IMMUTABLE);
      }
      if (config.isInMemory) {
        _realmLib.realm_config_set_in_memory(configHandle._pointer, config.isInMemory);
      }
      if (config.fifoFilesFallbackPath != null) {
        _realmLib.realm_config_set_fifo_path(configHandle._pointer, config.fifoFilesFallbackPath!.toUtf8Ptr(arena));
      }
      if (config.disableFormatUpgrade) {
        _realmLib.realm_config_set_disable_format_upgrade(configHandle._pointer, config.disableFormatUpgrade);
      }

      if (config.initialDataCallback != null) {
        _realmLib.realm_config_set_data_initialization_function(
            configHandle._pointer, Pointer.fromFunction(initial_data_callback, FALSE), config.toWeakHandle());
      }

      if (config.shouldCompactCallback != null) {
        _realmLib.realm_config_set_should_compact_on_launch_function(
            configHandle._pointer, Pointer.fromFunction(should_compact_callback, 0), config.toWeakHandle());
      }

      return configHandle;
    });
  }

  static int initial_data_callback(Pointer<Void> userdata, Pointer<shared_realm> realmHandle) {
    try {
      final Configuration? config = userdata.toObject();
      if (config == null) {
        return FALSE;
      }
      final realm = RealmInternal.getUnowned(config, RealmHandle._unowned(realmHandle));
      config.initialDataCallback!(realm);
      return TRUE;
    } catch (ex) {
      // TODO: this should propagate the error to Core: https://github.com/realm/realm-core/issues/5366
    }

    return FALSE;
  }

  static int should_compact_callback(Pointer<Void> userdata, int totalSize, int usedSize) {
    final Configuration? config = userdata.toObject();
    if (config == null) {
      return FALSE;
    }

    return config.shouldCompactCallback!(totalSize, usedSize) ? TRUE : FALSE;
  }

  SchedulerHandle createScheduler(int isolateId, int sendPort) {
    final schedulerPtr = _realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invokeScheduler(SchedulerHandle schedulerHandle) {
    _realmLib.realm_scheduler_perform_work(schedulerHandle._pointer);
  }

  RealmHandle openRealm(Configuration config, Scheduler scheduler) {
    final configHandle = _createConfig(config, scheduler.handle);
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_open(configHandle._pointer), "Error opening realm at path ${config.path}");
    return RealmHandle._(realmPtr);
  }

  void deleteRealmFiles(String path) {
    using((Arena arena) {
      final realm_deleted = arena<Uint8>();
      _realmLib.invokeGetBool(() => _realmLib.realm_delete_files(path.toUtf8Ptr(arena), realm_deleted), "Error deleting realm at path $path");
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

  RealmClassMetadata getClassMetadata(Realm realm, String className, Type classType) {
    return using((Arena arena) {
      final found = arena<Uint8>();
      final classInfo = arena<realm_class_info_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_find_class(realm.handle._pointer, className.toUtf8Ptr(arena), found, classInfo),
          "Error getting class $className from realm at ${realm.config.path}");

      if (found.value == 0) {
        throwLastError("Class $className not found in ${realm.config.path}");
      }

      final primaryKey = classInfo.ref.primary_key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      return RealmClassMetadata(classType, classInfo.ref.key, primaryKey);
    });
  }

  Map<String, RealmPropertyMetadata> getPropertyMetadata(Realm realm, int classKey) {
    return using((Arena arena) {
      final propertyCountPtr = arena<IntPtr>();
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
        final propertyMeta = RealmPropertyMetadata(property.ref.key, RealmCollectionType.values.elementAt(property.ref.collection_type));
        result[propertyName] = propertyMeta;
      }
      return result;
    });
  }

  RealmObjectHandle createRealmObject(Realm realm, int classKey) {
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_object_create(realm.handle._pointer, classKey));
    return RealmObjectHandle._(realmPtr);
  }

  RealmObjectHandle createRealmObjectWithPrimaryKey(Realm realm, int classKey, Object primaryKey) {
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
    return _realmLib.realm_object_to_string(object.handle._pointer).cast<Utf8>().toRealmDartString(freeNativeMemory: true)!;
  }

  // For debugging
  // ignore: unused_element
  int get _threadId => _realmLib.get_thread_id();

  RealmObjectHandle? find(Realm realm, int classKey, Object primaryKey) {
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

  RealmResultsHandle queryClass(Realm realm, int classKey, String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_value_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmValue(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse(
          realm.handle._pointer,
          classKey,
          query.toUtf8Ptr(arena),
          length,
          argsPointer,
        ),
      ));
      final resultsPointer = _realmLib.invokeGetPointer(() => _realmLib.realm_query_find_all(queryHandle._pointer));
      return RealmResultsHandle._(resultsPointer);
    });
  }

  RealmResultsHandle queryResults(RealmResults target, String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_value_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmValue(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse_for_results(
          target.handle._pointer,
          query.toUtf8Ptr(arena),
          length,
          argsPointer,
        ),
      ));
      final resultsPointer = _realmLib.invokeGetPointer(() => _realmLib.realm_query_find_all(queryHandle._pointer));
      return RealmResultsHandle._(resultsPointer);
    });
  }

  RealmResultsHandle queryList(RealmList target, String query, List<Object> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_value_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmValue(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = RealmQueryHandle._(_realmLib.invokeGetPointer(
        () => _realmLib.realm_query_parse_for_list(
          target.handle._pointer,
          query.toUtf8Ptr(arena),
          length,
          argsPointer,
        ),
      ));
      final resultsPointer = _realmLib.invokeGetPointer(() => _realmLib.realm_query_find_all(queryHandle._pointer));
      return RealmResultsHandle._(resultsPointer);
    });
  }

  RealmObjectHandle getObjectAt(RealmResults results, int index) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_get_object(results.handle._pointer, index));
    return RealmObjectHandle._(pointer);
  }

  int getResultsCount(RealmResults results) {
    return using((Arena arena) {
      final countPtr = arena<IntPtr>();
      _realmLib.invokeGetBool(() => _realmLib.realm_results_count(results.handle._pointer, countPtr));
      return countPtr.value;
    });
  }

  CollectionChanges getCollectionChanges(RealmCollectionChangesHandle changes) {
    return using((arena) {
      final out_num_deletions = arena<IntPtr>();
      final out_num_insertions = arena<IntPtr>();
      final out_num_modifications = arena<IntPtr>();
      final out_num_moves = arena<IntPtr>();
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

      final out_deletion_indexes = arena<IntPtr>(deletionsCount);
      final out_insertion_indexes = arena<IntPtr>(insertionCount);
      final out_modification_indexes = arena<IntPtr>(modificationCount);
      final out_modification_indexes_after = arena<IntPtr>(modificationCount);
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
      final size = arena<IntPtr>();
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

  void listClear(RealmList list) {
    _realmLib.invokeGetBool(() => _realmLib.realm_list_clear(list.handle._pointer));
  }

  bool _equals<T extends NativeType>(Handle<T> first, Handle<T> second) {
    return _realmLib.realm_equals(first._pointer.cast(), second._pointer.cast());
  }

  bool objectEquals(RealmObject first, RealmObject second) => _equals(first.handle, second.handle);
  bool realmEquals(Realm first, Realm second) => _equals(first.handle, second.handle);

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

  RealmNotificationTokenHandle subscribeResultsNotifications(RealmResultsHandle handle, NotificationsController controller, SchedulerHandle schedulerHandle) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_add_notification_callback(
          handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
          nullptr,
          schedulerHandle._pointer,
        ));

    return RealmNotificationTokenHandle._(pointer);
  }

  RealmNotificationTokenHandle subscribeListNotifications(RealmListHandle handle, NotificationsController controller, SchedulerHandle schedulerHandle) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_list_add_notification_callback(
          handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(collection_change_callback),
          nullptr,
          schedulerHandle._pointer,
        ));

    return RealmNotificationTokenHandle._(pointer);
  }

  RealmNotificationTokenHandle subscribeObjectNotifications(RealmObjectHandle handle, NotificationsController controller, SchedulerHandle schedulerHandle) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_object_add_notification_callback(
          handle._pointer,
          controller.toWeakHandle(),
          nullptr,
          nullptr,
          Pointer.fromFunction(object_change_callback),
          nullptr,
          schedulerHandle._pointer,
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
      final app_id = configuration.appId.toUtf8Ptr(arena);
      final handle = AppConfigHandle._(_realmLib.realm_app_config_new(app_id, httpTransport._pointer));

      _realmLib.realm_app_config_set_base_url(handle._pointer, configuration.baseUrl.toString().toUtf8Ptr(arena));

      _realmLib.realm_app_config_set_default_request_timeout(handle._pointer, configuration.defaultRequestTimeout.inMilliseconds);

      if (configuration.localAppName != null) {
        _realmLib.realm_app_config_set_local_app_name(handle._pointer, configuration.localAppName!.toUtf8Ptr(arena));
      }

      if (configuration.localAppVersion != null) {
        _realmLib.realm_app_config_set_local_app_version(handle._pointer, configuration.localAppVersion!.toUtf8Ptr(arena));
      }

      _realmLib.realm_app_config_set_platform(handle._pointer, Platform.operatingSystem.toUtf8Ptr(arena));
      _realmLib.realm_app_config_set_platform_version(handle._pointer, Platform.operatingSystemVersion.toUtf8Ptr(arena));

      //This sets the realm lib version instead of the SDK version.
      //TODO:  Read the SDK version from code generated version field
      _realmLib.realm_app_config_set_sdk_version(handle._pointer, libraryVersion.toUtf8Ptr(arena));

      return handle;
    });
  }

  RealmAppCredentialsHandle createAppCredentialsAnonymous() {
    return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_anonymous());
  }

  RealmAppCredentialsHandle createAppCredentialsEmailPassword(String email, String password) {
    return using((arena) {
      final emailPtr = email.toUtf8Ptr(arena);
      final passwordPtr = password.toRealmString(arena);
      return RealmAppCredentialsHandle._(_realmLib.realm_app_credentials_new_email_password(emailPtr, passwordPtr.ref));
    });
  }

  RealmHttpTransportHandle _createHttpTransport(HttpClient httpClient) {
    return RealmHttpTransportHandle._(_realmLib.realm_http_transport_new(
      Pointer.fromFunction(request_callback),
      httpClient.toWeakHandle(),
      nullptr,
    ));
  }

  static void request_callback(Pointer<Void> userData, realm_http_request request, Pointer<Void> request_context) {
    //
    // The request struct only survives until end-of-call, even though
    // we explicitly call realm_http_transport_complete_request to
    // mark request as completed later.
    //
    // Therefor we need to copy everything out of request before returning.
    // We cannot clone request on the native side with realm_clone,
    // since realm_http_request does not inherit from WrapC.

    HttpClient? userObject = userData.toObject();
    if (userObject == null) {
      return;
    }

    HttpClient client = userObject;

    client.connectionTimeout = Duration(milliseconds: request.timeout_ms);

    final url = Uri.parse(request.url.cast<Utf8>().toRealmDartString()!);

    final body = request.body.cast<Utf8>().toRealmDartString()!;

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
        responseRef.body = responseBody.toInt8Ptr(arena);
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
            headerRef.name = name.toUtf8Ptr(arena);
            headerRef.value = value.toUtf8Ptr(arena);
            index++;
          }
        });

        responseRef.custom_status_code = _CustomErrorCode.noError.code;
      } on SocketException catch (_) {
        // TODO: A Timeout causes a socket exception, but not all socket exceptions are due to timeouts
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

  SyncClientConfigHandle _createSyncClientConfig(AppConfiguration configuration) {
    return using((arena) {
      final handle = SyncClientConfigHandle._(_realmLib.realm_sync_client_config_new());

      _realmLib.realm_sync_client_config_set_base_file_path(handle._pointer, configuration.baseFilePath.path.toUtf8Ptr(arena));
      _realmLib.realm_sync_client_config_set_metadata_mode(handle._pointer, configuration.metadataPersistenceMode.index);

      if (configuration.metadataEncryptionKey != null && configuration.metadataPersistenceMode == MetadataPersistenceMode.encrypted) {
        _realmLib.realm_sync_client_config_set_metadata_encryption_key(handle._pointer, configuration.metadataEncryptionKey!.toUint8Ptr(arena));
      }

      return handle;
    });
  }

  AppHandle getApp(AppConfiguration configuration) {
    final httpTransportHandle = _createHttpTransport(configuration.httpClient);
    final appConfigHandle = _createAppConfig(configuration, httpTransportHandle);
    final syncClientConfigHandle = _createSyncClientConfig(configuration);
    final realmAppPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_app_get(appConfigHandle._pointer, syncClientConfigHandle._pointer));
    return AppHandle._(realmAppPtr);
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
              _deletePersistentHandleFuncPtr,
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
            email.toUtf8Ptr(arena),
            password.toRealmString(arena).ref,
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordConfirmUser(App app, String token, String tokenId) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_confirm_user(
            app.handle._pointer,
            token.toUtf8Ptr(arena),
            tokenId.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordResendUserConfirmation(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_resend_confirmation_email(
            app.handle._pointer,
            email.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
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
            token.toUtf8Ptr(arena),
            tokenId.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordResetPassword(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_send_reset_password_email(
            app.handle._pointer,
            email.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordCallResetPasswordFunction(App app, String email, String password, String argsAsJSON) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_call_reset_password_function(
            app.handle._pointer,
            email.toUtf8Ptr(arena),
            password.toRealmString(arena).ref,
            argsAsJSON.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
          ));
    });
    return completer.future;
  }

  Future<void> emailPasswordRetryCustomConfirmationFunction(App app, String email) {
    final completer = Completer<void>();
    using((arena) {
      _realmLib.invokeGetBool(() => _realmLib.realm_app_email_password_provider_client_retry_custom_confirmation(
            app.handle._pointer,
            email.toUtf8Ptr(arena),
            Pointer.fromFunction(void_completion_callback),
            completer.toPersistentHandle(),
            _deletePersistentHandleFuncPtr,
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

  Future<void> logOut(App application, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_log_out(
              application.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(_logOutCallback),
              completer.toPersistentHandle(),
              _deletePersistentHandleFuncPtr,
            ),
        "Logout failed");
    return completer.future;
  }

  void clearCachedApps() {
    _realmLib.realm_clear_cached_apps();
  }

  List<UserHandle> getUsers(App app) {
    return using((arena) {
      final usersCount = arena<IntPtr>();
      _realmLib.invokeGetBool(() => _realmLib.realm_app_get_all_users(app.handle._pointer, nullptr, 0, usersCount));

      final usersPtr = arena<Pointer<realm_user>>(usersCount.value);
      _realmLib.invokeGetBool(() => _realmLib.realm_app_get_all_users(
            app.handle._pointer,
            Pointer.fromAddress(usersPtr.address),
            usersCount.value,
            usersCount,
          ));

      final userHandles = <UserHandle>[];
      for (var i = 0; i < usersCount.value; i++) {
        final usrPtr = usersPtr.elementAt(i).value;
        userHandles.add(UserHandle._(usrPtr));
      }

      return userHandles;
    });
  }

  Future<void> removeUser(App app, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_remove_user(
              app.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(void_completion_callback),
              completer.toPersistentHandle(),
              _deletePersistentHandleFuncPtr,
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

  String userGetCustomData(User user) {
    final customDataPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_user_get_custom_data(user.handle._pointer));
    try {
      final customData = customDataPtr.cast<Utf8>().toDartString();
      return customData;
    } finally {
      _realmLib.realm_free(customDataPtr.cast());
    }
  }

  Future<void> userRefreshCustomData(App app, User user) {
    final completer = Completer<void>();
    _realmLib.invokeGetBool(
        () => _realmLib.realm_app_refresh_custom_data(
              app.handle._pointer,
              user.handle._pointer,
              Pointer.fromFunction(void_completion_callback),
              completer.toPersistentHandle(),
              _deletePersistentHandleFuncPtr,
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
              _deletePersistentHandleFuncPtr,
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

  List<UserIdentity> userGetIdentities(User user) {
    return using((arena) {
      //TODO: This approach is prone to race conditions. Fix this once Core changes how count is retrieved.
      final idsCount = arena<IntPtr>();
      _realmLib.invokeGetBool(
          () => _realmLib.realm_user_get_all_identities(user.handle._pointer, nullptr, 0, idsCount), "Error while getting user identities count");

      final idsPtr = arena<realm_user_identity_t>(idsCount.value);
      _realmLib.invokeGetBool(
          () => _realmLib.realm_user_get_all_identities(user.handle._pointer, idsPtr, idsCount.value, idsCount), "Error while getting user identities");

      final userIdentities = <UserIdentity>[];
      for (var i = 0; i < idsCount.value; i++) {
        final idPtr = idsPtr.elementAt(i);
        userIdentities.add(UserIdentityInternal.create(idPtr.ref.id.cast<Utf8>().toDartString(), AuthProviderType.values.fromIndex(idPtr.ref.provider_type)));
      }

      return userIdentities;
    });
  }

  Future<void> userLogOut(User user) {
    _realmLib.invokeGetBool(() => _realmLib.realm_user_log_out(user.handle._pointer), "Logout failed");
    return Future<void>.value();
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

abstract class Handle<T extends NativeType> {
  final Pointer<T> _pointer;
  late final Dart_FinalizableHandle _finalizableHandle;

  Handle(this._pointer, int size) {
    _finalizableHandle = _realmLib.realm_attach_finalizer(this, _pointer.cast(), size);
    if (_finalizableHandle == nullptr) {
      throw Exception("Error creating $runtimeType");
    }
  }

  Handle.unowned(this._pointer);

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<IntPtr>().value}";
}

class SchemaHandle extends Handle<realm_schema> {
  SchemaHandle._(Pointer<realm_schema> pointer) : super(pointer, 24);
}

class ConfigHandle extends Handle<realm_config> {
  ConfigHandle._(Pointer<realm_config> pointer) : super(pointer, 512);
}

class RealmHandle extends Handle<shared_realm> {
  RealmHandle._(Pointer<shared_realm> pointer) : super(pointer, 24);

  RealmHandle._unowned(Pointer<shared_realm> pointer) : super.unowned(pointer);
}

class SchedulerHandle extends Handle<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer, 24);
}

class RealmObjectHandle extends Handle<realm_object> {
  RealmObjectHandle._(Pointer<realm_object> pointer) : super(pointer, 112);
}

class RealmLinkHandle {
  final int targetKey;
  final int classKey;
  RealmLinkHandle._(realm_link_t link)
      : targetKey = link.target,
        classKey = link.target_table;
}

class RealmResultsHandle extends Handle<realm_results> {
  RealmResultsHandle._(Pointer<realm_results> pointer) : super(pointer, 872);
}

class RealmListHandle extends Handle<realm_list> {
  RealmListHandle._(Pointer<realm_list> pointer) : super(pointer, 88);
}

class RealmQueryHandle extends Handle<realm_query> {
  RealmQueryHandle._(Pointer<realm_query> pointer) : super(pointer, 256);
}

class RealmNotificationTokenHandle extends Handle<realm_notification_token> {
  bool released = false;
  RealmNotificationTokenHandle._(Pointer<realm_notification_token> pointer) : super(pointer, 32);

  void release() {
    if (released) {
      return;
    }

    _realmLib.realm_delete_finalizable(_finalizableHandle, this);
    _realmLib.realm_release(_pointer.cast());
    released = true;
  }
}

class RealmCollectionChangesHandle extends Handle<realm_collection_changes> {
  RealmCollectionChangesHandle._(Pointer<realm_collection_changes> pointer) : super(pointer, 256);
}

class RealmObjectChangesHandle extends Handle<realm_object_changes> {
  RealmObjectChangesHandle._(Pointer<realm_object_changes> pointer) : super(pointer, 256);
}

class RealmAppCredentialsHandle extends Handle<realm_app_credentials> {
  RealmAppCredentialsHandle._(Pointer<realm_app_credentials> pointer) : super(pointer, 16);
}

class RealmHttpTransportHandle extends Handle<realm_http_transport> {
  RealmHttpTransportHandle._(Pointer<realm_http_transport> pointer) : super(pointer, 24);
}

class AppConfigHandle extends Handle<realm_app_config> {
  AppConfigHandle._(Pointer<realm_app_config> pointer) : super(pointer, 8);
}

class SyncClientConfigHandle extends Handle<realm_sync_client_config> {
  SyncClientConfigHandle._(Pointer<realm_sync_client_config> pointer) : super(pointer, 8);
}

class AppHandle extends Handle<realm_app> {
  AppHandle._(Pointer<realm_app> pointer) : super(pointer, 16);
}

class UserHandle extends Handle<realm_user> {
  UserHandle._(Pointer<realm_user> pointer) : super(pointer, 24);
}

extension on List<int> {
  Pointer<Int8> toInt8Ptr(Allocator allocator) {
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
  Pointer<Int8> toUtf8Ptr(Allocator allocator) {
    final units = utf8.encode(this);
    return units.toInt8Ptr(allocator);
  }

  Pointer<realm_string_t> toRealmString(Allocator allocator) {
    final realm_string = allocator<realm_string_t>();
    realm_string.ref.data = toUtf8Ptr(allocator);
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
        realm_value.ref.values.boolean = (value as bool) ? 1 : 0;
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
        return ref.values.boolean != 0;
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
        throw Exception("Not implemented");
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

extension on Pointer<IntPtr> {
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

    Object object = isPersistent ? _realmLib.persistent_handle_to_object(this) : _realmLib.weak_handle_to_object(this);

    assert(object is T, "$T expected");
    if (object is! T) {
      return null;
    }

    return object;
  }
}

extension on Pointer<Utf8> {
  String? toRealmDartString({bool treatEmptyAsNull = false, int? length, bool freeNativeMemory = false}) {
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
      if (freeNativeMemory) {
        _realmLib.realm_free(cast());
      }
    }
  }
}

extension on Object {
  Pointer<Void> toWeakHandle() {
    return _realmLib.object_to_weak_handle(this);
  }

  Pointer<Void> toPersistentHandle() {
    return _realmLib.object_to_persistent_handle(this);
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

// TODO: Once enhanced-enums land in 2.17, replace with:
/*
enum _CustomErrorCode {
  noError(0),
  httpClientDisposed(997),
  unknownHttp(998),
  unknown(999),
  timeout(1000);

  final int code;
  const _CustomErrorCode(this.code);
}
*/

enum _CustomErrorCode {
  noError,
  httpClientDisposed,
  unknownHttp,
  unknown,
  timeout,
}

extension on _CustomErrorCode {
  int get code {
    switch (this) {
      case _CustomErrorCode.noError:
        return 0;
      case _CustomErrorCode.httpClientDisposed:
        return 997;
      case _CustomErrorCode.unknownHttp:
        return 998;
      case _CustomErrorCode.unknown:
        return 999;
      case _CustomErrorCode.timeout:
        return 1000;
    }
  }
}

enum _HttpMethod {
  get,
  post,
  patch,
  put,
  delete,
}
