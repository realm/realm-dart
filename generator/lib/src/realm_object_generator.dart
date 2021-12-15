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

library realm_generator;

import 'dart:async';
import 'dart:cli';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:realm_annotations/realm_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_span/source_span.dart';

// NOTE: This is copied from `package:build_runner_core`.
// Hopefully it will be made public at some point.
String humanReadable(Duration duration) {
  // Added microseconds
  if (duration < const Duration(milliseconds: 1)) {
    return '${duration.inMicroseconds}μs';
  }
  if (duration < const Duration(seconds: 1)) {
    return '${duration.inMilliseconds}ms';
  }
  if (duration < const Duration(minutes: 1)) {
    return '${(duration.inMilliseconds / 1000.0).toStringAsFixed(1)}s';
  }
  if (duration < const Duration(hours: 1)) {
    final minutes = duration.inMinutes;
    final remaining = duration - Duration(minutes: minutes);
    return '${minutes}m ${remaining.inSeconds}s';
  }
  final hours = duration.inHours;
  final remaining = duration - Duration(hours: hours);
  return '${hours}h ${remaining.inMinutes}m';
}

FutureOr<T> meassure<T>(FutureOr<T> Function() action,
    {String tag = '', repetitions = 1}) async {
  return [
    for (int i = 0; i < repetitions; ++i)
      await (() async {
        final stopwatch = Stopwatch()..start();
        try {
          return await action();
        } finally {
          stopwatch.stop();
          final time = humanReadable(stopwatch.elapsed);
          log.info('[$tag ($i)] completed, took $time');
        }
      })()
  ].last;
}

extension on DartType {
  bool isExactly<T>() => TypeChecker.fromRuntime(T).isExactlyType(this);

  bool get isRealmAny =>
      const TypeChecker.fromRuntime(RealmAny).isAssignableFromType(this);
  bool get isRealmBacklink => false; // TODO
  bool get isRealmObject =>
      realmModelChecker.annotationsOfExact(element!).isNotEmpty;

  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;

  RealmCollectionType get realmCollectionType {
    if (isDartCoreSet) return RealmCollectionType.set;
    if (isDartCoreList) return RealmCollectionType.list;
    // TODO: Check that key type is String!
    if (isDartCoreMap) return RealmCollectionType.map;
    return RealmCollectionType.none;
  }

  RealmPropertyType? get realmType => _realmType(true);

  RealmPropertyType? _realmType(bool recurse) {
    if (realmCollectionType != RealmCollectionType.none && recurse) {
      return (this as ParameterizedType)
          .typeArguments
          .last
          ._realmType(false); // only recurse once! (for now)
    }
    if (isDartCoreInt) return RealmPropertyType.int;
    if (isDartCoreBool) return RealmPropertyType.bool;
    if (isDartCoreString) return RealmPropertyType.string;
    if (isExactly<Uint8List>()) return RealmPropertyType.binary;
    if (isRealmAny) return RealmPropertyType.mixed;
    if (isExactly<DateTime>()) return RealmPropertyType.timestamp;
    if (isExactly<Float>()) return RealmPropertyType.float;
    if (isDartCoreNum || isDartCoreDouble) return RealmPropertyType.double;
    if (isExactly<Decimal128>()) return RealmPropertyType.decimal128;
    if (isRealmObject) return RealmPropertyType.object;
    if (isRealmBacklink) return RealmPropertyType.linkingObjects;
    if (isExactly<ObjectId>()) return RealmPropertyType.objectid;
    if (isExactly<Uuid>()) return RealmPropertyType.uuid;

    return null;
  }
}

class RealmModelInfo {
  final String name;
  final String modelName;
  final List<RealmFieldInfo> fields;

  RealmModelInfo(this.name, this.modelName, this.fields);

  Iterable<String> toCode() sync* {
    yield 'class $name extends $modelName with RealmObject {';
    {
      yield '$name({';
      {
        yield* fields.map((f) =>
            '${f.optional | f.hasDefaultValue ? '' : 'required '}${f.typeName}${!f.optional & f.hasDefaultValue ? '?' : ''} ${f.name},');
        yield '}) {';
        yield* fields.map((f) {
          final prefix = f.isFinal ? '_' : 'this.';
          return f.hasDefaultValue
              ? '$prefix${f.name} = ${f.declaration.node.toString().replaceFirst('=', '??')};' // TODO: Feels a bit hacky!
              : '$prefix${f.name} = ${f.name};';
        });
      }
      yield '}';
      yield '';

      yield* fields.expand((f) => [
            ...f.toCode(),
            '',
          ]);

      yield 'static const schema = SchemaObject($name, [';
      {
        yield* fields.map((f) {
          final namedArgs = {
            if (f.name != f.realmName) 'mapTo': f.realmName,
            if (f.optional) 'optional': f.optional,
            if (f.primaryKey) 'primaryKey': f.primaryKey,
          };
          return "SchemaProperty('${f.realmName}', ${f.realmType}${namedArgs.isNotEmpty ? ', ' + namedArgs.toArgsString() : ''}),";
        });
      }
      yield ']);';
      yield '';
    }
    yield '}';
  }
}

