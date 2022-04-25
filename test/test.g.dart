// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmEntity, RealmObject {
  Car(
    String make,
  ) {
    RealmObject.set(this, 'make', make);
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;
  @override
  set make(String value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Car>> get changes =>
      RealmObject.getChanges<Car>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Car._);
    return const SchemaObject(Car, 'Car', [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}

class Person extends _Person with RealmEntity, RealmObject {
  Person(
    String name,
  ) {
    RealmObject.set(this, 'name', name);
  }

  Person._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<Person>> get changes =>
      RealmObject.getChanges<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Person._);
    return const SchemaObject(Person, 'Person', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }
}

class Dog extends _Dog with RealmEntity, RealmObject {
  Dog(
    String name, {
    int? age,
    Person? owner,
  }) {
    RealmObject.set(this, 'name', name);
    RealmObject.set(this, 'age', age);
    RealmObject.set(this, 'owner', owner);
  }

  Dog._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  @override
  int? get age => RealmObject.get<int>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObject.set(this, 'age', value);

  @override
  Person? get owner => RealmObject.get<Person>(this, 'owner') as Person?;
  @override
  set owner(covariant Person? value) => RealmObject.set(this, 'owner', value);

  @override
  Stream<RealmObjectChanges<Dog>> get changes =>
      RealmObject.getChanges<Dog>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Dog._);
    return const SchemaObject(Dog, 'Dog', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int, optional: true),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true, linkTarget: 'Person'),
    ]);
  }
}

class Team extends _Team with RealmEntity, RealmObject {
  Team(
    String name, {
    Iterable<Person> players = const [],
    Iterable<int> scores = const [],
  }) {
    RealmObject.set(this, 'name', name);
    RealmObject.set<RealmList<Person>>(
        this, 'players', RealmList<Person>(players));
    RealmObject.set<RealmList<int>>(this, 'scores', RealmList<int>(scores));
  }

  Team._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  RealmList<Person> get players =>
      RealmObject.get<Person>(this, 'players') as RealmList<Person>;
  @override
  set players(covariant RealmList<Person> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get scores =>
      RealmObject.get<int>(this, 'scores') as RealmList<int>;
  @override
  set scores(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Team>> get changes =>
      RealmObject.getChanges<Team>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Team._);
    return const SchemaObject(Team, 'Team', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('players', RealmPropertyType.object,
          linkTarget: 'Person', collectionType: RealmCollectionType.list),
      SchemaProperty('scores', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Student extends _Student with RealmEntity, RealmObject {
  Student(
    int number, {
    String? name,
    int? yearOfBirth,
    School? school,
  }) {
    RealmObject.set(this, 'number', number);
    RealmObject.set(this, 'name', name);
    RealmObject.set(this, 'yearOfBirth', yearOfBirth);
    RealmObject.set(this, 'school', school);
  }

  Student._();

  @override
  int get number => RealmObject.get<int>(this, 'number') as int;
  @override
  set number(int value) => throw RealmUnsupportedSetError();

  @override
  String? get name => RealmObject.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObject.set(this, 'name', value);

  @override
  int? get yearOfBirth => RealmObject.get<int>(this, 'yearOfBirth') as int?;
  @override
  set yearOfBirth(int? value) => RealmObject.set(this, 'yearOfBirth', value);

  @override
  School? get school => RealmObject.get<School>(this, 'school') as School?;
  @override
  set school(covariant School? value) => RealmObject.set(this, 'school', value);

  @override
  Stream<RealmObjectChanges<Student>> get changes =>
      RealmObject.getChanges<Student>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Student._);
    return const SchemaObject(Student, 'Student', [
      SchemaProperty('number', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
      SchemaProperty('school', RealmPropertyType.object,
          optional: true, linkTarget: 'School'),
    ]);
  }
}

class School extends _School with RealmEntity, RealmObject {
  School(
    String name, {
    String? city,
    School? branchOfSchool,
    Iterable<Student> students = const [],
    Iterable<School> branches = const [],
  }) {
    RealmObject.set(this, 'name', name);
    RealmObject.set(this, 'city', city);
    RealmObject.set(this, 'branchOfSchool', branchOfSchool);
    RealmObject.set<RealmList<Student>>(
        this, 'students', RealmList<Student>(students));
    RealmObject.set<RealmList<School>>(
        this, 'branches', RealmList<School>(branches));
  }

  School._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  @override
  String? get city => RealmObject.get<String>(this, 'city') as String?;
  @override
  set city(String? value) => RealmObject.set(this, 'city', value);

  @override
  RealmList<Student> get students =>
      RealmObject.get<Student>(this, 'students') as RealmList<Student>;
  @override
  set students(covariant RealmList<Student> value) =>
      throw RealmUnsupportedSetError();

  @override
  School? get branchOfSchool =>
      RealmObject.get<School>(this, 'branchOfSchool') as School?;
  @override
  set branchOfSchool(covariant School? value) =>
      RealmObject.set(this, 'branchOfSchool', value);

  @override
  RealmList<School> get branches =>
      RealmObject.get<School>(this, 'branches') as RealmList<School>;
  @override
  set branches(covariant RealmList<School> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<School>> get changes =>
      RealmObject.getChanges<School>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(School._);
    return const SchemaObject(School, 'School', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('city', RealmPropertyType.string, optional: true),
      SchemaProperty('students', RealmPropertyType.object,
          linkTarget: 'Student', collectionType: RealmCollectionType.list),
      SchemaProperty('branchOfSchool', RealmPropertyType.object,
          optional: true, linkTarget: 'School'),
      SchemaProperty('branches', RealmPropertyType.object,
          linkTarget: 'School', collectionType: RealmCollectionType.list),
    ]);
  }
}

class RemappedClass extends $RemappedClass with RealmEntity, RealmObject {
  RemappedClass(
    String remappedProperty, {
    Iterable<RemappedClass> listProperty = const [],
  }) {
    RealmObject.set(this, 'primitive_property', remappedProperty);
    RealmObject.set<RealmList<RemappedClass>>(
        this, 'list-with-dashes', RealmList<RemappedClass>(listProperty));
  }

  RemappedClass._();

  @override
  String get remappedProperty =>
      RealmObject.get<String>(this, 'primitive_property') as String;
  @override
  set remappedProperty(String value) =>
      RealmObject.set(this, 'primitive_property', value);

  @override
  RealmList<RemappedClass> get listProperty =>
      RealmObject.get<RemappedClass>(this, 'list-with-dashes')
          as RealmList<RemappedClass>;
  @override
  set listProperty(covariant RealmList<RemappedClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<RemappedClass>> get changes =>
      RealmObject.getChanges<RemappedClass>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(RemappedClass._);
    return const SchemaObject(RemappedClass, 'myRemappedClass', [
      SchemaProperty('primitive_property', RealmPropertyType.string,
          mapTo: 'primitive_property'),
      SchemaProperty('list-with-dashes', RealmPropertyType.object,
          mapTo: 'list-with-dashes',
          linkTarget: 'myRemappedClass',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Task extends _Task with RealmEntity, RealmObject {
  Task(
    ObjectId id,
  ) {
    RealmObject.set(this, '_id', id);
  }

  Task._();

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Task>> get changes =>
      RealmObject.getChanges<Task>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Task._);
    return const SchemaObject(Task, 'Task', [
      SchemaProperty('_id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}
