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
import 'dart:collection' as collection;

import 'native/realm_core.dart';
import 'realm_class.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the Realm that match the underlying query.
///
/// {@category Realm}
class RealmResults<T extends RealmObject> extends collection.IterableBase<T> {
  final RealmResultsHandle _handle;
  final Realm _realm;

  RealmResults._(this._handle, this._realm);

  /// Returns the element of type `T` at the specified [index]
  T operator [](int index) {
    final handle = realmCore.getObjectAt(this, index);
    return _realm.createObject(T, handle) as T;
  }

  /// Returns a new [RealmResults] filtered according to the provided query.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query(String query, [List<Object> args = const []]) {
    final handle = realmCore.queryResults(this, query, args);
    return RealmResultsInternal.create<T>(handle, _realm);
  }

  /// `true` if the `Results` collection is empty
  @override
  bool get isEmpty => length == 0;

  /// Returns a new `Iterator` that allows iterating the elements in this `RealmResults`
  @override
  Iterator<T> get iterator {
    RealmResults<T> results = this;
    bool isSubtypeOfRealmObject = (<T>[] is List<RealmObject>);
    if (isSubtypeOfRealmObject) {
      final handle = realmCore.resultsSnapshot(this);
      results = RealmResultsInternal.create<T>(handle, _realm);
    }
    return _RealmResultsIterator(results);
  }

  /// The number of values in this `Results` collection.
  @override
  int get length => realmCore.getResultsCount(this);
}

/// @nodoc
//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
  RealmResultsHandle get handle => _handle;

  static RealmResults<T> create<T extends RealmObject>(RealmResultsHandle handle, Realm realm) {
    return RealmResults<T>._(handle, realm);
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
