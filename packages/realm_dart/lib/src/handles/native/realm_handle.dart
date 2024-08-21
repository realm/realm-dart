// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:cancellation_token/cancellation_token.dart';
import 'ffi.dart';
import 'package:realm_common/realm_common.dart';

import '../../logging.dart';
import '../../realm_class.dart';
import '../../realm_object.dart';
import 'config_handle.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'handle_base.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';
import 'schema_handle.dart';

import '../realm_handle.dart' as intf;

class RealmHandle extends HandleBase<shared_realm> implements intf.RealmHandle {
  int _counter = 0;

  final Map<int, WeakReference<RootedHandleBase>> _children = {};

  RealmHandle(Pointer<shared_realm> pointer) : super(pointer, 24);

  RealmHandle.unowned(super.pointer) : super.unowned();

  factory RealmHandle.open(Configuration config) {
    var dir = File(config.path).parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final configHandle = ConfigHandle.from(config);

    return RealmHandle(realmLib
        .realm_open(configHandle.pointer) //
        .raiseLastErrorIfNull());
  }

  @override
  int addChild(covariant RootedHandleBase child) {
    final id = _counter++;
    _children[id] = WeakReference(child);
    rootedHandleFinalizer.attach(this, FinalizationToken(this, id), detach: this);
    return id;
  }

  @override
  void removeChild(int id) {
    final child = _children.remove(id);
    if (child != null) {
      final target = child.target;
      if (target != null) {
        rootedHandleFinalizer.detach(target);
      }
    }
  }

  @override
  void releaseCore() {
    for (final child in _children.values.toList()) {
      child.target?.release();
    }
  }

