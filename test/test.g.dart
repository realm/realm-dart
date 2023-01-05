// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmEntity, RealmObjectBase, RealmObject {
  Car(
    String make,
  ) {
    RealmObjectBase.set(this, 'make', make);
  }

  Car._();

  @override
  String get make => RealmObjectBase.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObjectBase.set(this, 'make', value);

  @override
  Stream<RealmObjectChanges<Car>> get changes =>
      RealmObjectBase.getChanges<Car>(this);

  @override
  Car freeze() => RealmObjectBase.freezeObject<Car>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Car._);
    return const SchemaObject(ObjectType.realmObject, Car, 'Car', [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}

class Person extends _Person with RealmEntity, RealmObjectBase, RealmObject {
  Person(
    String name,
  ) {
    RealmObjectBase.set(this, 'name', name);
  }

  Person._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<Person>> get changes =>
      RealmObjectBase.getChanges<Person>(this);

  @override
  Person freeze() => RealmObjectBase.freezeObject<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Person._);
    return const SchemaObject(ObjectType.realmObject, Person, 'Person', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }
}

class Dog extends _Dog with RealmEntity, RealmObjectBase, RealmObject {
  Dog(
    String name, {
    int? age,
    Person? owner,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'age', age);
    RealmObjectBase.set(this, 'owner', owner);
  }

  Dog._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int? get age => RealmObjectBase.get<int>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObjectBase.set(this, 'age', value);

  @override
  Person? get owner => RealmObjectBase.get<Person>(this, 'owner') as Person?;
  @override
  set owner(covariant Person? value) =>
      RealmObjectBase.set(this, 'owner', value);

  @override
  Stream<RealmObjectChanges<Dog>> get changes =>
      RealmObjectBase.getChanges<Dog>(this);

  @override
  Dog freeze() => RealmObjectBase.freezeObject<Dog>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Dog._);
    return const SchemaObject(ObjectType.realmObject, Dog, 'Dog', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int, optional: true),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true, linkTarget: 'Person'),
    ]);
  }
}

