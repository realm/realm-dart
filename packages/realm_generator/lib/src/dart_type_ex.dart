// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:realm_common/realm_common.dart';
import 'package:realm_generator/src/pseudo_type.dart';
import 'package:source_gen/source_gen.dart';

import 'session.dart';
import 'type_checkers.dart';

extension DartTypeEx on DartType {
  bool isExactly<T>() => TypeChecker.fromRuntime(T).isExactlyType(this);
  bool isA<T>() => TypeChecker.fromRuntime(T).isAssignableFromType(this);

  bool get isRealmValue => const TypeChecker.fromRuntime(RealmValue).isAssignableFromType(this);
  bool get isRealmCollection => realmCollectionType != RealmCollectionType.none;
  bool get isRealmSet => realmCollectionType == RealmCollectionType.set;

  ObjectType? get realmObjectType {
    if (element == null) return null;
    final realmModelAnnotation = realmModelChecker.firstAnnotationOfExact(element!);
    if (realmModelAnnotation == null) return null; // not a RealmModel
    final index = realmModelAnnotation.getField('baseType')!.getField('index')!.toIntValue()!;
    return ObjectType.values[index];
  }

  bool get isRealmModel => realmObjectType != null;
  bool isRealmModelOfType(ObjectType type) => realmObjectType == type;

  bool get isUint8List => isExactly<Uint8List>();

  bool get isNullable => session.typeSystem.isNullable(this);
  DartType get asNonNullable => session.typeSystem.promoteToNonNull(this);
  DartType get asNullable => session.typeSystem.leastUpperBound(this, session.typeProvider.nullType);

  RealmCollectionType get realmCollectionType {
    if (isDartCoreSet) return RealmCollectionType.set;
    if (isDartCoreList) return RealmCollectionType.list;
    if (isDartCoreMap) return RealmCollectionType.map;
    return RealmCollectionType.none;
  }

  DartType? get nullIfDynamic => this is DynamicType ? null : this;

  DartType get basicType {
    final self = this;
    if (self is ParameterizedType && (isRealmCollection || isDartCoreIterable)) {
      return self.typeArguments.last;
    }
    return this;
  }

  String get basicMappedName => basicType.mappedName;

  DartType get mappedType {
    final self = this;
    if (isRealmCollection) {
      if (self is ParameterizedType) {
        final mapped = self.typeArguments.last.mappedType;
        if (self != mapped) {
          if (self.isDartCoreList) {
            return PseudoType('RealmList<${mapped.getDisplayString(withNullability: true)}>');
          }
          if (self.isDartCoreSet) {
            return PseudoType('RealmSet<${mapped.getDisplayString(withNullability: true)}>');
          }
          if (self.isDartCoreMap) {
            return PseudoType('RealmMap<${mapped.getDisplayString(withNullability: true)}>');
          }
        }
      }
    } else if (isDartCoreIterable) {
      if (self is ParameterizedType) {
        final mapped = self.typeArguments.last.mappedType;
        if (self != mapped) {
          return PseudoType('RealmResults<${mapped.basicMappedName}>', nullabilitySuffix: NullabilitySuffix.none);
        }
      }
    } else if (isRealmModel) {
      return PseudoType(
        getDisplayString(withNullability: false).replaceAll(session.prefix, ''),
        nullabilitySuffix: nullabilitySuffix,
      );
    }
    return self;
  }

  String get mappedName => mappedType.getDisplayString(withNullability: true);

  RealmPropertyType? get realmType => _realmType(true);

  RealmPropertyType? _realmType(bool recurse) {
    if (isRealmCollection && recurse) {
      return (this as ParameterizedType).typeArguments.last._realmType(false); // only recurse once! (for now)
    }
    if (isDartCoreInt) return RealmPropertyType.int;
    if (isDartCoreBool) return RealmPropertyType.bool;
    if (isDartCoreString) return RealmPropertyType.string;
    if (isExactly<Uint8List>()) return RealmPropertyType.binary;
    if (isRealmValue) return RealmPropertyType.mixed;
    if (isExactly<DateTime>()) return RealmPropertyType.timestamp;
    if (isDartCoreNum || isDartCoreDouble) return RealmPropertyType.double;
    if (isA<Decimal128>()) return RealmPropertyType.decimal128;
    if (isRealmModel) return RealmPropertyType.object;
    if (isDartCoreIterable) return RealmPropertyType.linkingObjects;
    if (isExactly<ObjectId>()) return RealmPropertyType.objectid;
    if (isExactly<Uuid>()) return RealmPropertyType.uuid;

    return null;
  }
}
