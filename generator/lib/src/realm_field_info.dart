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
import 'session.dart';

class RealmFieldInfo {
  final FieldElement fieldElement;
  final String? mapTo;
  final bool primaryKey;
  final bool indexed;
  final RealmPropertyType realmType;

  RealmFieldInfo({
    required this.fieldElement,
    required this.mapTo,
    required this.primaryKey,
    required this.indexed,
    required this.realmType,
  });

  DartType get type => fieldElement.type;

  bool get isFinal => fieldElement.isFinal;
  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.isNullable;
  bool get isRequired => !(hasDefaultValue || optional);

  String get name => fieldElement.name;
  String get realmName => mapTo ?? name;

  String get basicTypeName => type.basicName;

  String get typeModelName => fieldElement.typeModelName;

  String get typeName => typeModelName.replaceAll(
      session.prefix, ''); // TODO: using replaceAll is a hack

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$typeName get $name => RealmObject.get<$basicTypeName>(this, '$realmName') as $typeName;";
    if (!isFinal) {
      yield '@override';
      yield "set $name(${typeName != typeModelName ? 'covariant ' : ''}$typeName value) => RealmObject.set(this, '$realmName', value);";
    }
  }

  @override
  String toString() => fieldElement.displayName;
}