class Team extends _Team with RealmEntity, RealmObjectBase, RealmObject {
  Team(
    String name, {
    Iterable<Person> players = const [],
    Iterable<int> scores = const [],
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set<RealmList<Person>>(
        this, 'players', RealmList<Person>(players));
    RealmObjectBase.set<RealmList<int>>(this, 'scores', RealmList<int>(scores));
  }

  Team._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<Person> get players =>
      RealmObjectBase.get<Person>(this, 'players') as RealmList<Person>;
  @override
  set players(covariant RealmList<Person> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get scores =>
      RealmObjectBase.get<int>(this, 'scores') as RealmList<int>;
  @override
  set scores(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Team>> get changes =>
      RealmObjectBase.getChanges<Team>(this);

  @override
  Team freeze() => RealmObjectBase.freezeObject<Team>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Team._);
    return const SchemaObject(ObjectType.realmObject, Team, 'Team', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('players', RealmPropertyType.object,
          linkTarget: 'Person', collectionType: RealmCollectionType.list),
      SchemaProperty('scores', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Student extends _Student with RealmEntity, RealmObjectBase, RealmObject {
  Student(
    int number, {
    String? name,
    int? yearOfBirth,
    School? school,
  }) {
    RealmObjectBase.set(this, 'number', number);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'yearOfBirth', yearOfBirth);
    RealmObjectBase.set(this, 'school', school);
  }

  Student._();

  @override
  int get number => RealmObjectBase.get<int>(this, 'number') as int;
  @override
  set number(int value) => RealmObjectBase.set(this, 'number', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  int? get yearOfBirth => RealmObjectBase.get<int>(this, 'yearOfBirth') as int?;
  @override
  set yearOfBirth(int? value) =>
      RealmObjectBase.set(this, 'yearOfBirth', value);

  @override
  School? get school => RealmObjectBase.get<School>(this, 'school') as School?;
  @override
  set school(covariant School? value) =>
      RealmObjectBase.set(this, 'school', value);

  @override
  Stream<RealmObjectChanges<Student>> get changes =>
      RealmObjectBase.getChanges<Student>(this);

  @override
  Student freeze() => RealmObjectBase.freezeObject<Student>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Student._);
    return const SchemaObject(ObjectType.realmObject, Student, 'Student', [
      SchemaProperty('number', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
      SchemaProperty('school', RealmPropertyType.object,
          optional: true, linkTarget: 'School'),
    ]);
  }
}

class School extends _School with RealmEntity, RealmObjectBase, RealmObject {
  School(
    String name, {
    String? city,
    School? branchOfSchool,
    Iterable<Student> students = const [],
    Iterable<School> branches = const [],
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set(this, 'branchOfSchool', branchOfSchool);
    RealmObjectBase.set<RealmList<Student>>(
        this, 'students', RealmList<Student>(students));
    RealmObjectBase.set<RealmList<School>>(
        this, 'branches', RealmList<School>(branches));
  }

  School._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get city => RealmObjectBase.get<String>(this, 'city') as String?;
  @override
  set city(String? value) => RealmObjectBase.set(this, 'city', value);

  @override
  RealmList<Student> get students =>
      RealmObjectBase.get<Student>(this, 'students') as RealmList<Student>;
  @override
  set students(covariant RealmList<Student> value) =>
      throw RealmUnsupportedSetError();

  @override
  School? get branchOfSchool =>
      RealmObjectBase.get<School>(this, 'branchOfSchool') as School?;
  @override
  set branchOfSchool(covariant School? value) =>
      RealmObjectBase.set(this, 'branchOfSchool', value);

  @override
  RealmList<School> get branches =>
      RealmObjectBase.get<School>(this, 'branches') as RealmList<School>;
  @override
  set branches(covariant RealmList<School> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<School>> get changes =>
      RealmObjectBase.getChanges<School>(this);

  @override
  School freeze() => RealmObjectBase.freezeObject<School>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(School._);
    return const SchemaObject(ObjectType.realmObject, School, 'School', [
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

class RemappedClass extends $RemappedClass
    with RealmEntity, RealmObjectBase, RealmObject {
  RemappedClass(
    String remappedProperty, {
    Iterable<RemappedClass> listProperty = const [],
  }) {
    RealmObjectBase.set(this, 'primitive_property', remappedProperty);
    RealmObjectBase.set<RealmList<RemappedClass>>(
        this, 'list-with-dashes', RealmList<RemappedClass>(listProperty));
  }

  RemappedClass._();

  @override
  String get remappedProperty =>
      RealmObjectBase.get<String>(this, 'primitive_property') as String;
  @override
  set remappedProperty(String value) =>
      RealmObjectBase.set(this, 'primitive_property', value);

  @override
  RealmList<RemappedClass> get listProperty =>
      RealmObjectBase.get<RemappedClass>(this, 'list-with-dashes')
          as RealmList<RemappedClass>;
  @override
  set listProperty(covariant RealmList<RemappedClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<RemappedClass>> get changes =>
      RealmObjectBase.getChanges<RemappedClass>(this);

  @override
  RemappedClass freeze() => RealmObjectBase.freezeObject<RemappedClass>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RemappedClass._);
    return const SchemaObject(
        ObjectType.realmObject, RemappedClass, 'myRemappedClass', [
      SchemaProperty('remappedProperty', RealmPropertyType.string,
          mapTo: 'primitive_property'),
      SchemaProperty('listProperty', RealmPropertyType.object,
          mapTo: 'list-with-dashes',
          linkTarget: 'myRemappedClass',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Task extends _Task with RealmEntity, RealmObjectBase, RealmObject {
  Task(
    ObjectId id,
  ) {
    RealmObjectBase.set(this, '_id', id);
  }

  Task._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Stream<RealmObjectChanges<Task>> get changes =>
      RealmObjectBase.getChanges<Task>(this);

  @override
  Task freeze() => RealmObjectBase.freezeObject<Task>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Task._);
    return const SchemaObject(ObjectType.realmObject, Task, 'Task', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}

class Product extends _Product with RealmEntity, RealmObjectBase, RealmObject {
  Product(
    ObjectId id,
    String name,
  ) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'stringQueryField', name);
  }

  Product._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name =>
      RealmObjectBase.get<String>(this, 'stringQueryField') as String;
  @override
  set name(String value) =>
      RealmObjectBase.set(this, 'stringQueryField', value);

  @override
  Stream<RealmObjectChanges<Product>> get changes =>
      RealmObjectBase.getChanges<Product>(this);

  @override
  Product freeze() => RealmObjectBase.freezeObject<Product>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Product._);
    return const SchemaObject(ObjectType.realmObject, Product, 'Product', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string,
          mapTo: 'stringQueryField'),
    ]);
  }
}

class Schedule extends _Schedule
    with RealmEntity, RealmObjectBase, RealmObject {
  Schedule(
    ObjectId id, {
    Iterable<Task> tasks = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set<RealmList<Task>>(this, 'tasks', RealmList<Task>(tasks));
  }

  Schedule._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<Task> get tasks =>
      RealmObjectBase.get<Task>(this, 'tasks') as RealmList<Task>;
  @override
  set tasks(covariant RealmList<Task> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Schedule>> get changes =>
      RealmObjectBase.getChanges<Schedule>(this);

  @override
  Schedule freeze() => RealmObjectBase.freezeObject<Schedule>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Schedule._);
    return const SchemaObject(ObjectType.realmObject, Schedule, 'Schedule', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('tasks', RealmPropertyType.object,
          linkTarget: 'Task', collectionType: RealmCollectionType.list),
    ]);
  }
}

class AllTypes extends _AllTypes
    with RealmEntity, RealmObjectBase, RealmObject {
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
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
  }

  AllTypes._();

  @override
  String get stringProp =>
      RealmObjectBase.get<String>(this, 'stringProp') as String;
  @override
  set stringProp(String value) =>
      RealmObjectBase.set(this, 'stringProp', value);

  @override
  bool get boolProp => RealmObjectBase.get<bool>(this, 'boolProp') as bool;
  @override
  set boolProp(bool value) => RealmObjectBase.set(this, 'boolProp', value);

  @override
  DateTime get dateProp =>
      RealmObjectBase.get<DateTime>(this, 'dateProp') as DateTime;
  @override
  set dateProp(DateTime value) => RealmObjectBase.set(this, 'dateProp', value);

  @override
  double get doubleProp =>
      RealmObjectBase.get<double>(this, 'doubleProp') as double;
  @override
  set doubleProp(double value) =>
      RealmObjectBase.set(this, 'doubleProp', value);

  @override
  ObjectId get objectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdProp') as ObjectId;
  @override
  set objectIdProp(ObjectId value) =>
      RealmObjectBase.set(this, 'objectIdProp', value);

  @override
  Uuid get uuidProp => RealmObjectBase.get<Uuid>(this, 'uuidProp') as Uuid;
  @override
  set uuidProp(Uuid value) => RealmObjectBase.set(this, 'uuidProp', value);

  @override
  int get intProp => RealmObjectBase.get<int>(this, 'intProp') as int;
  @override
  set intProp(int value) => RealmObjectBase.set(this, 'intProp', value);

  @override
  String? get nullableStringProp =>
      RealmObjectBase.get<String>(this, 'nullableStringProp') as String?;
  @override
  set nullableStringProp(String? value) =>
      RealmObjectBase.set(this, 'nullableStringProp', value);

  @override
  bool? get nullableBoolProp =>
      RealmObjectBase.get<bool>(this, 'nullableBoolProp') as bool?;
  @override
  set nullableBoolProp(bool? value) =>
      RealmObjectBase.set(this, 'nullableBoolProp', value);

  @override
  DateTime? get nullableDateProp =>
      RealmObjectBase.get<DateTime>(this, 'nullableDateProp') as DateTime?;
  @override
  set nullableDateProp(DateTime? value) =>
      RealmObjectBase.set(this, 'nullableDateProp', value);

  @override
  double? get nullableDoubleProp =>
      RealmObjectBase.get<double>(this, 'nullableDoubleProp') as double?;
  @override
  set nullableDoubleProp(double? value) =>
      RealmObjectBase.set(this, 'nullableDoubleProp', value);

  @override
  ObjectId? get nullableObjectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'nullableObjectIdProp') as ObjectId?;
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      RealmObjectBase.set(this, 'nullableObjectIdProp', value);

  @override
  Uuid? get nullableUuidProp =>
      RealmObjectBase.get<Uuid>(this, 'nullableUuidProp') as Uuid?;
  @override
  set nullableUuidProp(Uuid? value) =>
      RealmObjectBase.set(this, 'nullableUuidProp', value);

  @override
  int? get nullableIntProp =>
      RealmObjectBase.get<int>(this, 'nullableIntProp') as int?;
  @override
  set nullableIntProp(int? value) =>
      RealmObjectBase.set(this, 'nullableIntProp', value);

  @override
  Stream<RealmObjectChanges<AllTypes>> get changes =>
      RealmObjectBase.getChanges<AllTypes>(this);

  @override
  AllTypes freeze() => RealmObjectBase.freezeObject<AllTypes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AllTypes._);
    return const SchemaObject(ObjectType.realmObject, AllTypes, 'AllTypes', [
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

class LinksClass extends _LinksClass
    with RealmEntity, RealmObjectBase, RealmObject {
  LinksClass(
    Uuid id, {
    LinksClass? link,
    Iterable<LinksClass> list = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'link', link);
    RealmObjectBase.set<RealmList<LinksClass>>(
        this, 'list', RealmList<LinksClass>(list));
  }

  LinksClass._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  LinksClass? get link =>
      RealmObjectBase.get<LinksClass>(this, 'link') as LinksClass?;
  @override
  set link(covariant LinksClass? value) =>
      RealmObjectBase.set(this, 'link', value);

  @override
  RealmList<LinksClass> get list =>
      RealmObjectBase.get<LinksClass>(this, 'list') as RealmList<LinksClass>;
  @override
  set list(covariant RealmList<LinksClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<LinksClass>> get changes =>
      RealmObjectBase.getChanges<LinksClass>(this);

  @override
  LinksClass freeze() => RealmObjectBase.freezeObject<LinksClass>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(LinksClass._);
    return const SchemaObject(
        ObjectType.realmObject, LinksClass, 'LinksClass', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('link', RealmPropertyType.object,
          optional: true, linkTarget: 'LinksClass'),
      SchemaProperty('list', RealmPropertyType.object,
          linkTarget: 'LinksClass', collectionType: RealmCollectionType.list),
    ]);
  }
}

class AllCollections extends _AllCollections
    with RealmEntity, RealmObjectBase, RealmObject {
  AllCollections({
    Iterable<String> strings = const [],
    Iterable<bool> bools = const [],
    Iterable<DateTime> dates = const [],
    Iterable<double> doubles = const [],
    Iterable<ObjectId> objectIds = const [],
    Iterable<Uuid> uuids = const [],
    Iterable<int> ints = const [],
    Iterable<String?> nullableStrings = const [],
    Iterable<bool?> nullableBools = const [],
    Iterable<DateTime?> nullableDates = const [],
    Iterable<double?> nullableDoubles = const [],
    Iterable<ObjectId?> nullableObjectIds = const [],
    Iterable<Uuid?> nullableUuids = const [],
    Iterable<int?> nullableInts = const [],
  }) {
    RealmObjectBase.set<RealmList<String>>(
        this, 'strings', RealmList<String>(strings));
    RealmObjectBase.set<RealmList<bool>>(this, 'bools', RealmList<bool>(bools));
    RealmObjectBase.set<RealmList<DateTime>>(
        this, 'dates', RealmList<DateTime>(dates));
    RealmObjectBase.set<RealmList<double>>(
        this, 'doubles', RealmList<double>(doubles));
    RealmObjectBase.set<RealmList<ObjectId>>(
        this, 'objectIds', RealmList<ObjectId>(objectIds));
    RealmObjectBase.set<RealmList<Uuid>>(this, 'uuids', RealmList<Uuid>(uuids));
    RealmObjectBase.set<RealmList<int>>(this, 'ints', RealmList<int>(ints));
    RealmObjectBase.set<RealmList<String?>>(
        this, 'nullableStrings', RealmList<String?>(nullableStrings));
    RealmObjectBase.set<RealmList<bool?>>(
        this, 'nullableBools', RealmList<bool?>(nullableBools));
    RealmObjectBase.set<RealmList<DateTime?>>(
        this, 'nullableDates', RealmList<DateTime?>(nullableDates));
    RealmObjectBase.set<RealmList<double?>>(
        this, 'nullableDoubles', RealmList<double?>(nullableDoubles));
    RealmObjectBase.set<RealmList<ObjectId?>>(
        this, 'nullableObjectIds', RealmList<ObjectId?>(nullableObjectIds));
    RealmObjectBase.set<RealmList<Uuid?>>(
        this, 'nullableUuids', RealmList<Uuid?>(nullableUuids));
    RealmObjectBase.set<RealmList<int?>>(
        this, 'nullableInts', RealmList<int?>(nullableInts));
  }

  AllCollections._();

  @override
  RealmList<String> get strings =>
      RealmObjectBase.get<String>(this, 'strings') as RealmList<String>;
  @override
  set strings(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool> get bools =>
      RealmObjectBase.get<bool>(this, 'bools') as RealmList<bool>;
  @override
  set bools(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime> get dates =>
      RealmObjectBase.get<DateTime>(this, 'dates') as RealmList<DateTime>;
  @override
  set dates(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double> get doubles =>
      RealmObjectBase.get<double>(this, 'doubles') as RealmList<double>;
  @override
  set doubles(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId> get objectIds =>
      RealmObjectBase.get<ObjectId>(this, 'objectIds') as RealmList<ObjectId>;
  @override
  set objectIds(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid> get uuids =>
      RealmObjectBase.get<Uuid>(this, 'uuids') as RealmList<Uuid>;
  @override
  set uuids(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get ints =>
      RealmObjectBase.get<int>(this, 'ints') as RealmList<int>;
  @override
  set ints(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmList<String?> get nullableStrings =>
      RealmObjectBase.get<String?>(this, 'nullableStrings')
          as RealmList<String?>;
  @override
  set nullableStrings(covariant RealmList<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool?> get nullableBools =>
      RealmObjectBase.get<bool?>(this, 'nullableBools') as RealmList<bool?>;
  @override
  set nullableBools(covariant RealmList<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime?> get nullableDates =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDates')
          as RealmList<DateTime?>;
  @override
  set nullableDates(covariant RealmList<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double?> get nullableDoubles =>
      RealmObjectBase.get<double?>(this, 'nullableDoubles')
          as RealmList<double?>;
  @override
  set nullableDoubles(covariant RealmList<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId?> get nullableObjectIds =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIds')
          as RealmList<ObjectId?>;
  @override
  set nullableObjectIds(covariant RealmList<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid?> get nullableUuids =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuids') as RealmList<Uuid?>;
  @override
  set nullableUuids(covariant RealmList<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int?> get nullableInts =>
      RealmObjectBase.get<int?>(this, 'nullableInts') as RealmList<int?>;
  @override
  set nullableInts(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllCollections>> get changes =>
      RealmObjectBase.getChanges<AllCollections>(this);

  @override
  AllCollections freeze() => RealmObjectBase.freezeObject<AllCollections>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AllCollections._);
    return const SchemaObject(
        ObjectType.realmObject, AllCollections, 'AllCollections', [
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
      SchemaProperty('nullableStrings', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableBools', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDates', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDoubles', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableObjectIds', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableUuids', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableInts', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.list),
    ]);
  }
}

class NullableTypes extends _NullableTypes
    with RealmEntity, RealmObjectBase, RealmObject {
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
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
  }

  NullableTypes._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get differentiator =>
      RealmObjectBase.get<ObjectId>(this, 'differentiator') as ObjectId;
  @override
  set differentiator(ObjectId value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  String? get stringProp =>
      RealmObjectBase.get<String>(this, 'stringProp') as String?;
  @override
  set stringProp(String? value) =>
      RealmObjectBase.set(this, 'stringProp', value);

  @override
  bool? get boolProp => RealmObjectBase.get<bool>(this, 'boolProp') as bool?;
  @override
  set boolProp(bool? value) => RealmObjectBase.set(this, 'boolProp', value);

  @override
  DateTime? get dateProp =>
      RealmObjectBase.get<DateTime>(this, 'dateProp') as DateTime?;
  @override
  set dateProp(DateTime? value) => RealmObjectBase.set(this, 'dateProp', value);

  @override
  double? get doubleProp =>
      RealmObjectBase.get<double>(this, 'doubleProp') as double?;
  @override
  set doubleProp(double? value) =>
      RealmObjectBase.set(this, 'doubleProp', value);

  @override
  ObjectId? get objectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdProp') as ObjectId?;
  @override
  set objectIdProp(ObjectId? value) =>
      RealmObjectBase.set(this, 'objectIdProp', value);

  @override
  Uuid? get uuidProp => RealmObjectBase.get<Uuid>(this, 'uuidProp') as Uuid?;
  @override
  set uuidProp(Uuid? value) => RealmObjectBase.set(this, 'uuidProp', value);

  @override
  int? get intProp => RealmObjectBase.get<int>(this, 'intProp') as int?;
  @override
  set intProp(int? value) => RealmObjectBase.set(this, 'intProp', value);

  @override
  Stream<RealmObjectChanges<NullableTypes>> get changes =>
      RealmObjectBase.getChanges<NullableTypes>(this);

  @override
  NullableTypes freeze() => RealmObjectBase.freezeObject<NullableTypes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NullableTypes._);
    return const SchemaObject(
        ObjectType.realmObject, NullableTypes, 'NullableTypes', [
      SchemaProperty('id', RealmPropertyType.objectid,
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

class Event extends _Event with RealmEntity, RealmObjectBase, RealmObject {
  Event(
    ObjectId id, {
    String? name,
    bool? isCompleted,
    int? durationInMinutes,
    String? assignedTo,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'stringQueryField', name);
    RealmObjectBase.set(this, 'boolQueryField', isCompleted);
    RealmObjectBase.set(this, 'intQueryField', durationInMinutes);
    RealmObjectBase.set(this, 'assignedTo', assignedTo);
  }

  Event._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get name =>
      RealmObjectBase.get<String>(this, 'stringQueryField') as String?;
  @override
  set name(String? value) =>
      RealmObjectBase.set(this, 'stringQueryField', value);

  @override
  bool? get isCompleted =>
      RealmObjectBase.get<bool>(this, 'boolQueryField') as bool?;
  @override
  set isCompleted(bool? value) =>
      RealmObjectBase.set(this, 'boolQueryField', value);

  @override
  int? get durationInMinutes =>
      RealmObjectBase.get<int>(this, 'intQueryField') as int?;
  @override
  set durationInMinutes(int? value) =>
      RealmObjectBase.set(this, 'intQueryField', value);

  @override
  String? get assignedTo =>
      RealmObjectBase.get<String>(this, 'assignedTo') as String?;
  @override
  set assignedTo(String? value) =>
      RealmObjectBase.set(this, 'assignedTo', value);

  @override
  Stream<RealmObjectChanges<Event>> get changes =>
      RealmObjectBase.getChanges<Event>(this);

  @override
  Event freeze() => RealmObjectBase.freezeObject<Event>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Event._);
    return const SchemaObject(ObjectType.realmObject, Event, 'Event', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string,
          mapTo: 'stringQueryField', optional: true),
      SchemaProperty('isCompleted', RealmPropertyType.bool,
          mapTo: 'boolQueryField', optional: true),
      SchemaProperty('durationInMinutes', RealmPropertyType.int,
          mapTo: 'intQueryField', optional: true),
      SchemaProperty('assignedTo', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Party extends _Party with RealmEntity, RealmObjectBase, RealmObject {
  Party(
    int year, {
    Friend? host,
    Party? previous,
    Iterable<Friend> guests = const [],
  }) {
    RealmObjectBase.set(this, 'host', host);
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'previous', previous);
    RealmObjectBase.set<RealmList<Friend>>(
        this, 'guests', RealmList<Friend>(guests));
  }

  Party._();

  @override
  Friend? get host => RealmObjectBase.get<Friend>(this, 'host') as Friend?;
  @override
  set host(covariant Friend? value) => RealmObjectBase.set(this, 'host', value);

  @override
  int get year => RealmObjectBase.get<int>(this, 'year') as int;
  @override
  set year(int value) => RealmObjectBase.set(this, 'year', value);

  @override
  RealmList<Friend> get guests =>
      RealmObjectBase.get<Friend>(this, 'guests') as RealmList<Friend>;
  @override
  set guests(covariant RealmList<Friend> value) =>
      throw RealmUnsupportedSetError();

  @override
  Party? get previous => RealmObjectBase.get<Party>(this, 'previous') as Party?;
  @override
  set previous(covariant Party? value) =>
      RealmObjectBase.set(this, 'previous', value);

  @override
  Stream<RealmObjectChanges<Party>> get changes =>
      RealmObjectBase.getChanges<Party>(this);

  @override
  Party freeze() => RealmObjectBase.freezeObject<Party>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Party._);
    return const SchemaObject(ObjectType.realmObject, Party, 'Party', [
      SchemaProperty('host', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
      SchemaProperty('year', RealmPropertyType.int),
      SchemaProperty('guests', RealmPropertyType.object,
          linkTarget: 'Friend', collectionType: RealmCollectionType.list),
      SchemaProperty('previous', RealmPropertyType.object,
          optional: true, linkTarget: 'Party'),
    ]);
  }
}

class Friend extends _Friend with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Friend(
    String name, {
    int age = 42,
    Friend? bestFriend,
    Iterable<Friend> friends = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Friend>({
        'age': 42,
      });
    }
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'age', age);
    RealmObjectBase.set(this, 'bestFriend', bestFriend);
    RealmObjectBase.set<RealmList<Friend>>(
        this, 'friends', RealmList<Friend>(friends));
  }

  Friend._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get age => RealmObjectBase.get<int>(this, 'age') as int;
  @override
  set age(int value) => RealmObjectBase.set(this, 'age', value);

  @override
  Friend? get bestFriend =>
      RealmObjectBase.get<Friend>(this, 'bestFriend') as Friend?;
  @override
  set bestFriend(covariant Friend? value) =>
      RealmObjectBase.set(this, 'bestFriend', value);

  @override
  RealmList<Friend> get friends =>
      RealmObjectBase.get<Friend>(this, 'friends') as RealmList<Friend>;
  @override
  set friends(covariant RealmList<Friend> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Friend>> get changes =>
      RealmObjectBase.getChanges<Friend>(this);

  @override
  Friend freeze() => RealmObjectBase.freezeObject<Friend>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Friend._);
    return const SchemaObject(ObjectType.realmObject, Friend, 'Friend', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int),
      SchemaProperty('bestFriend', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
      SchemaProperty('friends', RealmPropertyType.object,
          linkTarget: 'Friend', collectionType: RealmCollectionType.list),
    ]);
  }
}

class When extends _When with RealmEntity, RealmObjectBase, RealmObject {
  When(
    DateTime dateTimeUtc,
    String locationName,
  ) {
    RealmObjectBase.set(this, 'dateTimeUtc', dateTimeUtc);
    RealmObjectBase.set(this, 'locationName', locationName);
  }

  When._();

  @override
  DateTime get dateTimeUtc =>
      RealmObjectBase.get<DateTime>(this, 'dateTimeUtc') as DateTime;
  @override
  set dateTimeUtc(DateTime value) =>
      RealmObjectBase.set(this, 'dateTimeUtc', value);

  @override
  String get locationName =>
      RealmObjectBase.get<String>(this, 'locationName') as String;
  @override
  set locationName(String value) =>
      RealmObjectBase.set(this, 'locationName', value);

  @override
  Stream<RealmObjectChanges<When>> get changes =>
      RealmObjectBase.getChanges<When>(this);

  @override
  When freeze() => RealmObjectBase.freezeObject<When>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(When._);
    return const SchemaObject(ObjectType.realmObject, When, 'When', [
      SchemaProperty('dateTimeUtc', RealmPropertyType.timestamp),
      SchemaProperty('locationName', RealmPropertyType.string),
    ]);
  }
}

class Player extends _Player with RealmEntity, RealmObjectBase, RealmObject {
  Player(
    String name, {
    Game? game,
    Iterable<int?> scoresByRound = const [],
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'game', game);
    RealmObjectBase.set<RealmList<int?>>(
        this, 'scoresByRound', RealmList<int?>(scoresByRound));
  }

  Player._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Game? get game => RealmObjectBase.get<Game>(this, 'game') as Game?;
  @override
  set game(covariant Game? value) => RealmObjectBase.set(this, 'game', value);

  @override
  RealmList<int?> get scoresByRound =>
      RealmObjectBase.get<int?>(this, 'scoresByRound') as RealmList<int?>;
  @override
  set scoresByRound(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Player>> get changes =>
      RealmObjectBase.getChanges<Player>(this);

  @override
  Player freeze() => RealmObjectBase.freezeObject<Player>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Player._);
    return const SchemaObject(ObjectType.realmObject, Player, 'Player', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('game', RealmPropertyType.object,
          optional: true, linkTarget: 'Game'),
      SchemaProperty('scoresByRound', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.list),
    ]);
  }
}

class Game extends _Game with RealmEntity, RealmObjectBase, RealmObject {
  Game({
    Iterable<Player> winnerByRound = const [],
  }) {
    RealmObjectBase.set<RealmList<Player>>(
        this, 'winnerByRound', RealmList<Player>(winnerByRound));
  }

  Game._();

  @override
  RealmList<Player> get winnerByRound =>
      RealmObjectBase.get<Player>(this, 'winnerByRound') as RealmList<Player>;
  @override
  set winnerByRound(covariant RealmList<Player> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Game>> get changes =>
      RealmObjectBase.getChanges<Game>(this);

  @override
  Game freeze() => RealmObjectBase.freezeObject<Game>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Game._);
    return const SchemaObject(ObjectType.realmObject, Game, 'Game', [
      SchemaProperty('winnerByRound', RealmPropertyType.object,
          linkTarget: 'Player', collectionType: RealmCollectionType.list),
    ]);
  }
}

class AllTypesEmbedded extends _AllTypesEmbedded
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  AllTypesEmbedded(
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
    Iterable<String> strings = const [],
    Iterable<bool> bools = const [],
    Iterable<DateTime> dates = const [],
    Iterable<double> doubles = const [],
    Iterable<ObjectId> objectIds = const [],
    Iterable<Uuid> uuids = const [],
    Iterable<int> ints = const [],
  }) {
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
    RealmObjectBase.set<RealmList<String>>(
        this, 'strings', RealmList<String>(strings));
    RealmObjectBase.set<RealmList<bool>>(this, 'bools', RealmList<bool>(bools));
    RealmObjectBase.set<RealmList<DateTime>>(
        this, 'dates', RealmList<DateTime>(dates));
    RealmObjectBase.set<RealmList<double>>(
        this, 'doubles', RealmList<double>(doubles));
    RealmObjectBase.set<RealmList<ObjectId>>(
        this, 'objectIds', RealmList<ObjectId>(objectIds));
    RealmObjectBase.set<RealmList<Uuid>>(this, 'uuids', RealmList<Uuid>(uuids));
    RealmObjectBase.set<RealmList<int>>(this, 'ints', RealmList<int>(ints));
  }

  AllTypesEmbedded._();

  @override
  String get stringProp =>
      RealmObjectBase.get<String>(this, 'stringProp') as String;
  @override
  set stringProp(String value) =>
      RealmObjectBase.set(this, 'stringProp', value);

  @override
  bool get boolProp => RealmObjectBase.get<bool>(this, 'boolProp') as bool;
  @override
  set boolProp(bool value) => RealmObjectBase.set(this, 'boolProp', value);

  @override
  DateTime get dateProp =>
      RealmObjectBase.get<DateTime>(this, 'dateProp') as DateTime;
  @override
  set dateProp(DateTime value) => RealmObjectBase.set(this, 'dateProp', value);

  @override
  double get doubleProp =>
      RealmObjectBase.get<double>(this, 'doubleProp') as double;
  @override
  set doubleProp(double value) =>
      RealmObjectBase.set(this, 'doubleProp', value);

  @override
  ObjectId get objectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdProp') as ObjectId;
  @override
  set objectIdProp(ObjectId value) =>
      RealmObjectBase.set(this, 'objectIdProp', value);

  @override
  Uuid get uuidProp => RealmObjectBase.get<Uuid>(this, 'uuidProp') as Uuid;
  @override
  set uuidProp(Uuid value) => RealmObjectBase.set(this, 'uuidProp', value);

  @override
  int get intProp => RealmObjectBase.get<int>(this, 'intProp') as int;
  @override
  set intProp(int value) => RealmObjectBase.set(this, 'intProp', value);

  @override
  String? get nullableStringProp =>
      RealmObjectBase.get<String>(this, 'nullableStringProp') as String?;
  @override
  set nullableStringProp(String? value) =>
      RealmObjectBase.set(this, 'nullableStringProp', value);

  @override
  bool? get nullableBoolProp =>
      RealmObjectBase.get<bool>(this, 'nullableBoolProp') as bool?;
  @override
  set nullableBoolProp(bool? value) =>
      RealmObjectBase.set(this, 'nullableBoolProp', value);

  @override
  DateTime? get nullableDateProp =>
      RealmObjectBase.get<DateTime>(this, 'nullableDateProp') as DateTime?;
  @override
  set nullableDateProp(DateTime? value) =>
      RealmObjectBase.set(this, 'nullableDateProp', value);

  @override
  double? get nullableDoubleProp =>
      RealmObjectBase.get<double>(this, 'nullableDoubleProp') as double?;
  @override
  set nullableDoubleProp(double? value) =>
      RealmObjectBase.set(this, 'nullableDoubleProp', value);

  @override
  ObjectId? get nullableObjectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'nullableObjectIdProp') as ObjectId?;
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      RealmObjectBase.set(this, 'nullableObjectIdProp', value);

  @override
  Uuid? get nullableUuidProp =>
      RealmObjectBase.get<Uuid>(this, 'nullableUuidProp') as Uuid?;
  @override
  set nullableUuidProp(Uuid? value) =>
      RealmObjectBase.set(this, 'nullableUuidProp', value);

  @override
  int? get nullableIntProp =>
      RealmObjectBase.get<int>(this, 'nullableIntProp') as int?;
  @override
  set nullableIntProp(int? value) =>
      RealmObjectBase.set(this, 'nullableIntProp', value);

  @override
  RealmList<String> get strings =>
      RealmObjectBase.get<String>(this, 'strings') as RealmList<String>;
  @override
  set strings(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool> get bools =>
      RealmObjectBase.get<bool>(this, 'bools') as RealmList<bool>;
  @override
  set bools(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime> get dates =>
      RealmObjectBase.get<DateTime>(this, 'dates') as RealmList<DateTime>;
  @override
  set dates(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double> get doubles =>
      RealmObjectBase.get<double>(this, 'doubles') as RealmList<double>;
  @override
  set doubles(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId> get objectIds =>
      RealmObjectBase.get<ObjectId>(this, 'objectIds') as RealmList<ObjectId>;
  @override
  set objectIds(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid> get uuids =>
      RealmObjectBase.get<Uuid>(this, 'uuids') as RealmList<Uuid>;
  @override
  set uuids(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get ints =>
      RealmObjectBase.get<int>(this, 'ints') as RealmList<int>;
  @override
  set ints(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllTypesEmbedded>> get changes =>
      RealmObjectBase.getChanges<AllTypesEmbedded>(this);

  @override
  AllTypesEmbedded freeze() =>
      RealmObjectBase.freezeObject<AllTypesEmbedded>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AllTypesEmbedded._);
    return const SchemaObject(
        ObjectType.embeddedObject, AllTypesEmbedded, 'AllTypesEmbedded', [
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

class ObjectWithEmbedded extends _ObjectWithEmbedded
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithEmbedded(
    String id, {
    Uuid? differentiator,
    AllTypesEmbedded? singleObject,
    RecursiveEmbedded1? recursiveObject,
    Iterable<AllTypesEmbedded> list = const [],
    Iterable<RecursiveEmbedded1> recursiveList = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'singleObject', singleObject);
    RealmObjectBase.set(this, 'recursiveObject', recursiveObject);
    RealmObjectBase.set<RealmList<AllTypesEmbedded>>(
        this, 'list', RealmList<AllTypesEmbedded>(list));
    RealmObjectBase.set<RealmList<RecursiveEmbedded1>>(
        this, 'recursiveList', RealmList<RecursiveEmbedded1>(recursiveList));
  }

  ObjectWithEmbedded._();

  @override
  String get id => RealmObjectBase.get<String>(this, '_id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, '_id', value);

  @override
  Uuid? get differentiator =>
      RealmObjectBase.get<Uuid>(this, 'differentiator') as Uuid?;
  @override
  set differentiator(Uuid? value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  AllTypesEmbedded? get singleObject =>
      RealmObjectBase.get<AllTypesEmbedded>(this, 'singleObject')
          as AllTypesEmbedded?;
  @override
  set singleObject(covariant AllTypesEmbedded? value) =>
      RealmObjectBase.set(this, 'singleObject', value);

  @override
  RealmList<AllTypesEmbedded> get list =>
      RealmObjectBase.get<AllTypesEmbedded>(this, 'list')
          as RealmList<AllTypesEmbedded>;
  @override
  set list(covariant RealmList<AllTypesEmbedded> value) =>
      throw RealmUnsupportedSetError();

  @override
  RecursiveEmbedded1? get recursiveObject =>
      RealmObjectBase.get<RecursiveEmbedded1>(this, 'recursiveObject')
          as RecursiveEmbedded1?;
  @override
  set recursiveObject(covariant RecursiveEmbedded1? value) =>
      RealmObjectBase.set(this, 'recursiveObject', value);

  @override
  RealmList<RecursiveEmbedded1> get recursiveList =>
      RealmObjectBase.get<RecursiveEmbedded1>(this, 'recursiveList')
          as RealmList<RecursiveEmbedded1>;
  @override
  set recursiveList(covariant RealmList<RecursiveEmbedded1> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<ObjectWithEmbedded>> get changes =>
      RealmObjectBase.getChanges<ObjectWithEmbedded>(this);

  @override
  ObjectWithEmbedded freeze() =>
      RealmObjectBase.freezeObject<ObjectWithEmbedded>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ObjectWithEmbedded._);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithEmbedded, 'ObjectWithEmbedded', [
      SchemaProperty('id', RealmPropertyType.string,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.uuid, optional: true),
      SchemaProperty('singleObject', RealmPropertyType.object,
          optional: true, linkTarget: 'AllTypesEmbedded'),
      SchemaProperty('list', RealmPropertyType.object,
          linkTarget: 'AllTypesEmbedded',
          collectionType: RealmCollectionType.list),
      SchemaProperty('recursiveObject', RealmPropertyType.object,
          optional: true, linkTarget: 'RecursiveEmbedded1'),
      SchemaProperty('recursiveList', RealmPropertyType.object,
          linkTarget: 'RecursiveEmbedded1',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class RecursiveEmbedded1 extends _RecursiveEmbedded1
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecursiveEmbedded1(
    String value, {
    RecursiveEmbedded2? child,
    ObjectWithEmbedded? realmObject,
    Iterable<RecursiveEmbedded2> children = const [],
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'child', child);
    RealmObjectBase.set(this, 'realmObject', realmObject);
    RealmObjectBase.set<RealmList<RecursiveEmbedded2>>(
        this, 'children', RealmList<RecursiveEmbedded2>(children));
  }

  RecursiveEmbedded1._();

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  RecursiveEmbedded2? get child =>
      RealmObjectBase.get<RecursiveEmbedded2>(this, 'child')
          as RecursiveEmbedded2?;
  @override
  set child(covariant RecursiveEmbedded2? value) =>
      RealmObjectBase.set(this, 'child', value);

  @override
  RealmList<RecursiveEmbedded2> get children =>
      RealmObjectBase.get<RecursiveEmbedded2>(this, 'children')
          as RealmList<RecursiveEmbedded2>;
  @override
  set children(covariant RealmList<RecursiveEmbedded2> value) =>
      throw RealmUnsupportedSetError();

  @override
  ObjectWithEmbedded? get realmObject =>
      RealmObjectBase.get<ObjectWithEmbedded>(this, 'realmObject')
          as ObjectWithEmbedded?;
  @override
  set realmObject(covariant ObjectWithEmbedded? value) =>
      RealmObjectBase.set(this, 'realmObject', value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded1>> get changes =>
      RealmObjectBase.getChanges<RecursiveEmbedded1>(this);

  @override
  RecursiveEmbedded1 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded1>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RecursiveEmbedded1._);
    return const SchemaObject(
        ObjectType.embeddedObject, RecursiveEmbedded1, 'RecursiveEmbedded1', [
      SchemaProperty('value', RealmPropertyType.string),
      SchemaProperty('child', RealmPropertyType.object,
          optional: true, linkTarget: 'RecursiveEmbedded2'),
      SchemaProperty('children', RealmPropertyType.object,
          linkTarget: 'RecursiveEmbedded2',
          collectionType: RealmCollectionType.list),
      SchemaProperty('realmObject', RealmPropertyType.object,
          optional: true, linkTarget: 'ObjectWithEmbedded'),
    ]);
  }
}

class RecursiveEmbedded2 extends _RecursiveEmbedded2
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecursiveEmbedded2(
    String value, {
    RecursiveEmbedded3? child,
    ObjectWithEmbedded? realmObject,
    Iterable<RecursiveEmbedded3> children = const [],
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'child', child);
    RealmObjectBase.set(this, 'realmObject', realmObject);
    RealmObjectBase.set<RealmList<RecursiveEmbedded3>>(
        this, 'children', RealmList<RecursiveEmbedded3>(children));
  }

  RecursiveEmbedded2._();

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  RecursiveEmbedded3? get child =>
      RealmObjectBase.get<RecursiveEmbedded3>(this, 'child')
          as RecursiveEmbedded3?;
  @override
  set child(covariant RecursiveEmbedded3? value) =>
      RealmObjectBase.set(this, 'child', value);

  @override
  RealmList<RecursiveEmbedded3> get children =>
      RealmObjectBase.get<RecursiveEmbedded3>(this, 'children')
          as RealmList<RecursiveEmbedded3>;
  @override
  set children(covariant RealmList<RecursiveEmbedded3> value) =>
      throw RealmUnsupportedSetError();

  @override
  ObjectWithEmbedded? get realmObject =>
      RealmObjectBase.get<ObjectWithEmbedded>(this, 'realmObject')
          as ObjectWithEmbedded?;
  @override
  set realmObject(covariant ObjectWithEmbedded? value) =>
      RealmObjectBase.set(this, 'realmObject', value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded2>> get changes =>
      RealmObjectBase.getChanges<RecursiveEmbedded2>(this);

  @override
  RecursiveEmbedded2 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded2>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RecursiveEmbedded2._);
    return const SchemaObject(
        ObjectType.embeddedObject, RecursiveEmbedded2, 'RecursiveEmbedded2', [
      SchemaProperty('value', RealmPropertyType.string),
      SchemaProperty('child', RealmPropertyType.object,
          optional: true, linkTarget: 'RecursiveEmbedded3'),
      SchemaProperty('children', RealmPropertyType.object,
          linkTarget: 'RecursiveEmbedded3',
          collectionType: RealmCollectionType.list),
      SchemaProperty('realmObject', RealmPropertyType.object,
          optional: true, linkTarget: 'ObjectWithEmbedded'),
    ]);
  }
}

class RecursiveEmbedded3 extends _RecursiveEmbedded3
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecursiveEmbedded3(
    String value,
  ) {
    RealmObjectBase.set(this, 'value', value);
  }

  RecursiveEmbedded3._();

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded3>> get changes =>
      RealmObjectBase.getChanges<RecursiveEmbedded3>(this);

  @override
  RecursiveEmbedded3 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded3>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RecursiveEmbedded3._);
    return const SchemaObject(
        ObjectType.embeddedObject, RecursiveEmbedded3, 'RecursiveEmbedded3', [
      SchemaProperty('value', RealmPropertyType.string),
    ]);
  }
}
