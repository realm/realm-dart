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

class Schedule extends _Schedule with RealmEntity, RealmObject {
  Schedule(
    ObjectId id, {
    Iterable<Task> tasks = const [],
  }) {
    RealmObject.set(this, '_id', id);
    RealmObject.set<RealmList<Task>>(this, 'tasks', RealmList<Task>(tasks));
  }

  Schedule._();

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  RealmList<Task> get tasks =>
      RealmObject.get<Task>(this, 'tasks') as RealmList<Task>;
  @override
  set tasks(covariant RealmList<Task> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Schedule>> get changes =>
      RealmObject.getChanges<Schedule>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Schedule._);
    return const SchemaObject(Schedule, 'Schedule', [
      SchemaProperty('_id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('tasks', RealmPropertyType.object,
          linkTarget: 'Task', collectionType: RealmCollectionType.list),
    ]);
  }
}

class AllTypes extends _AllTypes with RealmEntity, RealmObject {
  AllTypes(
    String stringProp,
    bool boolProp,
    DateTime dateProp,
    double doubleProp,
    ObjectId objectIdProp,
    Uuid uuidProp,
    int intProp, {
    String? nullableStringProp,
    bool? nullableBoolProp,
    DateTime? nullableDateProp,
    double? nullableDoubleProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
    int? nullableIntProp,
  }) {
    RealmObject.set(this, 'stringProp', stringProp);
    RealmObject.set(this, 'boolProp', boolProp);
    RealmObject.set(this, 'dateProp', dateProp);
    RealmObject.set(this, 'doubleProp', doubleProp);
    RealmObject.set(this, 'objectIdProp', objectIdProp);
    RealmObject.set(this, 'uuidProp', uuidProp);
    RealmObject.set(this, 'intProp', intProp);
    RealmObject.set(this, 'nullableStringProp', nullableStringProp);
    RealmObject.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObject.set(this, 'nullableDateProp', nullableDateProp);
    RealmObject.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObject.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObject.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObject.set(this, 'nullableIntProp', nullableIntProp);
  }

  AllTypes._();

  @override
  String get stringProp =>
      RealmObject.get<String>(this, 'stringProp') as String;
  @override
  set stringProp(String value) => RealmObject.set(this, 'stringProp', value);

  @override
  bool get boolProp => RealmObject.get<bool>(this, 'boolProp') as bool;
  @override
  set boolProp(bool value) => RealmObject.set(this, 'boolProp', value);

  @override
  DateTime get dateProp =>
      RealmObject.get<DateTime>(this, 'dateProp') as DateTime;
  @override
  set dateProp(DateTime value) => RealmObject.set(this, 'dateProp', value);

  @override
  double get doubleProp =>
      RealmObject.get<double>(this, 'doubleProp') as double;
  @override
  set doubleProp(double value) => RealmObject.set(this, 'doubleProp', value);

  @override
  ObjectId get objectIdProp =>
      RealmObject.get<ObjectId>(this, 'objectIdProp') as ObjectId;
  @override
  set objectIdProp(ObjectId value) =>
      RealmObject.set(this, 'objectIdProp', value);

  @override
  Uuid get uuidProp => RealmObject.get<Uuid>(this, 'uuidProp') as Uuid;
  @override
  set uuidProp(Uuid value) => RealmObject.set(this, 'uuidProp', value);

  @override
  int get intProp => RealmObject.get<int>(this, 'intProp') as int;
  @override
  set intProp(int value) => RealmObject.set(this, 'intProp', value);

  @override
  String? get nullableStringProp =>
      RealmObject.get<String>(this, 'nullableStringProp') as String?;
  @override
  set nullableStringProp(String? value) =>
      RealmObject.set(this, 'nullableStringProp', value);

  @override
  bool? get nullableBoolProp =>
      RealmObject.get<bool>(this, 'nullableBoolProp') as bool?;
  @override
  set nullableBoolProp(bool? value) =>
      RealmObject.set(this, 'nullableBoolProp', value);

