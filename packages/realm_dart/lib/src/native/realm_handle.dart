// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:ffi/ffi.dart';
import 'package:realm_common/realm_common.dart';

import '../logging.dart';
import '../realm_class.dart';
import '../realm_object.dart';
import 'config_handle.dart';
import 'convert.dart';
import 'error_handling.dart';
import 'handle_base.dart';
import 'object_handle.dart';
import 'query_handle.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';
import 'schema_handle.dart';
import 'session_handle.dart';
import 'subscription_set_handle.dart';

class RealmHandle extends HandleBase<shared_realm> {
  int _counter = 0;

  final Map<int, WeakReference<RootedHandleBase>> _children = {};

  RealmHandle(Pointer<shared_realm> pointer) : super(pointer, 24);

  RealmHandle.unowned(super.pointer) : super.unowned();

  factory RealmHandle.open(Configuration config) {
    final configHandle = ConfigHandle.from(config);
    final realmPtr = invokeGetPointer(() => realmLib.realm_open(configHandle.pointer), 'Error opening realm at path ${config.path}');
    return RealmHandle(realmPtr);
  }

  int addChild(RootedHandleBase child) {
    final id = _counter++;
    _children[id] = WeakReference(child);
    rootedHandleFinalizer.attach(this, FinalizationToken(this, id), detach: this);
    return id;
  }

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

