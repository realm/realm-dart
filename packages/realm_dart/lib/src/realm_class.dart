// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:collection/collection.dart';
import 'package:realm_common/realm_common.dart';

import 'configuration.dart';
import 'handles/handle_base.dart';
import 'handles/list_handle.dart';
import 'handles/map_handle.dart';
import 'handles/notification_token_handle.dart';
import 'handles/object_handle.dart';
import 'handles/realm_core.dart';
import 'handles/realm_handle.dart';
import 'handles/set_handle.dart';
import 'list.dart';
import 'logging.dart';
import 'map.dart';
import 'realm_object.dart';
import 'results.dart';
import 'scheduler.dart';
import 'set.dart';

export 'package:cancellation_token/cancellation_token.dart' show CancellationToken, TimeoutCancellationToken, CancelledException;
export 'package:realm_common/realm_common.dart'
    show
        Backlink,
        DoubleToGeoDistance,
        GeoBox,
        GeoCircle,
        GeoDistance,
        GeoPoint,
        GeoPolygon,
        GeoRing,
        GeoShape,
        Ignored,
        Indexed,
        MapTo,
        ObjectId,
        ObjectType,
        PrimaryKey,
        RealmClosedError,
        RealmCollectionType,
        RealmError,
        RealmIndexType,
        RealmModel,
        RealmPropertyType,
        RealmStateError,
        RealmUnsupportedSetError,
        RealmValue,
        RealmValueType,
        Uuid;

// always expose with `show` to explicitly control the public API surface
export 'collections.dart' show Move;
export "configuration.dart"
    show
        encryptionKeySize,
        Configuration,
        InitialDataCallback,
        InMemoryConfiguration,
        LocalConfiguration,
        MigrationCallback,
        RealmSchema,
        SchemaObject,
        ShouldCompactCallback;
export 'handles/decimal128.dart' show Decimal128;
export 'list.dart' show RealmList, RealmListOfObject, RealmListChanges, ListExtension;
export 'logging.dart' hide RealmLoggerInternal;
export 'map.dart' show RealmMap, RealmMapChanges, RealmMapOfObject;
export 'migration.dart' show Migration;
export 'realm_object.dart'
    show
        DynamicRealmObject,
        EmbeddedObject,
        EmbeddedObjectExtension,
        RealmEntity,
        RealmException,
        RealmObject,
        RealmObjectBase,
        RealmObjectChanges,
        UserCallbackException;
export 'realm_property.dart';
export 'results.dart' show RealmResultsOfObject, RealmResultsChanges, RealmResults, WaitForSyncMode;
export 'set.dart' show RealmSet, RealmSetChanges, RealmSetOfObject;

/// A [Realm] instance represents a `Realm` database.
///
/// {@category Realm}
class Realm {
  late final RealmMetadata _metadata;
  late final RealmHandle _handle;
  final bool _isInMigration;
  late final CallbackTokenHandle? _schemaCallbackHandle;
  final List<StreamController<RealmSchemaChanges>> _schemaChangeListeners = [];

  /// An object encompassing this `Realm` instance's dynamic API.
  late final DynamicRealm dynamic = DynamicRealm._(this);

  /// The [Configuration] object used to open this [Realm]
  final Configuration config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  late final RealmSchema schema;

  /// Gets a value indicating whether this [Realm] is frozen. Frozen Realms are immutable
  /// and will not update when writes are made to the database.
  late final bool isFrozen = handle.isFrozen;

  /// Opens a `Realm` using a [Configuration] object.
  Realm(Configuration config) : this._(config);

  Realm._(this.config, [RealmHandle? handle, this._isInMigration = false]) : _handle = handle ?? _openRealm(config) {
    _populateMetadata();

    // The schema of a Realm file may change due to another process adding new properties/classes. We subscribe for notifications
    // in order to update the managed schema instance in case this happens. The same is true for dynamic Realms. For
    // local Realms with user-supplied schema, the schema on disk may still change, but Core doesn't report the updated
    // schema, so even if we subscribe, we wouldn't be able to see the updates.
    if (config.schemaObjects.isEmpty) {
      // TODO: enable once https://github.com/realm/realm-core/issues/7426 is fixed.
      //_schemaCallbackHandle = handle!.subscribeForSchemaNotifications(this);
      _schemaCallbackHandle = null;
    } else {
      _schemaCallbackHandle = null;
    }
  }

