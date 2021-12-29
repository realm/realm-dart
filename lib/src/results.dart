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

// ignore_for_file: native_function_body_in_non_sdk_code

import 'dart:collection' as collection;

import 'native/realm_core.dart';

import 'realm_object.dart';
import 'realm_class.dart';

/// A listener callback to be called when the [Results<T>] collection changes
///
/// The [changes] parameter will contain a dictionary with keys `insertions`,
/// `newModifications`, `oldModifications` and `deletions`, each containing a list of
/// indices in the collection that were inserted, updated or deleted respectively.
/// `deletions` and `oldModifications` are indices into the collection before the
/// change happened, while `insertions` and `newModifications` are indices into
/// the new version of the collection.
// typedef void ResultsListenerCallback(dynamic collection, dynamic changes);

/*
/// @nodoc
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
  Results<T> _results;

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
  void set length(int newLength) {
    _results.length = newLength;
  }
}
*/

/// Instances of this class are typically live collections returned by [Realm.objects]
/// that will update as new objects are either added to or deleted from the Realm
/// that match the underlying query.
class RealmResults<T extends RealmObject> {
  late final RealmResultsHandle _handle;
  late final Realm _realm;
  // RealmResults _results;

  RealmResults._(this._handle, this._realm);

  // Results._(this._results);

  /// Returns the Realm object of type `T` at the specified `index`
  T operator [](int index) {
    final handle = realmCore.getObjectAt(this, index);
    return _realm.createObject(T, handle) as T;
  }

  /// Returns a new `Results<T>` filtered according to the provided query
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  // Results<T> where(String filter) {
  //   var results = _results.filtered(filter);
  //   return Results<T>(results);
  // }

  /// Returns a new `Results<T>` that represent a sorted view of this collection.
  ///
  /// A `Results<T>` collection of Realm Objects can be sorted on one or more properties of those objects,
  /// or of properties of objects linked to by those objects.  Optionally the sort can be reversed using the `reverse` parameter
  /// ```dart
  /// var sortedCars = cars.sort("make");
  /// var myCars = person.cars.sort("kilometers");
  /// ```
  // Results<T> sort(String sort, {bool reverse = false}) {
  //   var results = _results.sorted(sort, reverse: reverse);
  //   return Results<T>(results);
  // }

  /// Returns an [Iterable<E>] collection for use with `for..in`
  // List<T> asList() {
  //   return _ResultsList(this);
  // }
  

  ///Removes all the objects matching results from database
  void removeAll() {
    realmCore.realmResultsDeleteAll(this);
  }

  /// Returns the index of the given object in the Results collection.
  // int indexOf(T value) {
  //   return _results.indexOf(value);
  // }

  /// Returns `true` if the Results collection is empty
  bool isEmpty() {
    return length == 0;
  }

  /// Returns `true` if this Results collection has not been deleted and is part of a valid Realm.
  ///
  /// Accessing an invalid Results collection will throw an [RealmException]
  // bool get isValid => _results.isValid();

  /// Returns the number of values in the Results collection.
  int get length => realmCore.getResultsCount(this);

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

//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
  RealmResultsHandle get handle => _handle;

  static RealmResults<T> create<T extends RealmObject>(
      RealmResultsHandle handle, Realm realm) {
    return RealmResults<T>._(handle, realm);
  }
}
