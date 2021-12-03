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

class RealmModel {
  const RealmModel();
}

enum RealmPropertyType {
  int, 
  bool,
  string,
  // ignore: unused_field, constant_identifier_names
  _3,
  binary,
  // ignore: unused_field, constant_identifier_names
  _5,
  mixed,
  // ignore: unused_field, constant_identifier_names
  _7,
  timestamp,
  float,
  double,
  decimal128,
  object,
  // ignore: unused_field, constant_identifier_names
  _13,
  linkingObjects,
  objectid,
  // ignore: unused_field, constant_identifier_names
  _16,
  uuid,
}

class _RealmProperty {
  
  /// Realm will use this property as the primary key
  final bool? primaryKey;
  
  /// The Realm type of this property
  final RealmPropertyType type;

  final bool nullable;
  
  /// The default value for this property
  final String? defaultValue;
  
  /// `true` if this property is optional
  final bool? optional;
  
  /// An alias to another property of the same RealmObject
  final String? mapTo;
  
  const _RealmProperty(this.type, {this.nullable = false, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class MapTo {
  final String name;
  const MapTo(this.name);
}

class PrimaryKey {
  const PrimaryKey();
}

class Indexed {
  const Indexed();
}

class Ignored {
  const Ignored();
}

/// A RealmProperty in a schema. Used for runtime representation of `RealmProperty`
class SchemaProperty extends _RealmProperty {
  final String name;
  const SchemaProperty(this.name, RealmPropertyType type, {String? defaultValue, bool? optional, String? mapTo, bool? primaryKey }) 
    : super(type, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}



