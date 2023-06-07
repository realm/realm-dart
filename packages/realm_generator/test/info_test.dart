import 'dart:io';

import 'package:test/test.dart';

import 'test_util.dart';

void main() async {
  const directory = 'test/info_test_data';

  await for (final infoFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected')).cast<File>()) {
    final sb = StringBuffer();
    var done = false;

    final sourceFile = File(infoFile.path.replaceFirst('.expected', '.dart'));
    testCompile(
      'compile $sourceFile',
      sourceFile,
      completes,
      onLog: (l) {
        // we want to ignore the logs from other loggers (such as build_resolvers)
        if (!done && l.loggerName == 'testBuilder') {
          // disregard all, but first record
          sb.writeln(l);
          done = true;
        }
      },
    );

    test('log from compile $sourceFile', () {
      expect(
        sb.toString().trim(),
        infoFile.readAsStringSync().trim(),
      );
    });
  }
}
