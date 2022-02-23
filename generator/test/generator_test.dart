import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';

void main() {
  test('pinhole', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Foo {
  int x = 0;
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Foo extends _Foo with RealmObject {\n'
            '  static var _defaultsSet = false;\n'
            '\n'
            '  Foo({\n'
            '    int x = 0,\n'
            '  }) {\n'
            '    if (!_defaultsSet) {\n'
            '      _defaultsSet = RealmObject.setDefaults<Foo>({\n'
            '        \'x\': 0,\n'
            '      });\n'
            '    }\n'
            '    RealmObject.set(this, \'x\', x);\n'
            '  }\n'
            '\n'
            '  Foo._();\n'
            '\n'
            '  @override\n'
            '  int get x => RealmObject.get<int>(this, \'x\') as int;\n'
            '  @override\n'
            '  set x(int value) => RealmObject.set(this, \'x\', value);\n'
            '\n'
            '  @override\n'
            '  Stream<RealmObjectChanges<Foo>> get changes =>\n'
            '      RealmObject.getChanges<Foo>(this);\n'
            '\n'
            '  static SchemaObject get schema => _schema ??= _initSchema();\n'
            '  static SchemaObject? _schema;\n'
            '  static SchemaObject _initSchema() {\n'
            '    RealmObject.registerFactory(Foo._);\n'
            '    return const SchemaObject(Foo, [\n'
            '      SchemaProperty(\'x\', RealmPropertyType.int),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            '',
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

import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
@MapTo('Fooo')
class _Foo {
  int x = 0;
} 

@RealmModel()
class _Bar {
  @PrimaryKey()
  late String id;
  late bool aBool, another;
  var data = Uint8List(16);
  // late RealmAny any; // not supported yet
  @MapTo('tidspunkt')
  var timestamp = DateTime.now();
  var aDouble = 0.0;
  // late Decimal128 decimal; // not supported yet
  _Foo? foo;
  // late ObjectId id;
  // late Uuid uuid; // not supported yet
  @Ignored()
  var theMeaningOfEverything = 42;
  var list = [0]; // list of ints with default value
  // late Set<int> set; // not supported yet
  // late map = <String, int>{}; // not supported yet

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
import 'package:realm_common/realm_common.dart';

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
          (e) => e.format(),
          'format()',
          'Not a realm type\n'
              '\n'
              'in: package:pkg/src/test.dart:9:8\n'
              '    ╷\n'
              '5   │ class NonRealm {}\n'
              '    │       ━━━━━━━━ \n'
              '... │\n'
              '7   │ @RealmModel()\n'
              '8   │ class _Bad {\n'
              '    │       ━━━━ in realm model for \'Bad\'\n'
              '9   │   late NonRealm notARealmType;\n'
              '    │        ^^^^^^^^ NonRealm is not a realm model type\n'
              '    ╵\n'
              'Add a @RealmModel annotation on \'NonRealm\', or an @Ignored annotation on \'notARealmType\'.\n'
              '',
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
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  @Indexed()
  Double notAnIndexableType;
}'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        isA<RealmInvalidGenerationSourceError>().having(
          (e) => e.format(),
          'format()',
          'Realm only support indexes on String, int, and bool fields\n'
              '\n'
              'in: package:pkg/src/test.dart:8:3\n'
              '  ╷\n'
              '5 │ @RealmModel()\n'
              '6 │ class _Bad {\n'
              '  │       ━━━━ in realm model for \'Bad\'\n'
              '7 │   @Indexed()\n'
              '8 │   Double notAnIndexableType;\n'
              '  │   ^^^^^^ Double is not an indexable type\n'
              '  ╵\n'
              'Change the type of \'notAnIndexableType\', or remove the @Indexed() annotation\n'
              '',
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
import 'package:realm_common/realm_common.dart';

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
          (e) => e.format(),
          'format()',
          'Primary key cannot be nullable\n'
              '\n'
              'in: package:pkg/src/test.dart:8:3\n'
              '  ╷\n'
              '5 │ @RealmModel()\n'
              '6 │ class _Bad {\n'
              '  │       ━━━━ in realm model for \'Bad\'\n'
              '7 │   @PrimaryKey()\n'
              '8 │   int? nullableKeyNotAllowed;\n'
              '  │   ^^^^ is nullable\n'
              '  ╵\n'
              'Consider using the @Indexed() annotation instead, or make \'nullableKeyNotAllowed\' an int.\n'
              '',
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
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Questionable {
  @PrimaryKey()
  @Indexed()
  late int primartKeysAreAlwaysIndexed;
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
      'in: package:pkg/src/test.dart:9:12\n'
      '  ╷\n'
      '7 │   @PrimaryKey()\n'
      '8 │   @Indexed()\n'
      '9 │   late int primartKeysAreAlwaysIndexed;\n'
      '  │            ^^^^^^^^^^^^^^^^^^^^^^^^^^^\n'
      '  ╵\n'
      'Remove either the @Indexed or @PrimaryKey annotation from \'primartKeysAreAlwaysIndexed\'.\n'
      '\n'
      '',
    );
  });

  test('list of list not supported', () async {
    await expectLater(
        () async => await testBuilder(
              generateRealmObjects(),
              {
                'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

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
            (e) => e.format(),
            'format()',
            'Not a realm type\n'
                '\n'
                'in: package:pkg/src/test.dart:8:21\n'
                '    ╷\n'
                '5   │ @RealmModel()\n'
                '6   │ class _Bad {\n'
                '    │       ━━━━ in realm model for \'Bad\'\n'
                '... │\n'
                '8   │   var listOfLists = [[0], [1]];\n'
                '    │                     ^^^^^^^^^^ List<List<int>> is not a realm model type\n'
                '    ╵\n'
                'Remove the invalid field or add an @Ignored annotation on \'listOfLists\'.\n')));
  });

  test('missing underscore', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

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
        (e) => e.format(),
        'format()',
        'Not a realm type\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '6 │ class _Bad {\n'
            '  │       ━━━━ in realm model for \'Bad\'\n'
            '7 │   late Other other;\n'
            '  │        ^^^^^ Other is not a realm model type\n'
            '  ╵\n'
            'Did you intend to use _Other as type for \'other\'?\n'
            '',
      )),
    );
  });

  test('double primary key', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int first;

  @PrimaryKey()
  late String second;

  late String another;

  @PrimaryKey()
  late String third;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Duplicate primary keys\n'
            '\n'
            'in: package:pkg/src/test.dart:11:15\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ class _Bad {\n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '7   │   @PrimaryKey()\n'
            '8   │   late int first;\n'
            '    │            ━━━━━ \n'
            '... │\n'
            '10  │   @PrimaryKey()\n'
            '11  │   late String second;\n'
            '    │               ^^^^^^ second primary key\n'
            '... │\n'
            '15  │   @PrimaryKey()\n'
            '16  │   late String third;\n'
            '    │               ━━━━━ \n'
            '    ╵\n'
            'Avoid duplicated @PrimaryKey() on fields \'first\', \'second\', \'third\'\n'
            '',
      )),
    );
  });

  test('invalid model name prefix', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class Bad { // missing _ or $ prefix
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Missing prefix on realm model name\n'
            '\n'
            'in: package:pkg/src/test.dart:6:7\n'
            '  ╷\n'
            '5 │ @RealmModel()\n'
            '6 │ class Bad { // missing _ or \$ prefix\n'
            '  │       ^^^ missing prefix\n'
            '  ╵\n'
            'Either align class name to match prefix [_\$] (regular expression), or add a @MapTo annotation.\n'
            '',
      )),
    );
  });

  test('invalid model name mapping', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

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
        (e) => e.format(),
        'format()',
        'Invalid class name\n'
            '\n'
            'in: package:pkg/src/test.dart:7:8\n'
            '   ╷\n'
            '6  │ @RealmModel()\n'
            '7  │ @MapTo(one) // <- invalid\n'
            '   │        ^^^ which evaluates to \'1\' is not a valid class name\n'
            '8  │ // prefix is not important, as we explicitly define name with @MapTo, \n'
            '9  │ // but obviously 1 is not a valid class name\n'
            '10 │ class Bad {}\n'
            '   │       ━━━ when generating realm object class for \'Bad\'\n'
            '   ╵\n'
            'We need a valid indentifier\n'
            '',
      )),
    );
  });

  test('repeated class annotations', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
@MapTo('Bad')
@RealmModel()
class _Bad {}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Repeated annotation\n'
            '\n'
            'in: package:pkg/src/test.dart:7:1\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '    │ ━━━━━━━━━━━━━ \n'
            '... │\n'
            '7   │ @RealmModel()\n'
            '    │ ^^^^^^^^^^^^^ duplicated annotation\n'
            '8   │ class _Bad {}\n'
            '    ╵\n'
            'Remove all duplicated @RealmModel() annotations.\n'
            '',
      )),
    );
  });

  test('repeated field annotations', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Bad { 
  @PrimaryKey()
  @MapTo('key')
  @PrimaryKey()
  late int id;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Repeated annotation\n'
            '\n'
            'in: package:pkg/src/test.dart:9:3\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ class _Bad { \n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '7   │   @PrimaryKey()\n'
            '    │   ━━━━━━━━━━━━━ \n'
            '... │\n'
            '9   │   @PrimaryKey()\n'
            '    │   ^^^^^^^^^^^^^ duplicated annotation\n'
            '10  │   late int id;\n'
            '    ╵\n'
            'Remove all duplicated @PrimaryKey() annotations.\n'
            '',
      )),
    );
  });

  test('invalid extend', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

class Base {}

@RealmModel()
class _Bad extends Base { 
  @PrimaryKey()
  late int id;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Realm model classes can only extend Object\n'
            '\n'
            'in: package:pkg/src/test.dart:8:7\n'
            '  ╷\n'
            '7 │ @RealmModel()\n'
            '8 │ class _Bad extends Base { \n'
            '  │       ^^^^ cannot extend Base\n'
            '  ╵',
      )),
    );
  });

  test('illigal constructor', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Bad { 
  @PrimaryKey()
  late int id;

  _Bad(this.id);
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'No constructors allowed on realm model classes\n'
            '\n'
            'in: package:pkg/src/test.dart:10:3\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ class _Bad { \n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '... │\n'
            '10  │   _Bad(this.id);\n'
            '    │   ^ has constructor\n'
            '    ╵\n'
            'Remove constructor\n'
            '',
      )),
    );
  });

  test('nullable list', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Bad { 
  @PrimaryKey()
  late int id;

  List<int>? wrong;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Realm collections cannot be nullable\n'
            '\n'
            'in: package:pkg/src/test.dart:10:3\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ class _Bad { \n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '... │\n'
            '10  │   List<int>? wrong;\n'
            '    │   ^^^^^^^^^^ is nullable\n'
            '    ╵',
      )),
    );
  });

  test('nullable list elements', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Other {}

@RealmModel()
class _Bad { 
  @PrimaryKey()
  late int id;

  late List<int?> okay;
  late List<_Other?> wrong;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Nullable realm objects are not allowed in collections\n'
            '\n'
            'in: package:pkg/src/test.dart:14:8\n'
            '    ╷\n'
            '8   │ @RealmModel()\n'
            '9   │ class _Bad { \n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '... │\n'
            '14  │   late List<_Other?> wrong;\n'
            '    │        ^^^^^^^^^^^^^ which has a nullable realm object element type\n'
            '    ╵\n'
            'Ensure element type is non-nullable\n'
            '',
      )),
    );
  });

  test('non-nullable realm object reference', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Other {}

@RealmModel()
class _Bad { 
  @PrimaryKey()
  late int id;

  late _Other wrong;
}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Realm object references must be nullable\n'
            '\n'
            'in: package:pkg/src/test.dart:13:8\n'
            '    ╷\n'
            '8   │ @RealmModel()\n'
            '9   │ class _Bad { \n'
            '    │       ━━━━ in realm model for \'Bad\'\n'
            '... │\n'
            '13  │   late _Other wrong;\n'
            '    │        ^^^^^^ is not nullable\n'
            '    ╵\n'
            'Change type to _Other?\n'
            '',
      )),
    );
  });

  test('defining both _Bad and \$Bad', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class $Bad1 {}

@RealmModel()
class _Bad1 {}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Duplicate definition\n'
            '\n'
            'in: package:pkg/src/test.dart:9:7\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ class \$Bad1 {}\n'
            '    │       ━━━━━ \n'
            '... │\n'
            '8   │ @RealmModel()\n'
            '9   │ class _Bad1 {}\n'
            '    │       ^^^^^ realm model \'\$Bad1\' already defines \'Bad1\'\n'
            '    ╵\n'
            'Duplicate realm model definitions \'_Bad1\' and \'\$Bad1\'.\n'
            '',
      )),
    );
  });

  test('reusing mapTo name', () async {
    await expectLater(
      () async => await testBuilder(
        generateRealmObjects(),
        {
          'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
@MapTo('Bad3')
class _Foo {}

@MapTo('Bad3')
@RealmModel()
class _Bar {}
'''
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(isA<RealmInvalidGenerationSourceError>().having(
        (e) => e.format(),
        'format()',
        'Duplicate definition\n'
            '\n'
            'in: package:pkg/src/test.dart:11:7\n'
            '    ╷\n'
            '5   │ @RealmModel()\n'
            '6   │ @MapTo(\'Bad3\')\n'
            '7   │ class _Foo {}\n'
            '    │       ━━━━ \n'
            '... │\n'
            '9   │ @MapTo(\'Bad3\')\n'
            '10  │ @RealmModel()\n'
            '11  │ class _Bar {}\n'
            '    │       ^^^^ realm model \'_Foo\' already defines \'Bad3\'\n'
            '    ╵\n'
            'Duplicate realm model definitions \'_Bar\' and \'_Foo\'.\n'
            '',
      )),
    );
  });

  test('bool not allowed on indexed field', () async {
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
  @Indexed()
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
            '8 │   @Indexed()\n'
            '9 │   late bool bad;\n'
            '  │        ^^^^ bool is not an indexable type\n'
            '  ╵\n'
            'Change the type of \'bad\', or remove the @Indexed() annotation\n'
            '',
      )),
    );
  });

  test('bool not allowed as primary key', () async {
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
}
