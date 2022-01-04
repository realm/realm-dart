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

import 'dart:core';
import 'dart:core' as core;
import 'dart:collection' as collection;

import 'native/realm_core.dart';

import 'realm_object.dart';
import 'realm_class.dart';

class RealmList<T extends Object> extends collection.ListBase<T> {
  late final RealmListHandle _handle;
  late final Realm _realm;

  RealmList._(this._handle, this._realm);

  @override
  int get length => realmCore.getListSize(this);

  //settng lenght is no operation
  @override
  set length(int length) {}

  @override
  T operator [](int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      final value = realmCore.listGetElementAt(this, index);

      if (value is RealmObjectHandle) {
        return _realm.createObject(T, value) as T;
      }

      return value as T;
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  void operator []=(int index, T value) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      if (value is RealmObject && !value.isManaged) {
        _realm.add<RealmObject>(value);
      }

      if (index >= length) {
        realmCore.listInsertElementAt(this, index, value);
      } else {
        realmCore.listSetElementAt(this, index, value);
      }
    } on Exception catch (e) {
      throw RealmException("Error setting value at index $index. Error: $e");
    }
  }

  @override
  void clear() {
    throw UnimplementedError();
  }
}

extension RealmListInternal on RealmList {
  RealmListHandle get handle => _handle;
  Realm? get realm => _realm;

  static RealmList<T> create<T extends Object>(RealmListHandle handle, Realm realm) => RealmList<T>._(handle, realm);
}
