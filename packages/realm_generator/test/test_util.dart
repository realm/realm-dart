import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'package:pub_semver/pub_semver.dart';

final _formatter = DartFormatter(
  languageVersion: Version(3, 7, 0),
  lineEnding: '\n',
);

/// Used to test both correct an erroneous compilation.
/// [source] can be a [File] or a [String].
/// [matcher] can be a [File], [String] or a [Matcher].
/// Both expected and actual output will be formatted with [DartFormatter].
@isTest
void testCompile(
  String description,
  dynamic source,
  dynamic matcher, {
  dynamic skip,
  void Function(LogRecord)? onLog,
  bool verbose = false,
}) {
  if (source is Iterable) {
    testCompileMany(description, source, matcher);
    return;
  }

  final assetName = source is File ? source.path : 'source.dart';
  source = source is File ? source.readAsStringSync() : source;
  if (source is! String) throw ArgumentError.value(source, 'source');

  matcher = matcher is File ? matcher.readAsStringSync() : matcher;
  if (matcher is String) {
    final source = _formatter.format(matcher);
    matcher = completion(equals(source));
  }
  if (matcher is! Matcher) throw ArgumentError.value(matcher, 'matcher');

  test(description, () async {
    final readerWriter = TestReaderWriter(
      rootPackage: 'realm_generator',
    );

    await readerWriter.testing.loadIsolateSources();

    generate() async {
      final result = await testBuilder(
        generateRealmObjects(),
        {'realm_generator|$assetName': '$source'},
        readerWriter: readerWriter,
        onLog: onLog,
        verbose: verbose,
      );

      if (!result.succeeded) {
        return result.errors.first.trim().normalizeLineEndings();
      }

      // The “logical” AssetId of the generated file
      final logicalId = AssetId.parse('realm_generator|$assetName')
          .changeExtension('.realm.dart');

      // Convert to “physical” AssetId in .dart_tool/build/generated
      final generatedId = AssetId(
        logicalId.package,
        '.dart_tool/build/generated/${logicalId.package}/${logicalId.path}',
      );

      final bytes = readerWriter.testing.readBytes(generatedId);

      return _formatter.format(utf8.decode(bytes));
    }

    expect(generate(), matcher);
  }, skip: skip);
}

@isTest
void testCompileMany(
  String description,
  Iterable<dynamic> sources,
  dynamic matcher,
) async {
  final inputs = switch (sources) {
    Iterable<File> files => files.map((file) {
        return ('realm_generator|${file.path}', _formatter.format(file.readAsStringSync()));
      }),
    Iterable<String> strings => strings.indexed.map((x) {
        final (index, text) = x;
        return ('realm_generator|source_$index.dart', _formatter.format(text));
      }),
    _ => throw ArgumentError.value(sources, 'sources'),
  };

  matcher = switch (matcher) {
    Matcher m => m,
    Iterable<String> strings => completion(
        equals(strings.map((e) => _formatter.format(e))),
      ),
    Iterable<File> files => completion(
        equals(files.map((x) => _formatter.format(x.readAsStringSync()))),
      ),
    _ => throw ArgumentError.value(matcher, 'matcher'),
  };

  test(description, () async {
    final readerWriter = TestReaderWriter(
      rootPackage: 'realm_generator',
    );

    await readerWriter.testing.loadIsolateSources();

    generate() async {
      final inputList = inputs.toList();
      await testBuilder(
        generateRealmObjects(),
        Map<String, Object>.fromEntries(
          inputList.map((x) {
            final (id, source) = x;
            return MapEntry(id, source);
          }),
        ),
        readerWriter: readerWriter,
      );
      final formattedOutputs = <String>[];
      for (final (id, _) in inputList) {
        // Generated outputs are written "hidden" under the build cache, so map
        // each input's logical `.realm.dart` id to its physical location.
        final logicalId = AssetId.parse(id).changeExtension('.realm.dart');
        final generatedId = AssetId(
          logicalId.package,
          '.dart_tool/build/generated/${logicalId.package}/${logicalId.path}',
        );
        if (!readerWriter.testing.exists(generatedId)) continue;
        final bytes = readerWriter.testing.readBytes(generatedId);
        formattedOutputs.add(_formatter.format(utf8.decode(bytes)));
      }
      return formattedOutputs;
    }

    expect(generate(), matcher);
  });
}

final _endOfLine = RegExp(r'\r\n?|\n');

extension StringX on String {
  String normalizeLineEndings() => replaceAll(_endOfLine, '\n');
}
