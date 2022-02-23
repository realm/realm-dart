import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';

void main() {
  test('required argument with default value', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  int age = 47;
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Person extends _Person with RealmObject {\n'
            '  static var _defaultsSet = false;\n'
            '\n'
            '  Person({\n'
            '    int age = 47,\n'
            '  }) {\n'
            '    if (!_defaultsSet) {\n'
            '      _defaultsSet = RealmObject.setDefaults<Person>({\n'
            '        \'age\': 47,\n'
            '      });\n'
            '    }\n'
            '    RealmObject.set(this, \'age\', age);\n'
            '  }\n'
            '\n'
            '  Person._();\n'
            '\n'
            '  @override\n'
            '  int get age => RealmObject.get<int>(this, \'age\') as int;\n'
            '  @override\n'
            '  set age(int value) => RealmObject.set(this, \'age\', value);\n'
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
            '      SchemaProperty(\'age\', RealmPropertyType.int),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            '',
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });

  test('required argument', () async {
    await testBuilder(
      generateRealmObjects(),
      {
        'pkg|lib/src/test.dart': r'''
import 'package:realm_common/realm_common.dart';

part 'test.g.dart';

@RealmModel()
class _Person {
  @PrimaryKey()
  late String name;
}''',
      },
      outputs: {
        'pkg|lib/src/test.realm_objects.g.part': '// **************************************************************************\n'
            '// RealmObjectGenerator\n'
            '// **************************************************************************\n'
            '\n'
            'class Person extends _Person with RealmObject {\n'
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
            '  set name(String value) => throw RealmUnsupportedSetError();\n'
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
            '      SchemaProperty(\'name\', RealmPropertyType.string, primaryKey: true),\n'
            '    ]);\n'
            '  }\n'
            '}\n'
            '',
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
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
            'class Person extends _Person with RealmObject {\n'
            '  Person({\n'
            '    Iterable<Person> children = const [],\n'
            '  }) {\n'
            '    RealmObject.set<List<Person>>(this, \'children\', children.toList());\n'
            '  }\n'
            '\n'
            '  Person._();\n'
            '\n'
            '  @override\n'
            '  List<Person> get children =>\n'
            '      RealmObject.get<Person>(this, \'children\') as List<Person>;\n'
            '  @override\n'
            '  set children(covariant List<Person> value) =>\n'
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
            'class Person extends _Person with RealmObject {\n'
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
            'class Person extends _Person with RealmObject {\n'
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
