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
import 'dart:collection' as collection;

import 'collections.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'results.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the collection or from the Realm.
///
/// {@category Realm}
abstract class RealmList<T extends Object> with RealmEntity implements List<T> {
  late final RealmObjectMetadata? _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  factory RealmList._(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmList._(handle, realm, metadata);
  factory RealmList(Iterable<T> items) => UnmanagedRealmList(items);
}

class ManagedRealmList<T extends Object> extends collection.ListBase<T> with RealmEntity implements RealmList<T> {
  final RealmListHandle _handle;

  @override
  late final RealmObjectMetadata? _metadata;

  ManagedRealmList._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  int get length => realmCore.getListSize(_handle);

  @override

  /// Setting the `length` is a required method on [List], but makes no sense
  /// for [RealmList]s. Hence this operation is a no-op that simply ignores [newLength]
  set length(int newLength) {} // no-op for managed lists

  @override
  T operator [](int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      final value = realmCore.listGetElementAt(this, index);

      if (value is RealmObjectHandle) {
        return realm.createObject(T, value, _metadata!) as T;
      }

      return value as T;
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  void operator []=(int index, T value) {
    RealmListInternal.setValue(handle, realm, index, value);
  }

  @override

  /// Removes all objects from this list; the length of the list becomes zero.
  /// The objects are not deleted from the realm, but are no longer referenced from this list.
  void clear() => realmCore.listClear(this);

  @override
  bool get isValid => realmCore.listIsValid(this);
}

class UnmanagedRealmList<T extends Object> extends collection.ListBase<T> with RealmEntity implements RealmList<T> {
  final _unmanaged = <T?>[]; // use T? for length=

  UnmanagedRealmList([Iterable<T>? items]) {
    if (items != null) {
      _unmanaged.addAll(items);
    }
  }

  @override
  RealmObjectMetadata? get _metadata => throw RealmException("Unmanaged lists don't have metadata associated with them.");

  @override
  set _metadata(RealmObjectMetadata? _) => throw RealmException("Unmanaged lists don't have metadata associated with them.");

  @override
  int get length => _unmanaged.length;

  @override
  set length(int length) => _unmanaged.length = length;

  @override
  T operator [](int index) => _unmanaged[index] as T;

  @override
  void operator []=(int index, T value) => _unmanaged[index] = value;

  @override
  void clear() => _unmanaged.clear();

  @override
  bool get isValid => true;
}

// The query operations on lists, as well as the ability to subscribe for notifications,
// only work for list of objects (core restriction), so we add these as an extension methods
// to allow the compiler to prevent misuse.
extension RealmListOfObject<T extends RealmObject> on RealmList<T> {
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
    final managedList = asManaged();
    final controller = ListNotificationsController<T>(managedList);
    return controller.createStream();
  }
}

/// @nodoc
extension RealmListInternal<T extends Object> on RealmList<T> {
  ManagedRealmList<T> asManaged() => this is ManagedRealmList<T> ? this as ManagedRealmList<T> : throw RealmStateError('$this is not managed');

  RealmListHandle get handle => asManaged()._handle;

  static RealmList<T> create<T extends Object>(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => RealmList<T>._(handle, realm, metadata);

  static void setValue(RealmListHandle handle, Realm realm, int index, Object? value) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      if (value is RealmObject && !value.isManaged) {
        realm.add<RealmObject>(value);
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