  /// A method for asynchronously opening a [Realm].
  ///
  /// * `config`- a configuration object that describes the realm.
  /// * `cancellationToken` - an optional [CancellationToken] used to cancel the operation.
  ///
  /// Returns `Future<Realm>` that completes with the [Realm] once the remote [Realm] is fully synchronized or with a [CancelledException] if operation is canceled.
  /// When the configuration is [LocalConfiguration] this completes right after the local [Realm] is opened.
  /// Using [Realm.open] for opening a local Realm is equivalent to using the constructor of [Realm].
  static Future<Realm> open(Configuration config, {CancellationToken? cancellationToken}) async {
    if (cancellationToken != null && cancellationToken.isCancelled) {
      throw cancellationToken.exception!;
    }

    final realm = Realm(config);
    return await CancellableFuture.value(realm, cancellationToken);
  }

  static RealmHandle _openRealm(Configuration config) {
    return RealmHandle.open(config);
  }

  void _populateMetadata() {
    schema = config.schemaObjects.isNotEmpty ? RealmSchema(config.schemaObjects) : handle.readSchema();
    _metadata = RealmMetadata._(schema.map((c) => handle.getObjectMetadata(c)));
  }

  /// Deletes all files associated with a `Realm` located at given [path]
  ///
  /// The `Realm` must not be open.
  static void deleteRealm(String path) {
    realmCore.deleteRealmFiles(path);
  }

  /// Synchronously checks whether a `Realm` exists at [path]
  static bool existsSync(String path) {
    return realmCore.checkIfRealmExists(path);
  }

  /// Checks whether a `Realm` exists at [path].
  static Future<bool> exists(String path) async {
    return await Isolate.run(() => realmCore.checkIfRealmExists(path));
  }

  /// Adds a [RealmObject] to the `Realm`.
  ///
  /// This `Realm` will start managing the [RealmObject].
  /// A [RealmObject] instance can be managed only by one `Realm`.
  /// If the object is already managed by this `Realm`, this method does nothing.
  /// This method modifies the object in-place as it becomes managed. Managed instances are persisted and become live objects.
  /// Returns the same instance as managed. This is just meant as a convenience to enable fluent syntax scenarios.
  ///
  /// By setting the [update] flag you can update any existing object with the same primary key.
  /// Updating only makes sense for objects with primary keys, and is effectively ignored
  /// otherwise.
  ///
  /// Throws [RealmException] when trying to add objects with the same primary key.
  /// Throws [RealmException] if there is no write transaction created with [write].
  T add<T extends RealmObject>(T object, {bool update = false}) {
    if (object.isManaged) {
      _ensureManagedByThis(object, 'add object to Realm');

      return object;
    }

    final metadata = _metadata.getByType(object.runtimeType);
    final handle = _createObject(object, metadata, update);

    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    object.manage(this, handle, accessor, update);

    return object;
  }

  ObjectHandle _createObject(RealmObjectBase object, RealmObjectMetadata metadata, bool update) {
    final key = metadata.classKey;
    final primaryKey = metadata.primaryKey;
    if (primaryKey == null) {
      return handle.create(key);
    }
    if (update) {
      return _handle.getOrCreateWithPrimaryKey(key, object.accessor.get(object, primaryKey));
    }
    return _handle.createWithPrimaryKey(key, object.accessor.get(object, primaryKey));
  }

  /// Adds a collection [RealmObject]s to this `Realm`.
  ///
  /// If the collection contains items that are already managed by this `Realm`, they will be ignored.
  /// This method behaves as calling [add] multiple times.
  ///
  /// By setting the [update] flag you can update any existing object with the same primary key.
  /// Updating only makes sense for objects with primary keys, and is effectively ignored
  /// otherwise.
  void addAll<T extends RealmObject>(Iterable<T> items, {bool update = false}) {
    for (final i in items) {
      add(i, update: update);
    }
  }

  /// Deletes a [RealmObject] from this `Realm`.
  void delete<T extends RealmObjectBase>(T object) {
    if (!object.isManaged) {
      throw RealmError('Cannot delete an unmanaged object');
    }

    _ensureManagedByThis(object, 'delete object from Realm');

    object.handle.delete();
  }

