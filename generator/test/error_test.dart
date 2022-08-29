import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  const directory = 'test/error_test_data';
  getListOfTestFiles(directory).forEach((inputFile, outputFile) {
    executeTest(getTestName(inputFile), () async {
      await expectLater(
        () async => await generatorTestBuilder(directory, inputFile, expectError: true),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.format().trim(),
            'format()',
            myersDiff(
              (await File(path.join(directory, outputFile)).readFileAsErrorFormattedString()).trim(),
            ),
          ),
        ),
      );
    });
  });
}
