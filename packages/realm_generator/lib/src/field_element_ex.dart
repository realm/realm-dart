// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:realm_common/realm_common.dart';
import 'package:realm_generator/src/expanded_context_span.dart';
import 'package:realm_generator/src/pseudo_type.dart';
import 'package:realm_generator/src/utils.dart';
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

extension FieldElementEx on FieldElement {
  static const realmSetUnsupportedRealmTypes = [RealmPropertyType.linkingObjects];

  ClassElement get enclosingClassElement => enclosingElement3 as ClassElement;

  FieldDeclaration get declarationAstNode => getDeclarationFromElement(this)!.node.parent!.parent as FieldDeclaration;

  AnnotationValue? get ignoredInfo => annotationInfoOfExact(ignoredChecker);

  AnnotationValue? get primaryKeyInfo => annotationInfoOfExact(primaryKeyChecker);

  AnnotationValue? get indexedInfo => annotationInfoOfExact(indexedChecker);

  AnnotationValue? get backlinkInfo => annotationInfoOfExact(backlinkChecker);

  TypeAnnotation? get typeAnnotation => declarationAstNode.fields.type;

  Expression? get initializerExpression => declarationAstNode.fields.variables.singleWhere((v) => v.name.toString() == name).initializer;

  FileSpan? typeSpan(SourceFile file) => ExpandedContextSpan(
        ExpandedContextSpan(
          (typeAnnotation ?? initializerExpression)?.span(file) ?? span!,
          [span!],
        ),
        [span!],
      );

