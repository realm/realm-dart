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
import 'package:source_gen/source_gen.dart';

import 'session.dart';
import 'type_checkers.dart';

extension DartTypeEx on DartType {
  bool isExactly<T>() => TypeChecker.fromRuntime(T).isExactlyType(this);

  bool get isRealmAny =>
      const TypeChecker.fromRuntime(RealmAny).isAssignableFromType(this);
  bool get isRealmBacklink => false; // TODO
  bool get isRealmCollection => realmCollectionType != RealmCollectionType.none;
  bool get isRealmModel =>
      realmModelChecker.annotationsOfExact(element!).isNotEmpty;

  bool get isNullable => session.typeSystem.isNullable(this);
  DartType get asNonNullable => session.typeSystem.promoteToNonNull(this);

  RealmCollectionType get realmCollectionType {
    if (isDartCoreSet) return RealmCollectionType.set;
    if (isDartCoreList) return RealmCollectionType.list;
    if (isDartCoreMap &&
        (this as ParameterizedType).typeArguments.first ==
            session.typeProvider.stringType) {
      return RealmCollectionType.dictionary;
    }
    return RealmCollectionType.none;
  }

  DartType get basicType {
    if (isDynamic) return this;
    if (isNullable) return asNonNullable.basicType;
    if (isRealmCollection) {
      return (this as ParameterizedType).typeArguments.last;
    }
    if (isRealmModel) {
      // TODO: convert _T to T using a ClassTypeMacro.
      // This awaits the addition of the static meta programming feature to Dart.
      // Until then we get by with a few wellplaced string operations.
    }
    return this;
  }

  // TODO: Using replaceAll is a hack.
  // It is needed for now, since we cannot construct a DartType for the yet to
  // be generated classes, ie. for _A given A. Once the new static meta
  // programming feature is added to dart, we should be able to resolve this
  // using a ClassTypeMacro.
  String get basicName => basicType.toString().replaceAll(session.prefix, '');

  DartType get mappedType {
    final self = this;
    if (isRealmCollection) {
      if (self is ParameterizedType) {
        final provider = session.typeProvider;
        final mapped = self.typeArguments.last.mappedType;
        if (self != mapped) {
          if (self.isDartCoreList) return provider.listType(mapped);
          if (self.isDartCoreSet) return provider.setType(mapped);
          if (self.isDartCoreMap) {
            return provider.mapType(self.typeArguments.first, mapped);
          }
        }
      }
    } else if (isRealmModel) {
      // TODO: convert _T to T using a ClassTypeMacro.
      // This awaits the addition of the static meta programming feature to Dart.
      // Until then we get by with a few wellplaced string operations.
    }
    return self;
  }

  RealmPropertyType? get realmType => _realmType(true);

  RealmPropertyType? _realmType(bool recurse) {
    if (isRealmCollection && recurse) {
      return (this as ParameterizedType)
          .typeArguments
          .last
          ._realmType(false); // only recurse once! (for now)
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
