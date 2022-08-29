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
import 'configuration.dart';
import 'realm_object.dart';
import 'list.dart';
import 'type_utils.dart';

/// Describes a [RealmObject]'s property with its name, type and other attributes in the [RealmSchema]
///{@category Configuration}
abstract class SchemaProperty {
  /// The name of the property as persisted in the [Realm]
  String get name;

  /// The [RealmPropertyType] of the property
  RealmPropertyType get propertyType;

  /// `true` if the property is a primary key.
  bool get primaryKey;

  /// `true` if the property is a primary key.
  bool get indexed;

  /// Defines the [Realm] collection type if this property is a collection.
  RealmCollectionType get collectionType;

  /// Name of the link target type, if any
  String? get linkTarget;

  /// [Type] of the property
  Type get type;

  /// `true` if the property is optional
  bool get optional;

  /// Default value to use, if any
  Object? get defaultValue;

  /// Get value of this property from [object]
  Object? getValue(RealmObject object);

  /// Set value of this property on [object]
  void setValue(RealmObject object, Object? value);

  factory SchemaProperty.dynamic({
    required String name,
    required RealmPropertyType propertyType,
    required bool primaryKey,
    required bool indexed,
    required bool optional,
    required RealmCollectionType collectionType,
    required String? linkTarget,
  }) = _DynamicProperty;
}

/// @nodoc
abstract class BaseProperty<T extends Object?> implements SchemaProperty {
  const BaseProperty(
    this.name,
    this.propertyType, {
    this.primaryKey = false,
    this.indexed = false,
    this.collectionType = RealmCollectionType.none,
    this.linkTarget,
    this.defaultValue,
  });

  @override
  final String name;

  @override
  final RealmPropertyType propertyType;

  @override
  final bool primaryKey;

  @override
  final bool indexed;

  @override
  final RealmCollectionType collectionType;

  @override
  final String? linkTarget;

  @override
  Type get type => T;

  @override
  final T? defaultValue;

  @override
  void setValue(RealmObject object, covariant T value) {
    object.accessor.set(object, name, value);
  }
}

/// @nodoc
class ValueProperty<T extends Object?> extends BaseProperty<T> {
  const ValueProperty(
    super.name,
    super.propertyType, {
    super.primaryKey = false,
    super.indexed = false,
    super.defaultValue,
    super.collectionType = RealmCollectionType.none,
  });

  @override
  T getValue(RealmObject object) {
    return (object.accessor.getValue<T>(object, name) ?? defaultValue) as T;
  }

  @override
  bool get optional => isNullable<T>() || defaultValue != null;
}

/// @nodoc
class ObjectProperty<LinkT extends RealmObject> extends BaseProperty<LinkT?> {
  const ObjectProperty(String name, String linkTarget) : super(name, RealmPropertyType.object, linkTarget: linkTarget);

  @override
  LinkT? getValue(RealmObject object) {
    return object.accessor.getObject<LinkT>(object, name);
  }

  @override
  bool get optional => true;
}

/// @nodoc
class ListProperty<ElementT extends Object?> extends BaseProperty<RealmList<ElementT>> {
  const ListProperty(super.name, super.propertyType, {super.linkTarget}) : super(collectionType: RealmCollectionType.list);

  @override
  RealmList<ElementT> getValue(RealmObject object) {
    return object.accessor.getList<ElementT>(object, name);
  }

  @override
  bool get optional => isNullable<ElementT>();
}

/// @nodoc
class _DynamicProperty implements SchemaProperty {
  _DynamicProperty({
    required this.name,
    required this.propertyType,
    required this.primaryKey,
    required this.indexed,
    required this.optional,
    required this.collectionType,
    required this.linkTarget,
  });

  @override
  final String name;
  @override
  final RealmPropertyType propertyType;
  @override
  final bool primaryKey;
  @override
  final bool indexed;
  @override
  final bool optional;
  @override
  final RealmCollectionType collectionType;
  @override
  final String? linkTarget;

  @override
  Object? get defaultValue => null;

  @override
  Object? getValue(RealmObject object) {
    final map = propertyType.mapping;
    final accessor = object.accessor;
    if (collectionType == RealmCollectionType.none) {
      if (propertyType == RealmPropertyType.object) return map.getObject(accessor, object, name);
      if (optional) return map.getNullableValue(accessor, object, name);
      return map.getValue(accessor, object, name);
    }
    if (collectionType == RealmCollectionType.list) {
      if (optional) return map.getListOfNullables(accessor, object, name);
      return map.getList(accessor, object, name);
    }
    throw RealmError('Unsupported collection type: $collectionType');
  }

  @override
  void setValue(RealmObject object, Object? value) {
    object.accessor.set(object, name, value);
  }

  @override
  Type get type {
    final map = propertyType.mapping;
    if (collectionType == RealmCollectionType.none) {
      if (optional) return map.nullableType;
      return map.type;
    }
    if (collectionType == RealmCollectionType.list) {
      if (optional) return map.listOfNullablesType;
      return map.listType;
    }
    throw RealmError('Unsupported collection type: $collectionType');
  }
}
