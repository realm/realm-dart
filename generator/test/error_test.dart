import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  const directory = 'test/error_test_data';
  getListOfTestFiles(directory).forEach((inputFile, outputFile) {
    executeTest(getTestName(inputFile), () async {
      expectLater(
        generatorTestBuilder(directory, inputFile),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.format(),
            'format()',
            await readFileAsErrorFormattedString(directory, outputFile),
          ),
        ),
      );
    });
  });
}
