import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';
void main() {

  final folderName = 'good_test_io';

  test('required argument with default value', () async {
    await ioTestBuilder(folderName, 'required_arg_with_default_value.dart', 'required_arg_with_default_value.g.dart');
  });

  test('required argument', () async {
    await ioTestBuilder(folderName, 'required_argument.dart', 'required_argument.g.dart');
  }); 

  test('list initialization', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  late List<_Person> children;
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Person extends _Person with RealmEntity, RealmObject {\n'
            '  Person({\n'
            '    Iterable<Person> children = const [],\n'
            '  }) {\n'
            '    RealmObject.set<RealmList<Person>>(\n'
            '        this, \'children\', RealmList<Person>(children));\n'
            '  }\n'
            '\n'
            '  Person._();\n'
            '\n'
            '  @override\n'
            '  RealmList<Person> get children =>\n'
            '      RealmObject.get<Person>(this, \'children\') as RealmList<Person>;\n'
            '  @override\n'
            '  set children(covariant RealmList<Person> value) =>\n'
            '      throw RealmUnsupportedSetError();\n'
            '\n'
            '  @override\n'
            '  Stream<RealmObjectChanges<Person>> get changes =>\n'
            '      RealmObject.getChanges<Person>(this);\n'
            '\n'
            '  static SchemaObject get schema => _schema ??= _initSchema();\n'
            '  static SchemaObject? _schema;\n'
            '  static SchemaObject _initSchema() {\n'
            '    RealmObject.registerFactory(Person._);\n'
            '    return const SchemaObject(Person, [\n'
            '      SchemaProperty(\'children\', RealmPropertyType.object,\n'
            '          linkTarget: \'Person\', collectionType: RealmCollectionType.list),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            ''
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });

  test('optional argument', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  _Person? spouse;
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Person extends _Person with RealmEntity, RealmObject {\n'
            '  Person({\n'
            '    Person? spouse,\n'
            '  }) {\n'
            '    RealmObject.set(this, \'spouse\', spouse);\n'
            '  }\n'
            '\n'
            '  Person._();\n'
            '\n'
            '  @override\n'
            '  Person? get spouse => RealmObject.get<Person>(this, \'spouse\') as Person?;\n'
            '  @override\n'
            '  set spouse(covariant Person? value) => RealmObject.set(this, \'spouse\', value);\n'
            '\n'
            '  @override\n'
            '  Stream<RealmObjectChanges<Person>> get changes =>\n'
            '      RealmObject.getChanges<Person>(this);\n'
            '\n'
            '  static SchemaObject get schema => _schema ??= _initSchema();\n'
            '  static SchemaObject? _schema;\n'
            '  static SchemaObject _initSchema() {\n'
            '    RealmObject.registerFactory(Person._);\n'
            '    return const SchemaObject(Person, [\n'
            '      SchemaProperty(\'spouse\', RealmPropertyType.object,\n'
            '          optional: true, linkTarget: \'Person\'),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            '',
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });

  test('user defined getter', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  late String name;
  String get lastName => name.split(' ').first; // <-- should be ignored by generator
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Person extends _Person with RealmEntity, RealmObject {\n'
            '  Person(\n'
            '    String name,\n'
            '  ) {\n'
            '    RealmObject.set(this, \'name\', name);\n'
            '  }\n'
            '\n'
            '  Person._();\n'
            '\n'
            '  @override\n'
            '  String get name => RealmObject.get<String>(this, \'name\') as String;\n'
            '  @override\n'
            '  set name(String value) => RealmObject.set(this, \'name\', value);\n'
            '\n'
            '  @override\n'
            '  Stream<RealmObjectChanges<Person>> get changes =>\n'
            '      RealmObject.getChanges<Person>(this);\n'
            '\n'
            '  static SchemaObject get schema => _schema ??= _initSchema();\n'
            '  static SchemaObject? _schema;\n'
            '  static SchemaObject _initSchema() {\n'
            '    RealmObject.registerFactory(Person._);\n'
            '    return const SchemaObject(Person, [\n'
            '      SchemaProperty(\'name\', RealmPropertyType.string),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            '',
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });
}