  ObjectHandle createWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = primaryKey.toNative(arena);
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_create_with_primary_key(pointer, classKey, realmValue.ref));
      return ObjectHandle(realmPtr, this);
    });
  }

  ObjectHandle create(int classKey) {
    final realmPtr = invokeGetPointer(() => realmLib.realm_object_create(pointer, classKey));
    return ObjectHandle(realmPtr, this);
  }

  ObjectHandle getOrCreateWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = primaryKey.toNative(arena);
      final didCreate = arena<Bool>();
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_get_or_create_with_primary_key(
            pointer,
            classKey,
            realmValue.ref,
            didCreate,
          ));
      return ObjectHandle(realmPtr, this);
    });
  }

  bool compact() {
    return using((arena) {
      final outDidCompact = arena<Bool>();
      invokeGetBool(() => realmLib.realm_compact(pointer, outDidCompact));
      return outDidCompact.value;
    });
  }

  void writeCopy(Configuration config) {
    final configHandle = ConfigHandle.from(config);
    invokeGetBool(() => realmLib.realm_convert_with_config(pointer, configHandle.pointer, false));
  }

  ResultsHandle queryClass(int classKey, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        intoRealmQueryArg(args[i], argsPointer + i, arena);
      }
      final queryHandle = QueryHandle(
          invokeGetPointer(
            () => realmLib.realm_query_parse(
              pointer,
              classKey,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          this);
      return queryHandle.findAll();
    });
  }

  RealmHandle freeze() => RealmHandle(invokeGetPointer(() => realmLib.realm_freeze(pointer)));

  SessionHandle getSession() {
    return SessionHandle(invokeGetPointer(() => realmLib.realm_sync_session_get(pointer)), this);
  }

  bool get isFrozen {
    return realmLib.realm_is_frozen(pointer.cast());
  }

  SubscriptionSetHandle get subscriptions {
    return SubscriptionSetHandle(invokeGetPointer(() => realmLib.realm_sync_get_active_subscription_set(pointer)), this);
  }

  void disableAutoRefreshForTesting() {
    realmLib.realm_set_auto_refresh(pointer, false);
  }

  void close() {
    invokeGetBool(() => realmLib.realm_close(pointer), "Realm close failed");
  }

  bool get isClosed {
    return realmLib.realm_is_closed(pointer);
  }

  void beginWrite() {
    invokeGetBool(() => realmLib.realm_begin_write(pointer), "Could not begin write");
  }

  void commitWrite() {
    invokeGetBool(() => realmLib.realm_commit(pointer), "Could not commit write");
  }

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
        invokeGetBool(() => realmLib.realm_async_begin_write(
              pointer,
              Pointer.fromFunction(_completeAsyncBeginWrite),
              completer.toPersistentHandle(),
              realmLib.addresses.realm_dart_delete_persistent_handle,
              true,
              transactionId,
            ));
        id = transactionId.value;
      });
    }
    return completer.future;
  }

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
        invokeGetBool(() => realmLib.realm_async_commit(
              pointer,
              Pointer.fromFunction(_completeAsyncCommit),
              completer.toPersistentHandle(),
              realmLib.addresses.realm_dart_delete_persistent_handle,
              false,
              transactionId,
            ));
        id = transactionId.value;
      });
    }
    return completer.future;
  }

  bool _cancelAsync(int cancellationId) {
    return using((Arena arena) {
      final didCancel = arena<Bool>();
      invokeGetBool(() => realmLib.realm_async_cancel(pointer, cancellationId, didCancel));
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

  bool get isWritable {
    return realmLib.realm_is_writable(pointer);
  }

  void rollbackWrite() {
    invokeGetBool(() => realmLib.realm_rollback(pointer), "Could not rollback write");
  }

  bool refresh() {
    return using((Arena arena) {
      final didRefresh = arena<Bool>();
      invokeGetBool(() => realmLib.realm_refresh(pointer, didRefresh), "Could not refresh");
      return didRefresh.value;
    });
  }

  Future<bool> refreshAsync() async {
    final completer = Completer<bool>();
    final callback = Pointer.fromFunction<Void Function(Pointer<Void>)>(_realmRefreshAsyncCallback);
    Pointer<Void> completerPtr = realmLib.realm_dart_object_to_persistent_handle(completer);
    Pointer<realm_refresh_callback_token> result =
        realmLib.realm_add_realm_refresh_callback(pointer, callback.cast(), completerPtr, realmLib.addresses.realm_dart_delete_persistent_handle);

    if (result == nullptr) {
      return Future<bool>.value(false);
    }

    return completer.future;
  }

  static void _realmRefreshAsyncCallback(Pointer<Void> userdata) {
    if (userdata == nullptr) {
      return;
    }

    final completer = realmLib.realm_dart_persistent_handle_to_object(userdata) as Completer<bool>;
    completer.complete(true);
  }

  ResultsHandle findAll(int classKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_object_find_all(pointer, classKey));
    return ResultsHandle(ptr, this);
  }

  ObjectHandle? find(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = primaryKey.toNative(arena);
      final ptr = realmLib.realm_object_find_with_primary_key(pointer, classKey, realmValue.ref, nullptr);
      if (ptr == nullptr) {
        return null;
      }
      return ObjectHandle(ptr, this);
    });
  }

  ObjectHandle? findExisting(int classKey, ObjectHandle other) {
    final key = realmLib.realm_object_get_key(other.pointer);
    final ptr = invokeGetPointer(() => realmLib.realm_get_object(pointer, classKey, key));
    return ptr.convert((p) => ObjectHandle(p, this));
  }

  void renameProperty(String objectType, String oldName, String newName, SchemaHandle schema) {
    using((Arena arena) {
      invokeGetBool(() =>
          realmLib.realm_schema_rename_property(pointer, schema.pointer, objectType.toCharPtr(arena), oldName.toCharPtr(arena), newName.toCharPtr(arena)));
    });
  }

  bool deleteType(String objectType) {
    return using((Arena arena) {
      final tableDeleted = arena<Bool>();
      invokeGetBool(() => realmLib.realm_remove_table(pointer, objectType.toCharPtr(arena), tableDeleted));
      return tableDeleted.value;
    });
  }

  ObjectHandle getObject(int classKey, int objectKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_object(pointer, classKey, objectKey));
    return ObjectHandle(ptr, this);
  }

  CallbackTokenHandle subscribeForSchemaNotifications(Realm realm) {
    final ptr = invokeGetPointer(
      () => realmLib.realm_add_schema_changed_callback(
        pointer,
        Pointer.fromFunction(_schemaChangeCallback),
        realm.toPersistentHandle(),
        realmLib.addresses.realm_dart_delete_persistent_handle,
      ),
    );
    return CallbackTokenHandle(ptr, this);
  }

  RealmSchema readSchema() {
    return using((Arena arena) {
      return _readSchema(arena);
    });
  }

  RealmSchema _readSchema(Arena arena, {int expectedSize = 10}) {
    final classesPtr = arena<Uint32>(expectedSize);
    final actualCount = arena<Size>();
    invokeGetBool(() => realmLib.realm_get_class_keys(pointer, classesPtr, expectedSize, actualCount));
    if (expectedSize < actualCount.value) {
      arena.free(classesPtr);
      return _readSchema(arena, expectedSize: actualCount.value);
    }

    final schemas = <SchemaObject>[];
    for (var i = 0; i < actualCount.value; i++) {
      final classInfo = arena<realm_class_info>();
      final classKey = (classesPtr + i).value;
      invokeGetBool(() => realmLib.realm_get_class(pointer, classKey, classInfo));

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
    invokeGetBool(() => realmLib.realm_get_class_properties(pointer, classKey, propertiesPtr, expectedSize, actualCount));

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
      case ObjectType.asymmetricObject:
        type = AsymmetricObject;
        break;
      default:
        throw RealmError('$baseType is not supported yet');
    }

    return SchemaObject(baseType, type, name, result);
  }

  Map<String, RealmPropertyMetadata> getPropertiesMetadata(int classKey, String? primaryKeyName) {
    return using((Arena arena) {
      return _getPropertiesMetadata(classKey, primaryKeyName, arena);
    });
  }

  RealmObjectMetadata getObjectMetadata(SchemaObject schema) {
    return using((Arena arena) {
      final found = arena<Bool>();
      final classInfo = arena<realm_class_info_t>();
      invokeGetBool(() => realmLib.realm_find_class(pointer, schema.name.toCharPtr(arena), found, classInfo));
          // "Error getting class ${schema.name} from realm at ${realm.config.path}");

      if (!found.value) {
        throwLastError(); //"Class ${schema.name} not found in ${realm.config.path}");
      }

      final primaryKey = classInfo.ref.primary_key.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
      return RealmObjectMetadata(schema, classInfo.ref.key, _getPropertiesMetadata(classInfo.ref.key, primaryKey, arena));
    });
  }

  Map<String, RealmPropertyMetadata> _getPropertiesMetadata(int classKey, String? primaryKeyName, Arena arena) {
    final propertyCountPtr = arena<Size>();
    invokeGetBool(() => realmLib.realm_get_property_keys(pointer, classKey, nullptr, 0, propertyCountPtr), "Error getting property count");

    var propertyCount = propertyCountPtr.value;
    final propertiesPtr = arena<realm_property_info_t>(propertyCount);
    invokeGetBool(
        () => realmLib.realm_get_class_properties(pointer, classKey, propertiesPtr, propertyCount, propertyCountPtr), "Error getting class properties.");

    propertyCount = propertyCountPtr.value;
    Map<String, RealmPropertyMetadata> result = <String, RealmPropertyMetadata>{};
    for (var i = 0; i < propertyCount; i++) {
      final property = propertiesPtr + i;
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
}

class CallbackTokenHandle extends RootedHandleBase<realm_callback_token> {
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
