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
    _singleLinkProperty.setValue(this, singleLink);
    _listLinkProperty.setValue(this, RealmList<Original>(listLink));
  }

  MappedToo._();

  static const _singleLinkProperty = ObjectProperty<Original>('singleLink');
  @override
  Original? get singleLink => _singleLinkProperty.getValue(this);
  @override
  set singleLink(covariant Original? value) =>
      _singleLinkProperty.setValue(this, value);

  static const _listLinkProperty =
      ListProperty<Original>('listLink', RealmPropertyType.object);
  @override
  RealmList<Original> get listLink => _listLinkProperty.getValue(this);
  @override
  set listLink(covariant RealmList<Original> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<MappedToo>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<MappedToo>(
    MappedToo._,
    'this is also mapped',
    {
      'singleLink': _singleLinkProperty,
      'listLink': _listLinkProperty,
    },
  );
  @override
  Map<String, ValueProperty> get properties => schema.properties;
}
''';
    await testBuilder(generateRealmObjects(), inputs, outputs: outputs, reader: await PackageAssetReader.currentIsolate());
  });
}
