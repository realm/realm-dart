import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';

import 'test_util.dart';

import 'package:test/test.dart';

void main() {
  const directory = 'test/good_test_data';
  getListOfTestFiles(directory).forEach((inputFile, expectedFile) {
    executeTest(getTestName(inputFile), () async {
      await generatorTestBuilder(directory, inputFile);
    });
  });

  test('Links to mapped to class in another file', () async {
    final inputs = await getInputFileAsset('$directory/mapto.dart');
    inputs['pkg|$directory/another_mapto.dart'] = r'''
import 'package:realm_common/realm_common.dart';
import 'mapto.dart';

part 'another_mapto.g.dart';

@RealmModel()
@MapTo('this is also mapped')
class _MappedToo {
  late $Original? singleLink;

  late List<$Original> listLink;
}
    ''';

    final outputs = await getExpectedFileAsset('$directory/mapto.dart', '$directory/mapto.expected');
    outputs['pkg|$directory/another_mapto.realm_objects.g.part'] = r'''
// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class MappedToo extends _MappedToo with RealmEntity, RealmObject {
  MappedToo({
    Original? singleLink,
    Iterable<Original> listLink = const [],
  }) {
    RealmObject.set(this, 'singleLink', singleLink);
    RealmObject.set<RealmList<Original>>(
        this, 'listLink', RealmList<Original>(listLink));
  }

  MappedToo._();

  @override
  Original? get singleLink =>
      RealmObject.get<Original>(this, 'singleLink') as Original?;
  @override
  set singleLink(covariant Original? value) =>
      RealmObject.set(this, 'singleLink', value);

  @override
  RealmList<Original> get listLink =>
      RealmObject.get<Original>(this, 'listLink') as RealmList<Original>;
  @override
  set listLink(covariant RealmList<Original> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<MappedToo>> get changes =>
      RealmObject.getChanges<MappedToo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MappedToo._);
    return const SchemaObject(MappedToo, 'this is also mapped', [
      SchemaProperty('singleLink', RealmPropertyType.object,
          optional: true, linkTarget: 'another type'),
      SchemaProperty('listLink', RealmPropertyType.object,
          linkTarget: 'another type', collectionType: RealmCollectionType.list),
    ]);
  }
}
''';

    await testBuilder(generateRealmObjects(), inputs, outputs: outputs, reader: await PackageAssetReader.currentIsolate());
  });
}
