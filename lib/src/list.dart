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

import 'dart:core';
import 'dart:core' as core;
import 'dart:collection';

import 'realm_object.dart';


/// @nodoc
class RealmList {
  /**
   * Called from native code
   */
  RealmList._constructor();

  // /**
  //  * Called from List<T>
  //  */
  // RealmList._create_empty() native "List_create_empty";

  RealmObject operator [](int index) native "List_get_by_index";
  void operator []=(int index, RealmObject value) native "List_set_by_index";

  int get length native "List_get_length";
  dynamic get type native "List_get_type";
  dynamic get optional native "List_get_optional";

  dynamic push() native "List_push";
  dynamic pop() native "List_pop";
  dynamic unshift() native "List_unshift";
  dynamic shift() native "List_shift";
  dynamic splice() native "List_splice";
  dynamic snapshot() native "List_snapshot";
  dynamic filtered() native "List_filtered";
  dynamic sorted() native "List_sorted";
  bool get isValid native "List_isValid";
  bool get isEmpty native "List_isEmpty";
  //dynamic indexOf() native "List_indexOf";
  dynamic min() native "List_min";
  dynamic max() native "List_max";
  dynamic sum() native "List_sum";
  dynamic avg() native "List_avg";
  dynamic addListener() native "List_addListener";
  dynamic removeListener() native "List_removeListener";
  dynamic removeAllListeners() native "List_removeAllListeners";
}

// class List<T extends RealmObject> extends RealmList {
//   //RealmList _list;

//   List() : super._create_empty();

//   // List(Iterable<T> values);

//   // List.empty();

//   //List._constructor() : RealmList._constructor();

//   T operator [](int index) {
//     //return _list[index] as T;
//     return super[index] as T;
//   }

//   void operator []=(int index, covariant T value) {
//     //_list[index] = value;
//     super[index] = value;
//   }

//   //int get length => _list.length;

//   void add(T value) {}
// }

// class List<T extends RealmObject> extends ListBase<T> {
//   RealmList _list;
//   List<T> _unmanagedValues;

//   List() {
//     _unmanagedValues = new List<T>();
//   }

//   // List(Iterable<T> values);

//   // List.empty();

//   //List._constructor() : RealmList._constructor();

//   T operator [](int index) {
//     return _list[index] as T;
//     //return super[index] as T;
//   }

//   void operator []=(int index, covariant T value) {
//     _list[index] = value;
//     //super[index] = value;
//   }

//   int get length => _list.length;

//   void add(T value) {}

//   //Dart: no operation. consider supporting this as delete all values from newLength to the end
//   @override
//   void set length(int newLength) => {};
// }

/**
 * Dart: Have two classes implement the same interface and swap the unamanged and managed 
 * implementation instead of checking _unmanagedValues in every member
 */
/// @nodoc
class _RealmListUnmanaged {}

/// A list of RealmObjects
class ArrayList<T extends RealmObject> with ListMixin<T> {
  RealmList? _list;
  core.List<T>? _unmanagedValues;

  /**
   * Called from native code
   */
  ArrayList.fromRealmList(RealmList realmList) {
    _list = realmList;
  }


  ArrayList(Iterable<T> values) {
    _unmanagedValues = new core.List<T>.from(values);
  }

  ArrayList.empty() : this([]);

  T operator [](int index) {
    if (_unmanagedValues != null) {
      return _unmanagedValues![index];
    }

    return _list![index] as T;
  }

  void operator []=(int index, covariant T value) {
    if (_unmanagedValues != null) {
      _unmanagedValues![index] = value;
      return;
    }

    _list![index] = value;
    //super[index] = value;
  }

  int get length {
    if (_unmanagedValues != null) {
      return _unmanagedValues!.length;
    }

    return _list!.length;
  } 

  @override
  void add(T value) {
    if (_unmanagedValues != null) {
      return _unmanagedValues!.add(value);
    }

    throw Exception("not implemented for native code");
    //return _list.push;
  }

  @override
  void addAll(Iterable<T> values) {
     if (_unmanagedValues != null) {
      return _unmanagedValues!.addAll(values);
    }

    throw Exception("not implemented for native code");
    //return _list.push;
  }


  //Dart: no operation. consider supporting this as delete all values from newLength to the end
  @override
  void set length(int newLength) {
    throw Exception("not implemented");
  }
}