extension<K, V> on Map<K, V> {
  String toArgsString() {
    return () sync* {
      for (final e in entries) {
        if (e.value is String) {
          yield "${e.key}: '${e.value}'";
        } else {
          yield '${e.key}: ${e.value}';
        }
      }
    }()
        .join(',');
  }
}

class _Config {
  final Pattern prefix;
  final String suffix;
  final bool color;

  _Config({String? prefix, String? suffix, this.color = false})
      : prefix = prefix ?? RegExp(r'[_$]'), // defaults to _ or $
        suffix = suffix ?? '';
}

late _Config _config;

final _validIdentifier = RegExp(r'^[a-zA-Z]\w*$');

extension on ClassElement {
  ClassDeclaration get declarationAstNode =>
      getDeclarationFromElement(this)!.node as ClassDeclaration;

  RealmAnnotationInfo? get realmModelInfo =>
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

      final prefix = _config.prefix;
      var suffix = _config.suffix;

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

      final name = modelName
          .substring(
              0, modelName.length - suffix.length) // remove suffix, if any
          .replaceFirst(prefix, ''); // remove prefix

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

extension on Iterable<ClassElement> {
  Iterable<RealmModelInfo> get realmInfo =>
      map((m) => m.realmInfo).whereNotNull;
}

enum RealmCollectionType {
  none,
  list,
  set,
  map,
}

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

  String get name => fieldElement.name;
  String get realmName => mapTo ?? name;
  DartType get type => fieldElement.type;
  ElementDeclarationResult get declaration =>
      getDeclarationFromElement(fieldElement)!;

  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.isNullable;
  bool get isFinal => fieldElement.isFinal;

  String get typeName =>
      typeModelName.replaceAll('_', ''); // TODO: Very hackish

  String get typeModelName => type.isDynamic
      ? (declaration.node.parent as VariableDeclarationList)
          .type
          .toString() // read from AST
      : type.getDisplayString(withNullability: true);

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
        !typeName.startsWith(_config.prefix)) {
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

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$typeName get $name => RealmObject.get<$typeName>(this, '$realmName') as $typeName;";
    if (!isFinal) yield '@override';
    yield "set ${isFinal ? '_' : ''}$name(${typeName != typeModelName ? 'covariant ' : ''}$typeName value) => RealmObject.set(this, '$realmName', value);";
  }

  @override
  String toString() => fieldElement.displayName;
}

const realmModelChecker = TypeChecker.fromRuntime(RealmModel);
const ignoredChecker = TypeChecker.fromRuntime(Ignored);
const indexedChecker = TypeChecker.fromRuntime(Indexed);
const mapToChecker = TypeChecker.fromRuntime(MapTo);
const primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);

const realmAnnotationChecker = TypeChecker.any([
  ignoredChecker,
  indexedChecker,
  mapToChecker,
  primaryKeyChecker,
]);

class RealmAnnotationInfo {
  final Annotation annotation;
  final DartObject value;
  RealmAnnotationInfo(this.annotation, this.value);
}

extension on Element {
  FileSpan? get shortSpan {
    try {
      return spanForElement(this) as FileSpan;
    } catch (_) {}
    return null;
  }

  AnnotatedNode get declarationAstNode {
    final self = this;
    // Don't replace with switch! (there be dragons here)
    if (self is ClassElement) return self.declarationAstNode;
    if (self is FieldElement) return self.declarationAstNode;
    throw UnsupportedError('$runtimeType not supported');
  }

  Iterable<RealmAnnotationInfo> _annotationsInfoOfExact(TypeChecker checker) sync* {
    // This is a bit backwards because of the api surface on TypeCheckers
    final values = checker.annotationsOfExact(this).toSet();
    final node = declarationAstNode;
    for (final annotation in node.metadata) {
      final value = annotation.elementAnnotation?.computeConstantValue();
      if (value != null && values.contains(value)) {
        yield RealmAnnotationInfo(annotation, value);
      }
    }
  }

  RealmAnnotationInfo? annotationInfoOfExact(TypeChecker checker) {
    RealmAnnotationInfo? result;
    for (final info in _annotationsInfoOfExact(checker)) {
      if (result == null) {
        result = info;
      } else {
        final elementSpan = shortSpan!;
        final file = elementSpan.file;
        throw RealmInvalidGenerationSourceError('Repeated annotation',
            element: this,
            primarySpan: info.annotation.span(file),
            primaryLabel: '2nd',
            secondarySpans: {
              elementSpan: 'on $displayName',
              result.annotation.span(file): '1st',
            },
            todo: 'Remove all duplicated ${info.annotation} annotations.');
      }
    }
    return result;
  }

