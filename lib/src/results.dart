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

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the Realm that match the underlying query.
///
/// {@category Realm}
class RealmResults<T extends RealmObject> extends collection.IterableBase<T> {
  final RealmResultsHandle _handle;

  /// The Realm instance this collection belongs to.
  final Realm realm;

  final _supportsSnapshot = <T>[] is List<RealmObject?>;

  RealmResults._(this._handle, this.realm);

  /// Returns the element of type `T` at the specified [index].
  T operator [](int index) {
    final handle = realmCore.getObjectAt(this, index);
    return realm.createObject(T, handle) as T;
  }

  /// Returns a new [RealmResults] filtered according to the provided query.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query(String query, [List<Object> args = const []]) {
    final handle = realmCore.queryResults(this, query, args);
    return RealmResultsInternal.create<T>(handle, realm);
  }

  /// `true` if the `Results` collection is empty.
  @override
  bool get isEmpty => length == 0;

  /// Returns a new `Iterator` that allows iterating the elements in this `RealmResults`.
  @override
  Iterator<T> get iterator {
    var results = this;
    if (_supportsSnapshot) {
      final handle = realmCore.resultsSnapshot(this);
      results = RealmResults._(handle, realm);
    }
    return _RealmResultsIterator(results);
  }

  /// The number of values in this `Results` collection.
  @override
  int get length => realmCore.getResultsCount(this);

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmResultsChanges<T>> get changes {
    final controller = ResultsNotificationsController<T>(this);
    return controller.createStream();
  }
}

/// @nodoc
//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
  RealmResultsHandle get handle => _handle;

  static RealmResults<T> create<T extends RealmObject>(RealmResultsHandle handle, Realm realm) {
    return RealmResults<T>._(handle, realm);
  }
}

/// Describes the changes in a Realm results collection since the last time the notification callback was invoked.
class RealmResultsChanges<T extends RealmObject> extends RealmCollectionChanges {
  /// The results collection being monitored for changes.
  final RealmResults<T> results;

  RealmResultsChanges._(super.handle, this.results);
}

/// @nodoc
class ResultsNotificationsController<T extends RealmObject> extends NotificationsController {
  final RealmResults<T> results;
  late final StreamController<RealmResultsChanges<T>> streamController;

  ResultsNotificationsController(this.results);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeResultsNotifications(results, this);
  }

  Stream<RealmResultsChanges<T>> createStream() {
    streamController = StreamController<RealmResultsChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(Handle changesHandle) {
    if (changesHandle is! RealmCollectionChangesHandle) {
      throw RealmError("Invalid changes handle. RealmCollectionChangesHandle expected");
    }

    final changes = RealmResultsChanges._(changesHandle, results);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}

class _RealmResultsIterator<T extends RealmObject> implements Iterator<T> {
  final RealmResults<T> _results;
  int _index;
  T? _current;

  _RealmResultsIterator(RealmResults<T> results)
      : _results = results,
        _index = -1;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    int length = _results.length;
    _index++;
    if (_index >= length) {
      _current = null;
      return false;
    }
    _current = _results[_index];

    return true;
  }
}
