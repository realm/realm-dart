import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  const directory = 'test/error_test_data';
  getListOfTestFiles(directory).forEach((inputFile, outputFile) {
    executeTest(getTestName(inputFile), () async {
      final expectedContent = await readFileAsErrorFormattedString(directory, outputFile);
      expectLater(
        generatorTestBuilder(directory, inputFile),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.format(),
            '',
            LinesEqualsMatcher(expectedContent),
          ),
        ),
      );
    });
  });
}
