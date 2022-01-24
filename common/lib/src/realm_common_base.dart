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

///@nodoc
late String _noDoc;

/// RealmModel annotation for class level.
///
/// Use this annotation to mark this class as Realm object model
/// that could be persisted in Realm.
///
/// {@category Annotations}
class RealmModel {
  const RealmModel();
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

/// PrimaryKey annotation for class member level.
///
/// Indicates the primary key property.
/// It allows quick lookup of objects and enforces uniqueness of the values stored.
/// It may only be applied to a single property in a class.
/// Only char, integral types, and strings can be used as primary keys.
/// Once an object with a Primary Key has been added to the Realm, that property may not be changed.
///
/// {@category Annotations}
class PrimaryKey {
  const PrimaryKey();
}

/// Indexed annotation for class member level.
///
/// Indicates an indexed property. Indexed properties slightly slow down insertions,
/// but can greatly speed up queries.
///
/// {@category Annotations}
class Indexed {
  const Indexed();
}

/// Ignored annotation for class member level.
///
/// Indicates an ignored property.
/// Ignored properties will not be persisted in the Realm.
///
/// {@category Annotations}
class Ignored {
  const Ignored();
}
