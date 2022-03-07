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
/// added to or deleted to the list or from the Realm.
///
/// {@category Realm}
abstract class RealmList<T extends Object> with RealmEntity implements List<T> {
  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  factory RealmList._(RealmListHandle handle, Realm realm) => ManagedRealmList._(handle, realm);
  factory RealmList(Iterable<T> items) => UnmanagedRealmList(items);
}

class ManagedRealmList<T extends Object> extends collection.ListBase<T> with RealmEntity implements RealmList<T> {
  final RealmListHandle _handle;

  ManagedRealmList._(this._handle, Realm realm) {
    setRealm(realm);
  }

  @override
  int get length => realmCore.getListSize(_handle);

  @override
  set length(int length) {} // no-op for managed lists

  @override
  T operator [](int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      final value = realmCore.listGetElementAt(this, index);

      if (value is RealmObjectHandle) {
        return realm.createObject(T, value) as T;
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
  void clear() => realmCore.listClear(this);

  @override
  bool get isValid => realmCore.listIsValid(this);
}

class UnmanagedRealmList<T extends Object> extends collection.ListBase<T> with RealmEntity implements RealmList<T> {
  late final _unmanaged = <T?>[]; // lazy ctor'ed (use T? for length=)

  UnmanagedRealmList([Iterable<T>? items]) {
    if (items != null) {
      _unmanaged.addAll(items);
    }
  }

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
    final handle = realmCore.queryList(this, query, arguments);
    return RealmResultsInternal.create<T>(handle, realm);
  }

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmListChanges<T>> get changes {
    final controller = ListNotificationsController<T>(managed);
    return controller.createStream();
  }
}

/// @nodoc
extension RealmListInternal<T extends Object> on RealmList<T> {
  ManagedRealmList<T> get managed => this as ManagedRealmList<T>;

  RealmListHandle get handle => managed._handle;

  static RealmList<T> create<T extends Object>(RealmListHandle handle, Realm realm) => RealmList<T>._(handle, realm);

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

  RealmListChanges._(RealmCollectionChangesHandle handle, this.list) : super(handle);
}

/// @nodoc
class ListNotificationsController<T extends Object> extends NotificationsController {
  final ManagedRealmList<T> list;
  late final StreamController<RealmListChanges<T>> streamController;

  ListNotificationsController(this.list);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeListNotifications(list._handle, this, list.realm.scheduler.handle);
  }

  Stream<RealmListChanges<T>> createStream() {
    streamController = StreamController<RealmListChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(Handle changesHandle) {
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
