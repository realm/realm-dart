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
/// Use this annotation to mark this class as Realm object model.
///
/// {@category Annotations}
class RealmModel {
  const RealmModel();
}

/// MapTo annotation for class member level.
///
/// Use this annotation to mark this member as property with specific name in Realm object model.
/// This annotation allows class member name to be different from the property name in Realm schema.
///
/// {@category Annotations}
class MapTo {
  final String name;
  const MapTo(this.name);
}

/// PrimaryKey annotation for class member level.
///
/// Use this annotation to mark this member as primary key in Realm schema.
/// Primary key member must be ```final```.
///
/// {@category Annotations}
class PrimaryKey {
  const PrimaryKey();
}

/// Indexed annotation for class member level.
///
/// {@category Annotations}
class Indexed {
  const Indexed();
}

/// Ignored annotation for class member level.
///
/// Use this annotation to exclude this member from Realm object schema.
/// Members marked with `@Ignore` will not be persisted in the database.
/// They could be used only in memory.
///
/// {@category Annotations}
class Ignored {
  const Ignored();
}
