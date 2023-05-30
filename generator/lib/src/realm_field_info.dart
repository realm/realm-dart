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
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:realm_common/realm_common.dart';

import 'dart_type_ex.dart';
import 'element.dart';
import 'field_element_ex.dart';

class RealmFieldInfo {
  final FieldElement fieldElement;
  final String? mapTo;
  final bool isPrimaryKey;
  final RealmIndexType indexType;
  final RealmPropertyType realmType;
  final String? linkOriginProperty;

  RealmFieldInfo({
    required this.fieldElement,
    required this.mapTo,
    required this.isPrimaryKey,
    required this.indexType,
    required this.realmType,
    required this.linkOriginProperty,
  });

  DartType get type => fieldElement.type;

  bool get isFinal => fieldElement.isFinal;
  bool get isRealmCollection => type.isRealmCollection;
  bool get isDartCoreSet => type.isDartCoreSet;
  bool get isLate => fieldElement.isLate;
  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.basicType.isNullable || realmType == RealmPropertyType.mixed;
  bool get isRequired => !(hasDefaultValue || optional);
  bool get isRealmBacklink => realmType == RealmPropertyType.linkingObjects;
  bool get isMixed => realmType == RealmPropertyType.mixed;
  bool get isComputed => isRealmBacklink; // only computed, so far

  String get name => fieldElement.name;
  String get realmName => mapTo ?? name;

  String get basicMappedTypeName => type.basicMappedName;

  String get basicNonNullableMappedTypeName => type.basicType.asNonNullable.mappedName;

  String get basicRealmTypeName =>
      fieldElement.modelType.basicType.asNonNullable.element2?.remappedRealmName ?? fieldElement.modelType.asNonNullable.basicMappedName;

  String get modelTypeName => fieldElement.modelTypeName;

  String get mappedTypeName => fieldElement.mappedTypeName;

  String get initializer {
    if (type.isDartCoreList) return ' = const []';
    if (isMixed && !type.isRealmCollection) return ' = const RealmValue.nullValue()';
    if (hasDefaultValue) return ' = ${fieldElement.initializerExpression}';
    if (type.isDartCoreSet) return ' = const {}';
    return ''; // no initializer
  }

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  Iterable<String> toCode() sync* {
    final getTypeName = type.isRealmCollection ? basicMappedTypeName : basicNonNullableMappedTypeName;
    yield '@override';
    yield "$mappedTypeName get $name => RealmObjectBase.get<$getTypeName>(this, '$realmName') as $mappedTypeName;";
    bool generateSetter = !isFinal && !isRealmCollection && !isRealmBacklink;
    if (generateSetter) {
      yield '@override';
      yield "set $name(${mappedTypeName != modelTypeName ? 'covariant ' : ''}$mappedTypeName value) => RealmObjectBase.set(this, '$realmName', value);";
    } else {
      bool generateThrowError = isLate || isRealmCollection || isRealmBacklink;
      if (generateThrowError) {
        yield '@override';
        yield "set $name(${mappedTypeName != modelTypeName ? 'covariant ' : ''}$mappedTypeName value) => throw RealmUnsupportedSetError();";
      }
    }
  }

  @override
  String toString() => fieldElement.displayName;
}
