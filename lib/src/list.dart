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
/// added to or deleted from the Realm that match the underlying query.
///
///{@category Realm}
class RealmList<T extends Object> extends collection.ListBase<T> {
  final RealmListHandle _handle;
  
  /// The Realm isntance this collection belongs to.
  final Realm realm;

  RealmList._(this._handle, this.realm);

  /// The length of this [RealmList].
  @override
  int get length => realmCore.getListSize(handle);

  /// @nodoc
  //settng lenght is no operation
  @override
  set length(int length) {}

  /// Returns the element at the specified index.
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

  /// Sets the element at the specified index in the list.
  @override
  void operator []=(int index, T value) {
    RealmListInternal.setValue(handle, realm, index, value);
  }

  /// Clears the collection in memory and the references
  /// to the objects in this collection in Realm.

  /// Removes all elements from this list.
  ///
  /// The length of the list becomes zero.
  /// If the elements are managed [RealmObject]s, they all remain in the Realm.
  @override
  void clear() {
    realmCore.listClear(this);
  }

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid => realmCore.listIsValid(this);
}

// The query operations on lists only work for list of objects (core restriction),
// so we add it as an extension method to allow the compiler to prevent misuse.
extension RealmListOfObject<T extends RealmObject> on RealmList<T> {
  
  /// Filters the list and returns a new [RealmResults] according to the provided query.
  ///
  /// Only works for lists of Realm objects.
  ///
  /// @param query The query used to filter the list
  /// @param args Optional parameters for substitution in the query
  ///
  /// @return The live result
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  ///
  /// Only works for lists of objects.
  RealmResults<T> query(String query, [List<Object> args = const []]) {
    final handle = realmCore.queryList(this, query, args);
    return RealmResultsInternal.create<T>(handle, realm);
  }

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmListChanges<T>> get changes {
    final controller = ListNotificationsController<T>(this);
    return controller.createStream();
  }
}

/// @nodoc
extension RealmListInternal on RealmList {
  RealmListHandle get handle => _handle;

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
  final RealmList<T> list;
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

