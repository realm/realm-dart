import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  const directory = 'test/info_test_data';
  getListOfTestFiles(directory).forEach((inputFile, outputFile) {
    executeTest(getTestName(inputFile), () async {
      final sb = StringBuffer();
      var done = false;

      await testBuilder(
        generateRealmObjects(),
        await getInputFileAsset('$directory/$inputFile'),
        reader: await PackageAssetReader.currentIsolate(),
        onLog: (l) {
          if (!done) {
            // disregard all, but first record
            sb.writeln(l);
            done = true;
          }
        },
      );

      expect(
        sb.toString(),
        await readFileAsErrorFormattedString(directory, outputFile),
      );
    });
  });
}