  FileSpan? initializerExpressionSpan(SourceFile file, Expression initializerExpression) => ExpandedContextSpan(
        ExpandedContextSpan(
          (initializerExpression).span(file),
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

      if (ignoredInfo != null) {
        // skip ignored fields
        return null;
      }

      final primaryKey = primaryKeyInfo;
      final indexed = indexedInfo;
      final backlink = backlinkInfo;

      // Validate primary key
      if (primaryKey != null) {
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
        // in dart. Therefore we keep the code out-commented for later.
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

        if (type.realmType?.mapping.canBePrimaryKey != true) {
          final file = span!.file;
          final listOfValidTypes = RealmPropertyType.values //
              .map((t) => t.mapping)
              .where((m) => m.canBePrimaryKey)
              .map((m) => m.type);

          throw RealmInvalidGenerationSourceError(
            'Realm only supports the @PrimaryKey annotation on fields of type\n${listOfValidTypes.join(', ')}\nas well as their nullable versions',
            element: this,
            primarySpan: typeSpan(file),
            primaryLabel: "$modelTypeName is not a valid type here",
            todo: "Change the type of '$displayName' or remove the @PrimaryKey annotation",
          );
        }
      }

      final indexType = indexed == null ? null : RealmIndexType.values.elementAt(indexed.value.getField("indexType")!.getField("index")!.toIntValue()!);

      if (indexed != null) {
        final file = span!.file;

        if (indexType == RealmIndexType.fullText && type.realmType != RealmPropertyType.string) {
          throw RealmInvalidGenerationSourceError('Cannot add full-text index on a non-string property',
              element: this,
              primarySpan: typeSpan(file),
              primaryLabel: 'Cannot use RealmIndexType.fullText for property of type $modelTypeName',
              todo: 'Change the index type to general or change the property type to string');
        }

        if (type.realmType?.mapping.indexable != true) {
          final listOfValidTypes = RealmPropertyType.values //
              .map((t) => t.mapping)
              .where((m) => m.indexable)
              .map((m) => m.type);

          throw RealmInvalidGenerationSourceError(
            'Realm only supports the @Indexed annotation on fields of type\n${listOfValidTypes.join(', ')}\nas well as their nullable versions',
            element: this,
            primarySpan: typeSpan(file),
            primaryLabel: '$modelTypeName is not a valid type here',
            todo: "Change the type of '$displayName' or remove the @Indexed annotation",
          );
        }
      }

      String? linkOriginProperty;

      // Validate field type
      final modelSpan = enclosingElement3.span!;
      final file = modelSpan.file;
      final realmType = type.realmType;
      if (realmType == null) {
        final notARealmTypeSpan = type.element?.span;
        String todo;
        if (notARealmTypeSpan != null) {
          todo = //
              "Add a @RealmModel annotation on '$mappedTypeName', "
              "or an @Ignored annotation on '$displayName'.";
        } else if (session.mapping['_$mappedTypeName'] != null) {
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
            modelSpan: "in realm model '${enclosingElement3.displayName}'",
            // may go both above and below, or stem from another file
            if (notARealmTypeSpan != null) notARealmTypeSpan: ''
          },
          todo: todo,
        );
      } else {
        // Validate collections and backlinks
        if (type.isRealmCollection || backlink != null) {
          final typeDescription = type.isRealmCollection ? type.realmCollectionType.plural : 'backlinks';
          if (type.isNullable) {
            throw RealmInvalidGenerationSourceError(
              'Realm $typeDescription cannot be nullable',
              primarySpan: typeSpan(file),
              primaryLabel: 'is nullable',
              todo: '',
              element: this,
            );
          }
          final itemType = type.basicType;
          final objectsShouldBeNullable = type.realmCollectionType == RealmCollectionType.map;
          if (itemType.isRealmModel && itemType.isNullable != objectsShouldBeNullable) {
            final requestedObjectType = objectsShouldBeNullable ? 'nullable' : 'non-nullable';
            final invalidObjectType = objectsShouldBeNullable ? 'non-nullable' : 'nullable';

            throw RealmInvalidGenerationSourceError('Realm objects in $typeDescription must be $requestedObjectType',
                primarySpan: typeSpan(file),
                primaryLabel: 'which has a $invalidObjectType realm object element type',
                element: this,
                todo: 'Ensure element type is $requestedObjectType');
          }

          if (realmType == RealmPropertyType.mixed && itemType.isNullable) {
            throw RealmInvalidGenerationSourceError('$type is not supported',
                primarySpan: typeSpan(file),
                primaryLabel: 'Nullable RealmValues are not supported',
                element: this,
                todo: 'Ensure the RealmValue type argument is non-nullable. RealmValue can hold null, but must not be nullable itself.');
          }

          if (itemType.isRealmCollection || itemType.realmType == RealmPropertyType.linkingObjects) {
            throw RealmInvalidGenerationSourceError('$type is not supported',
                primarySpan: typeSpan(file),
                primaryLabel: 'Collections of collections are not supported',
                element: this,
                todo: 'Ensure the collection element type $itemType is not Iterable.');
          }

          final initExpression = initializerExpression;
          if (initExpression != null && !_isValidCollectionInitializer(initExpression)) {
            throw RealmInvalidGenerationSourceError('Non-empty default values for $typeDescription are not supported.',
                primarySpan: initializerExpressionSpan(file, initExpression),
                primaryLabel: 'Remove the default value.',
                element: this,
                todo: 'Remove the default value for field $displayName or change it to be an empty collection.');
          }

          switch (type.realmCollectionType) {
            case RealmCollectionType.map:
              final keyType = (type as ParameterizedType).typeArguments.first;
              if (!keyType.isDartCoreString || keyType.isNullable) {
                throw RealmInvalidGenerationSourceError('$type is not supported',
                    primarySpan: typeSpan(file),
                    primaryLabel: 'Non-String keys are not supported in maps',
                    element: this,
                    todo: 'Change the map key type to be String');
              }
              break;
            case RealmCollectionType.set:
              if (itemType.realmObjectType == ObjectType.embeddedObject) {
                throw RealmInvalidGenerationSourceError('$type is not supported',
                    primarySpan: typeSpan(file),
                    primaryLabel: 'Embedded objects in sets are not supported',
                    element: this,
                    todo: 'Change the collection element to be a non-embedded object');
              }
              break;
            default:
              break;
          }
        }

        // Validate backlinks
        if (backlink != null) {
          if (!type.isDartCoreIterable || !(type as ParameterizedType).typeArguments.first.isRealmModel) {
            throw RealmInvalidGenerationSourceError(
              'Backlink must be an iterable of realm objects',
              primarySpan: typeSpan(file),
              primaryLabel: '$modelTypeName is not an iterable of realm objects',
              todo: '',
              element: this,
            );
          }

          final sourceFieldName = backlink.value.getField('fieldName')?.toSymbolValue();
          final sourceType = (type as ParameterizedType).typeArguments.first;
          final sourceField = (sourceType.element as ClassElement?)?.fields.where((f) => f.name == sourceFieldName).singleOrNull;

          if (sourceField == null) {
            throw RealmInvalidGenerationSourceError(
              'Backlink must point to a valid field',
              primarySpan: typeSpan(file),
              primaryLabel: '$sourceType does not have a field named $sourceFieldName',
              todo: '',
              element: this,
            );
          }

          final thisType = (enclosingElement3 as ClassElement).thisType;
          final linkType = thisType.asNullable;
          final listOf = session.typeProvider.listType(thisType);
          if (sourceField.type != linkType && sourceField.type != listOf) {
            throw RealmInvalidGenerationSourceError(
              'Incompatible backlink type',
              primarySpan: typeSpan(file),
              primaryLabel: "$sourceType.$sourceFieldName is not a '$linkType' or '$listOf'",
              todo: '',
              element: this,
            );
          }

          // everything is kosher, just need to account for @MapTo!
          linkOriginProperty = sourceField.remappedRealmName ?? sourceField.name;
        }

        // Validate object references
        else if (realmType == RealmPropertyType.object && !type.isRealmCollection) {
          if (!type.isNullable) {
            throw RealmInvalidGenerationSourceError(
              'Realm object references must be nullable',
              primarySpan: typeSpan(file),
              primaryLabel: 'is not nullable',
              todo: 'Change type to $modelTypeName?',
              element: this,
            );
          }

          final initExpression = initializerExpression;
          if (initExpression != null) {
            throw RealmInvalidGenerationSourceError(
              'Realm object references should not have default values',
              primarySpan: initializerExpressionSpan(file, initExpression),
              primaryLabel: ' Remove the default value',
              todo: 'Remove the default value for field "$displayName"',
              element: this,
            );
          }
        }

        // Validate mixed (RealmValue)
        else if (realmType == RealmPropertyType.mixed && type.isNullable) {
          throw RealmInvalidGenerationSourceError(
            'RealmValue fields cannot be nullable',
            primarySpan: typeSpan(file),
            primaryLabel: '$modelTypeName is nullable',
            todo: 'Change type to RealmValue. RealmValue can hold null, but must not be nullable itself.',
            element: this,
          );
        }
      }

      final initExpression = initializerExpression;
      if (initExpression != null && !_isValidFieldInitializer(initExpression)) {
        throw RealmInvalidGenerationSourceError(
          'Field initializers must be constant',
          primarySpan: initializerExpressionSpan(file, initExpression),
          primaryLabel: 'Must be const',
          todo: 'Ensure the default value for field "$displayName" is const',
          element: this,
        );
      }

      return RealmFieldInfo(
        fieldElement: this,
        indexType: indexType,
        isPrimaryKey: primaryKey != null,
        mapTo: remappedRealmName,
        realmType: realmType,
        linkOriginProperty: linkOriginProperty,
      );
    } on InvalidGenerationSourceError catch (_) {
      rethrow;
    } catch (e, s) {
      // Fallback. Not perfect, but better than just forwarding original error.
      throw RealmInvalidGenerationSourceError(
        '$e\n$s',
        todo: //
            'Unexpected error. Please open an issue on: '
            'https://github.com/realm/realm-dart',
        element: this,
      );
    }
  }

  bool _isValidCollectionInitializer(Expression initExpression) {
    if (initExpression is AstNodeImpl) {
      final astNode = initExpression as AstNodeImpl;
      final elementsNode = astNode.namedChildEntities.where((e) => e.name == 'elements').singleOrNull;
      final nodeValue = elementsNode?.value;
      if (nodeValue is NodeList && nodeValue.isEmpty) {
        return true;
      }
    }
    return false;
  }

  bool _isValidFieldInitializer(Expression initExpression) {
    return switch (initExpression) {
      Literal _ => true,
      InstanceCreationExpression i => i.isConst,
      ParenthesizedExpression i => _isValidFieldInitializer(i.expression),
      PrefixExpression e => _isValidFieldInitializer(e.operand),
      BinaryExpression b => _isValidFieldInitializer(b.leftOperand) && _isValidFieldInitializer(b.rightOperand),
      Identifier i => (i.staticElement as PropertyAccessorElement?)?.variable2?.isConst ?? false,
      _ => false,
    };
  }
}
