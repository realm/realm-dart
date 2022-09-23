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

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:collection/collection.dart' as collection;

import 'collections.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'results.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the collection or from the Realm.
///
/// {@category Realm}
abstract class RealmList<T extends Object?> with RealmEntityMixin implements List<T>, Finalizable {
  RealmObjectMetadata? get _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  factory RealmList._(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmList._(handle, realm, metadata);
  factory RealmList(Iterable<T> items) => UnmanagedRealmList(items);

  /// Creates a frozen snapshot of this `RealmList`.
  RealmList<T> freeze();
}

class ManagedRealmList<T extends Object?> with RealmEntityMixin, ListMixin<T> implements RealmList<T> {
  final RealmListHandle _handle;

  @override
  final RealmObjectMetadata? _metadata;

  ManagedRealmList._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  int get length => realmCore.getListSize(handle);

  /// Setting the `length` is a required method on [List], but makes less sense
  /// for [RealmList]s. You can only decrease the length, increasing it doesn't
  /// do anything.
  @override
  set length(int newLength) {
    var l = length;
    if (newLength < l) {
      removeRange(newLength, l);
    } else {
      throw RealmException('You cannot increase length on a realm list without adding elements');
    }
  }

  @override
  void removeRange(int start, int end) {
    var cnt = end - start;
    while (cnt-- > 0) {
      removeAt(start);
    }
  }

  @override
  bool remove(covariant T element) {
    if (element is RealmObject && !element.isManaged) {
      throw RealmStateError('Cannot call remove on a managed list with an element that is an unmanaged object');
    }
    final index = indexOf(element);
    final found = index > 0;
    if (found) {
      removeAt(index);
    }
    return found;
  }

  @override
  T operator [](int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      final value = realmCore.listGetElementAt(this, index);

      if (value is RealmObjectHandle) {
        return RealmObjectInternal.create<T>(realm, value, _metadata!);
      }

      return value as T;
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  void add(T element) {
    RealmListInternal.setValue(handle, realm, length, element);
  }

  @override
  void insert(int index, T element) {
    realmCore.listInsertElementAt(handle, index, element);
  }

  @override
  void operator []=(int index, T value) {
    RealmListInternal.setValue(handle, realm, index, value);
  }

  @override
  T removeAt(int index) {
    final result = this[index];
    realmCore.listRemoveElementAt(handle, index);
    return result;
  }

  /// Removes all objects from this list; the length of the list becomes zero.
  /// The objects are not deleted from the realm, but are no longer referenced from this list.
  @override
  void clear() => realmCore.listClear(handle);

  @override
  int indexOf(covariant T element, [int start = 0]) {
    if (element is RealmObject && !element.isManaged) {
      throw RealmStateError('Cannot call indexOf on a managed list with an element that is an unmanaged object');
    }
    if (start < 0) start = 0;
    final index = realmCore.listFind(this, element);
    return index < start ? -1 : index; // to align with dart list semantics
  }

  @override
  bool get isValid => realmCore.listIsValid(this);

  @override
  RealmList<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveList(this)!;
  }
}

class UnmanagedRealmList<T extends Object?> extends collection.DelegatingList<T> with RealmEntityMixin implements RealmList<T> {
  UnmanagedRealmList([Iterable<T>? items]) : super(List<T>.from(items ?? <T>[]));

  @override
  RealmObjectMetadata? get _metadata => throw RealmException("Unmanaged lists don't have metadata associated with them.");

  @override
  bool get isValid => true;

  @override
  RealmList<T> freeze() => throw RealmStateError("Unmanaged lists can't be frozen");
}

// The query operations on lists, as well as the ability to subscribe for notifications,
// only work for list of objects (core restriction), so we add these as an extension methods
// to allow the compiler to prevent misuse.
extension RealmListOfObject<T extends RealmObject<T>> on RealmList<T> {
  /// Filters the list and returns a new [RealmResults] according to the provided [query] (with optional [arguments]).
  ///
  /// Only works for lists of [RealmObject]s.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query(String query, [List<Object> arguments = const []]) {
    final managedList = asManaged();
    final handle = realmCore.queryList(managedList, query, arguments);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmListChanges<T>> get changes {
    if (isFrozen) {
      throw RealmStateError('List is frozen and cannot emit changes');
    }

    final managedList = asManaged();
    final controller = ListNotificationsController<T>(managedList);
    return controller.createStream();
  }
}

/// @nodoc
extension RealmListInternal<T extends Object?> on RealmList<T> {
  @pragma('vm:never-inline')
  void keepAlive() {
    final self = this;
    if (self is ManagedRealmList<T>) {
      realm.keepAlive();
      self._handle.keepAlive();
    }
  }

  ManagedRealmList<T> asManaged() => this is ManagedRealmList<T> ? this as ManagedRealmList<T> : throw RealmStateError('$this is not managed');

  RealmListHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a list that belongs to a closed Realm');
    }

    return result;
  }

  RealmObjectMetadata? get metadata => asManaged()._metadata;

  static RealmList<T> create<T extends Object?>(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => RealmList<T>._(handle, realm, metadata);

  static void setValue<T>(RealmListHandle handle, Realm realm, int index, T? value, {bool update = false}) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      if (value is RealmObject<T> && !value.isManaged) {
        realm.createThenAddOrUpdate(value, update);
      }

      final length = realmCore.getListSize(handle);
      if (index >= length) {
        realmCore.listInsertElementAt(handle, index, value);
      } else {
        realmCore.listSetElementAt(handle, index, value);
      }
    } on Exception catch (e) {
      throw RealmException("Error setting value at index $index. Error: $e");
    }
  }
}

/// Describes the changes in a Realm results collection since the last time the notification callback was invoked.
class RealmListChanges<T extends Object> extends RealmCollectionChanges {
  /// The collection being monitored for changes.
  final RealmList<T> list;

  RealmListChanges._(super.handle, this.list);
}

/// @nodoc
class ListNotificationsController<T extends Object> extends NotificationsController {
  final ManagedRealmList<T> list;
  late final StreamController<RealmListChanges<T>> streamController;

  ListNotificationsController(this.list);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeListNotifications(list, this);
  }

  Stream<RealmListChanges<T>> createStream() {
    streamController = StreamController<RealmListChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmCollectionChangesHandle) {
      throw RealmError("Invalid changes handle. RealmCollectionChangesHandle expected");
    }

    final changes = RealmListChanges._(changesHandle, list);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}
