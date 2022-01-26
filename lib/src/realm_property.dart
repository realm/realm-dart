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
import 'package:realm_dart/realm.dart';

class _RealmProperty {
  /// `true` if the property is a primary key.
  final bool primaryKey;

  /// The `Realm` type of the property
  final RealmPropertyType propertyType;

  /// `true` if the property is optional
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

/// Describes a [RealmObject]'s property with its name, type and other attributes in the [RealmSchema]
///{@category Configuration}
class SchemaProperty extends _RealmProperty {
  /// The name of the property as persisted in the `Realm`
  final String name;
  
  final String? linkTarget;

  /// Defines the `Realm` collection type if this property is a collection.
  final RealmCollectionType collectionType;

  /// @nodoc
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
