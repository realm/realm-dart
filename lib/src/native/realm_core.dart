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

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows silently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;

import '../collections.dart';
import '../configuration.dart';
import '../init.dart';
import '../list.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../results.dart';
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

  String get libraryVersion => _realmLib.realm_get_library_version().cast<Utf8>().toDartString();

  LastError? getLastError(Allocator allocator) {
    final error = allocator<realm_error_t>();
    final success = _realmLib.realm_get_last_error(error);
    if (!success) {
      return null;
    }

    String? message;
    if (error.ref.message != nullptr) {
      message = error.ref.message.cast<Utf8>().toDartString();
    }

    return LastError(error.ref.error, message);
  }

  void throwLastError([String? errorMessage]) {
    using((Arena arena) {
      final lastError = getLastError(arena);
      throw RealmException('${errorMessage != null ? errorMessage + ". " : ""}${lastError ?? ""}');
    });
  }

  SchemaHandle createSchema(List<SchemaObject> schema) {
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

  void setSchema(Configuration config) {
    _realmLib.realm_config_set_schema(config.handle._pointer, config.schema.handle._pointer);
  }

  void validateSchema(RealmSchema schema) {
    _realmLib.invokeGetBool(
        () => _realmLib.realm_schema_validate(schema.handle._pointer, realm_schema_validation_mode.RLM_SCHEMA_VALIDATION_BASIC), "Invalid Realm schema.");
  }

  int getSchemaVersion(Configuration config) {
    return _realmLib.realm_config_get_schema_version(config.handle._pointer);
  }

  void setSchemaVersion(Configuration config, int version) {
    _realmLib.realm_config_set_schema_version(config.handle._pointer, version);
  }

  bool getConfigReadOnly(Configuration config) {
    int mode = _realmLib.realm_config_get_schema_mode(config.handle._pointer);
    return mode == realm_schema_mode.RLM_SCHEMA_MODE_IMMUTABLE;
  }

  void setConfigReadOnly(Configuration config, bool value) {
    int mode = value ? realm_schema_mode.RLM_SCHEMA_MODE_IMMUTABLE : realm_schema_mode.RLM_SCHEMA_MODE_AUTOMATIC;
    _realmLib.realm_config_set_schema_mode(config.handle._pointer, mode);
  }

  bool getConfigInMemory(Configuration config) {
    return _realmLib.realm_config_get_in_memory(config.handle._pointer);
  }

  void setConfigInMemory(Configuration config, bool value) {
    _realmLib.realm_config_set_in_memory(config.handle._pointer, value);
  }

  String getConfigFifoPath(Configuration config) {
    return _realmLib.realm_config_get_fifo_path(config.handle._pointer).cast<Utf8>().toDartString();
  }

  void setConfigFifoPath(Configuration config, String path) {
    return using((Arena arena) {
      _realmLib.realm_config_set_fifo_path(config.handle._pointer, path.toUtf8Ptr(arena));
    });
  }

  ConfigHandle createConfig() {
    final configPtr = _realmLib.realm_config_new();
    return ConfigHandle._(configPtr);
  }

  String getConfigPath(Configuration config) {
    return _realmLib.realm_config_get_path(config.handle._pointer).cast<Utf8>().toDartString();
  }

  void setConfigPath(Configuration config, String path) {
    return using((Arena arena) {
      _realmLib.realm_config_set_path(config.handle._pointer, path.toUtf8Ptr(arena));
    });
  }

  SchedulerHandle createScheduler(int isolateId, int sendPort) {
    final schedulerPtr = _realmLib.realm_dart_create_scheduler(isolateId, sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invokeScheduler(SchedulerHandle schedulerHandle) {
    _realmLib.realm_scheduler_perform_work(schedulerHandle._pointer);
  }

  void setScheduler(Configuration config, SchedulerHandle schedulerHandle) {
    _realmLib.realm_config_set_scheduler(config.handle._pointer, schedulerHandle._pointer);
  }

  RealmHandle openRealm(Configuration config) {
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_open(config.handle._pointer), "Error opening realm at path ${config.path}");
    return RealmHandle._(realmPtr);
  }

  void deleteRealmFiles(String path) {
    using((Arena arena) {
      final realm_deleted = arena<Uint8>();
      _realmLib.invokeGetBool(() => _realmLib.realm_delete_files(path.toUtf8Ptr(arena), realm_deleted), "Error deleting realm at path $path");
    });
  }

  String getFilesPath() {
    return _realmLib.realm_dart_get_files_path().cast<Utf8>().toDartString();
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

      String? primaryKey;
      if (classInfo.ref.primary_key != nullptr) {
        primaryKey = classInfo.ref.primary_key.cast<Utf8>().toDartString();
        if (primaryKey.isEmpty) {
          primaryKey = null;
        }
      }
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
        final propertyName = property.ref.name.cast<Utf8>().toDartString();
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
  bool configurationEquals(Configuration first, Configuration second) => _equals(first.handle, second.handle);

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
    final controller = _realmLib.gc_handle_deref(userdata);
    if (controller is NotificationsController) {
      if (data == nullptr) {
        controller.onError(RealmError("Invalid notifications data received"));
        return;
      }

      try {
        final changesHandle = RealmCollectionChangesHandle._(_realmLib.realm_clone(data.cast()).cast());
        controller.onChanges(changesHandle);
      } catch (e) {
        controller.onError(RealmError("Error handling collection change notifications. Error: $e"));
      }
    }
  }

  static void object_change_callback(Pointer<Void> userdata, Pointer<realm_object_changes> data) {
    final controller = _realmLib.gc_handle_deref(userdata);
    if (controller is NotificationsController) {
      if (data == nullptr) {
        //realm_collection_changes data clone is done in native code before this callback is invoked. nullptr data means cloning failed.
        controller.onError(RealmError("Invalid notifications data received"));
        return;
      }

      try {
        final changesHandle = RealmObjectChangesHandle._(_realmLib.realm_clone(data.cast()).cast());
        controller.onChanges(changesHandle);
      } catch (e) {
        controller.onError(RealmError("Error handling collection change notifications. Error: $e"));
      }
    }
  }

  RealmNotificationTokenHandle subscribeResultsNotifications(RealmResultsHandle handle, NotificationsController controller, SchedulerHandle schedulerHandle) {
    final pointer = _realmLib.invokeGetPointer(() => _realmLib.realm_results_add_notification_callback(
          handle._pointer,
          _realmLib.gc_handle_weak_new(controller),
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
          _realmLib.gc_handle_weak_new(controller),
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
          _realmLib.gc_handle_weak_new(controller),
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
  RealmNotificationTokenHandle._(Pointer<realm_notification_token> pointer) : super(pointer, 1 << 32);

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

extension _StringEx on String {
  Pointer<Int8> toUtf8Ptr(Allocator allocator) {
    final units = utf8.encode(this);
    final nativeStringSize = units.length + 1;
    final result = allocator<Uint8>(nativeStringSize);
    final Uint8List nativeString = result.asTypedList(nativeStringSize);
    nativeString.setAll(0, units); // copy to native string
    nativeString.last = 0; // zero terminate
    return result.cast();
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
        realm_value.ref.values.boolean = value as bool ? 0 : 1;
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
        return ref.values.boolean == 0;
      case realm_value_type.RLM_TYPE_STRING:
        return ref.values.string.data.cast<Utf8>().toDartString(length: ref.values.string.size);
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
        throw Exception("Not implemented");
      case realm_value_type.RLM_TYPE_UUID:
        throw Exception("Not implemented");
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