  /// Deletes many [RealmObject]s from this `Realm`.
  ///
  /// Efficiently deletes all objects from the `Realm` and clears the [items] collection of type [RealmResults], [RealmList] or [RealmSet].
  /// Throws [RealmException] if there is no active write transaction.
  void deleteMany<T extends RealmObject>(Iterable<T> items) {
    if (items is RealmResults<T>) {
      _ensureManagedByThis(items, 'delete objects from Realm');

      items.handle.deleteAll();
    } else if (items is ManagedRealmList<T>) {
      _ensureManagedByThis(items, 'delete objects from Realm');

      items.handle.deleteAll();
    } else if (items is ManagedRealmSet<T>) {
      _ensureManagedByThis(items, 'delete objects from Realm');

      items.handle.deleteAll();
    } else {
      for (T realmObject in items) {
        delete(realmObject);
      }
    }
  }

  /// Checks whether the `Realm` is in write transaction.
  bool get isInTransaction => handle.isWritable;

  bool _isSubtype<S, T>() => <S>[] is List<T>;
  bool _isFuture<T>() => T != Never && _isSubtype<T, Future>();

  /// Synchronously calls the provided callback inside a write transaction.
  ///
  /// If no exception is thrown from within the callback, the transaction will be committed.
  /// It is more efficient to update several properties or even create multiple objects in a single write transaction.
  T write<T>(T Function() writeCallback) {
    assert(!_isFuture<T>(), 'writeCallback must be synchronous');
    final transaction = beginWrite();
    try {
      T result = writeCallback();
      transaction.commit();
      return result;
    } catch (e) {
      transaction.rollback();
      rethrow;
    }
  }

  /// Begins a write transaction for this [Realm].
  Transaction beginWrite() {
    handle.beginWrite();
    return Transaction._(this);
  }

  /// Asynchronously begins a write transaction for this [Realm]. You can supply a
  /// [CancellationToken] to cancel the operation.
  Future<Transaction> beginWriteAsync([CancellationToken? cancellationToken]) async {
    await handle.beginWriteAsync(cancellationToken);
    return Transaction._(this);
  }

  /// Executes the provided [writeCallback] in a temporary write transaction. Both acquiring the write
  /// lock and committing the transaction will be done asynchronously.
  Future<T> writeAsync<T>(T Function() writeCallback, [CancellationToken? cancellationToken]) async {
    assert(!_isFuture<T>(), 'writeCallback must be synchronous');
    final transaction = await beginWriteAsync(cancellationToken);
    try {
      T result = writeCallback();
      await transaction.commitAsync(cancellationToken);
      return result;
    } catch (e) {
      if (isInTransaction) {
        transaction.rollback();
      }
      rethrow;
    }
  }

  /// Closes the `Realm`.
  ///
  /// All [RealmObject]s and `Realm ` collections are invalidated and can not be used.
  /// This method will not throw if called multiple times.
  void close() {
    if (isClosed) {
      return;
    }

    _schemaCallbackHandle?.release();
    handle.close();
    handle.release();
  }

  /// Checks whether the `Realm` is closed.
  bool get isClosed => _handle.released || handle.isClosed;

  /// Fast lookup for a [RealmObject] with the specified [primaryKey].
  T? find<T extends RealmObject>(Object? primaryKey) {
    final metadata = _metadata.getByType(T);

    final handle = _handle.find(metadata.classKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    var object = RealmObjectInternal.create(T, this, handle, accessor);
    return object as T;
  }

  /// Returns all [RealmObject]s of type `T` in the `Realm`
  ///
  /// The returned [RealmResults] allows iterating all the values without further filtering.
  RealmResults<T> all<T extends RealmObject>() {
    final metadata = _metadata.getByType(T);
    final handle = this.handle.findAll(metadata.classKey);
    return RealmResultsInternal.create<T>(handle, this, metadata);
  }

  /// Returns all [RealmObject]s that match the specified [query].
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query<T extends RealmObject>(String query, [List<Object?> args = const []]) {
    final metadata = _metadata.getByType(T);
    return RealmResultsInternal.create<T>(
      _handle.queryClass(metadata.classKey, query, args),
      this,
      metadata,
    );
  }

  /// Deletes all [RealmObject]s of type `T` in the `Realm`
  void deleteAll<T extends RealmObject>() => deleteMany(all<T>());

  /// Returns a frozen (immutable) snapshot of this Realm.
  ///
  /// A frozen Realm is an immutable snapshot view of a particular version of a
  /// Realm's data. Unlike normal [Realm] instances, it does not live-update to
  /// reflect writes made to the Realm. Writing to a frozen Realm is not allowed,
  /// and attempting to begin a write transaction will throw an exception.
  ///
  /// All objects and collections read from a frozen Realm will also be frozen.
  ///
  /// Note: Keeping a large number of frozen Realms with different versions alive can
  /// have a negative impact on the file size of the underlying database.
  Realm freeze() {
    if (isFrozen) {
      return this;
    }

    return Realm._(config, handle.freeze());
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Realm) return false;
    return handle == other.handle;
  }

