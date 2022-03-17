
import 'test_util.dart';

void main() {
  final tests = {
    'required argument with default value',
    'required argument',
    'list initialization',
    'optional argument',
    'user defined getter',
  };

  for (var testData in tests) {
    var fileName = testData.replaceAll(' ', '_');

    generatorTest(testData, () async {
      await generatorTestBuilder('good_test_io', '$fileName.dart', '$fileName.expected');
    });
  }
}
