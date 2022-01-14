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

enum RealmCollectionType {
  none,
  list,
  set,
  dictionary,
}

class _RealmProperty {
  /// Realm will use this property as the primary key
  final bool primaryKey;

  /// The Realm type of this property
  final RealmPropertyType propertyType;

  final bool nullable;

  /// The default value for this property
  final String? defaultValue;

  /// `true` if this property is optional
  final bool optional;

  /// An alias to another property of the same RealmObject
  final String? mapTo;

  const _RealmProperty(this.propertyType, {this.nullable = false, this.defaultValue, this.optional = false, this.mapTo, this.primaryKey = false});
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
  final String? linkTarget;
  final RealmCollectionType collectionType;
  const SchemaProperty(this.name, RealmPropertyType propertyType,
      {bool nullable = false,
      String? defaultValue,
      bool optional = false,
      String? mapTo,
      bool primaryKey = false,
      this.linkTarget,
      this.collectionType = RealmCollectionType.none})
      : super(propertyType, nullable: nullable, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}
