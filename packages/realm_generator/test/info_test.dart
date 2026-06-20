import 'dart:io';

import 'package:term_glyph/term_glyph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() async {
  const directory = 'test/info_test_data';
  ascii = false; // force unicode glyphs

  await for (final infoFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected')).cast<File>()) {
    final sourceFile = File(infoFile.path.replaceFirst('.expected', '.dart'));
    final logMessages = <String>[];
    testCompile(
      'log from compile $sourceFile',
      sourceFile,
      completion(predicate((_) {
        // build_runner now wraps builder logs (prefixing them with
        // "Generating ... on <asset>:" and dropping the logger name), so match
        // the generator's info message as a substring rather than the old
        // "[INFO] testBuilder: ..." record format.
        final expected = infoFile.readAsStringSync().replaceFirst('[INFO] testBuilder: ', '').trim().normalizeLineEndings();
        return logMessages.any((m) => m.normalizeLineEndings().contains(expected));
      }, 'logs the expected info message')),
      // Builder info-level logs are only forwarded to `onLog` in verbose mode.
      verbose: true,
      onLog: (record) => logMessages.add(record.message),
    );
  }
}
