import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  
  final folderName = 'generator_test_io';
  final tests = {
    'not a realm type',
    'not an indexable type',
    'primary key cannot be nullable',
    'list of list not supported',
    'missing underscore',
    'double primary key',
    'invalid model name prefix',
    'invalid model name mapping',
    'repeated class annotations',
    'repeated field annotations',
    'invalid extend',
    'illigal constructor',
    'nullable list',
    'nullable list elements',
    'non nullable realm object reference',
    'defining both class prefixes',
    'reusing map_to name',
    'bool not allowed on indexed field',
    'bool not allowed as primary key',
    'set unsupported',
    'map unsupported',
  };

  for (var testData in tests) {
    var fileName = testData.replaceAll(' ', '_');

    generatorTest(testData, () async {
      await expectLater(
        () async => await generatorTestBuilder(folderName, '$fileName.dart'),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.format(),
            'format()',
            await readFileAsErrorFormattedString(folderName, '$fileName.expected'),
          ),
        ),
      );
    });
  }

  test('pinhole', () async {
    await generatorTestBuilder(folderName, 'pinhole.dart', 'pinhole.expected');
  });

  test('all types', () async {
    await generatorTestBuilder(folderName, 'all_types.dart');
  });

  test('primary keys always indexed', () async {
    final sb = StringBuffer();
    var done = false;

    await testBuilder(
      generateRealmObjects(),
      await getInputFileAsset('test/$folderName/primary_key_always_indexed.dart'),
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
      await readFileAsErrorFormattedString(folderName, 'primary_key_always_indexed.expected'),
    );
  });
}
