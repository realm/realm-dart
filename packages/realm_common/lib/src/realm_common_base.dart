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
  embeddedObject('EmbeddedObject', 1);

  const ObjectType(this._className, this._flags);

  final String _className;
  final int _flags;
}

extension ObjectTypeInternal on ObjectType {
  int get flags => _flags;

  String get className => _className;
}

/// An enum controlling the constructor type generated for a [RealmModel].
enum CtorStyle {
  /// Generate a constructor with only optional parameters named.
  /// All required parameters will be positional.
  /// This is the default, unless overridden in the build config.
  onlyOptionalNamed,

  /// Generate a constructor with all parameters named.
  allNamed,
}

/// Class used to define the desired constructor behavior for a [RealmModel].
///
/// {@category Annotations}
class GeneratorConfig {
  /// The style to use for the generated constructor
  final CtorStyle ctorStyle;

  const GeneratorConfig({this.ctorStyle = CtorStyle.onlyOptionalNamed});
}

/// Annotation class used to define `Realm` data model classes and their properties
///
/// {@category Annotations}
class RealmModel {
  /// The base type of the generated object class
  final ObjectType baseType;

  /// The generator configuration to use for this model
  final GeneratorConfig generatorConfig;

  // NOTE: To avoid a breaking change, we keep this old constructor and add a new one
  /// Creates a new instance of [RealmModel] optionally specifying the [baseType].
  const RealmModel([
    ObjectType baseType = ObjectType.realmObject,
  ]) : this.using(baseType: baseType);

  /// Creates a new instance of [RealmModel] optionally specifying the [baseType]
  /// and [generatorConfig].
  const RealmModel.using({
    this.baseType = ObjectType.realmObject,
    this.generatorConfig = const GeneratorConfig(),
  });
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
