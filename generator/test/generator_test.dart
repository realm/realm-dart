import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:realm_generator/src/realm_object_generator.dart';
import 'package:test/test.dart';

void main() {
  test('pinhole', () async {
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
                "  int get x => RealmObject.get<int>(this, 'x');\n"
                '  @override\n'
                "  set x(int value) => RealmObject.set(this, 'x', value);\n"
                '\n'
                '  static const schema = SchemaObject(Foo, [\n'
                "    SchemaProperty('x', RealmPropertyType.int),\n"
                '  ]);\n'
                '}\n',
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });

  test('all types', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'dart:typed_data';

import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
@MapTo('Fooo')
class _Foo {
  int x = 0;
} 

@RealmModel()
class _Bar {
  @PrimaryKey()
  late final String id;
  late bool aBool, another;
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
      reader: await PackageAssetReader.currentIsolate(),
    );
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
          'Not a realm type\n'
              '\n'
              'in: package:pkg/src/test.dart:9:8\n'
              '    ╷\n'
              '5   │   class NonRealm {}\n'
              '    │         ━━━━━━━━ \n'
              '... │\n'
              '7   │ ┌ @RealmModel()\n'
              '8   │ │ class _Bad {\n'
              '    │ └─── in realm model \'_Bad\'\n'
              '9   │     late NonRealm notARealmType;\n'
              '    │          ^^^^^^^^ NonRealm is not a realm type\n'
              '    ╵\n'
              'Add a @RealmModel annotation on \'NonRealm\', or an @Ignored annotation on \'notARealmType\'.\n',
        ),
      ),
    );
  });

  test('not an indexable type', () async {
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
              'in: package:pkg/src/test.dart:8:3\n'
              '  ╷\n'
              '5 │ ┌ @RealmModel()\n'
              '6 │ │ class _Bad {\n'
              '  │ └─── in realm model \'_Bad\'\n'
              '7 │     @Indexed()\n'
              '  │     ━━━━━━━━━━ index is requested on \'notAnIndexableType\', but\n'
              '8 │     Uuid notAnIndexableType;\n'
              '  │     ^^^^ Uuid is not an indexable type\n'
              '  ╵\n'
              'Change the type of \'notAnIndexableType\', or remove the @Indexed() annotation\n',
        ),
      ),
    );
  });

  test('primary key cannot be nullable', () async {
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
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Primary key cannot be nullable\n'
              '\n'
              'in: package:pkg/src/test.dart:8:3\n'
              '  ╷\n'
              '5 │ ┌ @RealmModel()\n'
              '6 │ │ class _Bad {\n'
              '  │ └─── in realm model \'_Bad\'\n'
              '7 │     @PrimaryKey()\n'
              '  │     ━━━━━━━━━━━━━ the primary key \'nullableKeyNotAllowed\' is\n'
              '8 │     int? nullableKeyNotAllowed;\n'
              '  │     ^^^^ nullable\n'
              '  ╵\n'
              'Consider using the @Indexed() annotation instead, or make \'nullableKeyNotAllowed\' an int.\n',
        ),
      ),
    );
  });

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
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Primary key field is not final\n'
              '\n'
              'in: package:pkg/src/test.dart:7:3\n'
              '  ╷\n'
              '7 │ ┌   @PrimaryKey()\n'
              '8 │ └   late int primartKeyIsNotFinal;\n'
              '  ╵\n'
              'Add a final keyword to the definition of \'primartKeyIsNotFinal\', or remove the @PrimaryKey annotation.\n',
        ),
      ),
    );
  });

  test('primary keys always indexed', () async {
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
      'in: package:pkg/src/test.dart:7:3\n'
      '  ╷\n'
      '7 │ ┌   @PrimaryKey()\n'
      '8 │ │   @Indexed()\n'
      '9 │ └   late final int primartKeysAreAlwaysIndexed;\n'
      '  ╵\n'
      'Remove either the @Indexed or @PrimaryKey annotation from \'primartKeysAreAlwaysIndexed\'.\n'
      '\n',
    );
  });

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
              reader: await PackageAssetReader.currentIsolate(),
            ),
        throwsA(isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.toString(),
          'toString()',
          'Not a realm type\n'
              '\n'
              'in: package:pkg/src/test.dart:8:21\n'
              '    ╷\n'
              '5   │ ┌ @RealmModel()\n'
              '6   │ │ class _Bad {\n'
              '    │ └─── in realm model \'_Bad\'\n'
              '... │\n'
              '8   │     var listOfLists = [[0], [1]];\n'
              '    │                       ^^^^^^^^^^ List<List<int>> is not a realm type\n'
              '    ╵\n'
              'Add an @Ignored annotation on \'listOfLists\'.\n',
        )));
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
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Not a realm type\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '  ╷\n'
            '5 │ ┌ @RealmModel()\n'
            '6 │ │ class _Bad {\n'
            '  │ └─── in realm model \'_Bad\'\n'
            '7 │     late Other other;\n'
            '  │          ^^^^^ Other is not a realm type\n'
            '  ╵\n'
            'Did you intend to use _Other as type for \'other\'?\n',
      )),
    );
  });

  test('double primary key', () async {
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
  late final int first;

  @MapTo('third')
  @PrimaryKey()
  late final String second; // just a thought..
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Primary key already defined\n'
            '\n'
            'in: package:pkg/src/test.dart:11:3\n'
            '    ╷\n'
            '5   │ ┌ @RealmModel()\n'
            '6   │ │ class _Bad {\n'
            '    │ └─── in realm model \'_Bad\'\n'
            '7   │     @PrimaryKey()\n'
            '    │     ━━━━━━━━━━━━━ the @PrimaryKey() annotation is used\n'
            '8   │     late final int first;\n'
            '    │                    ━━━━━ on both \'first\', and\n'
            '... │\n'
            '11  │     @PrimaryKey()\n'
            '    │     ^^^^^^^^^^^^^ again\n'
            '12  │     late final String second; // just a thought..\n'
            '    │                       ━━━━━━ on \'second\'\n'
            '    ╵\n'
            'Remove @PrimaryKey() annotation from either \'second\' or \'first\'\n',
      )),
    );
  });

  test('invalid model name prefix', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
class Bad { // missing _ or $ prefix
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Missing prefix on realm model name\n'
            '\n'
            'in: package:pkg/src/test.dart:6:7\n'
            '  ╷\n'
            '5 │ ┌ @RealmModel()\n'
            '6 │ │ class Bad { // missing _ or \$ prefix\n'
            '  │ │       ^^^ missing prefix\n'
            '  │ └─── on realm model \'Bad\'\n'
            '  ╵\n'
            'Either add a @MapTo annotation, or align class name to match prefix [_\$] (regular expression)\n',
      )),
    );
  });

  test('invalid model name mapping', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

const one = '1';
@RealmModel()
@MapTo(one) // <- invalid
// prefix is not important, as we explicitly define name with @MapTo, 
// but obviously 1 is not a valid class name
class Bad {}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Invalid class name\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '   ╷\n'
            '6  │ ┌ @RealmModel()\n'
            '7  │ │ @MapTo(one) // <- invalid\n'
            '   │ │        ^^^ which evaluates to \'1\' is not a valid class name\n'
            '8  │ │ // prefix is not important, as we explicitly define name with @MapTo, \n'
            '9  │ │ // but obviously 1 is not a valid class name\n'
            '10 │ │ class Bad {}\n'
            '   │ └─── when generating realm object class for \'Bad\'\n'
            '   ╵\n'
            'We need a valid indentifier\n',
      )),
    );
  });

  test('repeated class annotations', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_annotations/realm_annotations.dart';

part 'test.g.dart';

@RealmModel()
@RealmModel()
class _Bad {}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Repeated annotation\n'
            '\n'
            'in: package:pkg/src/test.dart:6:1\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '  │ ━━━━━━━━━━━━━ 1st\n'
            '6 │ @RealmModel()\n'
            '  │ ^^^^^^^^^^^^^ 2nd\n'
            '7 │ class _Bad {}\n'
            '  │       ━━━━ on _Bad\n'
            '  ╵\n'
            'Remove all duplicated @RealmModel() annotations.\n',
      )),
    );
  });

  test('repeated field annotations', () async {
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
  @PrimaryKey()
  late final int id;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        'Repeated annotation\n'
            '\n'
            'in: package:pkg/src/test.dart:8:3\n'
            '  ╷\n'
            '7 │   @PrimaryKey()\n'
            '  │   ━━━━━━━━━━━━━ 1st\n'
            '8 │   @PrimaryKey()\n'
            '  │   ^^^^^^^^^^^^^ 2nd\n'
            '9 │   late final int id;\n'
            '  │                  ━━ on id\n'
            '  ╵\n'
            'Remove all duplicated @PrimaryKey() annotations.\n',
      )),
    );
  });

  test('human readable durations', () {
    expect(humanReadable(const Duration(microseconds: 1)), '1μs');
    expect(humanReadable(const Duration(milliseconds: 1)), '1ms');
    expect(humanReadable(const Duration(seconds: 1)), '1.0s');
    expect(humanReadable(const Duration(minutes: 1)), '1m 0s');
    expect(humanReadable(const Duration(hours: 1)), '1h 0m');
    expect(humanReadable(const Duration(days: 1)), '24h 0m');
  });
}