  /// The logger that will emit log messages from the database and SDK operations.
  /// To receive log messages, use the [RealmLogger.onRecord] stream.
  ///
  /// If no isolate subscribes to the stream, the trace messages will go to stdout.
  ///
  /// The default log level is [LogLevel.info].
  static const logger = RealmLogger();

  /// Used to shutdown Realm and allow the process to correctly release native resources and exit.
  ///
  /// Disclaimer: This method is mostly needed on Dart standalone and if not called the Dart program will hang and not exit.
  /// This is a workaround of a Dart VM bug and will be removed in a future version of the SDK.
  static void shutdown() => scheduler.stop();

  // For debugging only. Enable in realm_dart.cpp
  // static void gc() => realmCore.invokeGC();

  void _ensureManagedByThis(RealmEntity entity, String operation) {
    if (entity.realm != this) {
      if (entity.isFrozen) {
        throw RealmError('Cannot $operation because the object is managed by a frozen Realm');
      }

      throw RealmError('Cannot $operation because the object is managed by another Realm instance');
    }
  }

  /// Compacts a Realm file. A Realm file usually contains free/unused space.
  ///
  /// This method removes this free space and the file size is thereby reduced.
  /// Objects within the Realm file are untouched.
  /// Note: The file system should have free space for at least a copy of the Realm file. This method must not be called inside a transaction.
  /// The Realm file is left untouched if any file operation fails.
  static bool compact(Configuration config) {
    if (config is InMemoryConfiguration) {
      throw RealmException("Can't compact an in-memory Realm");
    }

    if (!Realm.existsSync(config.path)) {
      print("realm file doesn't exist: ${config.path}");
      return false;
    }

    final realm = Realm(config);
    try {
      return realm.handle.compact();
    } finally {
      realm.close();
    }
  }

  /// Writes a compacted copy of the `Realm` to the path in the specified config. If the configuration object has
  /// non-null [Configuration.encryptionKey], the copy will be encrypted with that key.
  ///
  /// 1. The destination file should not already exist.
  /// 2. Copying realm is not allowed within a write transaction as well as during migration.
  /// 3. When using synced Realm, it is required that all local changes are synchronized with the server before the copy can be written.
  ///    This is to be sure that the file can be used as a starting point for a newly installed application.
  ///    The function will throw if there are pending uploads.
  /// 4. Copying a local `Realm` to a synced `Realm` is not supported.
  void writeCopy(Configuration config) {
    if (isInTransaction || _isInMigration) {
      throw RealmError("Copying a Realm is not allowed within a write transaction or during migration.");
    }

    handle.writeCopy(config);
  }

  /// Update the `Realm` instance and outstanding objects to point to the most recent persisted version.
  ///
  /// If another process or [Isolate] has made changes to the realm file, this causes
  /// those changes to become visible in this realm instance.
  /// Typically you don't need to call this method since Realm has auto-refresh built-in.
  /// Note that this may return `true` even if no data has actually changed.
  bool refresh() {
    return handle.refresh();
  }

  /// Returns a [Future] that will complete when the `Realm` is refreshed to the version which is the
  /// latest version at the time when this method is called.
  ///
  /// Note that this may return `true` even if no data has actually changed.
  Future<bool> refreshAsync() async {
    return handle.refreshAsync();
  }

  /// Allows listening for schema changes on this Realm. Only dynamic and synchronized
  /// Realms will emit schema change notifications.
  ///
  /// Returns a [Stream] of [RealmSchemaChanges] that can be listened to.
  // TODO: this is private due to https://github.com/realm/realm-core/issues/7426. Once that is fixed, we can expose it.
  Stream<RealmSchemaChanges> get _schemaChanges {
    late StreamController<RealmSchemaChanges> controller;
    controller = StreamController<RealmSchemaChanges>(
        onListen: () => _schemaChangeListeners.add(controller),
        onPause: () => _schemaChangeListeners.remove(controller),
        onResume: () => _schemaChangeListeners.add(controller),
        onCancel: () => _schemaChangeListeners.remove(controller),
        sync: true);
    return controller.stream;
  }

