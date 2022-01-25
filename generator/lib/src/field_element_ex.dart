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
import 'package:realm_common/realm_common.dart';
import 'package:realm_generator/src/expanded_context_span.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_span/source_span.dart';

import 'annotation_value.dart';
import 'dart_type_ex.dart';
import 'element.dart';
import 'error.dart';
import 'format_spans.dart';
import 'realm_field_info.dart';
import 'session.dart';
import 'type_checkers.dart';
import 'utils.dart';

extension FieldElementEx on FieldElement {
  FieldDeclaration get declarationAstNode => getDeclarationFromElement(this)!.node.parent!.parent as FieldDeclaration;

  AnnotationValue? get ignoredInfo => annotationInfoOfExact(ignoredChecker);

  AnnotationValue? get primaryKeyInfo => annotationInfoOfExact(primaryKeyChecker);

  AnnotationValue? get indexedInfo => annotationInfoOfExact(indexedChecker);

  TypeAnnotation? get typeAnnotation => declarationAstNode.fields.type;

  Expression? get initializerExpression => declarationAstNode.fields.variables.singleWhere((v) => v.name.name == name).initializer;

  // TODO: Why twice?
  FileSpan? typeSpan(SourceFile file) => ExpandedContextSpan(
        ExpandedContextSpan(
          (typeAnnotation ?? initializerExpression)?.span(file) ?? span!,
          [span!],
        ),
        [span!],
      );

  // Works even if type of field is unresolved
  String get typeText => (typeAnnotation ?? initializerExpression?.staticType ?? type).toString();

  String get typeModelName => type.isDynamic ? typeText : type.getDisplayString(withNullability: true);

  // TODO: using replaceAll is a temporary hack.
  // It is needed for now, since we cannot construct a DartType for the yet to
  // be generated classes, ie. for _A given A. Once the new static meta
  // programming feature is added to dart, we should be able to resolve this
  // using a ClassTypeMacro.
  String get typeName => typeModelName.replaceAll(session.prefix, '');

  RealmFieldInfo? get realmInfo {
    try {
      if (!(getter?.isSynthetic ?? false)) {
        // skip explicitly defined getters
        return null;
      }

      if (ignoredInfo != null || isPrivate) {
        // skip ignored and private fields
        return null;
      }

      final primaryKey = primaryKeyInfo;
      final indexed = indexedInfo;

      // Validate primary key
      if (primaryKey != null) {
        if (type.isNullable) {
          final modelSpan = enclosingElement.span!;
          final file = modelSpan.file;
          throw RealmInvalidGenerationSourceError(
            'Primary key cannot be nullable',
            element: this,
            primarySpan: typeSpan(file),
            primaryLabel: 'is nullable',
            todo: //
                'Consider using the @Indexed() annotation instead, '
                "or make '$displayName' ${anOrA(typeText)} ${type.asNonNullable}.",
          );
        }
        if (indexed != null) {
          log.info(formatSpans(
            'Indexed is implied for a primary key',
            primarySpan: span!,
            todo: "Remove either the @Indexed or @PrimaryKey annotation from '$displayName'.",
            element: this,
          ));
        }
        if (!isFinal) {
          throw RealmInvalidGenerationSourceError(
            'Primary key field is not final',
            primarySpan: span!,
            primaryLabel: 'is not final',
            todo: //
                "Add a final keyword to the definition of '$displayName', "
                'or remove the @PrimaryKey annotation.',
            element: this,
          );
        }
      }

      // Validate indexes
      if ((primaryKey != null || indexed != null) &&
          (![
                RealmPropertyType.string,
                RealmPropertyType.int,
              ].contains(type.realmType) ||
              type.isRealmCollection)) {
        final file = span!.file;
        final annotation = (primaryKey ?? indexed)!.annotation;

        throw RealmInvalidGenerationSourceError(
          'Realm only support indexes on String, int, and bool fields',
          element: this,
          primarySpan: typeSpan(file),
          primaryLabel: "$typeText is not an indexable type",
          todo: //
              "Change the type of '$displayName', "
              "or remove the $annotation annotation",
        );
      }

      // Validate field type
      final modelSpan = enclosingElement.span!;
      final file = modelSpan.file;
      final realmType = type.realmType;
      if (realmType == null) {
        final notARealmTypeSpan = type.element?.span;
        String todo;
        if (notARealmTypeSpan != null) {
          todo = //
              "Add a @RealmModel annotation on '$typeName', "
              "or an @Ignored annotation on '$displayName'.";
        } else if (type.isDynamic && typeName != 'dynamic' && !typeName.startsWith(session.prefix)) {
          todo = "Did you intend to use _$typeName as type for '$displayName'?";
        } else {
          todo = "Remove the invalid field or add an @Ignored annotation on '$displayName'.";
        }

        throw RealmInvalidGenerationSourceError(
          'Not a realm type',
          element: this,
          primarySpan: typeSpan(file),
          primaryLabel: '$typeText is not a realm model type',
          secondarySpans: {
            modelSpan: "in realm model '${enclosingElement.displayName}'",
            // may go both above and below, or stem from another file
            if (notARealmTypeSpan != null) notARealmTypeSpan: ''
          },
          todo: todo,
        );
      } else {
        // Validate collections
        if (type.isRealmCollection) {
          if (!isFinal) {
            throw RealmInvalidGenerationSourceError(
              'Realm collection field must be final',
              primarySpan: span,
              primaryLabel: 'is not final',
              todo: "Add a final keyword to the definition of '$displayName'",
              element: this,
            );
          }
          if (type.isNullable) {
            throw RealmInvalidGenerationSourceError(
              'Realm collections cannot be nullable',
              primarySpan: typeSpan(file),
              primaryLabel: 'is nullable',
              todo: '',
              element: this,
            );
          }
          final itemType = type.basicType;
          if (itemType.isRealmModel && itemType.isNullable) {
            throw RealmInvalidGenerationSourceError('Nullable realm objects are not allowed in collections',
                primarySpan: typeSpan(file), // TODO: Restrict span to the parameter type
                primaryLabel: 'which has a nullable realm object element type',
                element: this,
                todo: 'Ensure element type is non-nullable');
          }
        }

        // Validate object references
        else if (realmType == RealmPropertyType.object) {
          if (!type.isNullable) {
            throw RealmInvalidGenerationSourceError(
              'Realm object references must be nullable',
              primarySpan: typeSpan(file),
              primaryLabel: 'is not nullable',
              todo: 'Change type to $typeText?',
              element: this,
            );
          }
        }
      }

      return RealmFieldInfo(
        fieldElement: this,
        indexed: indexed != null,
        primaryKey: primaryKey != null,
        mapTo: mapToInfo?.value.getField('name')?.toStringValue(),
        realmType: realmType,
      );
    } on InvalidGenerationSourceError catch (_) {
      rethrow;
    } catch (e, s) {
      // Fallback. Not perfect, but better than just forwarding original error.
      print(s);
      throw RealmInvalidGenerationSourceError(
        '$e',
        todo: //
            'Unexpected error. Please open an issue on: '
            'https://github.com/realm/realm-dart',
        element: this,
      );
    }
  }
}
