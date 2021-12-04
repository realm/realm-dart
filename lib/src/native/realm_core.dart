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

// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows to sliently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;

import '../configuration.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import '../init.dart';

import 'realm_bindings.dart';

late RealmLibrary _realmLib;

final _RealmCore realmCore = _RealmCore();

class _RealmCore {
  //From realm.h. Currently not exported from the shared library
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  // ignore: unused_field
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  // ignore: unused_field
  static const int RLM_INVALID_OBJECT_KEY = -1;

  // Hide the RealmCore class and make it a singleton
  static _RealmCore? _instance;

  _RealmCore._() {
    final lib = initRealm();
    _realmLib = RealmLibrary(lib);
  }

  factory _RealmCore() {
    return _instance ??= _RealmCore._();
  }
  //

  String get libraryVersion => _realmLib.realm_get_library_version().cast<Utf8>().toDartString();

  LastError? getLastError([Allocator? allocator]) {
    if (allocator != null) {
      final error = _realmLib.realm_get_last_error();

      if (error == nullptr) {
        return null;
      }

      String? message;
      if (error.ref.message != nullptr) {
        message = error.ref.message.cast<Utf8>().toDartString();
      }
      _realmLib.realm_release_last_error(error);

      return LastError(error.ref.error, message);
    }

    return using((Arena arena) {
      return getLastError(arena);
    });
  }

  //TODO: Use Finalizers, when available, instead of native WeakHandles https://github.com/dart-lang/language/issues/1847
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
        classInfo.flags = realm_class_flags_e.RLM_CLASS_NORMAL;

