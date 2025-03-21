import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:ejson_generator/ejson_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

final _formatter = DartFormatter(
  languageVersion: Version(3, 7, 0),
  lineEnding: '\n',
);
final _tag = RegExp(r'// \*.*\n// EJsonGenerator\n// \*.*');

@isTest
void testCompile(String description, dynamic source, dynamic matcher, {dynamic skip}) {
  source = source is File ? source.readAsStringSync() : source;
  if (source is! String) throw ArgumentError.value(source, 'source');

  matcher = matcher is File ? matcher.readAsStringSync() : matcher;
  if (matcher is String) {
    final source = _formatter.format(matcher);
    matcher = completion(equals(source.substring(_tag.firstMatch(source)?.start ?? 0)));
  }
  matcher ??= completes; // fallback

  if (matcher is! Matcher) throw ArgumentError.value(matcher, 'matcher');

  test(description, () {
    generate() async {
      final writer = InMemoryAssetWriter();
      await testBuilder(
        getEJsonGenerator(),
        {'pkg|source.dart': source as Object},
        writer: writer,
        reader: await PackageAssetReader.currentIsolate(),
      );
      return _formatter.format(String.fromCharCodes(writer.assets.entries.single.value));
    }

    expect(generate(), matcher);
  }, skip: skip);
}

Future<void> main() async {
  group('user errors', () {
    testCompile(
      'two annotated ctors',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

class TwoAnnotatedCtors {
  final int i;
  @ejson
  TwoAnnotatedCtors(this.i);
  @ejson
  TwoAnnotatedCtors.named(this.i);
}
''',
      throwsA(isA<InvalidGenerationSourceError>().having(
        (e) => e.message,
        'message',
        'Too many annotated constructors',
      )),
    );
    testCompile(
      'missing getter',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

class MissingGetter {
  final int _i; // missing a getter for _i called i
  @ejson
  MissingGetter(int i) : _i = i;
}
''',
      throwsA(isA<InvalidGenerationSourceError>()),
    );

    testCompile(
      'mismatching getter',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

class MismatchingGetter {
  final int _i;
  String get i => _i.toString(); // getter is not of type int
  @ejson
  MismatchingGetter(int i) : _i = i;
}
''',
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  group('good', () {
    testCompile(
      'private field',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

class PrivateFieldIsOkay {
  final int _i; // private fields are okay
  @ejson
  PrivateFieldIsOkay(this._i);
}
''',
      completes,
    );

    testCompile(
      'mismatching getter but custom encoder',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

EJsonValue _encode(MismatchingGetterButCustomEncoder value) => {'i': value._i};

class MismatchingGetterButCustomEncoder {
  final int _i;
  String get i => _i.toString(); // getter is not of type int
  @EJson(encoder: _encode)
  MismatchingGetterButCustomEncoder(int i) : _i = i;
}
''',
      completes,
      skip: "don't work yet",
    );

    testCompile(
      'empty class',
      r'''
import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

class Empty {
  @ejson
  const Empty();
}
''',
      '''
// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue _encodeEmpty(Empty value) {
  return {};
}

Empty _decodeEmpty(EJsonValue ejson) {
  return switch (ejson) {
    Map m when m.isEmpty => Empty(),
    _ => raiseInvalidEJson(ejson),
  };
}

extension EmptyEJsonEncoderExtension on Empty {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeEmpty(this);
}

void registerEmpty() => register(_encodeEmpty, _decodeEmpty);
''',
    );
  });

  await for (final generatedFile in Directory.current.list(recursive: true).where((f) => f is File && f.path.endsWith('.g.dart'))) {
    final sourceFile = File(generatedFile.path.replaceFirst('.g.dart', '.dart'));
    testCompile('$sourceFile', sourceFile, generatedFile);
  }
}
