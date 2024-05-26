// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:core';
import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart' as collection;

import 'native/collection_changes_handle.dart';
import 'native/handle_base.dart';
import 'native/notification_token_handle.dart';
import 'native/object_handle.dart';
import 'native/set_handle.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'collections.dart';
import 'results.dart';

/// RealmSet is a collection that contains no duplicate elements.
abstract class RealmSet<T extends Object?> extends SetBase<T> with RealmEntity {
  RealmObjectMetadata? _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  /// Creates an unmanaged RealmSet from [items]
  factory RealmSet(Set<T> items) => UnmanagedRealmSet(items.toSet());

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmSetChanges<T>> get changes;

  /// Returns the element of type `T` at the specified [index].
  ///
  /// Note that elements in a RealmSet move around arbitrarily when other elements are
  /// inserted/removed.
  @override
  T elementAt(int index) => super.elementAt(index);

  /// Whether [value] is in the set.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// final containsB = characters.contains('B'); // true
  /// final containsD = characters.contains('D'); // false
  /// ```
  @override
  bool contains(covariant T element); //Note: explicitly overriding contains() to change parameter type

  /// If an object equal to [element] is in the set, return it.
  ///
  /// Checks whether [element] is in the set, like [contains], and if so,
  /// returns the object in the set, otherwise returns `null`.
  ///
  /// If the equality relation used by the set is not identity,
  /// then the returned object may not be *identical* to [element].
  /// Some set implementations may not be able to implement this method.
  /// If the [contains] method is computed,
  /// rather than being based on an actual object instance,
  /// then there may not be a specific object instance representing the
  /// set element.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// final containsB = characters.lookup('B');
  /// print(containsB); // B
  /// final containsD = characters.lookup('D');
  /// print(containsD); // null
  /// ```
  @override
  T? lookup(covariant T element); //Note: explicitly overriding lookup() to change parameter type

  /// Removes [value] from the set.
  ///
  /// Returns `true` if [value] was in the set, and `false` if not.
  /// The method has no effect if [value] was not in the set.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// final didRemoveB = characters.remove('B'); // true
  /// final didRemoveD = characters.remove('D'); // false
  /// print(characters); // {A, C}
  /// ```
  @override
  bool remove(covariant T value); //Note: explicitly overriding remove() to change parameter type

  /// Converts this [Set] to a [RealmResults].
  RealmResults<T> asResults();

  /// Creates a frozen snapshot of this `RealmSet`.
  RealmSet<T> freeze();
}

class UnmanagedRealmSet<T extends Object?> extends collection.DelegatingSet<T> with RealmEntity implements RealmSet<T> {
  UnmanagedRealmSet([Set<T>? items]) : super(items ?? <T>{});

  @override
  bool add(T value) {
    _throwOnRealmValueCollection(value);

    return super.add(value);
  }

  @override
  // ignore: unused_element
  RealmObjectMetadata? get _metadata => throw RealmError("Unmanaged RealmSets don't have metadata associated with them.");

  @override
  // ignore: unused_element
  set _metadata(RealmObjectMetadata? _) => throw RealmError("Unmanaged RealmSets don't have metadata associated with them.");

  @override
  bool get isValid => true;

  @override
  Stream<RealmSetChanges<T>> get changes => throw RealmStateError("Unmanaged RealmSets don't support changes");

  @override
  RealmResults<T> asResults() => throw RealmStateError("Unmanaged sets can't be converted to results");

  @override
  RealmSet<T> freeze() => throw RealmStateError("Unmanaged sets can't be frozen");
}

class ManagedRealmSet<T extends Object?> with RealmEntity, SetMixin<T> implements RealmSet<T> {
  final SetHandle _handle;

  ManagedRealmSet._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  late final RealmObjectMetadata? _metadata;

  @override
  bool get isValid => handle.isValid;

  @override
  bool add(T value) {
    _throwOnRealmValueCollection(value);

    if (_isManagedRealmObject(value)) {
      //It is valid to call `add` with managed objects already in the set.
      _ensureManagedByThis(value, "add");
    } else {
      // might be updating an existing realm object
      realm.addUnmanagedRealmObjectFromValue(value, false);
    }

    return _handle.insert(value);
  }

