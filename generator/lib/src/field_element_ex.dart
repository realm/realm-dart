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
import 'package:source_span/source_span.dart';

import 'dart_type_ex.dart';
import 'element.dart';
import 'error.dart';
import 'format_spans.dart';
import 'realm_field_info.dart';
import 'session.dart';
import 'type_checkers.dart';
import 'utils.dart';

extension FieldElementEx on FieldElement {
  FieldDeclaration get declarationAstNode =>
      getDeclarationFromElement(this)!.node.parent!.parent as FieldDeclaration;

  AnnotationValue? get ignoredInfo => annotationInfoOfExact(ignoredChecker);

  AnnotationValue? get primaryKeyInfo =>
      annotationInfoOfExact(primaryKeyChecker);

  AnnotationValue? get indexedInfo => annotationInfoOfExact(indexedChecker);

  TypeAnnotation? get typeAnnotation => declarationAstNode.fields.type;

  Expression? get initializerExpression => declarationAstNode.fields.variables
      .singleWhere((v) => v.name.name == name)
      .initializer;

  FileSpan? typeSpan(SourceFile file) =>
      (typeAnnotation ?? initializerExpression)?.span(file) ?? span;

  // Works even if type of field is unresolved
  String get typeText =>
      (typeAnnotation ?? initializerExpression?.staticType ?? type).toString();

  String get typeModelName =>
      type.isDynamic ? typeText : type.getDisplayString(withNullability: true);

  // TODO: using replaceAll is a hack
  String get typeName => typeModelName.replaceAll(session.prefix, '');

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
        final file = modelSpan.file;
        throw RealmInvalidGenerationSourceError(
          'Primary key cannot be nullable',
          element: this,
          secondarySpans: {
            modelSpan: "in realm model '${enclosingElement.displayName}'",
            primaryKey.annotation.span(file):
                "the primary key '$displayName' is"
          },
          primarySpan: typeSpan(file),
          primaryLabel: 'nullable',
          todo: //
              'Consider using the @Indexed() annotation instead, '
              "or make '$displayName' ${anOrA(typeText)} ${type.asNonNullable}.",
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
        final annotation = (primaryKey ?? indexed)!.annotation;

        throw RealmInvalidGenerationSourceError(
          'Realm only support indexes on String, int, and bool fields',
          element: this,
          secondarySpans: {
            enclosingElement.span!:
                "in realm model '${enclosingElement.displayName}'",
            annotation.span(file): "index is requested on '$displayName', but",
          },
          primarySpan: typeSpan(file),
          primaryLabel: "$typeText is not an indexable type",
          todo: //
              "Change the type of '$displayName', "
              "or remove the $annotation annotation",
        );
      }

      final realmType = type.realmType;
      if (realmType == null) {
        final notARealmTypeSpan = type.element?.span;
        String todo;
        if (notARealmTypeSpan != null) {
          todo = //
              "Add a @RealmModel annotation on '$typeName', "
              "or an @Ignored annotation on '$displayName'.";
        } else if (type.isDynamic &&
            typeName != 'dynamic' &&
            !typeName.startsWith(session.prefix)) {
          todo = "Did you intend to use _$typeName as type for '$displayName'?";
        } else {
          todo = "Add an @Ignored annotation on '$displayName'.";
        }

        final modelElement = enclosingElement;
        final modelSpan = modelElement.span!;
        final file = modelSpan.file;
        throw RealmInvalidGenerationSourceError(
          'Not a realm type',
          element: this,
          primarySpan: typeSpan(file),
          primaryLabel: '$typeText is not a realm type',
          secondarySpans: {
            modelSpan: "in realm model '${modelElement.displayName}'",
            // may go both above and below, or stem from another file
            if (notARealmTypeSpan != null) notARealmTypeSpan: ''
          },
          todo: todo,
        );
      }

      if (type.isRealmCollection && !isFinal) {
        throw RealmInvalidGenerationSourceError(
          'Realm collection field is not final',
          todo: "Add a final keyword to the definition of '$displayName'",
          element: this,
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
