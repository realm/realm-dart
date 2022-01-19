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

import 'collection_changes.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// Instances of this class are live collections and will update as new elements are either 
/// added to or deleted from the Realm that match the underlying query.
///
///{@category Realm}
class RealmList<T> extends collection.ListBase<T> {
  final RealmListHandle _handle;
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

  Stream<RealmListChanges<T>> get changed => realmCore
      .listChanged(
        this,
        realm.scheduler.handle,
      )
      .map((changes) => RealmListChanges(this, changes));
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
