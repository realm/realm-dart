import 'dart:async';
import 'dart:io';

import 'package:term_glyph/term_glyph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() async {
  const directory = 'test/info_test_data';
  ascii = false; // force unicode glyphs

  await for (final infoFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected')).cast<File>()) {
    final sourceFile = File(infoFile.path.replaceFirst('.expected', '.dart'));
    String? firstLog;
    testCompile(
      'log from compile $sourceFile',
      sourceFile,
      completion(predicate((_) {
        return firstLog?.normalizeLineEndings() == infoFile.readAsStringSync().normalizeLineEndings();
      })),
      onLog: (record) {
        if (firstLog == null && record.loggerName == 'testBuilder') {
          firstLog = '$record';
        }
      },
    );
  }
}
