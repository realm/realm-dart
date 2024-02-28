// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'realm_types.dart';

/// An enum controlling the base type for a [RealmModel].
///
/// {@category Annotations}
enum ObjectType {
  /// A standalone top-level object that can be persisted in Realm. It can link
  /// to other objects or collections of other objects.
  realmObject('RealmObject', 0),

  /// An object that can be embedded in other objects. It is considered owned
  /// by its parent and will be deleted if its parent is deleted.
  embeddedObject('EmbeddedObject', 1),

  /// A special type of object used to facilitate unidirectional synchronization
  /// with Atlas App Services. It is used to push data to Realm without the ability
  /// to query or modify it.
  asymmetricObject('AsymmetricObject', 2);

  const ObjectType([this._className = 'Unknown', this._flags = -1]);

  final String _className;

  final int _flags;
}

extension ObjectTypeInternal on ObjectType {
  int get flags => _flags;

  String get className => _className;
}

/// Annotation class used to define `Realm` data model classes and their properties
///
/// {@category Annotations}
class RealmModel {
  /// The base type of the object
  final ObjectType type;

  /// Creates a new instance of [RealmModel] specifying the desired base type.
  const RealmModel([this.type = ObjectType.realmObject]);
}

/// MapTo annotation for class level and class member level.
///
/// Indicates that the class or the property should be persisted under a different name.
/// This is useful when opening a Realm across different bindings where code style conventions might differ
/// or when migrating models.
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
/// You can optionally specify the type of the index with [RealmIndexType.regular] being the default.
///
/// {@category Annotations}
class Indexed {
  final RealmIndexType indexType;

  const Indexed([this.indexType = RealmIndexType.regular]);
}

/// Indicates an ignored property.
///
/// Ignored properties will not be persisted in the `Realm`.
///
/// {@category Annotations}
class Ignored {
  const Ignored();
}

/// Indicates that the field it decorates is the inverse end of a relationship.
/// {@category Annotations}
class Backlink {
  /// The name of the field in the other class that links to this class.
  final Symbol fieldName;
  const Backlink(this.fieldName);
}

/// @nodoc
class Tuple<T1, T2> {
  T1 item1;
  T2 item2;

  Tuple(this.item1, this.item2);
}
