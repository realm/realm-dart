import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';

final _formatter = DartFormatter(lineEnding: '\n');

// TODO: add meta package to pubspec.yaml
//@isTest
void testCompile(String description, dynamic source, dynamic matcher, {dynamic skip, void Function(LogRecord)? onLog}) {
  final assetName = source is File ? source.path : 'source.dart';
  source = source is File ? source.readAsStringSync() : source;
  if (source is! String) throw ArgumentError.value(source, 'source');

  matcher = matcher is File ? matcher.readAsStringSync() : matcher;
  if (matcher is String) {
    final source = _formatter.format(matcher);
    matcher = completion(equals(source));
  }
  matcher ??= completes; // fallback

  if (matcher is! Matcher) throw ArgumentError.value(matcher, 'matcher');

  test(description, () async {
    generate() async {
      final writer = InMemoryAssetWriter();
      await testBuilder(
        generateRealmObjects(),
        {'pkg|$assetName': '$source'},
        writer: writer,
        reader: await PackageAssetReader.currentIsolate(),
        onLog: onLog,
      );
      return _formatter.format(String.fromCharCodes(writer.assets.entries.single.value));
    }

    await expectLater(generate(), matcher);
  }, skip: skip);
}

final _endOfLine = RegExp(r'\r\n?|\n');

extension StringX on String {
  String normalizeLineEndings() => replaceAll(_endOfLine, '\n');
}
