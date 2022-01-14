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
import 'package:source_gen/source_gen.dart';
import 'annotation_value.dart';
import 'error.dart';
import 'field_element_ex.dart';

import 'element.dart';
import 'realm_field_info.dart';
import 'realm_model_info.dart';
import 'type_checkers.dart';
import 'session.dart';

final _validIdentifier = RegExp(r'^[a-zA-Z]\w*$');

extension on Iterable<FieldElement> {
  Iterable<RealmFieldInfo> get realmInfo sync* {
    RealmFieldInfo? primaryKeySeen;
    for (final f in this) {
      final info = f.realmInfo;
      if (info == null) continue;
      if (info.primaryKey) {
        if (primaryKeySeen == null) {
          primaryKeySeen = info;
        } else {
          final file = f.shortSpan!.file;
          final annotation = f.primaryKeyInfo!.annotation;
          final classElement = f.enclosingElement;
          throw RealmInvalidGenerationSourceError(
            'Primary key already defined',
            todo: //
                'Remove $annotation annotation from either '
                "'$info' or '$primaryKeySeen'",
            element: classElement,
            primarySpan: annotation.span(file),
            primaryLabel: 'again',
            secondarySpans: {
              classElement.span!:
                  "in realm model '${classElement.displayName}'",
              primaryKeySeen.fieldElement.primaryKeyInfo!.annotation.span(file):
                  'the $annotation annotation is used',
              primaryKeySeen.fieldElement.shortSpan!:
                  "on both '${primaryKeySeen.fieldElement.displayName}', and",
              f.shortSpan!: "on '${f.displayName}'",
            },
          );
        }
      }
      yield info;
    }
  }
}

extension ClassElementEx on ClassElement {
  ClassDeclaration get declarationAstNode =>
      getDeclarationFromElement(this)!.node as ClassDeclaration;

  AnnotationValue? get realmModelInfo =>
      annotationInfoOfExact(realmModelChecker);

  RealmModelInfo? get realmInfo {
    try {
      if (realmModelInfo == null) return null;

      final modelName = this.name;
      final mappedFields = fields.realmInfo.toList();

      final mapTo = mapToInfo;
      if (mapTo != null) {
        final name = mapTo.value.getField('name')!.toStringValue()!;
        if (!_validIdentifier.hasMatch(name)) {
          final elementSpan = span!;
          final file = elementSpan.file;
          final nameExpression = mapTo.annotation.arguments!.arguments.first;
          throw RealmInvalidGenerationSourceError(
            "Invalid class name",
            element: this,
            primarySpan: nameExpression.span(file),
            primaryLabel:
                "${'$nameExpression' == "'$name'" ? '' : "which evaluates to "}'$name' is not a valid class name",
            secondarySpans: {
              elementSpan:
                  "when generating realm object class for '$displayName'",
            },
            todo: 'We need a valid indentifier',
          );
        }
        return RealmModelInfo(name, modelName, mappedFields);
      }

      final prefix = session.prefix;
      var suffix = session.suffix;

      if (!modelName.startsWith(prefix)) {
        throw RealmInvalidGenerationSourceError(
          'Missing prefix on realm model name',
          element: this,
          primarySpan: shortSpan!,
          primaryLabel: 'missing prefix',
          secondarySpans: {span!: "on realm model '$displayName'"},
          todo: //
              'Either add a @MapTo annotation, '
              'or align class name to match prefix '
              '${prefix is RegExp ? '${prefix.pattern} (regular expression)' : prefix}',
        );
      }
      if (!modelName.endsWith(suffix)) {
        throw RealmInvalidGenerationSourceError(
          'Missing suffix on realm model name',
          element: this,
          primarySpan: shortSpan!,
          primaryLabel: 'missing suffix',
          secondarySpans: {span!: "on realm model '$displayName'"},
          //'Expected suffix: $suffix',
          todo: //
              'Either add a @MapTo annotation, '
              'or align class name to suffix $suffix',
        );
      }

      // remove suffix and prefix, if any
      final name = modelName
          .substring(0, modelName.length - suffix.length)
          .replaceFirst(prefix, '');

      return RealmModelInfo(
        name,
        modelName,
        mappedFields,
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
