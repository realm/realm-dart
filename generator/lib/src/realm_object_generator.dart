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

  RealmCollectionType get collectionType {
    if (isDartCoreSet) return RealmCollectionType.set;
    if (isDartCoreList) return RealmCollectionType.list;
    // TODO: Check that key type is String!
    if (isDartCoreMap) return RealmCollectionType.map;
    return RealmCollectionType.none;
  }

  RealmPropertyType get realmType =>
      _realmType(true) ??
      (throw SourceSpanException(
          'Not a valid realm type: ${this}', element?.span));

  RealmPropertyType? _realmType(bool recurse) {
    if (collectionType != RealmCollectionType.none && recurse) {
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
            '${f.optional | f.defaultValue ? '' : 'required '}${f.typeName}${!f.optional & f.defaultValue ? '?' : ''} ${f.name},');
        yield '}) {';
        yield* fields.map((f) => f.defaultValue
            ? 'this.${f.name} = ${f.declaration.node.toString().replaceFirst('=', '??')};' // TODO: Feels a bit hacky!
            : 'this.${f.name} = ${f.name};');
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
    final prefix = realmModel.getField('prefix')?.toStringValue() ?? '_';
    final suffix = realmModel.getField('suffix')?.toStringValue() ?? '';

    final prototypeName = this.name;
    assert(prototypeName.startsWith(prefix)); // TODO: Better error handling
    assert(prototypeName.endsWith(suffix));

    final name = prototypeName.substring(
        prefix.length, prototypeName.length - suffix.length);

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
  final String name;
  final String realmName;
  final DartType type;
  final ElementDeclarationResult declaration;
  final bool primaryKey;
  final bool indexed;
  final bool optional;
  final bool defaultValue;

  RealmFieldInfo({
    required this.name,
    required this.type,
    required this.declaration,
    String? mapTo,
    this.primaryKey = false,
    this.indexed = false,
    this.optional = false,
    this.defaultValue = false,
  }) : realmName = mapTo ?? name;

  String get typeName => type.getDisplayString(withNullability: true);
  RealmPropertyType get realmType => type.realmType;
  RealmCollectionType get realmCollectionType => type.collectionType;

  Iterable<String> toCode() sync* {
    yield '@override';
    yield "$typeName get $name => RealmObject.get<$typeName>(this, '$realmName');";
    yield '@override';
    yield "set $name($typeName value) => RealmObject.set<$typeName>(this, '$realmName', value);";
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
  SourceSpan? get span => spanForElement(this);

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
    if (ignoredChecker.annotationsOfExact(this).isNotEmpty || isPrivate) {
      // skip ignored and private fields
      return null;
    }

    final indexed = indexedChecker.annotationsOfExact(this).isNotEmpty;
    final optional = type.isNullable;
    final primaryKey = primaryKeyChecker.annotationsOfExact(this).isNotEmpty;
    if (primaryKey & optional) {
      throw SourceSpanException('Primary key cannot be nullable', span);
    }
    if (primaryKey & indexed) {
      log.info('Indexed is implied for a primary key $display');
    }
    if (primaryKey ^ isFinal) {
      log.warning(
        'Primary keys and no other fields should be marked as final $display',
      );
    }
    if ((primaryKey | indexed) &
        ![
          RealmPropertyType.string,
          RealmPropertyType.int,
          RealmPropertyType.bool,
        ].contains(type.realmType)) {
      throw SourceSpanException(
        'Realm only support indexes on String, int, and bool fields',
        span,
      );
    }

    final mapTo = mapToChecker.annotationsOfExact(this).singleOrNull;

    return RealmFieldInfo(
      name: name,
      type: type,
      declaration: getDeclarationFromElement(this),
      indexed: indexed,
      primaryKey: primaryKey,
      optional: optional,
      mapTo: mapTo?.getField('name')?.toStringValue(),
      defaultValue: hasInitializer,
    );
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
  Iterable<RealmFieldInfo> get realmInfo =>
      map((f) => f.realmInfo).whereNotNull;
}

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await meassure(() async {
      return library.classes.realmInfo.expand((m) => m.toCode()).join('\n');
    }, tag: 'generate');
  }
}
