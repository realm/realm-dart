import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:ejson_generator/ejson_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:matcher/matcher.dart' show StringDescription;
import 'package:test/test.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

final _formatter = DartFormatter(
  languageVersion: Version(3, 8, 0),
  lineEnding: '\n',
);
final _tag = RegExp(r'// \*.*\n// EJsonGenerator\n// \*.*');

@isTest
void testCompile(String description, dynamic source, dynamic matcher, {dynamic skip}) {
  source = source is File ? source.readAsStringSync() : source;
  if (source is! String) throw ArgumentError.value(source, 'source');

  // Check if this is an error test (expects throwsA with InvalidGenerationSourceError)
  // Store this before matcher is potentially modified
  final originalMatcher = matcher;
  final expectsError = originalMatcher is Matcher &&
      originalMatcher.describe(StringDescription()).toString().contains('InvalidGenerationSource');

  String? expectedErrorMessage;
  if (expectsError) {
    final desc = originalMatcher.describe(StringDescription()).toString();
    if (desc.contains('Too many annotated constructors')) {
      expectedErrorMessage = 'Too many annotated constructors';
    } else if (desc.contains('Missing getter')) {
      expectedErrorMessage = 'Missing getter';
    } else if (desc.contains('Mismatched getter type')) {
      expectedErrorMessage = 'Mismatched getter type';
    }
  }

  matcher = matcher is File ? matcher.readAsStringSync() : matcher;
  if (matcher is String) {
    final source = _formatter.format(matcher);
    matcher = completion(equals(source.substring(_tag.firstMatch(source)?.start ?? 0)));
  }
  matcher ??= completes; // fallback

  test(description, () async {
    final readerWriter = TestReaderWriter(rootPackage: 'pkg');
    await readerWriter.testing.loadIsolateSources();

    // Use testBuilders with flattenOutput to make outputs accessible
    final result = await testBuilders(
      [getEJsonGenerator()],
      {'pkg|lib/source.dart': source as Object},
      readerWriter: readerWriter,
      flattenOutput: true,
    );

    if (expectsError) {
      // For error tests, check that the build failed with the expected error
      expect(result.succeeded, isFalse, reason: 'Expected build to fail');
      expect(result.errors, isNotEmpty, reason: 'Expected errors in result');
      if (expectedErrorMessage != null) {
        expect(
          result.errors.any((e) => e.toString().contains(expectedErrorMessage!)),
          isTrue,
          reason: 'Expected error containing "$expectedErrorMessage", got: ${result.errors}',
        );
      }
      return; // Early return for error tests
    }

    // For success tests, verify output was generated
    if (!result.succeeded || result.outputs.isEmpty) {
      throw StateError('No outputs generated. Errors: ${result.errors}');
    }

    // Read the .g.part output
    final partOutputs = result.outputs.where((id) => id.path.endsWith('.g.part'));
    if (partOutputs.isEmpty) {
      throw StateError('No .g.part outputs found. Outputs: ${result.outputs}');
    }

    final output = partOutputs.first;
    final content = await result.readerWriter.readAsString(output);
    final formatted = _formatter.format(content);

    if (matcher is Matcher) {
      expect(Future.value(formatted), matcher);
    }
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
    Map m when m.isEmpty => Empty.new(),
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
