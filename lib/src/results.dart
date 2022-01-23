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
import 'realm_object.dart';

/// Instances of this class are typically live collections of [RealmObject]s returned by [Realm].
/// The objects this [RealmResults] collection matches the underlying query.
/// This collection will be updated when objects matching the underlying query
/// are either added to or deleted from the [Realm].
class RealmResults<E extends RealmObject> extends Iterable<E> {
  late final RealmResultsHandle _handle;
  late final Realm _realm;

  RealmResults._(this._handle, this._realm);

  /// Returns the Realm object of type `T` at the specified `index`
  E operator [](int index) {
    final handle = realmCore.getObjectAt(this, index);
    return _realm.createObject(E, handle) as E;
  }

  /// Returns a new `Results<T>` filtered according to the provided query.
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<E> query(String query, [List<Object> args = const []]) {
    final handle = realmCore.queryResults(this, query, args);
    return RealmResultsInternal.create<E>(handle, _realm);
  }

  /// Returns `true` if the Results collection is empty
  @override
  bool get isEmpty => length == 0;

  /// Iterates through all the [RealmObject]s in this [RealmResults]
  @override
  Iterator<E> get iterator => _RealmResultsIterator(this);

  /// Returns the number of values in the Results collection.
  @override
  int get length => realmCore.getResultsCount(this);

  ///@nodoc
  @override
  bool any(bool Function(E element) test) {
    return super.any(test);
  }

  ///@nodoc
  @override
  Iterable<R> cast<R>() {
    return super.cast<R>();
  }

  ///@nodoc
  @override
  bool contains(Object? element) {
    return super.contains(element);
  }

  ///@nodoc
  @override
  E elementAt(int index) {
    return super.elementAt(index);
  }

  ///@nodoc
  @override
  bool every(bool Function(E element) test) {
    return super.every(test);
  }

  ///@nodoc
  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return super.expand(toElements);
  }

  ///@nodoc
  @override
  E get first => super.first;

  ///@nodoc
  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return super.firstWhere(test, orElse: orElse);
  }

  ///@nodoc
  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return super.fold(initialValue, combine);
  }

  ///@nodoc
  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return super.followedBy(other);
  }

  ///@nodoc
  @override
  void forEach(void Function(E element) action) {
    return super.forEach(action);
  }

  ///@nodoc
  @override
  bool get isNotEmpty => super.isNotEmpty;

  ///@nodoc
  @override
  String join([String separator = ""]) {
    return super.join(separator);
  }

  ///@nodoc
  @override
  E get last => super.last;

  ///@nodoc
  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return super.lastWhere(test, orElse: orElse);
  }

  ///@nodoc
  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return super.map(toElement);
  }

  ///@nodoc
  @override
  E reduce(E Function(E value, E element) combine) {
    return super.reduce(combine);
  }

  ///@nodoc
  @override
  E get single => super.single;

  ///@nodoc
  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return super.singleWhere(test, orElse: orElse);
  }

  ///@nodoc
  @override
  Iterable<E> skip(int count) {
    return super.skip(count);
  }

  ///@nodoc
  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return super.skipWhile(test);
  }

  ///@nodoc
  @override
  Iterable<E> take(int count) {
    return super.take(count);
  }

  ///@nodoc
  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return super.takeWhile(test);
  }

  ///@nodoc
  @override
  List<E> toList({bool growable = true}) {
    return super.toList(growable: growable);
  }

  ///@nodoc
  @override
  Set<E> toSet() {
    return super.toSet();
  }

  ///@nodoc
  @override
  Iterable<E> where(bool Function(E element) test) {
    return super.where(test);
  }

  ///@nodoc
  @override
  Iterable<T> whereType<T>() {
    return super.whereType();
  }

  ///@nodoc
  /// Returns a new `Results<T>` that represent a sorted view of this collection.
  ///
  /// A `Results<T>` collection of Realm Objects can be sorted on one or more properties of those objects,
  /// or of properties of objects linked to by those objects.  Optionally the sort can be reversed using the `reverse` parameter
  /// ```dart
  /// var sortedCars = cars.sort("make");
  /// var myCars = person.cars.sort("kilometers");
  /// ```
  // RealmResults<T> sort(String sort, {bool reverse = false}) {
  //   return query('TRUEPREDICATE SORT($sort ${reverse ? 'DESC' : 'ASC'})');
  // }

  /// Returns an [Iterable<E>] collection for use with `for..in`
  // List<T> asList() {
  //   return _ResultsList(this);
  // }

  /// Returns the index of the given object in the Results collection.
  // int indexOf(T value) {
  //   return _results.indexOf(value);
  // }

  /// Returns `true` if this Results collection has not been deleted and is part of a valid Realm.
  ///
  /// Accessing an invalid Results collection will throw an [RealmException]
  // bool get isValid => _results.isValid();

  /// Returns a human-readable description of the objects contained in the collection.
  // String get description => _results.description;

  /// Adds a [ResultsListenerCallback] which will be called when a live collection instance changes.
  // void addListener(ResultsListenerCallback callback) {
  //   _results.addListener(callback);
  // }

  /// Removes a [ResultsListenerCallback] that was previously added with [addListener]
  ///
  /// The callback argument should be the same callback reference used in a previous call to [addListener]
  /// ```dart
  /// var callback = (collection, changes) { ... }
  /// realm.addListener(callback);
  /// realm.removeListener(callback);
  /// ```
  // void removeListener(ResultsListenerCallback callback) {
  //   _results.removeListener(callback);
  // }

  /// Removes all [ResultsListenerCallback] that were previously added with [addListener]
  // void removeAllListeners() {
  //   _results.removeAllListeners();
  // }

  /// Returns a `Results<T>` which is a frozen snapshot of the collection.
  ///
  /// Values added to and removed from the original collection will not be
  /// reflected in the new collection, including if the values
  /// of properties are changed to make them match or not match any filters applied.
  ///
  /// This is not a deep snapshot. Realm objects contained in this snapshot will
  /// continue to update as changes are made to them, and if they are deleted
  /// from the Realm they will be replaced by null at the respective indices.
  // Results<T> snapshot() {
  //   var results = _results.snapshot();
  //   return Results<T>(results);
  // }

  /// Not supported
  // void set length(int newLength) {
  //   throw new Exception("Setting length on Results<T> is not supported");
  // }
}

