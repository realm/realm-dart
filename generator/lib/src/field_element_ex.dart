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
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:realm_common/realm_common.dart';
import 'package:realm_generator/src/expanded_context_span.dart';
import 'package:realm_generator/src/pseudo_type.dart';
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

  // TODO: Why twice? - https://github.com/realm/realm-dart/issues/695
  FileSpan? typeSpan(SourceFile file) => ExpandedContextSpan(
        ExpandedContextSpan(
          (typeAnnotation ?? initializerExpression)?.span(file) ?? span!,
          [span!],
        ),
        [span!],
      );

  DartType get modelType => typeAnnotation?.type?.nullIfDynamic ?? initializerExpression?.staticType ?? PseudoType(typeAnnotation.toString());

  String get modelTypeName => modelType.getDisplayString(withNullability: true);

  String get mappedTypeName => modelType.mappedName;

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

      // Check for as-of-yet unsupported type
      if (type.isDartCoreSet || //
          type.isDartCoreMap ||
          type.isRealmAny ||
          type.isExactly<Decimal128>()) {
        throw RealmInvalidGenerationSourceError(
          'Field type not supported yet',
          element: this,
          primarySpan: typeSpan(span!.file),
          primaryLabel: 'not yet supported',
          todo: 'Avoid using $modelTypeName for now',
        );
      }

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
                "or make '$displayName' ${anOrA(modelTypeName)} ${type.asNonNullable}.",
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
        // Since the setter of a dart late final public field without initializer is public,
        // the error of setting a primary key after construction will be a runtime error no matter
        // what we do. See:
        //
        //  https://github.com/dart-lang/language/issues/1239
        //  https://github.com/dart-lang/language/issues/2068
        //
        // Hence we may as well lift the restriction that primary keys must be declared final.
        //
        // However, this may change in the future. Either as the dart language team change this
        // blemish. Or perhaps we can avoid the late modifier, once static meta programming lands
        // in dart. Therefor we keep the code outcommented for later.
        /*
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
        */
      }

      // Validate indexes
      if ((primaryKey != null || indexed != null) &&
          (![RealmPropertyType.string, RealmPropertyType.int, RealmPropertyType.objectid, RealmPropertyType.uuid].contains(type.realmType) ||
              type.isRealmCollection)) {
        final file = span!.file;
        final annotation = (primaryKey ?? indexed)!.annotation;

        throw RealmInvalidGenerationSourceError(
          'Realm only support indexes on String, int, and bool fields',
          element: this,
          primarySpan: typeSpan(file),
          primaryLabel: "$modelTypeName is not an indexable type",
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
              "Add a @RealmModel annotation on '$mappedTypeName', "
              "or an @Ignored annotation on '$displayName'.";
        } else if (type.isDynamic && mappedTypeName != 'dynamic' && !mappedTypeName.startsWith(session.prefix)) {
          todo = "Did you intend to use _$mappedTypeName as type for '$displayName'?";
        } else {
          todo = "Remove the invalid field or add an @Ignored annotation on '$displayName'.";
        }

        throw RealmInvalidGenerationSourceError(
          'Not a realm type',
          element: this,
          primarySpan: typeSpan(file),
          primaryLabel: '$modelTypeName is not a realm model type',
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
                primarySpan: typeSpan(file), // TODO: Restrict span to the parameter type - https://github.com/realm/realm-dart/issues/695
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
              todo: 'Change type to $modelTypeName?',
              element: this,
            );
          }
        }
      }

      return RealmFieldInfo(
        fieldElement: this,
        indexed: indexed != null,
        primaryKey: primaryKey != null,
        mapTo: remappedRealmName,
        realmType: realmType,
      );
    } on InvalidGenerationSourceError catch (_) {
      rethrow;
    } catch (e, s) {
      // Fallback. Not perfect, but better than just forwarding original error.
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
