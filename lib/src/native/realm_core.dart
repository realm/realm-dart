import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';

import '../configuration.dart';
import '../realm_class.dart';

import 'realm_bindings.dart';

late RealmLibrary _realmLib;


void setRealmLibrary(DynamicLibrary realmLibrary) {
  _realmLib = RealmLibrary(realmLibrary);
}

final _RealmCore realmCore = _RealmCore();

class _RealmCore {
   
  //From realm.h. Currently not exported from the shared library
  static const int RLM_INVALID_CLASS_KEY = 0x7FFFFFFF;
  static const int RLM_INVALID_PROPERTY_KEY = -1;
  static const int RLM_INVALID_OBJECT_KEY = -1;

  // Hide the RealmCore class and make it a singleton
  static _RealmCore? _instance;

  _RealmCore._();

  factory _RealmCore() {
    return _instance ??= _RealmCore._();
  }
  //

  String get libraryVersion => _realmLib.realm_get_library_version().cast<Utf8>().toDartString();

  //TODO: Use Finalizers, when available, instead of native WeakHandles https://github.com/dart-lang/language/issues/1847
  //The proposal: https://github.com/dart-lang/language/blob/master/working/1847%20-%20FinalizationRegistry/proposal.md
  SchemaHandle createSchema(List<SchemaObject> schema) {
    return using((Arena arena) {
      final classCount = schema.length;

      final schemaClasses = arena.allocate<realm_class_info_t>(classCount * sizeOf<realm_class_info_t>());
      final schemaProperties = arena.allocate<Pointer<realm_property_info_t>>(classCount * sizeOf<Pointer<realm_property_info_t>>());

      for (var i = 0; i < classCount; i++) {
        final schemaObject = schema.elementAt(i);
        final classInfo = schemaClasses.elementAt(i).ref;

        classInfo.name = schemaObject.name.toNativeUtf8().cast();
        classInfo.primary_key = "".toNativeUtf8().cast();
        classInfo.num_properties = schemaObject.properties.length;
        classInfo.num_computed_properties = 0;
        classInfo.key = RLM_INVALID_CLASS_KEY;
        classInfo.flags = realm_class_flags_e.RLM_CLASS_NORMAL;

        final propertiesCount = schemaObject.properties.length;
        final properties = arena.allocate<realm_property_info_t>(propertiesCount * sizeOf<realm_property_info_t>());

        for (var j = 0; j < propertiesCount; j++) {
          final schemaProperty = schemaObject.properties[j];
          final propInfo = properties.elementAt(j).ref;
          propInfo.name = schemaProperty.name.toNativeUtf8().cast();
          propInfo.public_name = "".toNativeUtf8().cast();
          propInfo.link_target = "".toNativeUtf8().cast();
          propInfo.link_origin_property_name = "".toNativeUtf8().cast();
          propInfo.type = schemaProperty.type.index;
          propInfo.collection_type = realm_collection_type_e.RLM_COLLECTION_TYPE_NONE;
          propInfo.flags = realm_property_flags_e.RLM_PROPERTY_NORMAL;
        }

        schemaProperties[0] = properties;
        schemaProperties.elementAt(i).value = properties;
      }

      final schemaPtr = _realmLib.realm_schema_new(schemaClasses, classCount, schemaProperties);
      return SchemaHandle._(schemaPtr);
    });
  }

  void validateSchema(RealmSchema schema) {
    bool isValid = _realmLib.realm_schema_validate(schema.handle._pointer, realm_schema_validation_mode_e.RLM_SCHEMA_VALIDATION_BASIC);
    if (!isValid) {
      using((Arena arena) {
        final realmError = arena<realm_error_t>();
        final result = _realmLib.realm_get_last_error(realmError);
        if (!result) {
          throw RealmException("Invalid Realm schema. Error: unknown");
        }

        throw RealmException("Invalid Realm schema. Error: ${realmError.ref.message.cast<Utf8>().toDartString()}");
      });
    }
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
    _realmLib.realm_config_set_path(config.handle._pointer, path.toNativeUtf8().cast());
  }

  SchedulerHandle createScheduler(int sendPort) {
    final schedulerPtr = _realmLib.realm_dart_create_scheduler(sendPort);
    return SchedulerHandle._(schedulerPtr);
  }

  void invokeScheduler(int message) {
    _realmLib.realm_dart_scheduler_invoke(Pointer.fromAddress(message));
  }

  void setScheduler(Configuration config, SchedulerHandle scheduler) {
    _realmLib.realm_config_set_scheduler(config.handle._pointer, scheduler._pointer);
  }

  RealmHandle openRealm(Configuration config) {
    var realmPtr = _realmLib.realm_open(config.handle._pointer);
    return RealmHandle._(realmPtr);
  }
}

class SchemaHandle extends Handle<realm_schema> {
  Pointer<realm_schema> _pointer;

  SchemaHandle._(this._pointer) {
    _realmLib.realm_attach_finalizer(this, this._pointer.cast(), 24);
  }

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<Uint64>().value}";
}

class ConfigHandle extends Handle<realm_config> {
  @override
  Pointer<realm_config> _pointer;

  ConfigHandle._(this._pointer) {
    _realmLib.realm_attach_finalizer(this, this._pointer.cast(), 512);
  }
}

abstract class Handle<T extends NativeType> {
  late Pointer<T> _pointer;

  @override
  String toString() => "${_pointer.toString()} value=${_pointer.cast<Uint64>().value}";
}

class RealmHandle extends Handle<shared_realm> {
  @override
  Pointer<shared_realm> _pointer;

  RealmHandle._(this._pointer) {
    _realmLib.realm_attach_finalizer(this, this._pointer.cast(), 1);
  }
}

class SchedulerHandle extends Handle<realm_scheduler> {
  @override
  Pointer<realm_scheduler> _pointer;

  SchedulerHandle._(this._pointer) {
    _realmLib.realm_attach_finalizer(this, this._pointer.cast(), 1);
  }
}