  @override
  DateTime? get nullableDateProp =>
      RealmObject.get<DateTime>(this, 'nullableDateProp') as DateTime?;
  @override
  set nullableDateProp(DateTime? value) =>
      RealmObject.set(this, 'nullableDateProp', value);

  @override
  double? get nullableDoubleProp =>
      RealmObject.get<double>(this, 'nullableDoubleProp') as double?;
  @override
  set nullableDoubleProp(double? value) =>
      RealmObject.set(this, 'nullableDoubleProp', value);

  @override
  ObjectId? get nullableObjectIdProp =>
      RealmObject.get<ObjectId>(this, 'nullableObjectIdProp') as ObjectId?;
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      RealmObject.set(this, 'nullableObjectIdProp', value);

  @override
  Uuid? get nullableUuidProp =>
      RealmObject.get<Uuid>(this, 'nullableUuidProp') as Uuid?;
  @override
  set nullableUuidProp(Uuid? value) =>
      RealmObject.set(this, 'nullableUuidProp', value);

  @override
  int? get nullableIntProp =>
      RealmObject.get<int>(this, 'nullableIntProp') as int?;
  @override
  set nullableIntProp(int? value) =>
      RealmObject.set(this, 'nullableIntProp', value);

  @override
  Stream<RealmObjectChanges<AllTypes>> get changes =>
      RealmObject.getChanges<AllTypes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(AllTypes._);
    return const SchemaObject(AllTypes, 'AllTypes', [
      SchemaProperty('stringProp', RealmPropertyType.string),
      SchemaProperty('boolProp', RealmPropertyType.bool),
      SchemaProperty('dateProp', RealmPropertyType.timestamp),
      SchemaProperty('doubleProp', RealmPropertyType.double),
      SchemaProperty('objectIdProp', RealmPropertyType.objectid),
      SchemaProperty('uuidProp', RealmPropertyType.uuid),
      SchemaProperty('intProp', RealmPropertyType.int),
      SchemaProperty('nullableStringProp', RealmPropertyType.string,
          optional: true),
      SchemaProperty('nullableBoolProp', RealmPropertyType.bool,
          optional: true),
      SchemaProperty('nullableDateProp', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('nullableDoubleProp', RealmPropertyType.double,
          optional: true),
      SchemaProperty('nullableObjectIdProp', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('nullableUuidProp', RealmPropertyType.uuid,
          optional: true),
      SchemaProperty('nullableIntProp', RealmPropertyType.int, optional: true),
    ]);
  }
}

class LinksClass extends _LinksClass with RealmEntity, RealmObject {
  LinksClass(
    Uuid id, {
    LinksClass? link,
    Iterable<LinksClass> list = const [],
  }) {
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'link', link);
    RealmObject.set<RealmList<LinksClass>>(
        this, 'list', RealmList<LinksClass>(list));
  }

  LinksClass._();

  @override
  Uuid get id => RealmObject.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => throw RealmUnsupportedSetError();

  @override
  LinksClass? get link =>
      RealmObject.get<LinksClass>(this, 'link') as LinksClass?;
  @override
  set link(covariant LinksClass? value) => RealmObject.set(this, 'link', value);

  @override
  RealmList<LinksClass> get list =>
      RealmObject.get<LinksClass>(this, 'list') as RealmList<LinksClass>;
  @override
  set list(covariant RealmList<LinksClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<LinksClass>> get changes =>
      RealmObject.getChanges<LinksClass>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(LinksClass._);
    return const SchemaObject(LinksClass, 'LinksClass', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('link', RealmPropertyType.object,
          optional: true, linkTarget: 'LinksClass'),
      SchemaProperty('list', RealmPropertyType.object,
          linkTarget: 'LinksClass', collectionType: RealmCollectionType.list),
    ]);
  }
}

