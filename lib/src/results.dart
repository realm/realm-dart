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

import 'realm_object.dart';

class RealmResults {
  RealmResults();

  RealmResults._constructor();

  RealmObject operator[](int index) native "Results_get_by_index";
  void operator[]=(int index, RealmObject value) native "Results_get_by_index";
  
  int get length native "Results_get_length";
  int get type native "Results_get_type";
  int get optional native "Results_get_optional";


  RealmResults filtered(String filter) native "Results_filtered";
  RealmResults sorted(String sort) native "Results_sorted";

  //not implemented
  dynamic description() native "Results_description";
  dynamic snapshot() native "Results_snapshot";
  dynamic isValid() native "Results_isValid";
  dynamic isEmpty() native "Results_isEmpty";
  dynamic min() native "Results_min";
  dynamic max() native "Results_max";
  dynamic sum() native "Results_sum";
  dynamic avg() native "Results_avg";
  dynamic indexOf() native "Results_indexOf";
  dynamic update() native "Results_update";
  dynamic addListener() native "Results_addListener";
  dynamic removeListener() native "Results_removeListener";
  dynamic removeAllListeners() native "Results_removeAllListeners";
}

//Some methods 'where' 'sort' etc of Results<T> clash with Iterable methods. Hence Results<T> can be made
//Iterable and can't support for..in. The Results<T>.asList method provides that
//Could rename these so Results<T> can be proper Iterable
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

class Results<T extends RealmObject>  {
  RealmResults _results;

  Results(this._results);

  T operator [](int index) {
    return _results[index] as T;
  }

  void operator []=(int index, T value) {
    _results[index] = value;
  }


  Results<T> where(String filter) {
    var results = _results.filtered(filter);
    return Results<T>(results);
  }

  Results<T> sort(String sort) {
    var results = _results.sorted(sort);
    return Results<T>(results);
  }

  List<T> asList() {
    return _ResultsList(this);
  }

  addListener() {
    // TODO: implement addListener
    return null;
  }

  avg() {
    // TODO: implement avg
    return null;
  }

  description() {
    // TODO: implement description
    return null;
  }

  

  indexOf() {
    // TODO: implement indexOf
    return null;
  }

  isEmpty() {
    // TODO: implement isEmpty
    return null;
  }

  isValid() {
    // TODO: implement isValid
    return null;
  }

  // TODO: implement length
  int get length => _results.length;

  max() {
    // TODO: implement max
    return null;
  }

  min() {
    // TODO: implement min
    return null;
  }

  // TODO: implement optional
  int get optional => _results.optional;

  removeAllListeners() {
    // TODO: implement removeAllListeners
    return null;
  }

  removeListener() {
    // TODO: implement removeListener
    return null;
  }

  snapshot() {
    // TODO: implement snapshot
    return null;
  }

  sorted() {
    // TODO: implement sorted
    return null;
  }

  sum() {
    // TODO: implement sum
    return null;
  }

  // TODO: implement type
  int get type => _results.type;

  update() {
    // TODO: implement update
    return null;
  }

  @override
  void set length(int newLength) {
    throw new Exception("Setting length on Results<T> is not supported");
  }
}



     