  void _updateSchema() {
    final newSchema = handle.readSchema();
    for (final listener in _schemaChangeListeners) {
      listener.add(RealmSchemaChanges._(schema, newSchema));
    }

    for (final schemaObject in newSchema) {
      final existing = schema.firstWhereOrNull((s) => s.name == schemaObject.name);
      if (existing == null) {
        schema.add(schemaObject);
        final meta = handle.getObjectMetadata(schemaObject);
        metadata._add(meta);
      } else if (schemaObject.length > existing.length) {
        final existingMeta = metadata.getByName(schemaObject.name);
        final propertyMeta = handle.getPropertiesMetadata(existingMeta.classKey, existingMeta.primaryKey);
        for (final property in schemaObject) {
          final existingProp = existing.firstWhereOrNull((e) => e.mapTo == property.mapTo);
          if (existingProp == null) {
            existing.add(property);
            existingMeta[property.name] = propertyMeta[property.name]!;
          }
        }
      }
    }
  }

  void disableAutoRefreshForTesting() => handle.disableAutoRefreshForTesting();
}

/// Describes the schema changes that occurred on a Realm
class RealmSchemaChanges {
  /// The current schema, as returned by [Realm.schema].
  final RealmSchema currentSchema;

  /// The new schema that will be applied to the Realm as soon as the event handler completes.
  final RealmSchema newSchema;

  RealmSchemaChanges._(this.currentSchema, this.newSchema);
}

/// Provides a scope to safely write data to a [Realm]. Can be created using [Realm.beginWrite] or
/// [Realm.beginWriteAsync].
class Transaction {
  Realm? _realm;

  /// Returns whether the transaction is still active.
  bool get isOpen => _realm != null;

  Transaction._(Realm realm) {
    _realm = realm;
  }

  /// Commits the changes to the Realm.
  void commit() {
    final realm = _ensureOpen('commit');

    realm.handle.commitWrite();

    _closeTransaction();
  }

  /// Commits the changes to the Realm asynchronously.
  /// Canceling the commit using the [cancellationToken] will not abort the transaction, but
  /// rather resolve the future immediately with a [CancelledException].
  Future<void> commitAsync([CancellationToken? cancellationToken]) async {
    final realm = _ensureOpen('commitAsync');

    await realm.handle.commitWriteAsync(cancellationToken);

    _closeTransaction();
  }

  /// Undoes all changes made in the transaction.
  void rollback() {
    final realm = _ensureOpen('rollback');

    if (!realm.isClosed) {
      realm.handle.rollbackWrite();
    }

    _closeTransaction();
  }

  Realm _ensureOpen(String action) {
    if (!isOpen) {
      throw RealmException('Transaction was already closed. Cannot $action');
    }

    return _realm!;
  }

  void _closeTransaction() {
    _realm = null;
  }
}

