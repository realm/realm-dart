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
import 'field_element_ex.dart';
import 'element.dart';

class RealmFieldInfo {
  final FieldElement fieldElement;
  final String? mapTo;
  final bool isPrimaryKey;
  final bool indexed;
  final RealmPropertyType realmType;

  RealmFieldInfo({
    required this.fieldElement,
    required this.mapTo,
    required this.isPrimaryKey,
    required this.indexed,
    required this.realmType,
  });

  DartType get type => fieldElement.type;

  bool get isFinal => fieldElement.isFinal;
  bool get isRealmCollection => fieldElement.type.isRealmCollection;
  bool get isLate => fieldElement.isLate;
  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.isNullable;
  bool get isRequired => !(hasDefaultValue || optional);

  String get name => fieldElement.name;
  String get realmName => mapTo ?? name;

  String get basicMappedTypeName => type.basicMappedName;

  String get basicRealmTypeName => fieldElement.modelType.basicType.element?.remappedRealmName ?? fieldElement.modelType.basicMappedName;

  String get modelTypeName => fieldElement.modelTypeName;

  String get mappedTypeName => fieldElement.mappedTypeName;

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$mappedTypeName get $name => RealmObject.get<$basicMappedTypeName>(this, '$realmName') as $mappedTypeName;";
    bool generateSetter = !isFinal && !isRealmCollection;
    if (generateSetter) {
      final setter = isPrimaryKey ? 'setUnique' : 'set';
      yield '@override';
      yield "set $name(${mappedTypeName != modelTypeName ? 'covariant ' : ''}$mappedTypeName value) => RealmObject.$setter(this, '$realmName', value);";
    } else {
      bool generateThrowError = isLate || isRealmCollection;
      if (generateThrowError) {
        yield '@override';
        yield "set $name(${mappedTypeName != modelTypeName ? 'covariant ' : ''}$mappedTypeName value) => throw RealmUnsupportedSetError();";
      }
    }
  }

  @override
  String toString() => fieldElement.displayName;
}
