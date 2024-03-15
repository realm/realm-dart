// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

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
