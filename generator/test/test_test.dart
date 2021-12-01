import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
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
} 
      ''',
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
}
'''
        },
        reader: await PackageAssetReader.currentIsolate());
  });
}