/// @nodoc
extension RealmInternal on Realm {
  RealmHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access realm that has been closed');
    }

    return _handle;
  }

  static Realm getUnowned(Configuration config, RealmHandle handle, {bool isInMigration = false}) {
    return Realm._(config, handle, isInMigration);
  }

  RealmObjectBase createObject(Type type, ObjectHandle handle, RealmObjectMetadata metadata) {
    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    return RealmObjectInternal.create(type, this, handle, accessor);
  }

  RealmList<T> createList<T extends Object?>(ListHandle handle, RealmObjectMetadata? metadata) {
    return RealmListInternal.create<T>(handle, this, metadata);
  }

  RealmSet<T> createSet<T extends Object?>(SetHandle handle, RealmObjectMetadata? metadata) {
    return RealmSetInternal.create<T>(handle, this, metadata);
  }

  RealmMap<T> createMap<T extends Object?>(MapHandle handle, RealmObjectMetadata? metadata) {
    return RealmMapInternal.create<T>(handle, this, metadata);
  }

  List<String> getPropertyNames(RealmObjectBase obj, List<int> propertyKeys) {
    final metadata = _metadata.tryGetByType(obj.runtimeType) ?? _metadata.getByName(obj.objectSchema.name);
    final result = <String>[];
    for (var key in propertyKeys) {
      final name = metadata.getPropertyName(key);
      if (name != null) {
        result.add(name);
      }
    }
    return result;
  }

  RealmMetadata get metadata => _metadata;

  void manageEmbedded(ObjectHandle handle, EmbeddedObject object, {bool update = false}) {
    final metadata = _metadata.getByType(object.runtimeType);

    final accessor = RealmCoreAccessor(metadata, _isInMigration);
    object.manage(this, handle, accessor, update);
  }

  /// This should only be used for testing
  RealmResults<T> allEmbedded<T extends EmbeddedObject>() {
    final metadata = _metadata.getByType(T);
    final resultsHandle = handle.findAll(metadata.classKey);
    return RealmResultsInternal.create<T>(resultsHandle, this, metadata);
  }

  T? resolveObject<T extends RealmObjectBase>(T object) {
    if (!object.isManaged) {
      throw RealmStateError("Can't resolve unmanaged objects");
    }

    if (!object.isValid) {
      throw RealmStateError("Can't resolve invalidated (deleted) objects");
    }

    final newHandle = object.handle.resolveIn(handle);
    if (newHandle == null) {
      return null;
    }

    final metadata = (object.accessor as RealmCoreAccessor).metadata;

    return RealmObjectInternal.create(T, this, newHandle, RealmCoreAccessor(metadata, _isInMigration)) as T;
  }

  RealmList<T>? resolveList<T extends Object?>(ManagedRealmList<T> list) {
    final newHandle = list.handle.resolveIn(handle);
    if (newHandle == null) {
      return null;
    }

    return createList<T>(newHandle, list.metadata);
  }

  RealmResults<T> resolveResults<T extends Object?>(RealmResults<T> results) {
    final newHandle = results.handle.resolveIn(handle);
    return RealmResultsInternal.create<T>(newHandle, this, results.metadata);
  }

  RealmSet<T>? resolveSet<T extends Object?>(ManagedRealmSet<T> set) {
    final newHandle = set.handle.resolveIn(handle);
    if (newHandle == null) {
      return null;
    }

    return createSet<T>(newHandle, set.metadata);
  }

  RealmMap<T>? resolveMap<T extends Object?>(ManagedRealmMap map) {
    final newHandle = map.handle.resolveIn(handle);
    if (newHandle == null) {
      return null;
    }

    return createMap<T>(newHandle, map.metadata);
  }

  static MigrationRealm getMigrationRealm(Realm realm) => MigrationRealm._(realm);

  bool get isInMigration => _isInMigration;

  void addUnmanagedRealmObjectFromValue(Object? value, bool update) {
    if (value is RealmObject && !value.isManaged) {
      add<RealmObject>(value, update: update);
    }

    if (value is RealmValue) {
      addUnmanagedRealmObjectFromValue(value.value, update);
    }
  }

  void updateSchema() {
    _updateSchema();
  }
}

/// @nodoc
abstract class NotificationsController {
  NotificationTokenHandle? handle;

  NotificationTokenHandle subscribe();
  void onChanges(HandleBase changesHandle);
  void onError(RealmError error);

  void start() {
    if (handle != null) {
      throw RealmStateError("Realm notifications subscription already started");
    }

    handle = subscribe();
  }

  void stop() {
    // If handle is null or released, no-op
    if (handle?.released != false) {
      return;
    }

    handle!.release();
    handle = null;
  }
}

/// @nodoc
class RealmMetadata {
  final _typeMap = <Type, RealmObjectMetadata>{};
  final _stringMap = <String, RealmObjectMetadata>{};
  final _classKeyMap = <int, RealmObjectMetadata>{};

  RealmMetadata._(Iterable<RealmObjectMetadata> objectMetadatas) {
    for (final metadata in objectMetadatas) {
      _add(metadata);
    }
  }

  /// This is used when constructing the metadata, but also when the Realm schema
  /// changes.
  void _add(RealmObjectMetadata metadata) {
    if (!metadata.schema.isGenericRealmObject) {
      _typeMap[metadata.schema.type] = metadata;
    } else {
      _stringMap[metadata.schema.name] = metadata;
    }
    _classKeyMap[metadata.classKey] = metadata;
  }

