////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart' as collection;

import 'dart:ffi';

import 'collections.dart';
import 'native/realm_core.dart';
import 'realm_object.dart';
import 'realm_class.dart';
import 'results.dart';

/// RealmMap is a collection that contains key-value pairs of <String, T>.
abstract class RealmMap<T extends Object?> with RealmEntity implements MapBase<String, T>, Finalizable {
  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  /// Creates an unmanaged RealmMap from [items]
  factory RealmMap(Map<String, T> items) => UnmanagedRealmMap(items);

  /// Creates a frozen snapshot of this `RealmMap`.
  RealmMap<T> freeze();

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmMapChanges<T>> get changes;
}

class UnmanagedRealmMap<T extends Object?> extends collection.DelegatingMap<String, T> with RealmEntity implements RealmMap<T> {
  UnmanagedRealmMap([Map<String, T>? items]) : super(Map<String, T>.from(items ?? <String, T>{}));

  @override
  bool get isValid => true;

  @override
  RealmMap<T> freeze() => throw RealmStateError("Unmanaged maps can't be frozen");

  @override
  Stream<RealmMapChanges<T>> get changes => throw RealmStateError("Unmanaged maps don't support changes");
}

class ManagedRealmMap<T extends Object?> with RealmEntity, MapMixin<String, T> implements RealmMap<T> {
  final RealmMapHandle _handle;

  late final RealmObjectMetadata? _metadata;

  ManagedRealmMap._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  int get length => realmCore.mapGetSize(handle);

  @override
  T? remove(Object? key) {
    if (key is! String) {
      return null;
    }

    final value = this[key];
    if (realmCore.mapRemoveKey(handle, key)) {
      return value;
    }

    return null;
  }

  @override
  T? operator [](Object? key) {
    if (key is! String) {
      return null;
    }

    try {
      var value = realmCore.mapGetElement(this, key);
      if (value is RealmObjectHandle) {
        late RealmObjectMetadata targetMetadata;
        late Type type;
        if (T == RealmValue) {
          (type, targetMetadata) = realm.metadata.getByClassKey(realmCore.getClassKey(value));
        } else {
          targetMetadata = _metadata!;
          type = T;
        }
        value = realm.createObject(type, value, targetMetadata);
      }

      if (T == RealmValue) {
        // Maps must return `null` if attempting to access a non-existing key. Without this check,
        // we'd return RealmValue(null) which is different.
        if (value == null && !containsKey(key)) {
          return null;
        }

        value = RealmValue.from(value);
      }

      return value as T?;
    } on Exception catch (e) {
      throw RealmException("Error getting value at key $key. Error: $e");
    }
  }

  @override
  void operator []=(String key, Object? value) => RealmMapInternal.setValue(handle, realm, key, value);

  /// Removes all objects from this map; the length of the map becomes zero.
  /// The objects are not deleted from the realm, but are no longer referenced from this map.
  @override
  void clear() => realmCore.mapClear(handle);

  @override
  bool get isValid => realmCore.mapIsValid(this);

  @override
  RealmMap<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveMap(this)!;
  }

  @override
  Stream<RealmMapChanges<T>> get changes {
    if (isFrozen) {
      throw RealmStateError('Map is frozen and cannot emit changes');
    }
    final controller = MapNotificationsController<T>(asManaged());
    return controller.createStream();
  }

  @override
  Iterable<String> get keys => RealmResultsInternal.create<String>(realmCore.mapGetKeys(this), realm, null);

  @override
  Iterable<T> get values => RealmResultsInternal.create<T>(realmCore.mapGetValues(this), realm, metadata);

  @override
  bool containsKey(Object? key) => key is String && realmCore.mapContainsKey(this, key);

  @override
  bool containsValue(Object? value) {
    if (value is! T?) {
      return false;
    }

    if (value is RealmObjectBase && !value.isManaged) {
      return false;
    }

    if (value is RealmValue && value.value is RealmObjectBase && !(value.value as RealmObjectBase).isManaged) {
      return false;
    }

    return realmCore.mapContainsValue(this, value);
  }
}

/// Describes the changes in a Realm map collection since the last time the notification callback was invoked.
class RealmMapChanges<T extends Object?> {
  /// The collection being monitored for changes.
  final RealmMap<T> map;

  final RealmMapChangesHandle _handle;
  MapChanges? _values;

  RealmMapChanges._(this._handle, this.map);

  MapChanges get _changes => _values ??= realmCore.getMapChanges(_handle);

  /// The keys of the map which have been removed.
  List<String> get deleted => _changes.deletions;

  /// The keys of the map which were added.
  List<String> get inserted => _changes.insertions;

  /// The keys of the map, whose corresponding values were modified in this version.
  List<String> get modified => _changes.modifications;
}

// The query operations on maps only work for maps of objects (core restriction),
// so we add these as an extension methods to allow the compiler to prevent misuse.
extension RealmMapOfObject<T extends RealmObjectBase> on RealmMap<T?> {
  /// Filters the map values and returns a new [RealmResults] according to the provided [query] (with optional [arguments]).
  ///
  /// Only works for maps of [RealmObject]s or [EmbeddedObject]s.
  ///
  /// For more details about the syntax of the Realm Query Language, refer to the documentation: https://www.mongodb.com/docs/realm/realm-query-language/.
  RealmResults<T> query(String query, [List<Object?> arguments = const []]) {
    final handle = realmCore.queryMap(asManaged(), query, arguments);
    return RealmResultsInternal.create<T>(handle, realm, metadata);
  }
}

/// @nodoc
extension RealmMapInternal<T extends Object?> on RealmMap<T> {
  @pragma('vm:never-inline')
  void keepAlive() {
    final self = this;
    if (self is ManagedRealmMap<T>) {
      realm.keepAlive();
      self._handle.keepAlive();
    }
  }

  ManagedRealmMap<T> asManaged() => this is ManagedRealmMap<T> ? this as ManagedRealmMap<T> : throw RealmStateError('$this is not managed');

  RealmMapHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a map that belongs to a closed Realm');
    }

    return result;
  }

  RealmObjectMetadata? get metadata => asManaged()._metadata;

  static RealmMap<T> create<T extends Object?>(RealmMapHandle handle, Realm realm, RealmObjectMetadata? metadata) =>
      ManagedRealmMap<T>._(handle, realm, metadata);

  static void setValue(RealmMapHandle handle, Realm realm, String key, Object? value, {bool update = false}) {
    try {
      if (value is EmbeddedObject) {
        if (value.isManaged) {
          throw RealmError("Can't add to map an embedded object that is already managed");
        }

        final objHandle = realmCore.mapInsertEmbeddedObject(realm, handle, key);
        realm.manageEmbedded(objHandle, value);
        return;
      }

      if (value is RealmValue) {
        value = value.value;
      }

      if (value is RealmObject && !value.isManaged) {
        realm.add<RealmObject>(value, update: update);
      }

      realmCore.mapInsertValue(handle, key, value);
    } on Exception catch (e) {
      throw RealmException("Error setting value at key $key. Error: $e");
    }
  }
}

/// @nodoc
class MapNotificationsController<T extends Object?> extends NotificationsController {
  final ManagedRealmMap<T> map;
  late final StreamController<RealmMapChanges<T>> streamController;

  MapNotificationsController(this.map);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeMapNotifications(map, this);
  }

  Stream<RealmMapChanges<T>> createStream() {
    streamController = StreamController<RealmMapChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmMapChangesHandle) {
      throw RealmError("Invalid changes handle. RealmMapChangesHandle expected");
    }

    final changes = RealmMapChanges._(changesHandle, map);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}