  RealmAnnotationInfo? get mapToInfo => annotationInfoOfExact(mapToChecker);

  FileSpan? get span {
    FileSpan? elementSpan;
    try {
      elementSpan = shortSpan!;
      final self = this;
      if (self is FieldElement) {
        final node = self.declarationAstNode;
        if (node.metadata.isNotEmpty) {
          return node.span(elementSpan.file);
        }
      } else if (self is ClassElement) {
        final node = self.declarationAstNode;
        if (node.metadata.isNotEmpty) {
          // don't include full class
          return node
              .span(elementSpan.file)
              .clampEnd(elementSpan.extentToEndOfLine());
        }
      }
    } catch (_) {}
    // don't allow span calculation to bring us down
    return elementSpan;
  }
}

extension on FileSpan {
  FileSpan clampEnd(FileSpan other) => file.span(
        start.offset,
        min(end.offset, other.end.offset),
      );

  FileSpan extentToEndOfLine([int noOfLines = 1]) {
    var end = this.end.offset;
    final line = file.location(end).line;
    end = max(end, file.getOffset(min(line + noOfLines, file.lines - 1)));
    return file.span(start.offset, end);
  }
}

extension on AstNode {
  FileSpan span(SourceFile file) {
    // TODO: Can we get rid of file argument and still be efficient?
    return file.span(offset, offset + length);
  }
}

ElementDeclarationResult? getDeclarationFromElement(Element element) {
  final session = element.session!;
  final library = waitFor(session.getResolvedLibraryByElement(element.library!))
      as ResolvedLibraryResult;
  return library.getElementDeclaration(element);
}

String anOrA(String text) => 'aeiouy'.contains(text[0]) ? 'an' : 'a';

extension on FieldElement {
  FieldDeclaration get declarationAstNode =>
      getDeclarationFromElement(this)!.node.parent!.parent as FieldDeclaration;

  RealmAnnotationInfo? get ignoredInfo =>
      annotationInfoOfExact(ignoredChecker);

  RealmAnnotationInfo? get primaryKeyInfo =>
      annotationInfoOfExact(primaryKeyChecker);

  RealmAnnotationInfo? get indexedInfo =>
      annotationInfoOfExact(indexedChecker);

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
        log.info(_formatMessage(
          'Indexed is implied for a primary key',
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
            annotation.span(file):
                "index is requested on '$displayName', but",
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

extension<T> on Iterable<T?> {
  Iterable<T> get whereNotNull => where((i) => i != null).cast<T>();
}

extension<T> on Iterable<T> {
  T? get singleOrNull =>
      cast<T?>().singleWhere((element) => true, orElse: () => null);
}

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
              primaryKeySeen.fieldElement.primaryKeyInfo!.annotation
                  .span(file): 'the $annotation annotation is used',
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

class RealmInvalidGenerationSourceError extends InvalidGenerationSourceError {
  final SourceSpan? primarySpan;
  final String? primaryLabel;
  final Map<SourceSpan, String> secondarySpans;

  RealmInvalidGenerationSourceError(
    String message, {
    required String todo,
    required Element element,
    this.primarySpan,
    this.primaryLabel,
    this.secondarySpans = const {},
  }) : super(message, todo: todo, element: element);

  @override
  String toString() => _formatMessage(
        message,
        element: element!,
        todo: todo,
        primaryLabel: primaryLabel,
        primarySpan: primarySpan,
        secondarySpans: secondarySpans,
      );
}

String _formatMessage(
  String message, {
  required Element element,
  required String todo,
  SourceSpan? primarySpan,
  String? primaryLabel,
  Map<SourceSpan, String> secondarySpans = const {},
}) {
  final buffer = StringBuffer(message);
  try {
    final span = primarySpan ?? element.span!;
    final formated = secondarySpans.isEmpty
        ? span.highlight(color: _config.color)
        : span.highlightMultiple(
            primaryLabel ?? '!',
            secondarySpans,
            color: _config.color,
          );
    buffer
      ..write('\n' * 2 + 'in: ')
      ..writeln(span.start.toolString)
      ..write(formated);
  } catch (e) {
    // Source for `element` wasn't found, it must be in a summary with no
    // associated source. We can still give the name.
    buffer.writeln('\nCause: $element');
  }
  if (todo.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(todo);
  }
  return buffer.toString();
}

class RealmObjectGenerator extends Generator {
  RealmObjectGenerator([_Config? config]) {
    _config = config ?? _Config();
  }

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await meassure(() async {
      return library.classes.realmInfo.expand((m) => m.toCode()).join('\n');
    }, tag: 'generate');
  }
}
