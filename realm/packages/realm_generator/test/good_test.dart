import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_util.dart';

void main() async {
  const directory = 'test/good_test_data';

  await for (final generatedFile in Directory(directory).list(recursive: true).where((f) => f.path.endsWith('.expected'))) {
    final sourceFile = File(generatedFile.path.replaceFirst('.expected', '.dart'));
    testCompile('compile $sourceFile', sourceFile, generatedFile);
  }

  testCompileMany(
    'Link to mapped class',
    [
      'another_mapto.dart',
      'mapto.dart',
    ].map<File>((n) => File(path.join(directory, n))),
    [
      'another_mapto.expected_multi',
      'mapto.expected',
    ].map<File>((n) => File(path.join(directory, n))),
  );
}
