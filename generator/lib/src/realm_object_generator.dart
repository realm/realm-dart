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
import 'dart:ffi';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
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
  final String prototypeName;
  final String realmName;
  final List<RealmFieldInfo> fields;

  RealmModelInfo(this.name, this.prototypeName, this.realmName, this.fields);

  Iterable<String> toCode() sync* {
    yield 'class $name extends $prototypeName with RealmObject {';
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

      yield 'static const schema = SchemaObject($realmName, [';
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

// TODO: Since build_runner runs dart format anyway indentation is kind of mood :-/
Iterable<String> indent(Iterable<String> Function() block) sync* {
  for (final statement in block()) {
    yield '  ' + statement;
  }
}

extension on ClassElement {
  RealmModelInfo? get realmInfo {
    final realmModel = realmModelChecker.annotationsOfExact(this).singleOrNull;
    if (realmModel == null) return null;
    if (!isPrivate) {
      // TODO: Warn user, but proceed
    }

    // TODO: Allow user to specify overrides globally
    Pattern prefix = RegExp(r'^[_\$]'); // default: _ or $
    var suffix = '';
    final prefixFromAnnotation = realmModel.getField('prefix')?.toStringValue();
    final suffixFromAnnotation = realmModel.getField('suffix')?.toStringValue();
    if (prefixFromAnnotation != null || suffixFromAnnotation != null) {
      prefix = prefixFromAnnotation ?? '';
      suffix = suffixFromAnnotation ?? '';
    }

    final prototypeName = this.name;
    if (!prototypeName.startsWith(prefix)) {
      throw RealmInvalidGenerationSourceError(
        'Expected prefix: $prefix',
        todo:
            'Either update prefix in @RealmModel annotation, or align class name.',
        element: this,
      );
    }
    if (!prototypeName.endsWith(suffix)) {
      throw RealmInvalidGenerationSourceError(
        'Expected suffix: $suffix',
        todo:
            'Either update suffix in @RealmModel annotation, or align class name.',
        element: this,
      );
    }

    final name = prototypeName
        .substring(0, prototypeName.length - suffix.length)
        .replaceFirst(prefix, '');

    final mapTo = mapToChecker.annotationsOfExact(this).singleOrNull;
    final realmName = mapTo?.getField('name')?.toStringValue() ?? name;

    return RealmModelInfo(
      name,
      prototypeName,
      realmName,
      fields.realmInfo.toList(),
    );
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
      getDeclarationFromElement(fieldElement);

  bool get hasDefaultValue => fieldElement.hasInitializer;
  bool get optional => type.isNullable;
  bool get isFinal => fieldElement.isFinal;

  String get typeName =>
      typeModelName.replaceAll('_', ''); // TODO: Very hackish

  String get typeModelName => type.getDisplayString(withNullability: true);

  RealmPropertyType get realmType {
    final realmType = type.realmType;
    if (realmType != null) return realmType;

    final typeDefinitionSpan = type.element?.span;
    if (typeDefinitionSpan != null) {
      throw RealmInvalidGenerationSourceError(
        'Not a valid realm type: $type',
        element: fieldElement,
        todo: //
            'Add a @RealmModel annotation on the type definition, '
            'or an @Ignored annotation on the field using it.',
        secondarySpans: {typeDefinitionSpan: 'defined here'},
      );
    } else if (!type.isDynamic) {
      throw RealmInvalidGenerationSourceError(
        'Not a valid realm type: $type',
        element: fieldElement,
        todo: 'Add an @Ignored annotation.',
      );
    } else {
      throw RealmInvalidGenerationSourceError(
        'Not a valid realm type',
        element: fieldElement,
        todo: 'Add an @Ignored annotation.',
      );
    }
  }

  RealmCollectionType get realmCollectionType => type.realmCollectionType;

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$typeName get $name => RealmObject.get<$typeName>(this, '$realmName');";
    if (!isFinal) yield '@override';
    yield "set ${isFinal ? '_' : ''}$name(${typeName != typeModelName ? 'covariant ' : ''}$typeName value) => RealmObject.set(this, '$realmName', value);";
  }
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

final lineMatcher = RegExp(r'^.*$', multiLine: true);

extension on int {
  String pad(int width) => toString().padLeft(width);
  int get width => math.log(this) ~/ math.ln10 + 1;
}

extension on Element {
  FileSpan? get span {
    FileSpan? elementSpan;
    try {
      elementSpan = spanForElement(this) as FileSpan;
      final annotationSpan =
          spanForElement(metadata.firstOrNull!.element!) as FileSpan;
      elementSpan = elementSpan.expand(annotationSpan);
    } catch (e) {
      // log.fine('issue getting span for $this', e);
    }
    // don't allow span calculation to bring us down
    return elementSpan;
  }

  String get display {
    return () sync* {
      // NOTE: I find it odd that there is no good support for this in the analyzer package
      // TODO: Use spanForElement() .. Doh!
      final code = source!.contents.data;
      const contextLines = 3;
      final matches = lineMatcher.allMatches(code).toList(); // split on lines

      var lineIndex =
          matches.indexWhere((m) => nameOffset < m.start); // one past!
      lineIndex = lineIndex < 0 ? matches.length : lineIndex;

      final firstLine = math.max(0, lineIndex - contextLines);
      final lastLine = math.min(lineIndex + contextLines, matches.length);
      final nameLineOffset = nameOffset - matches[lineIndex - 1].start;

      final lineNumberWidth = lastLine.width;
      var currentLine = firstLine;
      context(int start, int end) => matches.getRange(start, end).map((m) =>
          '${(++currentLine).pad(lineNumberWidth)} │ ${m.group(0).toString().trimRight()}');

      final prefix = ' ' * lineNumberWidth;
      yield '\n$source:$lineIndex:$nameLineOffset';
      yield prefix + ' ╷';
      yield* context(firstLine, lineIndex);
      yield prefix + ' │ ' + ' ' * nameLineOffset + '^' * nameLength;
      yield* context(lineIndex, lastLine);
      yield prefix + ' ╵';
    }()
        .join('\n');
  }
}

ElementDeclarationResult getDeclarationFromElement(Element element) {
  // TODO: Lots of bangs here. Ensure proper error handling
  final session = element.session!;
  final parsedLibrary = session.getParsedLibraryByElement(element.library!)
      as ParsedLibraryResult;
  return parsedLibrary.getElementDeclaration(element)!;
}

extension on FieldElement {
  RealmFieldInfo? get realmInfo {
    try {
      if (ignoredChecker.annotationsOfExact(this).isNotEmpty || isPrivate) {
        // skip ignored and private fields
        return null;
      }

      final primaryKeyAnnotation =
          primaryKeyChecker.annotationsOfExact(this).singleOrNull;
      final primaryKey = primaryKeyAnnotation != null;
      final indexedAnnotation =
          indexedChecker.annotationsOfExact(this).singleOrNull;
      final indexed = indexedAnnotation != null;
      final optional = type.isNullable;

      if (primaryKey & optional) {
        throw RealmInvalidGenerationSourceError(
            'Primary key cannot be nullable',
            todo: //
                'Consider using the @Indexed annotation instead, '
                'or make the field non-nullable.',
            element: this);
      }
      if (primaryKey & indexed) {
        log.info(_formatMessage(
          'Indexed is implied for a primary key',
          todo: 'Remove either the @Indexed or @PrimaryKey annotation.',
          element: this,
        ));
      }
      if (primaryKey && !isFinal) {
        throw RealmInvalidGenerationSourceError(
          'Primary key field is not final',
          todo: //
              'Add a final keyword to the field definition, '
              'or remove the @PrimaryKey annotation.',
          element: this,
        );
      }
      if (isFinal && !primaryKey) {}
      if ((primaryKey | indexed) &
          ![
            RealmPropertyType.string,
            RealmPropertyType.int,
            RealmPropertyType.bool,
          ].contains(type.realmType)) {
        final d = getDeclarationFromElement(this);
        final ast = d.node as AnnotatedNode;
        final annotation = ast.metadata.firstOrNull;

        var span = this.span!;
        if (annotation != null) {
          final start = annotation.offset;
          final end = start + annotation.length;
          final file = SourceFile.fromString(source!.contents.data);
          span.expand(file.span(start, end));
        }
        throw RealmInvalidGenerationSourceError(
          'Realm only support indexes on String, int, and bool fields',
          todo:
              'Change the type of the field, or remove the @Indexed annotation',
          element: this,
        );
      }

      final mapTo = mapToChecker.annotationsOfExact(this).singleOrNull;

      return RealmFieldInfo(
        fieldElement: this,
        indexed: indexed,
        primaryKey: primaryKey,
        mapTo: mapTo?.getField('name')?.toStringValue(),
      );
    } on RealmInvalidGenerationSourceError catch (_) {
      rethrow;
    } catch (e) {
      // Fallback. Not perfect, but better than just forwarding original error
      throw RealmInvalidGenerationSourceError(
        '$e',
        todo: 'Please open an issue on: https://github.com/realm/realm-dart',
        element: this,
      );
    }
  }
}

extension<T> on Iterable<T?> {
  Iterable<T> get whereNotNull => where((i) => i != null).cast<T>();
}

extension<T> on Iterable<T> {
  T? get firstOrNull =>
      cast<T?>().firstWhere((element) => true, orElse: () => null);
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
          throw RealmInvalidGenerationSourceError(
            'Primary key already defined',
            todo: 'Remove @PrimaryKey annotation from one or the other field',
            element: info.fieldElement,
            secondarySpans: {
              primaryKeySeen.fieldElement.span!: 'already defined here'
            },
          );
        }
      }
      yield info;
    }
  }
}

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await meassure(() async {
      return library.classes.realmInfo.expand((m) => m.toCode()).join('\n');
    }, tag: 'generate');
  }
}

class RealmInvalidGenerationSourceError extends InvalidGenerationSourceError {
  final Map<SourceSpan, String> secondarySpans;
  RealmInvalidGenerationSourceError(
    String message, {
    required String todo,
    required Element element,
    this.secondarySpans = const {},
  }) : super(message, todo: todo, element: element);

  @override
  String toString() => _formatMessage(
        message,
        element: element!,
        todo: todo,
        secondarySpans: secondarySpans,
      );
}

String _formatMessage(
  String message, {
  required Element element,
  required String todo,
  Map<SourceSpan, String> secondarySpans = const {},
}) {
  final buffer = StringBuffer(message);
  try {
    final span = element.span!;
    final formated = secondarySpans.isEmpty
        ? span.highlight()
        : span.highlightMultiple('', secondarySpans);
    buffer
      ..write('\n' * 2 + 'in: ')
      ..writeln(span.start.toolString)
      ..write(formated);
  } catch (e) {
    log.fine('WTF! $e');
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
