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
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:realm_annotations/realm_annotations.dart';
import 'package:realm_generator/src/annotation_value.dart';
import 'package:source_gen/source_gen.dart';

import 'dart_type_ex.dart';
import 'element.dart';
import 'error.dart';
import 'format_spans.dart';
import 'realm_field_info.dart';
import 'type_checkers.dart';
import 'utils.dart';

extension FieldElementEx on FieldElement {
  FieldDeclaration get declarationAstNode =>
      getDeclarationFromElement(this)!.node.parent!.parent as FieldDeclaration;

  AnnotationValue? get ignoredInfo => annotationInfoOfExact(ignoredChecker);

  AnnotationValue? get primaryKeyInfo =>
      annotationInfoOfExact(primaryKeyChecker);

  AnnotationValue? get indexedInfo => annotationInfoOfExact(indexedChecker);

  RealmFieldInfo? get realmInfo {
    try {
      if (ignoredInfo != null || isPrivate) {
        // skip ignored and private fields
        return null;
      }

      final primaryKey = primaryKeyInfo;
      final indexed = indexedInfo;

      final optional = type.isNullable;

      if (primaryKey != null && optional) {
        final modelSpan = enclosingElement.span!;
        final fieldDeclaration = declarationAstNode;
        final typeAnnotation = fieldDeclaration.fields.type!;
        final file = modelSpan.file;
        final typeText =
            typeAnnotation.type!.getDisplayString(withNullability: false);
        throw RealmInvalidGenerationSourceError(
          'Primary key cannot be nullable',
          element: this,
          secondarySpans: {
            modelSpan: "in realm model '${enclosingElement.displayName}'",
            primaryKey.annotation.span(file):
                "the primary key '$displayName' is"
          },
          primarySpan: typeAnnotation.span(file),
          primaryLabel: 'nullable',
          todo: //
              'Consider using the @Indexed() annotation instead, '
              "or make '$displayName' ${anOrA(typeText)} $typeText.",
        );
      }
      if (primaryKey != null && indexed != null) {
        log.info(formatSpans(
          'Indexed is implied for a primary key',
          primarySpan: span!,
          todo:
              "Remove either the @Indexed or @PrimaryKey annotation from '$displayName'.",
          element: this,
        ));
      }
      if (primaryKey != null && !isFinal) {
        throw RealmInvalidGenerationSourceError(
          'Primary key field is not final',
          todo: //
              "Add a final keyword to the definition of '$displayName', "
              'or remove the @PrimaryKey annotation.',
          element: this,
        );
      }
      if (isFinal && primaryKey == null) {}
      if ((primaryKey != null || indexed != null) &&
          (![
                RealmPropertyType.string,
                RealmPropertyType.int,
                RealmPropertyType.bool,
              ].contains(type.realmType) ||
              type.realmCollectionType != RealmCollectionType.none)) {
        final file = shortSpan!.file;
        final fieldDeclaration = declarationAstNode;
        final typeAnnotation = fieldDeclaration.fields.type;
        final initializerExpression = fieldDeclaration.fields.variables
            .singleWhere((v) => v.name.name == name)
            .initializer;
        final typeText =
            (typeAnnotation ?? initializerExpression?.staticType).toString();
        final annotation = (primaryKey ?? indexed)!.annotation;

        throw RealmInvalidGenerationSourceError(
          'Realm only support indexes on String, int, and bool fields',
          element: this,
          secondarySpans: {
            enclosingElement.span!:
                "in realm model '${enclosingElement.displayName}'",
            annotation.span(file): "index is requested on '$displayName', but",
          },
          primarySpan: (typeAnnotation ?? initializerExpression)!.span(file),
          primaryLabel: "$typeText is not an indexable type",
          todo: //
              "Change the type of '$displayName', "
              "or remove the $annotation annotation",
        );
      }

      final mapTo = mapToChecker.annotationsOfExact(this).singleOrNull;

      return RealmFieldInfo(
        fieldElement: this,
        indexed: indexed != null,
        primaryKey: primaryKey != null,
        mapTo: mapTo?.getField('name')?.toStringValue(),
      );
    } on InvalidGenerationSourceError catch (_) {
      rethrow;
    } catch (e) {
      // Fallback. Not perfect, but better than just forwarding original error
      throw RealmInvalidGenerationSourceError(
        '$e',
        todo: //
            'Inadequate error report. Please open an issue on: '
            'https://github.com/realm/realm-dart',
        element: this,
      );
    }
  }
}
