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
import 'package:realm_annotations/realm_annotations.dart';

import 'dart_type_ex.dart';
import 'error.dart';
import 'element.dart';
import 'field_element_ex.dart';
import 'session.dart';

class RealmFieldInfo {
  final FieldElement fieldElement;
  final String? mapTo;
  final bool primaryKey;
  final bool indexed;

  RealmFieldInfo({
    required this.fieldElement,
    required this.mapTo,
    required this.primaryKey,
    required this.indexed,
  });

  DartType get type => fieldElement.type;

  bool get isFinal => fieldElement.isFinal;
  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.isNullable;
  bool get isRequired => !(hasDefaultValue || optional);

  String get name => fieldElement.name;
  String get realmName => mapTo ?? name;

  String get basicTypeName => type.basicType
      .toString()
      .replaceAll(session.prefix, ''); // TODO: using replaceAll is a hack

  String get typeModelName => type.isDynamic
      ? fieldElement.declarationAstNode.fields.type.toString() // read from AST
      : type.getDisplayString(withNullability: true);

  String get typeName => typeModelName.replaceAll(
      session.prefix, ''); // TODO: using replaceAll is a hack

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  RealmPropertyType get realmType {
    final realmType = type.realmType;
    if (realmType != null) return realmType;

    final notARealmTypeSpan = type.element?.span;
    String todo;
    if (notARealmTypeSpan != null) {
      todo = //
          "Add a @RealmModel annotation on '$typeName', "
          "or an @Ignored annotation on '$this'.";
    } else if (type.isDynamic &&
        typeName != 'dynamic' &&
        !typeName.startsWith(session.prefix)) {
      todo = "Did you intend to use _$typeName as type for '$this'?";
    } else {
      todo = "Add an @Ignored annotation on '$this'.";
    }

    final fieldDeclaration = fieldElement.declarationAstNode;
    final modelElement = fieldElement.enclosingElement;
    final modelSpan = modelElement.span!;
    final file = modelSpan.file;
    final typeAnnotation = fieldDeclaration.fields.type;
    final initializerExpression = fieldDeclaration.fields.variables
        .singleWhere((v) => v.name.name == name)
        .initializer;
    final typeText =
        (typeAnnotation ?? initializerExpression?.staticType).toString();

    throw RealmInvalidGenerationSourceError(
      'Not a realm type',
      element: fieldElement,
      primarySpan: (typeAnnotation ?? initializerExpression)!.span(file),
      primaryLabel: '$typeText is not a realm type',
      secondarySpans: {
        modelSpan: "in realm model '${modelElement.displayName}'",
        // may go both above and below, or stem from another file
        if (notARealmTypeSpan != null) notARealmTypeSpan: ''
      },
      todo: todo,
    );
  }

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$typeName get $name => RealmObject.get<$basicTypeName>(this, '$realmName') as $typeName;";
    if (!isFinal) yield '@override';
    yield "set ${isFinal ? '_' : ''}$name(${typeName != typeModelName ? 'covariant ' : ''}$typeName value) => RealmObject.set(this, '$realmName', value);";
  }

  @override
  String toString() => fieldElement.displayName;
}
