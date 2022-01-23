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

import 'package:realm_common/realm_common.dart';

class _RealmProperty {
  /// Defines whether Realm will use this property as a primary key or not.
  final bool primaryKey;

  /// The Realm type of this property
  final RealmPropertyType propertyType;

  /// `true` if this property is optional
  final bool optional;

  /// An alias to another property of the same RealmObject
  final String? mapTo;

  const _RealmProperty(
    this.propertyType, {
    this.optional = false,
    this.mapTo,
    this.primaryKey = false,
  });
}

/// Defines [SchemaObject] properties with their name, type and other attributes.
class SchemaProperty extends _RealmProperty {
  /// Property name
  final String name;
  
  ///@nodoc
  final String? linkTarget;
  
  /// Defines the collection type if this property is collection.
  final RealmCollectionType collectionType;
  
  /// Creates an instance of [SchemaProperty] with required ```name``` and ```propertyType```.
  /// All other attributes are optional.
  const SchemaProperty(
    this.name,
    RealmPropertyType propertyType, {
    bool optional = false,
    String? mapTo,
    bool primaryKey = false,
    this.linkTarget,
    this.collectionType = RealmCollectionType.none,
  }) : super(
          propertyType,
          optional: optional,
          mapTo: mapTo,
          primaryKey: primaryKey,
        );
}
