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
  bool get isRealmModel => element2 != null ? realmModelChecker.annotationsOfExact(element2!).isNotEmpty : false;
  bool get isUint8List => isExactly<Uint8List>();

  bool get isNullable => session.typeSystem.isNullable(this);
  DartType get asNonNullable => session.typeSystem.promoteToNonNull(this);
  DartType get asNullable => session.typeSystem.leastUpperBound(this, session.typeProvider.nullType);

  RealmCollectionType get realmCollectionType {
    if (isDartCoreSet) return RealmCollectionType.set;
    if (isDartCoreList) return RealmCollectionType.list;
    if (isDartCoreMap && (this as ParameterizedType).typeArguments.first == session.typeProvider.stringType) {
      return RealmCollectionType.dictionary;
    }
    return RealmCollectionType.none;
  }

  DartType? get nullIfDynamic => isDynamic ? null : this;

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
          final provider = session.typeProvider;
          if (self.isDartCoreList) {
            final mappedList = provider.listType(mapped);
            return PseudoType('Realm${mappedList.getDisplayString(withNullability: true)}', nullabilitySuffix: mappedList.nullabilitySuffix);
          }
          if (self.isDartCoreSet) {
            final mappedSet = provider.setType(mapped);
            return PseudoType('Realm${mappedSet.getDisplayString(withNullability: true)}', nullabilitySuffix: mappedSet.nullabilitySuffix);
          }
          if (self.isDartCoreMap) {
            final mappedMap = provider.mapType(self.typeArguments.first, mapped);
            return PseudoType('Realm${mappedMap.getDisplayString(withNullability: true)}', nullabilitySuffix: mappedMap.nullabilitySuffix);
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
