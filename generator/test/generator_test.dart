import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';

void main() {
  final folderName = 'generator_test_io';

  test('pinhole', () async {
    await ioTestBuilder(folderName, 'pinhole.dart', 'pinhole.g.dart');
  });

  test('all types', () async {
    await ioTestBuilder(folderName, 'all_types.dart');
  });

  test('not a realm type', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'not_a_realm_type.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'not_a_realm_type.log'),
        ),
      ),
    );
  });

  test('not an indexable type', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'not_an_indexable_type.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'not_an_indexable_type.log'),
        ),
      ),
    );
  });

  test('primary key cannot be nullable', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'primary_key_not_be_nullable.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'primary_key_not_be_nullable.log'),
        ),
      ),
    );
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
      await readFileAsErrorFormattedString(folderName, 'primary_key_always_indexed.log'),
    );
  });

  test('list of list not supported', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'list_of_list_not_supported.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'list_of_list_not_supported.log'),
        ),
      ),
    );
  });

  test('missing underscore', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'missing_underscore.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'missing_underscore.log'),
        ),
      ),
    );
  });

  test('double primary key', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'double_primary_key.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'double_primary_key.log'),
        ),
      ),
    );
  });

  test('invalid model name prefix', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'invalid_model_name_prefix.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'invalid_model_name_prefix.log'),
        ),
      ),
    );
  });

  test('invalid model name mapping', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'invalid_model_name_mapping.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'invalid_model_name_mapping.log'),
        ),
      ),
    );
  });

  test('repeated class annotations', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'repeated_class_annotations.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'repeated_class_annotations.log'),
        ),
      ),
    );
  });

  test('repeated field annotations', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'repeated_field_annotations.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'repeated_field_annotations.log'),
        ),
      ),
    );
  });

  test('invalid extend', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'invalid_extend.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'invalid_extend.log'),
        ),
      ),
    );
  });

  test('illigal constructor', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'illigal_constructor.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'illigal_constructor.log'),
        ),
      ),
    );
  });

  test('nullable list', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'nullable_list.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'nullable_list.log'),
        ),
      ),
    );
  });

  test('nullable list elements', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'nullable_list_elements.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'nullable_list_elements.log'),
        ),
      ),
    );
  });

  test('non-nullable realm object reference', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'non_nullable_ro_reference.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'non_nullable_ro_reference.log'),
        ),
      ),
    );
  });

  test('defining both _Bad and \$Bad', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'defining_both_class_prefixes.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'defining_both_class_prefixes.log'),
        ),
      ),
    );
  });

  test('reusing mapTo name', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'reusing_mapto_name.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'reusing_mapto_name.log'),
        ),
      ),
    );
  });

  test('bool not allowed on indexed field', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'bool_not_for_indexed_field.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'bool_not_for_indexed_field.log'),
        ),
      ),
    );
  });

  test('bool not allowed as primary key', () async {
    await expectLater(
      () async => await ioTestErrorBuilder(folderName, 'bool_not_for_primary_key.dart'),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          await readFileAsErrorFormattedString(folderName, 'bool_not_for_primary_key.log'),
        ),
      ),
    );
  });
  test('old bool not allowed as primary key', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
@MapTo('Bad')
class _Foo {
  @PrimaryKey()
  late bool bad;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Realm only support indexes on String, int, and bool fields\n'
            '\n'
            'in: package:pkg/src/test.dart:9:8\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '6 │ @MapTo(\'Bad\')\n'
            '7 │ class _Foo {\n'
            '  │       ━━━━ in realm model for \'Bad\'\n'
            '8 │   @PrimaryKey()\n'
            '9 │   late bool bad;\n'
            '  │        ^^^^ bool is not an indexable type\n'
            '  ╵\n'
            'Change the type of \'bad\', or remove the @PrimaryKey() annotation\n'
            '',
      )),
    );
  });

  test('set unsupported', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  late Set<_Person> children;
}''',
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Field type not supported yet\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '6 │ class _Person {\n'
            '  │       ━━━━━━━ in realm model for \'Person\'\n'
            '7 │   late Set<_Person> children;\n'
            '  │        ^^^^^^^^^^^^ not yet supported\n'
            '  ╵\n'
            'Avoid using Set<_Person> for now\n'
            '',
      )),
    );
  });

  test('map unsupported', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  late Map<String, _Person> relatives;
}''',
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Field type not supported yet\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '6 │ class _Person {\n'
            '  │       ━━━━━━━ in realm model for \'Person\'\n'
            '7 │   late Map<String, _Person> relatives;\n'
            '  │        ^^^^^^^^^^^^^^^^^^^^ not yet supported\n'
            '  ╵\n'
            'Avoid using Map<String, _Person> for now\n'
            '',
      )),
    );
  });
}
