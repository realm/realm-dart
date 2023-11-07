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

import 'realm_class.dart';

/// Describes a property on [RealmObjectBase] with its name, type and other attributes in the [RealmSchema]
///{@category Configuration}
class SchemaProperty {
  /// The name of the property as persisted in the `Realm`
  final String name;

  final String? linkTarget;

  final String? linkOriginProperty;

  /// Defines the `Realm` collection type if this property is a collection
  final RealmCollectionType collectionType;

  /// `true` if the property is a primary key
  final bool primaryKey;

  /// `true` if the property is indexed
  @Deprecated("Use indexType instead")
  bool get indexed => indexType == RealmIndexType.regular;

  /// Returns the index type for this property
  final RealmIndexType? indexType;

  /// The `Realm` type of the property
  final RealmPropertyType propertyType;

  /// `true` if the property is computed
  bool get isComputed => propertyType == RealmPropertyType.linkingObjects;

  /// `true` if the property is optional
  final bool optional;

  final String? _mapTo;

  /// Indicates that the property should be persisted under a different name
  String get mapTo => _mapTo ?? name;

  /// @nodoc
  const SchemaProperty(
    this.name,
    this.propertyType, {
    this.optional = false,
    String? mapTo,
    this.primaryKey = false,
    this.indexType,
    this.linkTarget,
    this.linkOriginProperty,
    this.collectionType = RealmCollectionType.none,
  }) : _mapTo = mapTo;
}
