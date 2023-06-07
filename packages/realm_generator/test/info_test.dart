import 'dart:async';
import 'dart:io';

import 'package:term_glyph/term_glyph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() async {
  const directory = 'test/info_test_data';
  ascii = false; // force unicode glyphs

  await for (final infoFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected')).cast<File>()) {
    final log = Completer<String>();
    final sourceFile = File(infoFile.path.replaceFirst('.expected', '.dart'));

    testCompile(
      'compile $sourceFile',
      sourceFile,
      completes,
      onLog: (record) {
        if (!log.isCompleted && record.loggerName == 'testBuilder') {
          log.complete('$record'.normalizeLineEndings());
        }
      },
    );

    test('log from compile $sourceFile', () {
      expect(log.future, completion(infoFile.readAsStringSync().normalizeLineEndings()));
    });
  }
}