  @override
  ObjectHandle createWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((arena) {
      final realmValue = primaryKey.toNative(arena);
      return ObjectHandle(realmLib.realm_object_create_with_primary_key(pointer, classKey, realmValue.ref), this);
    });
  }

  @override
  ObjectHandle create(int classKey) {
    return ObjectHandle(realmLib.realm_object_create(pointer, classKey), this);
  }

  @override
  ObjectHandle getOrCreateWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((arena) {
      final realmValue = primaryKey.toNative(arena);
      final didCreate = arena<Bool>();
      return ObjectHandle(
        realmLib.realm_object_get_or_create_with_primary_key(
          pointer,
          classKey,
          realmValue.ref,
          didCreate,
        ),
        this,
      );
    });
  }

  @override
  bool compact() {
    return using((arena) {
      final outDidCompact = arena<Bool>();
      realmLib.realm_compact(pointer, outDidCompact).raiseLastErrorIfFalse();
      return outDidCompact.value;
    });
  }

  @override
  void writeCopy(Configuration config) {
    final configHandle = ConfigHandle.from(config);
    realmLib.realm_convert_with_config(pointer, configHandle.pointer, false).raiseLastErrorIfFalse();
  }

  @override
  ResultsHandle queryClass(int classKey, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle(
        realmLib.realm_query_parse(
          pointer,
          classKey,
          query.toCharPtr(arena),
          length,
          argsPointer,
        ),
        this,
      );
      return queryHandle.findAll();
    });
  }

  @override
  RealmHandle freeze() => RealmHandle(realmLib.realm_freeze(pointer));

  @override
  bool get isFrozen {
    return realmLib.realm_is_frozen(pointer.cast());
  }

  @override
  void disableAutoRefreshForTesting() {
    realmLib.realm_set_auto_refresh(pointer, false);
  }

  @override
  void close() {
    realmLib.realm_close(pointer).raiseLastErrorIfFalse();
  }

  @override
  bool get isClosed {
    return realmLib.realm_is_closed(pointer);
  }

  @override
  void beginWrite() {
    realmLib.realm_begin_write(pointer).raiseLastErrorIfFalse();
  }

  @override
  void commitWrite() {
    realmLib.realm_commit(pointer).raiseLastErrorIfFalse();
  }

  @override
  Future<void> beginWriteAsync(CancellationToken? ct) {
    int? id;
    final completer = CancellableCompleter<void>(ct, onCancel: () {
      if (id != null) {
        _cancelAsync(id!);
      }
    });
    if (ct?.isCancelled != true) {
      using((arena) {
        final transactionId = arena<UnsignedInt>();
        realmLib
            .realm_async_begin_write(
              pointer,
              Pointer.fromFunction(_completeAsyncBeginWrite),
              completer.toPersistentHandle(),
              realmLib.addresses.realm_dart_delete_persistent_handle,
              true,
              transactionId,
            )
            .raiseLastErrorIfFalse();
        id = transactionId.value;
      });
    }
    return completer.future;
  }

  @override
  Future<void> commitWriteAsync(CancellationToken? ct) {
    int? id;
    final completer = CancellableCompleter<void>(ct, onCancel: () {
      if (id != null) {
        _cancelAsync(id!);
      }
    });
    if (ct?.isCancelled != true) {
      using((arena) {
        final transactionId = arena<UnsignedInt>();
        realmLib
            .realm_async_commit(
              pointer,
              Pointer.fromFunction(_completeAsyncCommit),
              completer.toPersistentHandle(),
              realmLib.addresses.realm_dart_delete_persistent_handle,
              false,
              transactionId,
            )
            .raiseLastErrorIfFalse();
        id = transactionId.value;
      });
    }
    return completer.future;
  }

  bool _cancelAsync(int cancellationId) {
    return using((arena) {
      final didCancel = arena<Bool>();
      realmLib.realm_async_cancel(pointer, cancellationId, didCancel).raiseLastErrorIfFalse();
      return didCancel.value;
    });
  }

  static void _completeAsyncBeginWrite(Pointer<Void> userdata) {
    final Completer<void> completer = userdata.toObject();
    completer.complete();
  }

  static void _completeAsyncCommit(Pointer<Void> userdata, bool error, Pointer<Char> description) {
    final Completer<void> completer = userdata.toObject();
    if (error) {
      completer.completeError(RealmException(description.cast<Utf8>().toDartString()));
    } else {
      completer.complete();
    }
  }

  @override
  bool get isWritable {
    return realmLib.realm_is_writable(pointer);
  }

  @override
  void rollbackWrite() {
    realmLib.realm_rollback(pointer).raiseLastErrorIfFalse();
  }

  @override
  bool refresh() {
    return using((arena) {
      final didRefresh = arena<Bool>();
      realmLib.realm_refresh(pointer, didRefresh).raiseLastErrorIfFalse();
      return didRefresh.value;
    });
  }

  @override
  Future<bool> refreshAsync() async {
    final completer = Completer<bool>();
    final callback = Pointer.fromFunction<Void Function(Pointer<Void>)>(_realmRefreshAsyncCallback);
    final completerPtr = realmLib.realm_dart_object_to_persistent_handle(completer);
    final result = realmLib.realm_add_realm_refresh_callback(pointer, callback.cast(), completerPtr, realmLib.addresses.realm_dart_delete_persistent_handle);

    if (result == nullptr) {
      return false;
    }
    return await completer.future;
  }

  static void _realmRefreshAsyncCallback(Pointer<Void> userdata) {
    if (userdata == nullptr) {
      return;
    }

    final completer = realmLib.realm_dart_persistent_handle_to_object(userdata) as Completer<bool>;
    completer.complete(true);
  }

  @override
  ResultsHandle findAll(int classKey) {
    return ResultsHandle(realmLib.realm_object_find_all(pointer, classKey), this);
  }

  @override
  ObjectHandle? find(int classKey, Object? primaryKey) {
    return using((arena) {
      final realmValue = primaryKey.toNative(arena);
      final found = arena<Bool>();
      final ptr = realmLib.realm_object_find_with_primary_key(pointer, classKey, realmValue.ref, found);
      if (!found.value) {
        assert(ptr == nullptr); // If not found, the pointer should be null. Otherwise we have a leak
        return null;
      }
      return ObjectHandle(ptr, this);
    });
  }

  @override
  ObjectHandle? findExisting(int classKey, covariant ObjectHandle other) {
    final key = realmLib.realm_object_get_key(other.pointer);
    return ObjectHandle(realmLib.realm_get_object(pointer, classKey, key), this);
  }

  @override
  void renameProperty(String objectType, String oldName, String newName, covariant SchemaHandle schema) {
    using((arena) {
      realmLib
          .realm_schema_rename_property(
            pointer,
            schema.pointer,
            objectType.toCharPtr(arena),
            oldName.toCharPtr(arena),
            newName.toCharPtr(arena),
          )
          .raiseLastErrorIfFalse();
    });
  }

  @override
  bool deleteType(String objectType) {
    return using((arena) {
      final tableDeleted = arena<Bool>();
      realmLib.realm_remove_table(pointer, objectType.toCharPtr(arena), tableDeleted).raiseLastErrorIfFalse();
      return tableDeleted.value;
    });
  }

  @override
  ObjectHandle getObject(int classKey, int objectKey) {
    return ObjectHandle(realmLib.realm_get_object(pointer, classKey, objectKey), this);
  }

  @override
  CallbackTokenHandle subscribeForSchemaNotifications(Realm realm) {
    return CallbackTokenHandle(
      realmLib.realm_add_schema_changed_callback(
        pointer,
        Pointer.fromFunction(_schemaChangeCallback),
        realm.toPersistentHandle(),
        realmLib.addresses.realm_dart_delete_persistent_handle,
      ),
      this,
    );
  }

  @override
  RealmSchema readSchema() {
    return using((arena) {
      return _readSchema(arena);
    });
  }

  RealmSchema _readSchema(Arena arena, {int expectedSize = 10}) {
    final classesPtr = arena<Uint32>(expectedSize);
    final actualCount = arena<Size>();
    realmLib.realm_get_class_keys(pointer, classesPtr, expectedSize, actualCount).raiseLastErrorIfFalse();
    if (expectedSize < actualCount.value) {
      arena.free(classesPtr);
      return _readSchema(arena, expectedSize: actualCount.value);
    }

    final schemas = <SchemaObject>[];
    for (var i = 0; i < actualCount.value; i++) {
      final classInfo = arena<realm_class_info>();
      final classKey = (classesPtr + i).value;
      realmLib.realm_get_class(pointer, classKey, classInfo).raiseLastErrorIfFalse();

      final name = classInfo.ref.name.cast<Utf8>().toDartString();
      final baseType = ObjectType.values.firstWhere((element) => element.flags == classInfo.ref.flags,
          orElse: () => throw RealmError('No object type found for flags ${classInfo.ref.flags}'));
      final schema = _getSchemaForClassKey(classKey, name, baseType, arena, expectedSize: classInfo.ref.num_properties + classInfo.ref.num_computed_properties);
      schemas.add(schema);
    }

    return RealmSchema(schemas);
  }

  SchemaObject _getSchemaForClassKey(int classKey, String name, ObjectType baseType, Arena arena, {int expectedSize = 10}) {
    final actualCount = arena<Size>();
    final propertiesPtr = arena<realm_property_info>(expectedSize);
    realmLib.realm_get_class_properties(pointer, classKey, propertiesPtr, expectedSize, actualCount).raiseLastErrorIfFalse();

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(propertiesPtr);
      return _getSchemaForClassKey(classKey, name, baseType, arena, expectedSize: actualCount.value);
    }

    final result = <SchemaProperty>[];
    for (var i = 0; i < actualCount.value; i++) {
      final property = (propertiesPtr + i).ref.toSchemaProperty();
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
      default:
        throw RealmError('$baseType is not supported yet');
    }

    return SchemaObject(baseType, type, name, result);
  }

  @override
  Map<String, RealmPropertyMetadata> getPropertiesMetadata(int classKey, String? primaryKeyName) {
    return using((arena) {
      return _getPropertiesMetadata(classKey, primaryKeyName, arena);
    });
  }

  @override
  RealmObjectMetadata getObjectMetadata(SchemaObject schema) {
    return using((arena) {
      final found = arena<Bool>();
      final classInfo = arena<realm_class_info_t>();
      realmLib.realm_find_class(pointer, schema.name.toCharPtr(arena), found, classInfo).raiseLastErrorIfFalse();
      final primaryKey = classInfo.ref.primary_key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      return RealmObjectMetadata(schema, classInfo.ref.key, _getPropertiesMetadata(classInfo.ref.key, primaryKey, arena));
    });
  }

  Map<String, RealmPropertyMetadata> _getPropertiesMetadata(int classKey, String? primaryKeyName, Arena arena) {
    final propertyCountPtr = arena<Size>();
    realmLib.realm_get_property_keys(pointer, classKey, nullptr, 0, propertyCountPtr).raiseLastErrorIfFalse();

    var propertyCount = propertyCountPtr.value;
    final propertiesPtr = arena<realm_property_info_t>(propertyCount);
    realmLib.realm_get_class_properties(pointer, classKey, propertiesPtr, propertyCount, propertyCountPtr).raiseLastErrorIfFalse();

    propertyCount = propertyCountPtr.value;
    Map<String, RealmPropertyMetadata> result = <String, RealmPropertyMetadata>{};
    for (var i = 0; i < propertyCount; i++) {
      final property = propertiesPtr + i;
      final propertyName = property.ref.name.cast<Utf8>().toRealmDartString()!;
      final objectType = property.ref.link_target.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      final linkOriginProperty = property.ref.link_origin_property_name.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      final isNullable = property.ref.flags & realm_property_flags.RLM_PROPERTY_NULLABLE.value != 0;
      final isPrimaryKey = propertyName == primaryKeyName;
      final propertyMeta = RealmPropertyMetadata(property.ref.key, objectType, linkOriginProperty, RealmPropertyType.values.elementAt(property.ref.type),
          isNullable, isPrimaryKey, RealmCollectionType.values.elementAt(property.ref.collection_type));
      result[propertyName] = propertyMeta;
    }
    return result;
  }

  Pointer<realm_key_path_array> buildAndVerifyKeyPath(List<String>? keyPaths, int? classKey) {
    if (keyPaths == null || classKey == null) {
      return nullptr;
    }

    if (keyPaths.any((element) => element.isEmpty || element.trim().isEmpty)) {
      throw RealmException("None of the key paths provided can be empty or consisting only of white spaces");
    }

    return using((arena) {
      final length = keyPaths.length;
      final keypathsNative = arena<Pointer<Char>>(length);
      for (int i = 0; i < length; i++) {
        keypathsNative[i] = keyPaths[i].toCharPtr(arena);
      }

      return realmLib.realm_create_key_path_array(pointer, classKey, length, keypathsNative).raiseLastErrorIfNull();
    });
  }

  @override
  void verifyKeyPath(List<String>? keyPaths, int? classKey) => buildAndVerifyKeyPath(keyPaths, classKey);
}

class CallbackTokenHandle extends RootedHandleBase<realm_callback_token> implements intf.CallbackTokenHandle {
  CallbackTokenHandle(Pointer<realm_callback_token> pointer, RealmHandle root) : super(root, pointer, 32);
}

void _schemaChangeCallback(Pointer<Void> userdata, Pointer<realm_schema> data) {
  final Realm realm = userdata.toObject();
  try {
    realm.updateSchema();
  } catch (e) {
    Realm.logger.log(LogLevel.error, 'Failed to update Realm schema: $e');
  }
}