  @override
  T elementAt(int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      var value = handle.elementAt(realm, index);
      if (value is ObjectHandle) {
        late RealmObjectMetadata targetMetadata;
        late Type type;
        if (T == RealmValue) {
          (type, targetMetadata) = realm.metadata.getByClassKey(value.classKey);
        } else {
          targetMetadata = _metadata!; // will be null for RealmValue, so defer until here
          type = T;
        }

        value = realm.createObject(type, value, targetMetadata);
      }

      if (T == RealmValue) {
        return RealmValue.from(value) as T;
      }

      return value as T;
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  bool contains(covariant T element) {
    if (!_isManagedRealmObject(element)) {
      return false;
    }

    _ensureManagedByThis(element, "contains");

    return handle.find(element);
  }

  @override
  T? lookup(covariant T element) {
    return contains(element) ? element : null;
  }

  @override
  bool remove(covariant T value) {
    if (!_isManagedRealmObject(value)) {
      return false;
    }

    _ensureManagedByThis(value, "remove");

    return handle.remove(value);
  }

  @override
  Iterator<T> get iterator => _RealmSetIterator(this);

  @override
  Set<T> toSet() => <T>{...this};

  @override
  void clear() => _handle.clear();

  @override
  int get length => handle.size;

  @override
  Stream<RealmSetChanges<T>> get changes {
    if (isFrozen) {
      throw RealmStateError('Set is frozen and cannot emit changes');
    }
    final controller = RealmSetNotificationsController<T>(asManaged());
    return controller.createStream();
  }

  void _ensureManagedByThis(covariant T element, String action) {
    Object? value = element;
    if (element is RealmValue && element.value is RealmObject) {
      value = element.value;
    }

    if (value is! RealmObject) {
      return;
    }

    RealmObject realmObject = value;

    if (realmObject.realm != realm) {
      if (realmObject.isFrozen) {
        throw RealmError('Cannot invoke "$action" because the object is managed by a frozen Realm');
      }

      throw RealmError('Cannot invoke "$action" because the object is managed by another Realm instance');
    }
  }

  bool _isManagedRealmObject(Object? object) {
    if (object is RealmObject) {
      if (!object.isManaged) {
        return false;
      }
    }

    if (object is RealmValue) {
      return _isManagedRealmObject(object.value);
    }

    return true;
  }

  @override
  RealmResults<T> asResults() => RealmResultsInternal.create<T>(handle.asResults, realm, _metadata);

  @override
  RealmSet<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveSet(this)!;
  }
}

/// @nodoc
extension RealmSetInternal<T extends Object?> on RealmSet<T> {
  ManagedRealmSet<T> asManaged() => this is ManagedRealmSet<T> ? this as ManagedRealmSet<T> : throw RealmStateError('$this is not managed');

  RealmObjectMetadata? get metadata => asManaged()._metadata;

  SetHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a RealmSet that belongs to a closed Realm');
    }

    return result;
  }

  static RealmSet<T> create<T extends Object?>(SetHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmSet<T>._(handle, realm, metadata);
}

class _RealmSetIterator<T extends Object?> implements Iterator<T> {
  final RealmSet<T> _set;
  int _index;
  T? _current;

  _RealmSetIterator(this._set) : _index = -1;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    _index++;
    if (_index >= _set.length) {
      _current = null;
      return false;
    }
    _current = _set.elementAt(_index);

    return true;
  }
}

/// Describes the changes in a Realm set collection since the last time the notification callback was invoked.
class RealmSetChanges<T extends Object?> extends RealmCollectionChanges {
  /// The collection being monitored for changes.
  final RealmSet<T> set;

  RealmSetChanges._(super.handle, this.set);

  /// `true` if the underlying set was deleted.
  bool get isCollectionDeleted => changes.isDeleted;
}

/// @nodoc
class RealmSetNotificationsController<T extends Object?> extends NotificationsController {
  final ManagedRealmSet<T> set;
  late final StreamController<RealmSetChanges<T>> streamController;

  RealmSetNotificationsController(this.set);

  @override
  NotificationTokenHandle subscribe() {
    return set.handle.subscribeForNotifications(this);
  }

  Stream<RealmSetChanges<T>> createStream() {
    streamController = StreamController<RealmSetChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! CollectionChangesHandle) {
      throw RealmError("Invalid changes handle. RealmCollectionChangesHandle expected");
    }

    final changes = RealmSetChanges._(changesHandle, set);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}

// The query operations on sets only work for sets of objects (core restriction),
// so we add these as an extension methods to allow the compiler to prevent misuse.
extension RealmSetOfObject<T extends RealmObjectBase> on RealmSet<T> {
  /// Filters the set and returns a new [RealmResults] according to the provided [query] (with optional [arguments]).
  ///
  /// Only works for sets of [RealmObject]s or [EmbeddedObject]s.
  ///
  /// For more details about the syntax of the Realm Query Language, refer to the documentation: https://www.mongodb.com/docs/realm/realm-query-language/.
  RealmResults<T> query(String query, [List<Object?> arguments = const []]) {
    final handle = asManaged().handle.query(query, arguments);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }
}

extension on RealmSet {
  void _throwOnRealmValueCollection(Object? value) {
    // There's no API in Core that would allow us to store a collection inside a Set.
    if (value is RealmValue && value.type.isCollection) {
      throw RealmStateError('Storing collections inside Set<RealmValue> is not supported');
    }
  }
}
