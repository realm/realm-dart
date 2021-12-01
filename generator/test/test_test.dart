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
}
