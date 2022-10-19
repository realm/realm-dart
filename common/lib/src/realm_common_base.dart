// //////////////////////////////////////////////////////////////////////////////
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
// //////////////////////////////////////////////////////////////////////////////

enum RealmModelType {
  realmObject(0),
  embedded(1),
  // ignore: unused_field
  _asymmetricRealmObject(2);

  const RealmModelType(this.type);

  final int type;
}

/// Annotation class used to define `Realm` data model classes and their properties
///
/// {@category Annotations}
class RealmModel {
  final RealmModelType type;
  const RealmModel([this.type = RealmModelType.realmObject]);
}

/// MapTo annotation for class member level.
///
/// Indicates that a property should be persisted under a different name.
/// This is useful when opening a Realm across different bindings where code style conventions might differ.
///
/// {@category Annotations}
class MapTo {
  final String name;
  const MapTo(this.name);
}

/// Indicates a primary key property.
/// 
/// It enables quick lookup of objects and enforces uniqueness of the values stored.
/// It may only be applied to a single property in a [RealmModel] class.
/// Only [String] and [int] can be used as primary keys.
/// Once an object with a Primary Key has been added to the Realm, that property may not be changed.
///
/// {@category Annotations}
class PrimaryKey {
  const PrimaryKey();
}

/// Indicates an indexed property. 
/// 
/// Indexed properties slightly slow down insertions but can greatly speed up queries.
///
/// {@category Annotations}
class Indexed {
  const Indexed();
}

/// Indicates an ignored property.
/// 
/// Ignored properties will not be persisted in the `Realm`.
///
/// {@category Annotations}
class Ignored {
  const Ignored();
}