class AllCollections extends _AllCollections with RealmEntity, RealmObject {
  AllCollections({
    Iterable<String> strings = const [],
    Iterable<bool> bools = const [],
    Iterable<DateTime> dates = const [],
    Iterable<double> doubles = const [],
    Iterable<ObjectId> objectIds = const [],
    Iterable<Uuid> uuids = const [],
    Iterable<int> ints = const [],
  }) {
    RealmObject.set<RealmList<String>>(
        this, 'strings', RealmList<String>(strings));
    RealmObject.set<RealmList<bool>>(this, 'bools', RealmList<bool>(bools));
    RealmObject.set<RealmList<DateTime>>(
        this, 'dates', RealmList<DateTime>(dates));
    RealmObject.set<RealmList<double>>(
        this, 'doubles', RealmList<double>(doubles));
    RealmObject.set<RealmList<ObjectId>>(
        this, 'objectIds', RealmList<ObjectId>(objectIds));
    RealmObject.set<RealmList<Uuid>>(this, 'uuids', RealmList<Uuid>(uuids));
    RealmObject.set<RealmList<int>>(this, 'ints', RealmList<int>(ints));
  }

  AllCollections._();

  @override
  RealmList<String> get strings =>
      RealmObject.get<String>(this, 'strings') as RealmList<String>;
  @override
  set strings(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool> get bools =>
      RealmObject.get<bool>(this, 'bools') as RealmList<bool>;
  @override
  set bools(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime> get dates =>
      RealmObject.get<DateTime>(this, 'dates') as RealmList<DateTime>;
  @override
  set dates(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double> get doubles =>
      RealmObject.get<double>(this, 'doubles') as RealmList<double>;
  @override
  set doubles(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId> get objectIds =>
      RealmObject.get<ObjectId>(this, 'objectIds') as RealmList<ObjectId>;
  @override
  set objectIds(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid> get uuids =>
      RealmObject.get<Uuid>(this, 'uuids') as RealmList<Uuid>;
  @override
  set uuids(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get ints =>
      RealmObject.get<int>(this, 'ints') as RealmList<int>;
  @override
  set ints(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllCollections>> get changes =>
      RealmObject.getChanges<AllCollections>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(AllCollections._);
    return const SchemaObject(AllCollections, 'AllCollections', [
      SchemaProperty('strings', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('bools', RealmPropertyType.bool,
          collectionType: RealmCollectionType.list),
      SchemaProperty('dates', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.list),
      SchemaProperty('doubles', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
      SchemaProperty('objectIds', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.list),
      SchemaProperty('uuids', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.list),
      SchemaProperty('ints', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class NullableTypes extends _NullableTypes with RealmEntity, RealmObject {
  NullableTypes(
    ObjectId id,
    ObjectId differentiator, {
    String? stringProp,
    bool? boolProp,
    DateTime? dateProp,
    double? doubleProp,
    ObjectId? objectIdProp,
    Uuid? uuidProp,
    int? intProp,
  }) {
    RealmObject.set(this, '_id', id);
    RealmObject.set(this, 'differentiator', differentiator);
    RealmObject.set(this, 'stringProp', stringProp);
    RealmObject.set(this, 'boolProp', boolProp);
    RealmObject.set(this, 'dateProp', dateProp);
    RealmObject.set(this, 'doubleProp', doubleProp);
    RealmObject.set(this, 'objectIdProp', objectIdProp);
    RealmObject.set(this, 'uuidProp', uuidProp);
    RealmObject.set(this, 'intProp', intProp);
  }

  NullableTypes._();

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  ObjectId get differentiator =>
      RealmObject.get<ObjectId>(this, 'differentiator') as ObjectId;
  @override
  set differentiator(ObjectId value) =>
      RealmObject.set(this, 'differentiator', value);

  @override
  String? get stringProp =>
      RealmObject.get<String>(this, 'stringProp') as String?;
  @override
  set stringProp(String? value) => RealmObject.set(this, 'stringProp', value);

  @override
  bool? get boolProp => RealmObject.get<bool>(this, 'boolProp') as bool?;
  @override
  set boolProp(bool? value) => RealmObject.set(this, 'boolProp', value);

  @override
  DateTime? get dateProp =>
      RealmObject.get<DateTime>(this, 'dateProp') as DateTime?;
  @override
  set dateProp(DateTime? value) => RealmObject.set(this, 'dateProp', value);

  @override
  double? get doubleProp =>
      RealmObject.get<double>(this, 'doubleProp') as double?;
  @override
  set doubleProp(double? value) => RealmObject.set(this, 'doubleProp', value);

  @override
  ObjectId? get objectIdProp =>
      RealmObject.get<ObjectId>(this, 'objectIdProp') as ObjectId?;
  @override
  set objectIdProp(ObjectId? value) =>
      RealmObject.set(this, 'objectIdProp', value);

  @override
  Uuid? get uuidProp => RealmObject.get<Uuid>(this, 'uuidProp') as Uuid?;
  @override
  set uuidProp(Uuid? value) => RealmObject.set(this, 'uuidProp', value);

  @override
  int? get intProp => RealmObject.get<int>(this, 'intProp') as int?;
  @override
  set intProp(int? value) => RealmObject.set(this, 'intProp', value);

  @override
  Stream<RealmObjectChanges<NullableTypes>> get changes =>
      RealmObject.getChanges<NullableTypes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(NullableTypes._);
    return const SchemaObject(NullableTypes, 'NullableTypes', [
      SchemaProperty('_id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.objectid),
      SchemaProperty('stringProp', RealmPropertyType.string, optional: true),
      SchemaProperty('boolProp', RealmPropertyType.bool, optional: true),
      SchemaProperty('dateProp', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('doubleProp', RealmPropertyType.double, optional: true),
      SchemaProperty('objectIdProp', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('uuidProp', RealmPropertyType.uuid, optional: true),
      SchemaProperty('intProp', RealmPropertyType.int, optional: true),
    ]);
  }
}

class Event extends _Event with RealmEntity, RealmObject {
  Event(
    ObjectId id, {
    String? name,
    bool? isCompleted,
    int? durationInMinutes,
    String? assignedTo,
  }) {
    RealmObject.set(this, '_id', id);
    RealmObject.set(this, 'stringQueryField', name);
    RealmObject.set(this, 'boolQueryField', isCompleted);
    RealmObject.set(this, 'intQueryField', durationInMinutes);
    RealmObject.set(this, 'assignedTo', assignedTo);
  }

  Event._();

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  String? get name =>
      RealmObject.get<String>(this, 'stringQueryField') as String?;
  @override
  set name(String? value) => RealmObject.set(this, 'stringQueryField', value);

  @override
  bool? get isCompleted =>
      RealmObject.get<bool>(this, 'boolQueryField') as bool?;
  @override
  set isCompleted(bool? value) =>
      RealmObject.set(this, 'boolQueryField', value);

  @override
  int? get durationInMinutes =>
      RealmObject.get<int>(this, 'intQueryField') as int?;
  @override
  set durationInMinutes(int? value) =>
      RealmObject.set(this, 'intQueryField', value);

  @override
  String? get assignedTo =>
      RealmObject.get<String>(this, 'assignedTo') as String?;
  @override
  set assignedTo(String? value) => RealmObject.set(this, 'assignedTo', value);

  @override
  Stream<RealmObjectChanges<Event>> get changes =>
      RealmObject.getChanges<Event>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Event._);
    return const SchemaObject(Event, 'Event', [
      SchemaProperty('_id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('stringQueryField', RealmPropertyType.string,
          mapTo: 'stringQueryField', optional: true),
      SchemaProperty('boolQueryField', RealmPropertyType.bool,
          mapTo: 'boolQueryField', optional: true),
      SchemaProperty('intQueryField', RealmPropertyType.int,
          mapTo: 'intQueryField', optional: true),
      SchemaProperty('assignedTo', RealmPropertyType.string, optional: true),
    ]);
  }
}
