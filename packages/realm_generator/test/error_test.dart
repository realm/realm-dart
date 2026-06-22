import 'dart:io';

import 'package:test/test.dart';
import 'package:term_glyph/term_glyph.dart';
import 'test_util.dart';

void main() async {
  const directory = 'test/error_test_data';
  ascii = false; // force unicode glyphs

  await for (final errorFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected')).cast<File>()) {
    final sourceFile = File(errorFile.path.replaceFirst('.expected', '.dart'));
    testCompile(
      'compile $sourceFile',
      sourceFile,
      completion(equals((await errorFile.readAsString()).trim().normalizeLineEndings())),
    );
  }
}
