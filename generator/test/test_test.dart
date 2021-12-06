import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:realm_generator/src/realm_object_generator.dart';
import 'package:test/test.dart';

void main() {
  test(
    'pinhole',
    () async {
      await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Foo {
  int x = 0;
}''',
        },
        outputs: {
          'pkg|lib/src/test.RealmObjects.g.part':
              '// **************************************************************************\n'
                  '// RealmObjectGenerator\n'
                  '// **************************************************************************\n'
                  '\n'
                  'class Foo extends _Foo with RealmObject {\n'
                  '  Foo({\n'
                  '    int? x,\n'
                  '  }) {\n'
                  '    this.x = x ?? 0;\n'
                  '  }\n'
                  '\n'
                  '  @override\n'
                  '  int get x => RealmObject.get<int>(this, \'x\');\n'
                  '  @override\n'
                  '  set x(int value) => RealmObject.set(this, \'x\', value);\n'
                  '\n'
                  '  static const schema = SchemaObject(Foo, [\n'
                  "    SchemaProperty('x', RealmPropertyType.int),\n"
                  '  ]);\n'
                  '}\n',
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    },
  );

  test('all types', () async {
    await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'dart:typed_data';

import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Foo {
  int x = 0;
} 

@RealmModel()
class _Bar {
  @PrimaryKey()
  late final String id;
  late bool aBool;
  var data = Uint8List(16);
  late RealmAny any;
  @MapTo('tidspunkt')
  var timestamp = DateTime.now();
  var aDouble = 0.0;
  late Decimal128 decimal;
  late _Foo foo;
  late ObjectId id;
  late Uuid uuid;
  @Ignored()
  var theMeaningOfEverything = 42;
  var list = [0]; // list of ints with default value
  Set<int> set;
  var map = <String, int>{};

  @Indexed()
  String? anOptionalString;
}'''
        },
        reader: await PackageAssetReader.currentIsolate());
  });

  test('not a realm type', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

class NonRealm {}

@RealmModel()
class _Bad {
  late NonRealm notARealmType;
}'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Not a valid realm type: NonRealm\n'
              '\n'
              'in: package:pkg/src/test.dart:9:17\n'
              '    ╷\n'
              '5   │ class NonRealm {}\n'
              '    │       ━━━━━━━━ defined here\n'
              '... │\n'
              '9   │   late NonRealm notARealmType;\n'
              '    │                 ^^^^^^^^^^^^^ \n'
              '    ╵\n'
              'Add a @RealmModel annotation on the type definition, or an @Ignored annotation on the field using it.\n',
        ),
      ),
    );
  });

  test(
    'not an indexable type',
    () async {
      await expectLater(
        () async => await testBuilder(
          generateRealmObjects(),
          {
            'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  @Indexed()
  Uuid notAnIndexableType;
}'''
          },
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'toString()',
            'Realm only support indexes on String, int, and bool fields\n'
                '\n'
                'in: package:pkg/src/test.dart:8:8\n'
                '  ╷\n'
                '8 │   Uuid notAnIndexableType;\n'
                '  │        ^^^^^^^^^^^^^^^^^^\n'
                '  ╵\n'
                'Change the type of the field, or remove the @Indexed annotation\n',
          ),
        ),
      );
    },
  );

  test(
    'primary key cannot be nullable',
    () async {
      await expectLater(
        () async => await testBuilder(
            generateRealmObjects(),
            {
              'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  int? nullableKeyNotAllowed;
}'''
            },
            reader: await PackageAssetReader.currentIsolate()),
        throwsA(
          isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'toString()',
            'Primary key cannot be nullable\n'
                '\n'
                'in: package:pkg/src/test.dart:8:8\n'
                '  ╷\n'
                '8 │   int? nullableKeyNotAllowed;\n'
                '  │        ^^^^^^^^^^^^^^^^^^^^^\n'
                '  ╵\n'
                'Consider using the @Indexed annotation instead, or make the field non-nullable.\n',
          ),
        ),
      );
    },
  );

  test('primary key not final', () async {
    await expectLater(
      () async => await testBuilder(
          generateRealmObjects(),
          {
            'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int primartKeyIsNotFinal;
}'''
          },
          reader: await PackageAssetReader.currentIsolate()),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Primary key field is not final\n'
              '\n'
              'in: package:pkg/src/test.dart:8:12\n'
              '  ╷\n'
              '8 │   late int primartKeyIsNotFinal;\n'
              '  │            ^^^^^^^^^^^^^^^^^^^^\n'
              '  ╵\n'
              'Add a final keyword to the field definition, or remove the @PrimaryKey annotation.\n',
        ),
      ),
    );
  });

  test(
    'primary keys always indexed',
    () async {
      final sb = StringBuffer();
      var done = false;
      await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Questionable {
  @PrimaryKey()
  @Indexed()
  late final int primartKeysAreAlwaysIndexed;
}'''
        },
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
        '[INFO] testBuilder: Indexed is implied for a primary key\n'
        '\n'
        'in: package:pkg/src/test.dart:9:18\n'
        '  ╷\n'
        '9 │   late final int primartKeysAreAlwaysIndexed;\n'
        '  │                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^\n'
        '  ╵\n'
        'Remove either the @Indexed or @PrimaryKey annotation.\n'
        '\n',
      );
    },
  );

  test('list of list not supported', () async {
    await expectLater(
      () async => await testBuilder(
          generateRealmObjects(),
          {
            'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  late int x;
  var listOfLists = [[0], [1]];
}

'''
          },
          reader: await PackageAssetReader.currentIsolate()),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'toString()',
            'Not a valid realm type: List<List<int>>\n'
                '\n'
                'in: package:pkg/src/test.dart:8:7\n'
                '  ╷\n'
                '8 │   var listOfLists = [[0], [1]];\n'
                '  │       ^^^^^^^^^^^\n'
                '  ╵\n'
                'Add an @Ignored annotation.\n'),
      ),
    );
  });

  test('missing underscore', () async {
    await expectLater(
      () async => await testBuilder(
          generateRealmObjects(),
          {
            'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  late Other other;
}

@RealmModel()
class _Other {}

'''
          },
          reader: await PackageAssetReader.currentIsolate()),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Not a valid realm type\n'
              '\n'
              'in: package:pkg/src/test.dart:7:14\n'
              '  ╷\n'
              '7 │   late Other other;\n'
              '  │              ^^^^^\n'
              '  ╵\n'
              'Add an @Ignored annotation.\n')),
    );
  });
}