        final propertiesCount = schemaObject.properties.length;
        final properties = arena<realm_property_info_t>(propertiesCount);

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject.properties[j];
          final propInfo = properties.elementAt(j).ref;
          propInfo.name = schemaProperty.name.toUtf8Ptr(arena);
          //TODO: assign the correct public name value.
          propInfo.public_name = "".toUtf8Ptr(arena);
          propInfo.link_target = "".toUtf8Ptr(arena);
          propInfo.link_origin_property_name = "".toUtf8Ptr(arena);
          propInfo.type = schemaProperty.type.index;
          propInfo.collection_type = realm_collection_type_e.RLM_COLLECTION_TYPE_NONE;
          propInfo.flags = realm_property_flags_e.RLM_PROPERTY_NORMAL;
          if (schemaProperty.primaryKey ?? false) {
            classInfo.primary_key = schemaProperty.name.toUtf8Ptr(arena);
            propInfo.flags = realm_property_flags_e.RLM_PROPERTY_PRIMARY_KEY;
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
        () => _realmLib.realm_schema_validate(schema.handle._pointer, realm_schema_validation_mode_e.RLM_SCHEMA_VALIDATION_BASIC), "Invalid Realm schema.");
  }

  int getSchemaVersion(Configuration config) {
    return _realmLib.realm_config_get_schema_version(config.handle._pointer);
  }

  void setSchemaVersion(Configuration config, int version) {
    _realmLib.realm_config_set_schema_version(config.handle._pointer, version);
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

  void invokeScheduler(int isolateId, int message) {
    _realmLib.realm_dart_scheduler_invoke(isolateId, Pointer.fromAddress(message));
  }

  void setScheduler(Configuration config, SchedulerHandle scheduler) {
    _realmLib.realm_config_set_scheduler(config.handle._pointer, scheduler._pointer);
  }

  RealmHandle openRealm(Configuration config) {
    final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_open(config.handle._pointer), "Error opening realm at path ${config.path}");
    return RealmHandle._(realmPtr);
  }

  String getFilesPath() {
    return _realmLib.realm_dart_get_files_path().cast<Utf8>().toDartString();
  }

  void closeRealm(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_close(realm.handle._pointer), "Realm close failed");
  }

  void beginWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_begin_write(realm.handle._pointer), "Could not begin write");
  }

  void commitWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_commit(realm.handle._pointer), "Could commit write");
  }

  bool getIsWritable(Realm realm) {
    return _realmLib.realm_is_writable(realm.handle._pointer);
  }

  void rollbackWrite(Realm realm) {
    _realmLib.invokeGetBool(() => _realmLib.realm_rollback(realm.handle._pointer), "Could rollback write");
  }

  RealmClassMetadata getClassMetadata(Realm realm, String className, Type classType) {
    return using((Arena arena) {
      Pointer<Uint8> found = arena<Uint8>();
      Pointer<realm_class_info_t> classInfo = arena<realm_class_info_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_find_class(realm.handle._pointer, className.toUtf8Ptr(arena), found, classInfo),
          "Error getting class $className from realm at ${realm.config.path}");

      if (found.value == 0) {
        final error = getLastError();
        throw RealmException("Class $className not found in ${realm.config.path}. Error: $error");
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

  Map<String, int> getPropertyKeys(Realm realm, int classKey) {
    return using((Arena arena) {
      Pointer<IntPtr> propertyCountPtr = arena<IntPtr>();
      _realmLib.invokeGetBool(
          () => _realmLib.realm_get_property_keys(realm.handle._pointer, classKey, nullptr, 0, propertyCountPtr), "Error getting property count");

      var propertyCount = propertyCountPtr.value;
      final propertiesPtr = arena<realm_property_info_t>(propertyCount);
      _realmLib.invokeGetBool(() => _realmLib.realm_get_class_properties(realm.handle._pointer, classKey, propertiesPtr, propertyCount, propertyCountPtr),
          "Error getting class properties.");

      propertyCount = propertyCountPtr.value;
      Map<String, int> result = <String, int>{};
      for (var i = 0; i < propertyCount; i++) {
        final property = propertiesPtr.elementAt(i);
        result[property.ref.name.cast<Utf8>().toDartString()] = property.ref.key;
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
      Pointer<realm_value_t> realm_value = _toRealmValue(primaryKey, arena);
      final realmPtr = _realmLib.invokeGetPointer(() => _realmLib.realm_object_create_with_primary_key(realm.handle._pointer, classKey, realm_value.ref));
      return RealmObjectHandle._(realmPtr);
    });
  }

  Object getProperty(RealmObject object, int propertyKey) {
    return using((Arena arena) {
      Pointer<realm_value_t> realm_value = arena<realm_value_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_get_value(object.handle._pointer, propertyKey, realm_value));
      return realm_value.toDartValue();
    });
  }

  void setProperty(RealmObject object, int propertyKey, Object? value, [bool isDefault = false]) {
    return using((Arena arena) {
      Pointer<realm_value_t> realm_value = _toRealmValue(value, arena);
      _realmLib.invokeGetBool(() => _realmLib.realm_set_value(object.handle._pointer, propertyKey, realm_value.ref, isDefault));
    });
  }

  int get threadId => _realmLib.get_thread_id();

  Object triggerGC() {
    //create some new object to force the GC to run
    for (var i = 0; i < 16; i++) {
      Object hugeObject = Object();
      final configPtr = _realmLib.realm_config_new();
      _realmLib.realm_attach_finalizer(hugeObject, configPtr.cast(), 1024 * 1024 * 1024);
    }

    Object? k;
    for (var i = 0; i < 16; i++) {
      k = Object();
    }
    return k!;
  }

  RealmObjectHandle? find(Realm realm, int classKey, Object primaryKey) {
    return using((Arena arena) {
      final realm_value = _toRealmValue(primaryKey, arena);
      final pointer =
          _realmLib.invokeTryGetPointer(() => _realmLib.realm_object_find_with_primary_key(realm.handle._pointer, classKey, realm_value.ref, nullptr));
      if (pointer == nullptr) {
        return null;
      }

      return RealmObjectHandle._(pointer);
    });
  }
}

class LastError {
  final int code;
  final String? message;

  LastError(this.code, [this.message]);

  @override
  String toString() {
    return "Error code: $code ${(message != null ? "Message: $message" : "")}";
  }
}

abstract class Handle<T extends NativeType> {
  final Pointer<T> _pointer;

  Handle(this._pointer);

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<Uint64>().value}";
}

class SchemaHandle extends Handle<realm_schema> {
  SchemaHandle._(Pointer<realm_schema> pointer) : super(pointer) {
    _realmLib.realm_attach_finalizer(this, _pointer.cast(), 24);
  }
}

class ConfigHandle extends Handle<realm_config> {
  ConfigHandle._(Pointer<realm_config> pointer) : super(pointer) {
    _realmLib.realm_attach_finalizer(this, _pointer.cast(), 512);
  }
}

class RealmHandle extends Handle<shared_realm> {
  RealmHandle._(Pointer<shared_realm> pointer) : super(pointer) {
    _realmLib.realm_attach_finalizer(this, _pointer.cast(), 24);
  }
}

class SchedulerHandle extends Handle<realm_scheduler> {
  SchedulerHandle._(Pointer<realm_scheduler> pointer) : super(pointer) {
    _realmLib.realm_attach_finalizer(this, _pointer.cast(), 24);
  }
}

class RealmObjectHandle extends Handle<realm_object> {
  RealmObjectHandle._(Pointer<realm_object> pointer) : super(pointer) {
    _realmLib.realm_attach_finalizer(this, _pointer.cast(), 112);
  }
}

extension _StringEx on String {
  Pointer<T> toUtf8Ptr<T extends NativeType>(Allocator allocator) {
    final units = utf8.encode(this);
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }

  int utf8Length() {
    final units = utf8.encode(this);
    return units.length + 1;
  }
}

extension _RealmLibraryEx on RealmLibrary {
  void invokeGetBool(bool Function() callback, [String? errorMessage]) {
    bool success = callback();
    if (!success) {
      final lastError = realmCore.getLastError();
      throw RealmException("${errorMessage ?? ""} ${lastError.toString()}");
    }
  }

  Pointer<T> invokeGetPointer<T extends NativeType>(Pointer<T> Function() callback, [String? errorMessage]) {
    final result = callback();
    if (result == nullptr) {
      final lastError = realmCore.getLastError();
      throw RealmException("${errorMessage ?? ""} ${lastError.toString()}");
    }
    return result;
  }

  Pointer<T> invokeTryGetPointer<T extends NativeType>(Pointer<T> Function() callback) {
    return callback();
  }
}

Pointer<realm_value_t> _toRealmValue(Object? value, Allocator allocator) {
  Pointer<realm_value_t> realm_value = allocator<realm_value_t>();

  if (value == null) {
    realm_value.ref.type = realm_value_type_e.RLM_TYPE_NULL;
    return realm_value;
  }

  switch (value.runtimeType) {
    case int:
      realm_value.ref.values.integer = value as int;
      realm_value.ref.type = realm_value_type_e.RLM_TYPE_INT;
      break;
    case bool:
      realm_value.ref.values.boolean = value as bool ? 0 : 1;
      realm_value.ref.type = realm_value_type_e.RLM_TYPE_BOOL;
      break;
    case String:
      String string = value as String;
      final units = utf8.encode(string);
      final Pointer<Uint8> result = allocator<Uint8>(units.length);
      final Uint8List nativeString = result.asTypedList(units.length);
      nativeString.setAll(0, units);
      realm_value.ref.values.string.data = result.cast();
      realm_value.ref.values.string.size = units.length;
      realm_value.ref.type = realm_value_type_e.RLM_TYPE_STRING;
      break;
    case double:
      realm_value.ref.values.dnum = value as double;
      realm_value.ref.type = realm_value_type_e.RLM_TYPE_DOUBLE;
      break;
    default:
      throw RealmException("Property type ${value.runtimeType} not supported");
  }

  return realm_value;
}

extension _TypeEx on Type {
  RealmPropertyType toRealmProppertyType() {
    if (this == String) {
      return RealmPropertyType.string;
    } else if (this == int) {
      return RealmPropertyType.int;
    } else if (this == double) {
      return RealmPropertyType.double;
    } else {
      throw RealmException("Type $this can not converted to RealmPropertyType");
    }
  }
}

extension _realm_value_t_ex on Pointer<realm_value_t> {
  Object toDartValue() {
    if (this == nullptr) {
      throw RealmException("Can not convert nullptr realm_value to Dart value");
    }

    switch (ref.type) {
      case realm_value_type_e.RLM_TYPE_INT:
        return ref.values.integer;
      case realm_value_type_e.RLM_TYPE_BOOL:
        return ref.values.boolean == 0;
      case realm_value_type_e.RLM_TYPE_STRING:
        return ref.values.string.data.cast<Utf8>().toDartString(length: ref.values.string.size);
      case realm_value_type_e.RLM_TYPE_FLOAT:
        return ref.values.fnum;
      case realm_value_type_e.RLM_TYPE_DOUBLE:
        return ref.values.dnum;
      case realm_value_type_e.RLM_TYPE_BINARY:
        throw Exception("Not implemented");
      case realm_value_type_e.RLM_TYPE_TIMESTAMP:
        throw Exception("Not implemented");
      case realm_value_type_e.RLM_TYPE_DECIMAL128:
        throw Exception("Not implemented");
      case realm_value_type_e.RLM_TYPE_LINK:
        throw Exception("Not implemented");
      case realm_value_type_e.RLM_TYPE_OBJECT_ID:
        throw Exception("Not implemented");
      case realm_value_type_e.RLM_TYPE_UUID:
        throw Exception("Not implemented");
      default:
        throw RealmException("realm_value_type ${ref.type} not supported");
    }
  }
}
