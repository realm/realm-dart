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
import 'dart:ffi';
import 'dart:typed_data';

import 'package:analyzer/dart/element/type.dart';
import 'package:realm_common/realm_common.dart';
import 'package:realm_generator/src/pseudo_type.dart';
import 'package:source_gen/source_gen.dart';

import 'session.dart';
import 'type_checkers.dart';

extension DartTypeEx on DartType {
  bool isExactly<T>() => TypeChecker.fromRuntime(T).isExactlyType(this);

  bool get isRealmAny => const TypeChecker.fromRuntime(RealmAny).isAssignableFromType(this);
  bool get isRealmBacklink => false; // TODO: Implement Backlink support https://github.com/realm/realm-dart/issues/693
  bool get isRealmCollection => realmCollectionType != RealmCollectionType.none;
  bool get isRealmModel => element != null ? realmModelChecker.annotationsOfExact(element!).isNotEmpty : false;

  bool get isNullable => session.typeSystem.isNullable(this);
  DartType get asNonNullable => session.typeSystem.promoteToNonNull(this);

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
    if (isRealmCollection) {
      return (this as ParameterizedType).typeArguments.last;
    }
    return asNonNullable;
  }

  String get basicMappedName => basicType.mappedName;

  DartType get mappedType {
    final self = this;
    if (isRealmCollection) {
      if (self is ParameterizedType) {
        final provider = session.typeProvider;
        final mapped = self.typeArguments.last.mappedType;
        if (self != mapped) {
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
    if (isRealmAny) return RealmPropertyType.mixed;
    if (isExactly<DateTime>()) return RealmPropertyType.timestamp;
    if (isExactly<Float>()) return RealmPropertyType.float;
    if (isDartCoreNum || isDartCoreDouble) return RealmPropertyType.double;
    if (isExactly<Decimal128>()) return RealmPropertyType.decimal128;
    if (isRealmModel) return RealmPropertyType.object;
    if (isRealmBacklink) return RealmPropertyType.linkingObjects;
    if (isExactly<ObjectId>()) return RealmPropertyType.objectid;
    if (isExactly<Uuid>()) return RealmPropertyType.uuid;

    return null;
  }
}
