import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';

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
        'pkg|lib/src/test.RealmObjects.g.part': r'''
// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Foo extends _Foo with RealmObject {
  Foo({
    int? x,
  }) {
    this.x = x ?? 0;
  }

  @override
  int get x => RealmObject.get<int>(this, 'x');
  @override
  set x(int value) => RealmObject.set<int>(this, 'x', value);

  static const schema = SchemaObject(Foo, [
    SchemaProperty('x', RealmPropertyType.int),
  ]);
}
''',
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
            reader: await PackageAssetReader.currentIsolate()),
        throwsA(isA<SourceSpanException>().having(
          (e) => e.toString(),
          'toString()',
          r'''
Error on line 5, column 7 of package:pkg/src/test.dart: Not a valid realm type: NonRealm
  ╷
5 │ class NonRealm {}
  │       ^^^^^^^^
  ╵''',
        )));
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
            reader: await PackageAssetReader.currentIsolate()),
        throwsA(isA<SourceSpanException>().having(
          (e) => e.toString(),
          'toString()',
          r'''
Error on line 8, column 8 of package:pkg/src/test.dart: Realm only support indexes on String, int, and bool fields
  ╷
8 │   Uuid notAnIndexableType;
  │        ^^^^^^^^^^^^^^^^^^
  ╵''',
        )));
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
            reader: await PackageAssetReader.currentIsolate()),
        throwsA(isA<SourceSpanException>().having(
          (e) => e.toString(),
          'toString()',
          r'''
Error on line 8, column 8 of package:pkg/src/test.dart: Primary key cannot be nullable
  ╷
8 │   int? nullableKeyNotAllowed;
  │        ^^^^^^^^^^^^^^^^^^^^^
  ╵''',
        )));
  });

  test('primary key not final', () async {
    final sb = StringBuffer();
    await testBuilder(
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
        onLog: (l) => l.level >= Level.WARNING
            ? sb.writeln(l)
            : null // disregard timing info
        );
    expect(sb.toString(), r'''
[WARNING] testBuilder: Primary keys and no other fields should be marked as final 
/pkg/lib/src/test.dart:8:11
  ╷
6 │ class _Bad {
7 │   @PrimaryKey()
8 │   late int primartKeyIsNotFinal;
  │            ^^^^^^^^^^^^^^^^^^^^
9 │ }
  ╵
''');
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
        if (!done) { // disregard all, but first record
          sb.writeln(l);
          done = true;
        }
      },
    );
    expect(sb.toString(), r'''
[INFO] testBuilder: Indexed is implied for a primary key 
/pkg/lib/src/test.dart:9:17
   ╷
 7 │   @PrimaryKey()
 8 │   @Indexed()
 9 │   late final int primartKeysAreAlwaysIndexed;
   │                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
10 │ }
   ╵
''');
  });
}
