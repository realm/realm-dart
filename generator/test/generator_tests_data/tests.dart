import 'package:test/test.dart';
import '../test_util.dart';

void main() {
  final folderName = 'generator_tests_data';

  test('pinhole', () async {
    await ioTtestBuilder(folderName, 'pinhole');
  });
}