/// @nodoc
// A listener callback to be called when the [Results<T>] collection changes
///
/// The [changes] parameter will contain a dictionary with keys `insertions`,
/// `newModifications`, `oldModifications` and `deletions`, each containing a list of
/// indices in the collection that were inserted, updated or deleted respectively.
/// `deletions` and `oldModifications` are indices into the collection before the
/// change happened, while `insertions` and `newModifications` are indices into
/// the new version of the collection.
// typedef void ResultsListenerCallback(dynamic collection, dynamic changes);

/*
class RealmResults {
  RealmResults();

  RealmResults._constructor();

  RealmObject operator[](int index) native "Results_get_by_index";
  void operator[]=(int index, RealmObject value) native "Results_get_by_index";
  
  int get length native "Results_get_length";
  
  RealmResults filtered(String filter) native "Results_filtered";
  RealmResults sorted(String sort, {bool reverse = false}) native "Results_sorted";

  bool isValid() native "Results_isValid";
  bool isEmpty() native "Results_isEmpty";

  String get description native "Results_description";
  RealmResults snapshot() native "Results_snapshot";
  int indexOf(RealmObject value) native "Results_indexOf";

  void addListener(ResultsListenerCallback callback) native "Results_addListener";
  void removeListener(ResultsListenerCallback callback) native "Results_removeListener";
  void removeAllListeners() native "Results_removeAllListeners";
}
*/

//Some methods 'where' 'sort' etc of Results<T> clash with Iterable methods. Hence Results<T> can't be made
//Iterable and can't support for..in. The Results<T>.asList method provides that
//Could rename these so Results<T> can be proper Iterable

/*
class _ResultsList<T extends RealmObject> extends collection.ListBase<T> {
  final Results<T> _results;

  _ResultsList(this._results);

  @override
  int get length => _results.length;

  @override
  T operator [](int index) {
    return _results[index];
  }

  @override
  void operator []=(int index, T value) {
    _results[index] = value;
  }

  @override
  set length(int newLength) {
    _results.length = newLength;
  }
}
*/

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