  RealmObjectMetadata getByType(Type type) {
    final metadata = _typeMap[type];
    if (metadata == null) {
      throw RealmError("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
    }

    return metadata;
  }

  RealmObjectMetadata? tryGetByType(Type type) => _typeMap[type];

  RealmObjectMetadata getByName(String type) {
    var metadata = _stringMap[type];
    if (metadata == null) {
      metadata = _typeMap.values.firstWhereOrNull((v) => v.schema.name == type);
      if (metadata == null) {
        throw RealmError("Object type $type not configured in the current Realm's schema. Add type $type to your config before opening the Realm");
      }

      _stringMap[type] = metadata;
    }

    return metadata;
  }

  RealmObjectMetadata? getByClassKeyIfExists(int key) => _classKeyMap[key];

  (Type type, RealmObjectMetadata meta) getByClassKey(int key) {
    final meta = _classKeyMap[key];
    if (meta != null) {
      final type = _typeMap.entries.firstWhereOrNull((e) => e.value.classKey == key)?.key ?? RealmObjectBase;
      return (type, meta);
    }
    throw RealmError("Object with classKey $key not found in the current Realm's schema.");
  }
}

/// Exposes a set of dynamic methods on the Realm object. These don't use strongly typed
/// classes and instead lookup objects by string name.
///
/// {@category Realm}
class DynamicRealm {
  final Realm _realm;

  DynamicRealm._(this._realm);

  /// Returns all [RealmObject]s of type [className] in the `Realm`
  ///
  /// The returned [RealmResults] allows iterating all the values without further filtering.
  RealmResults<RealmObject> all(String className) {
    final metadata = _realm._metadata.getByName(className);
    final handle = _realm.handle.findAll(metadata.classKey);
    return RealmResultsInternal.create<RealmObject>(handle, _realm, metadata);
  }

  /// Fast lookup for a [RealmObject] of type [className] with the specified [primaryKey].
  RealmObject? find(String className, Object primaryKey) {
    final metadata = _realm._metadata.getByName(className);

    final handle = _realm.handle.find(metadata.classKey, primaryKey);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, _realm._isInMigration);
    return RealmObjectInternal.create(RealmObject, _realm, handle, accessor) as RealmObject;
  }

  /// Creates a managed RealmObject with the specified [className] and [primaryKey].
  RealmObject create(String className, {Object? primaryKey}) {
    final metadata = _realm._metadata.getByName(className);

    ObjectHandle handle;
    if (metadata.primaryKey != null) {
      if (primaryKey == null) {
        throw RealmError("The class $className has primary key defined, but you didn't pass one");
      }

      handle = _realm._handle.createWithPrimaryKey(metadata.classKey, primaryKey);
    } else {
      if (primaryKey != null) {
        throw RealmError("The class $className doesn't have primary key defined, but you passed $primaryKey");
      }

      handle = _realm._handle.create(metadata.classKey);
    }

    final accessor = RealmCoreAccessor(metadata, _realm._isInMigration);
    return RealmObjectInternal.create(RealmObject, _realm, handle, accessor) as RealmObject;
  }
}

/// A class used during a migration callback. It exposes a set of dynamic API as
/// well as the Realm config and schema.
///
/// {@category Realm}
class MigrationRealm extends DynamicRealm {
  /// The [Configuration] object used to open this [Realm]
  Configuration get config => _realm.config;

  /// The schema of this [Realm]. If the [Configuration] was created with a
  /// non-empty list of schemas, this will match the collection. Otherwise,
  /// the schema will be read from the file.
  RealmSchema get schema => _realm.schema;

  MigrationRealm._(super.realm) : super._();
}

/// @nodoc
extension RealmValueInternal on RealmValue {
  RealmCollectionType? get collectionType {
    if (type == RealmValueType.list) return RealmCollectionType.list;
    if (type == RealmValueType.map) return RealmCollectionType.map;
    return null;
  }
}

/// Extensions on RealmValue providing convenience conversion operators
extension RealmValueConvenience on RealmValue {
  /// Casts [value] to a List<RealmValue>. It will throw an exception if [value] is not a list.
  RealmList<RealmValue> asList() {
    if (value is RealmList<RealmValue>) {
      return as<RealmList<RealmValue>>();
    }

    return RealmListInternal.createFromList(as<List<RealmValue>>());
  }

  /// Casts [value] to a Map<String, RealmValue>. It will throw an exception if [value] is not a map.
  RealmMap<RealmValue> asMap() {
    if (value is RealmMap<RealmValue>) {
      return as<RealmMap<RealmValue>>();
    }

    return RealmMapInternal.createFromMap(as<Map<String, RealmValue>>());
  }
}
