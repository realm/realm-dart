// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_class.dart';
import '../realm_object.dart';
import 'handle_base.dart';
import 'object_handle.dart';
import 'results_handle.dart';
import 'schema_handle.dart';

import 'native/realm_handle.dart' if (dart.library.js_interop) 'web/realm_handle.dart' as impl;

abstract interface class RealmHandle extends HandleBase {
  factory RealmHandle.open(Configuration config) = impl.RealmHandle.open;

  int addChild(HandleBase child);
  void removeChild(int id);

  @override
  void releaseCore();

  ObjectHandle createWithPrimaryKey(int classKey, Object? primaryKey);

  ObjectHandle create(int classKey);
  ObjectHandle getOrCreateWithPrimaryKey(int classKey, Object? primaryKey);

  bool compact();

  void writeCopy(Configuration config);
  ResultsHandle queryClass(int classKey, String query, List<Object?> args);
  RealmHandle freeze();
  bool get isFrozen;

  void disableAutoRefreshForTesting();
  void close();

  bool get isClosed;

  void beginWrite();

  void commitWrite();

  Future<void> beginWriteAsync(CancellationToken? ct);
  Future<void> commitWriteAsync(CancellationToken? ct);
  bool get isWritable;
  void rollbackWrite();
  bool refresh();
  Future<bool> refreshAsync();
  ResultsHandle findAll(int classKey);
  ObjectHandle? find(int classKey, Object? primaryKey);
  ObjectHandle? findExisting(int classKey, ObjectHandle other);
  void renameProperty(String objectType, String oldName, String newName, SchemaHandle schema);
  bool deleteType(String objectType);
  ObjectHandle getObject(int classKey, int objectKey);

  CallbackTokenHandle subscribeForSchemaNotifications(Realm realm);

  RealmSchema readSchema();
  Map<String, RealmPropertyMetadata> getPropertiesMetadata(int classKey, String? primaryKeyName);

  RealmObjectMetadata getObjectMetadata(SchemaObject schema);

  void verifyKeyPath(List<String> keyPaths, int? classKey);
}

abstract class CallbackTokenHandle extends HandleBase {}
