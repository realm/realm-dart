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

import 'dart:collection';

//Empty RealmObject class template
class RealmObject {

  /**
   *  Default constructor.
   */
  RealmObject() {}
  
  RealmObject.constructor() {}

  static dynamic getSchema(String name, Iterable<RealmProperty> properties) {
  }

  Object? operator [](String name) { return null; }
  void operator []=(String name, Object value) {}
}

class RealmProperty {
  final bool? primaryKey;
  final String? type;
  final String? defaultValue;
  final bool? optional;
  final String? mapTo;
  const RealmProperty({this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class SchemaProperty extends RealmProperty {
  final String propertyName;
  const SchemaProperty(this.propertyName, { type, defaultValue, optional, mapTo, primaryKey }) 
    : super(type: type, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}

class ArrayList<T extends RealmObject> with ListMixin<T> {
  @override
  int length = 0;

  @override
  T operator [](int index) {
      throw UnimplementedError();
    }
  
    @override
    void operator []=(int index, T value) {
  }
}

extension Super on RealmObject {
  ArrayList<T> super_get<T extends RealmObject>(String name) {
    throw new Exception();
  }

  void super_set<T extends RealmObject>(String name, Iterable<T> value) {
  }
}
