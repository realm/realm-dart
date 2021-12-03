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

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

// Hide StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows to sliently allocating memory. Use toUtf8Ptr instead
import 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;

import '../configuration.dart';
import '../realm_class.dart';
import '../realm_object.dart';

import 'realm_bindings.dart';

late RealmLibrary _realmLib;

void setRealmLibrary(DynamicLibrary realmLibrary) {
  _realmLib = RealmLibrary(realmLibrary);
}

final _RealmCore realmCore = _RealmCore();

class _RealmCore {
  //From realm.h. Currently not exported from the shared library
  // ignore: constant_identifier_names
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  // ignore: constant_identifier_names, unused_field
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  // ignore: constant_identifier_names, unused_field
  static const int RLM_INVALID_OBJECT_KEY = -1;

  // Hide the RealmCore class and make it a singleton
  static _RealmCore? _instance;

  _RealmCore._();

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
        //TODO: assign the correct primary key value.
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

  int getClassKey(Realm realm, String className) {
    return using((Arena arena) {
      Pointer<Uint8> found = arena<Uint8>();
      Pointer<realm_class_info_t> classInfo = arena<realm_class_info_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_find_class(realm.handle._pointer, className.toUtf8Ptr(arena), found, classInfo),
          "Error getting class $className from realm at ${realm.config.path}");

      if (found.value == 0) {
        final error = getLastError();
        throw RealmException("Class $className not found in ${realm.config.path}. Error: $error");
      }

      return classInfo.ref.key;
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

  Object readProperty(RealmObject object, int propertyKey, RealmPropertyType propertyType) {
    return using((Arena arena) {
      Pointer<realm_value_t> value = arena<realm_value_t>();
      _realmLib.invokeGetBool(() => _realmLib.realm_get_value(object.handle._pointer, propertyKey, value));

      switch (propertyType) {
        case RealmPropertyType.int:
          return value.ref.values.integer;
        case RealmPropertyType.bool:
          return value.ref.values.boolean == 0;
        case RealmPropertyType.string:
          return value.ref.values.string.data.cast<Utf8>().toDartString(length: value.ref.values.string.size);
        case RealmPropertyType.float:
          return value.ref.values.fnum;
        case RealmPropertyType.double:
          return value.ref.values.dnum;
        case RealmPropertyType.binary:
          throw Exception("Not implemented");
        case RealmPropertyType.mixed:
          throw Exception("Not implemented");
        case RealmPropertyType.timestamp:
          throw Exception("Not implemented");
        case RealmPropertyType.decimal128:
          throw Exception("Not implemented");
        case RealmPropertyType.object:
          throw Exception("Not implemented");
        case RealmPropertyType.linkingObjects:
          throw Exception("Not implemented");
        case RealmPropertyType.objectid:
          throw Exception("Not implemented");
        case RealmPropertyType.uuid:
          throw Exception("Not implemented");
        default:
          throw RealmException("Property type $propertyType not supported");
      }
    });
  }

  int get threadId => _realmLib.get_thread_id();
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

extension on String {
  Pointer<T> toUtf8Ptr<T extends NativeType>(Allocator allocator) {
    final units = utf8.encode(this);
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}

extension on RealmLibrary {
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
}
