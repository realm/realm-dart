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

import 'dart:core';
import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:collection/collection.dart' as collection;

import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'collections.dart';

/// RealmSet is a collection that contains no duplicate elements.
abstract class RealmSet<T extends Object?> extends SetBase<T> with RealmEntity implements Finalizable {
  RealmObjectMetadata? _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

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

  /// If an object equal to [object] is in the set, return it.
  ///
  /// Checks whether [object] is in the set, like [contains], and if so,
  /// returns the object in the set, otherwise returns `null`.
  ///
  /// If the equality relation used by the set is not identity,
  /// then the returned object may not be *identical* to [object].
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

  //TODO: When adding Set of RealmObjects support: Removing a RealmObject is different than removing a primitive value
  /// Clear the set and if it is RealmSet<RealmObject> delete all realm objects from the realm.
  void deleteAll();
}

class UnmanagedRealmSet<T extends Object?> extends collection.DelegatingSet<T> with RealmEntity implements RealmSet<T> {
  UnmanagedRealmSet([Set<T>? items]) : super(items ?? <T>{});

  @override
  RealmObjectMetadata? get _metadata => throw RealmException("Unmanaged RealmSets don't have metadata associated with them.");

  @override
  set _metadata(RealmObjectMetadata? _) => throw RealmException("Unmanaged RealmSets don't have metadata associated with them.");

  @override
  bool get isValid => true;

  @override
  Stream<RealmSetChanges<T>> get changes => throw RealmStateError("Unmanaged RealmSets don't support changes");

  void deleteAll() => super.clear();
}

class ManagedRealmSet<T extends Object?> with RealmEntity, SetMixin<T> implements RealmSet<T> {
  final RealmSetHandle _handle;

  ManagedRealmSet._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  late final RealmObjectMetadata? _metadata;

  @override
  bool get isValid => realmCore.realmSetIsValid(this);

  @override
  bool add(T value) {
    //It is valid to call `add` with managed objects already in the set.
    if (value is RealmObject) {
      if (value.isManaged) {
        _ensureManagedByThis(value, "add");
      } else {
        // might be updating an existing realm object
        realm.add<RealmObject>(value, update: true);
      }
    }

    return realmCore.realmSetInsert(_handle, value);
  }

  @override
  T elementAt(int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      var value = realmCore.realmSetGetElementAt(this, index);
      if (value is RealmObjectHandle) {
        final RealmObjectMetadata targetMetadata = _metadata!;
        final Type type = T;
        value = realm.createObject(type, value, targetMetadata);
      }

      return value as T;
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  bool contains(covariant T element) {
    if (element is RealmObject) {
      if (!element.isManaged) {
        return false;
      }

      _ensureManagedByThis(element, "contains");
    }

    return realmCore.realmSetFind(this, element);
  }

  @override
  T? lookup(covariant T element) {
    return contains(element) ? element : null;
  }

  @override
  bool remove(covariant T value) {
    if (value is RealmObject) {
      if (!value.isManaged) {
        return false;
      }

      _ensureManagedByThis(value, "remove");
    }

    return realmCore.realmSetErase(this, value);
  }

  @override
  Iterator<T> get iterator => _RealmSetIterator(this);

  @override
  Set<T> toSet() => <T>{...this};

  @override
  void clear() => realmCore.realmSetClear(_handle);

  //TODO: implement
  void deleteAll() => RealmError("Not implemented");

  @override
  int get length => realmCore.realmSetSize(this);

  @override
  Stream<RealmSetChanges<T>> get changes {
    final controller = RealmSetNotificationsController<T>(asManaged());
    return controller.createStream();
  }

  void _ensureManagedByThis(covariant T element, String operation) {
    if (element is! RealmEntity) {
      return;
    }

    if (element.realm != realm) {
      if (element.isFrozen) {
        throw RealmError('Cannot do $operation because the object is managed by a frozen Realm');
      }

      throw RealmError('Cannot do $operation because the object is managed by another Realm instance');
    }
  }
}

/// @nodoc
extension RealmSetInternal<T extends Object?> on RealmSet<T> {
  ManagedRealmSet<T> asManaged() => this is ManagedRealmSet<T> ? this as ManagedRealmSet<T> : throw RealmStateError('$this is not managed');

  RealmSetHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a RealmSet that belongs to a closed Realm');
    }

    return result;
  }

  static RealmSet<T> create<T extends Object?>(RealmSetHandle handle, Realm realm, RealmObjectMetadata? metadata) =>
      ManagedRealmSet<T>._(handle, realm, metadata);

  // static void setValue<T extends Object?>(RealmSetHandle handle, Realm realm, Object? value, {bool update = false}) {
  //   try {
  //     if (value is RealmObject && !value.isManaged) {
  //       realm.add<RealmObject>(value, update: update);
  //     }

  //    return realmCore.realmSetInsert(handle, value);
  //   } on Exception catch (e) {
  //     throw RealmException("Error setting value at index $index. Error: $e");
  //   }
  // }
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
}

/// @nodoc
class RealmSetNotificationsController<T extends Object?> extends NotificationsController {
  final ManagedRealmSet<T> set;
  late final StreamController<RealmSetChanges<T>> streamController;

  RealmSetNotificationsController(this.set);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeSetNotifications(set, this);
  }

  Stream<RealmSetChanges<T>> createStream() {
    streamController = StreamController<RealmSetChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmCollectionChangesHandle) {
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