// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
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

class Foo extends _Foo with RealmEntity, RealmObjectBase, RealmObject {
  Foo(
    Uint8List requiredBinaryProp, {
    Uint8List? defaultValueBinaryProp,
    Uint8List? nullableBinaryProp,
  }) {
    RealmObjectBase.set(this, 'requiredBinaryProp', requiredBinaryProp);
    RealmObjectBase.set(
        this, 'defaultValueBinaryProp', defaultValueBinaryProp ?? Uint8List(8));
    RealmObjectBase.set(this, 'nullableBinaryProp', nullableBinaryProp);
  }

  Foo._();

  @override
  Uint8List get requiredBinaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'requiredBinaryProp') as Uint8List;
  @override
  set requiredBinaryProp(Uint8List value) =>
      RealmObjectBase.set(this, 'requiredBinaryProp', value);

  @override
  Uint8List get defaultValueBinaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'defaultValueBinaryProp')
          as Uint8List;
  @override
  set defaultValueBinaryProp(Uint8List value) =>
      RealmObjectBase.set(this, 'defaultValueBinaryProp', value);

  @override
  Uint8List? get nullableBinaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'nullableBinaryProp') as Uint8List?;
  @override
  set nullableBinaryProp(Uint8List? value) =>
      RealmObjectBase.set(this, 'nullableBinaryProp', value);

  @override
  Stream<RealmObjectChanges<Foo>> get changes =>
      RealmObjectBase.getChanges<Foo>(this);

  @override
  Foo freeze() => RealmObjectBase.freezeObject<Foo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Foo._);
    return const SchemaObject(ObjectType.realmObject, Foo, 'Foo', [
      SchemaProperty('requiredBinaryProp', RealmPropertyType.binary),
      SchemaProperty('defaultValueBinaryProp', RealmPropertyType.binary),
      SchemaProperty('nullableBinaryProp', RealmPropertyType.binary,
          optional: true),
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
    int intProp,
    Decimal128 decimalProp, {
    Uint8List? binaryProp,
    String? nullableStringProp,
    bool? nullableBoolProp,
    DateTime? nullableDateProp,
    double? nullableDoubleProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
    int? nullableIntProp,
    Decimal128? nullableDecimalProp,
    Uint8List? nullableBinaryProp,
  }) {
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'decimalProp', decimalProp);
    RealmObjectBase.set(this, 'binaryProp', binaryProp ?? Uint8List(16));
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
    RealmObjectBase.set(this, 'nullableDecimalProp', nullableDecimalProp);
    RealmObjectBase.set(this, 'nullableBinaryProp', nullableBinaryProp);
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
  Decimal128 get decimalProp =>
      RealmObjectBase.get<Decimal128>(this, 'decimalProp') as Decimal128;
  @override
  set decimalProp(Decimal128 value) =>
      RealmObjectBase.set(this, 'decimalProp', value);

  @override
  Uint8List get binaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'binaryProp') as Uint8List;
  @override
  set binaryProp(Uint8List value) =>
      RealmObjectBase.set(this, 'binaryProp', value);

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
  Decimal128? get nullableDecimalProp =>
      RealmObjectBase.get<Decimal128>(this, 'nullableDecimalProp')
          as Decimal128?;
  @override
  set nullableDecimalProp(Decimal128? value) =>
      RealmObjectBase.set(this, 'nullableDecimalProp', value);

  @override
  Uint8List? get nullableBinaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'nullableBinaryProp') as Uint8List?;
  @override
  set nullableBinaryProp(Uint8List? value) =>
      RealmObjectBase.set(this, 'nullableBinaryProp', value);

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
      SchemaProperty('decimalProp', RealmPropertyType.decimal128),
      SchemaProperty('binaryProp', RealmPropertyType.binary),
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
      SchemaProperty('nullableDecimalProp', RealmPropertyType.decimal128,
          optional: true),
      SchemaProperty('nullableBinaryProp', RealmPropertyType.binary,
          optional: true),
    ]);
  }
}

class LinksClass extends _LinksClass
    with RealmEntity, RealmObjectBase, RealmObject {
  LinksClass(
    Uuid id, {
    LinksClass? link,
    Iterable<LinksClass> list = const [],
    Set<LinksClass> set = const {},
    Map<String, LinksClass?> map = const {},
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'link', link);
    RealmObjectBase.set<RealmList<LinksClass>>(
        this, 'list', RealmList<LinksClass>(list));
    RealmObjectBase.set<RealmSet<LinksClass>>(
        this, 'set', RealmSet<LinksClass>(set));
    RealmObjectBase.set<RealmMap<LinksClass?>>(
        this, 'map', RealmMap<LinksClass?>(map));
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
  RealmSet<LinksClass> get set =>
      RealmObjectBase.get<LinksClass>(this, 'set') as RealmSet<LinksClass>;
  @override
  set set(covariant RealmSet<LinksClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<LinksClass?> get map =>
      RealmObjectBase.get<LinksClass?>(this, 'map') as RealmMap<LinksClass?>;
  @override
  set map(covariant RealmMap<LinksClass?> value) =>
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
      SchemaProperty('set', RealmPropertyType.object,
          linkTarget: 'LinksClass', collectionType: RealmCollectionType.set),
      SchemaProperty('map', RealmPropertyType.object,
          optional: true,
          linkTarget: 'LinksClass',
          collectionType: RealmCollectionType.map),
    ]);
  }
}

class AllCollections extends _AllCollections
    with RealmEntity, RealmObjectBase, RealmObject {
  AllCollections({
    Iterable<bool> boolList = const [],
    Iterable<DateTime> dateList = const [],
    Iterable<double> doubleList = const [],
    Iterable<ObjectId> objectIdList = const [],
    Iterable<Uuid> uuidList = const [],
    Iterable<int> intList = const [],
    Iterable<Decimal128> decimalList = const [],
    Iterable<String?> nullableStringList = const [],
    Iterable<bool?> nullableBoolList = const [],
    Iterable<DateTime?> nullableDateList = const [],
    Iterable<double?> nullableDoubleList = const [],
    Iterable<ObjectId?> nullableObjectIdList = const [],
    Iterable<Uuid?> nullableUuidList = const [],
    Iterable<int?> nullableIntList = const [],
    Iterable<String> stringList = const [],
    Iterable<Decimal128?> nullableDecimalList = const [],
    Set<String> stringSet = const {},
    Set<bool> boolSet = const {},
    Set<DateTime> dateSet = const {},
    Set<double> doubleSet = const {},
    Set<ObjectId> objectIdSet = const {},
    Set<int> intSet = const {},
    Set<DateTime?> nullableDateSet = const {},
    Set<int?> nullableIntSet = const {},
    Set<Uuid> uuidSet = const {},
    Set<Decimal128> decimalSet = const {},
    Set<String?> nullableStringSet = const {},
    Set<bool?> nullableBoolSet = const {},
    Set<double?> nullableDoubleSet = const {},
    Set<ObjectId?> nullableObjectIdSet = const {},
    Set<Uuid?> nullableUuidSet = const {},
    Set<Decimal128?> nullableDecimalSet = const {},
    Map<String, String> stringMap = const {},
    Map<String, DateTime> dateMap = const {},
    Map<String, int> intMap = const {},
    Map<String, String?> nullableStringMap = const {},
    Map<String, ObjectId?> nullableObjectIdMap = const {},
    Map<String, int?> nullableIntMap = const {},
    Map<String, bool> boolMap = const {},
    Map<String, double> doubleMap = const {},
    Map<String, Uuid> uuidMap = const {},
    Map<String, Decimal128> decimalMap = const {},
    Map<String, bool?> nullableBoolMap = const {},
    Map<String, double?> nullableDoubleMap = const {},
    Map<String, Uuid?> nullableUuidMap = const {},
    Map<String, Decimal128?> nullableDecimalMap = const {},
    Map<String, ObjectId> objectIdMap = const {},
    Map<String, DateTime?> nullableDateMap = const {},
  }) {
    RealmObjectBase.set<RealmList<bool>>(
        this, 'boolList', RealmList<bool>(boolList));
    RealmObjectBase.set<RealmList<DateTime>>(
        this, 'dateList', RealmList<DateTime>(dateList));
    RealmObjectBase.set<RealmList<double>>(
        this, 'doubleList', RealmList<double>(doubleList));
    RealmObjectBase.set<RealmList<ObjectId>>(
        this, 'objectIdList', RealmList<ObjectId>(objectIdList));
    RealmObjectBase.set<RealmList<Uuid>>(
        this, 'uuidList', RealmList<Uuid>(uuidList));
    RealmObjectBase.set<RealmList<int>>(
        this, 'intList', RealmList<int>(intList));
    RealmObjectBase.set<RealmList<Decimal128>>(
        this, 'decimalList', RealmList<Decimal128>(decimalList));
    RealmObjectBase.set<RealmList<String?>>(
        this, 'nullableStringList', RealmList<String?>(nullableStringList));
    RealmObjectBase.set<RealmList<bool?>>(
        this, 'nullableBoolList', RealmList<bool?>(nullableBoolList));
    RealmObjectBase.set<RealmList<DateTime?>>(
        this, 'nullableDateList', RealmList<DateTime?>(nullableDateList));
    RealmObjectBase.set<RealmList<double?>>(
        this, 'nullableDoubleList', RealmList<double?>(nullableDoubleList));
    RealmObjectBase.set<RealmList<ObjectId?>>(this, 'nullableObjectIdList',
        RealmList<ObjectId?>(nullableObjectIdList));
    RealmObjectBase.set<RealmList<Uuid?>>(
        this, 'nullableUuidList', RealmList<Uuid?>(nullableUuidList));
    RealmObjectBase.set<RealmList<int?>>(
        this, 'nullableIntList', RealmList<int?>(nullableIntList));
    RealmObjectBase.set<RealmList<String>>(
        this, 'stringList', RealmList<String>(stringList));
    RealmObjectBase.set<RealmList<Decimal128?>>(this, 'nullableDecimalList',
        RealmList<Decimal128?>(nullableDecimalList));
    RealmObjectBase.set<RealmSet<String>>(
        this, 'stringSet', RealmSet<String>(stringSet));
    RealmObjectBase.set<RealmSet<bool>>(
        this, 'boolSet', RealmSet<bool>(boolSet));
    RealmObjectBase.set<RealmSet<DateTime>>(
        this, 'dateSet', RealmSet<DateTime>(dateSet));
    RealmObjectBase.set<RealmSet<double>>(
        this, 'doubleSet', RealmSet<double>(doubleSet));
    RealmObjectBase.set<RealmSet<ObjectId>>(
        this, 'objectIdSet', RealmSet<ObjectId>(objectIdSet));
    RealmObjectBase.set<RealmSet<int>>(this, 'intSet', RealmSet<int>(intSet));
    RealmObjectBase.set<RealmSet<DateTime?>>(
        this, 'nullableDateSet', RealmSet<DateTime?>(nullableDateSet));
    RealmObjectBase.set<RealmSet<int?>>(
        this, 'nullableIntSet', RealmSet<int?>(nullableIntSet));
    RealmObjectBase.set<RealmSet<Uuid>>(
        this, 'uuidSet', RealmSet<Uuid>(uuidSet));
    RealmObjectBase.set<RealmSet<Decimal128>>(
        this, 'decimalSet', RealmSet<Decimal128>(decimalSet));
    RealmObjectBase.set<RealmSet<String?>>(
        this, 'nullableStringSet', RealmSet<String?>(nullableStringSet));
    RealmObjectBase.set<RealmSet<bool?>>(
        this, 'nullableBoolSet', RealmSet<bool?>(nullableBoolSet));
    RealmObjectBase.set<RealmSet<double?>>(
        this, 'nullableDoubleSet', RealmSet<double?>(nullableDoubleSet));
    RealmObjectBase.set<RealmSet<ObjectId?>>(
        this, 'nullableObjectIdSet', RealmSet<ObjectId?>(nullableObjectIdSet));
    RealmObjectBase.set<RealmSet<Uuid?>>(
        this, 'nullableUuidSet', RealmSet<Uuid?>(nullableUuidSet));
    RealmObjectBase.set<RealmSet<Decimal128?>>(
        this, 'nullableDecimalSet', RealmSet<Decimal128?>(nullableDecimalSet));
    RealmObjectBase.set<RealmMap<String>>(
        this, 'stringMap', RealmMap<String>(stringMap));
    RealmObjectBase.set<RealmMap<DateTime>>(
        this, 'dateMap', RealmMap<DateTime>(dateMap));
    RealmObjectBase.set<RealmMap<int>>(this, 'intMap', RealmMap<int>(intMap));
    RealmObjectBase.set<RealmMap<String?>>(
        this, 'nullableStringMap', RealmMap<String?>(nullableStringMap));
    RealmObjectBase.set<RealmMap<ObjectId?>>(
        this, 'nullableObjectIdMap', RealmMap<ObjectId?>(nullableObjectIdMap));
    RealmObjectBase.set<RealmMap<int?>>(
        this, 'nullableIntMap', RealmMap<int?>(nullableIntMap));
    RealmObjectBase.set<RealmMap<bool>>(
        this, 'boolMap', RealmMap<bool>(boolMap));
    RealmObjectBase.set<RealmMap<double>>(
        this, 'doubleMap', RealmMap<double>(doubleMap));
    RealmObjectBase.set<RealmMap<Uuid>>(
        this, 'uuidMap', RealmMap<Uuid>(uuidMap));
    RealmObjectBase.set<RealmMap<Decimal128>>(
        this, 'decimalMap', RealmMap<Decimal128>(decimalMap));
    RealmObjectBase.set<RealmMap<bool?>>(
        this, 'nullableBoolMap', RealmMap<bool?>(nullableBoolMap));
    RealmObjectBase.set<RealmMap<double?>>(
        this, 'nullableDoubleMap', RealmMap<double?>(nullableDoubleMap));
    RealmObjectBase.set<RealmMap<Uuid?>>(
        this, 'nullableUuidMap', RealmMap<Uuid?>(nullableUuidMap));
    RealmObjectBase.set<RealmMap<Decimal128?>>(
        this, 'nullableDecimalMap', RealmMap<Decimal128?>(nullableDecimalMap));
    RealmObjectBase.set<RealmMap<ObjectId>>(
        this, 'objectIdMap', RealmMap<ObjectId>(objectIdMap));
    RealmObjectBase.set<RealmMap<DateTime?>>(
        this, 'nullableDateMap', RealmMap<DateTime?>(nullableDateMap));
  }

  AllCollections._();

  @override
  RealmMap<String> get stringMap =>
      RealmObjectBase.get<String>(this, 'stringMap') as RealmMap<String>;
  @override
  set stringMap(covariant RealmMap<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool> get boolList =>
      RealmObjectBase.get<bool>(this, 'boolList') as RealmList<bool>;
  @override
  set boolList(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime> get dateList =>
      RealmObjectBase.get<DateTime>(this, 'dateList') as RealmList<DateTime>;
  @override
  set dateList(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double> get doubleList =>
      RealmObjectBase.get<double>(this, 'doubleList') as RealmList<double>;
  @override
  set doubleList(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId> get objectIdList =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdList')
          as RealmList<ObjectId>;
  @override
  set objectIdList(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid> get uuidList =>
      RealmObjectBase.get<Uuid>(this, 'uuidList') as RealmList<Uuid>;
  @override
  set uuidList(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get intList =>
      RealmObjectBase.get<int>(this, 'intList') as RealmList<int>;
  @override
  set intList(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Decimal128> get decimalList =>
      RealmObjectBase.get<Decimal128>(this, 'decimalList')
          as RealmList<Decimal128>;
  @override
  set decimalList(covariant RealmList<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String?> get nullableStringList =>
      RealmObjectBase.get<String?>(this, 'nullableStringList')
          as RealmList<String?>;
  @override
  set nullableStringList(covariant RealmList<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<bool?> get nullableBoolList =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolList') as RealmList<bool?>;
  @override
  set nullableBoolList(covariant RealmList<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<DateTime?> get nullableDateList =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateList')
          as RealmList<DateTime?>;
  @override
  set nullableDateList(covariant RealmList<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime> get dateMap =>
      RealmObjectBase.get<DateTime>(this, 'dateMap') as RealmMap<DateTime>;
  @override
  set dateMap(covariant RealmMap<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int> get intMap =>
      RealmObjectBase.get<int>(this, 'intMap') as RealmMap<int>;
  @override
  set intMap(covariant RealmMap<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmMap<String?> get nullableStringMap =>
      RealmObjectBase.get<String?>(this, 'nullableStringMap')
          as RealmMap<String?>;
  @override
  set nullableStringMap(covariant RealmMap<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId?> get nullableObjectIdMap =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdMap')
          as RealmMap<ObjectId?>;
  @override
  set nullableObjectIdMap(covariant RealmMap<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int?> get nullableIntMap =>
      RealmObjectBase.get<int?>(this, 'nullableIntMap') as RealmMap<int?>;
  @override
  set nullableIntMap(covariant RealmMap<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<String> get stringSet =>
      RealmObjectBase.get<String>(this, 'stringSet') as RealmSet<String>;
  @override
  set stringSet(covariant RealmSet<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<bool> get boolSet =>
      RealmObjectBase.get<bool>(this, 'boolSet') as RealmSet<bool>;
  @override
  set boolSet(covariant RealmSet<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime> get dateSet =>
      RealmObjectBase.get<DateTime>(this, 'dateSet') as RealmSet<DateTime>;
  @override
  set dateSet(covariant RealmSet<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<double> get doubleSet =>
      RealmObjectBase.get<double>(this, 'doubleSet') as RealmSet<double>;
  @override
  set doubleSet(covariant RealmSet<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId> get objectIdSet =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdSet') as RealmSet<ObjectId>;
  @override
  set objectIdSet(covariant RealmSet<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<bool> get boolMap =>
      RealmObjectBase.get<bool>(this, 'boolMap') as RealmMap<bool>;
  @override
  set boolMap(covariant RealmMap<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int> get intSet =>
      RealmObjectBase.get<int>(this, 'intSet') as RealmSet<int>;
  @override
  set intSet(covariant RealmSet<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmMap<double> get doubleMap =>
      RealmObjectBase.get<double>(this, 'doubleMap') as RealmMap<double>;
  @override
  set doubleMap(covariant RealmMap<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid> get uuidMap =>
      RealmObjectBase.get<Uuid>(this, 'uuidMap') as RealmMap<Uuid>;
  @override
  set uuidMap(covariant RealmMap<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128> get decimalMap =>
      RealmObjectBase.get<Decimal128>(this, 'decimalMap')
          as RealmMap<Decimal128>;
  @override
  set decimalMap(covariant RealmMap<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime?> get nullableDateSet =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateSet')
          as RealmSet<DateTime?>;
  @override
  set nullableDateSet(covariant RealmSet<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<bool?> get nullableBoolMap =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolMap') as RealmMap<bool?>;
  @override
  set nullableBoolMap(covariant RealmMap<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<double?> get nullableDoubleMap =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleMap')
          as RealmMap<double?>;
  @override
  set nullableDoubleMap(covariant RealmMap<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid?> get nullableUuidMap =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidMap') as RealmMap<Uuid?>;
  @override
  set nullableUuidMap(covariant RealmMap<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int?> get nullableIntSet =>
      RealmObjectBase.get<int?>(this, 'nullableIntSet') as RealmSet<int?>;
  @override
  set nullableIntSet(covariant RealmSet<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128?> get nullableDecimalMap =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalMap')
          as RealmMap<Decimal128?>;
  @override
  set nullableDecimalMap(covariant RealmMap<Decimal128?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId> get objectIdMap =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdMap') as RealmMap<ObjectId>;
  @override
  set objectIdMap(covariant RealmMap<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid> get uuidSet =>
      RealmObjectBase.get<Uuid>(this, 'uuidSet') as RealmSet<Uuid>;
  @override
  set uuidSet(covariant RealmSet<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<double?> get nullableDoubleList =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleList')
          as RealmList<double?>;
  @override
  set nullableDoubleList(covariant RealmList<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Decimal128> get decimalSet =>
      RealmObjectBase.get<Decimal128>(this, 'decimalSet')
          as RealmSet<Decimal128>;
  @override
  set decimalSet(covariant RealmSet<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId?> get nullableObjectIdList =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdList')
          as RealmList<ObjectId?>;
  @override
  set nullableObjectIdList(covariant RealmList<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<String?> get nullableStringSet =>
      RealmObjectBase.get<String?>(this, 'nullableStringSet')
          as RealmSet<String?>;
  @override
  set nullableStringSet(covariant RealmSet<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime?> get nullableDateMap =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateMap')
          as RealmMap<DateTime?>;
  @override
  set nullableDateMap(covariant RealmMap<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<bool?> get nullableBoolSet =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolSet') as RealmSet<bool?>;
  @override
  set nullableBoolSet(covariant RealmSet<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid?> get nullableUuidList =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidList') as RealmList<Uuid?>;
  @override
  set nullableUuidList(covariant RealmList<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<double?> get nullableDoubleSet =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleSet')
          as RealmSet<double?>;
  @override
  set nullableDoubleSet(covariant RealmSet<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int?> get nullableIntList =>
      RealmObjectBase.get<int?>(this, 'nullableIntList') as RealmList<int?>;
  @override
  set nullableIntList(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId?> get nullableObjectIdSet =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdSet')
          as RealmSet<ObjectId?>;
  @override
  set nullableObjectIdSet(covariant RealmSet<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get stringList =>
      RealmObjectBase.get<String>(this, 'stringList') as RealmList<String>;
  @override
  set stringList(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid?> get nullableUuidSet =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidSet') as RealmSet<Uuid?>;
  @override
  set nullableUuidSet(covariant RealmSet<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Decimal128?> get nullableDecimalList =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalList')
          as RealmList<Decimal128?>;
  @override
  set nullableDecimalList(covariant RealmList<Decimal128?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Decimal128?> get nullableDecimalSet =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalSet')
          as RealmSet<Decimal128?>;
  @override
  set nullableDecimalSet(covariant RealmSet<Decimal128?> value) =>
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
      SchemaProperty('stringMap', RealmPropertyType.string,
          collectionType: RealmCollectionType.map),
      SchemaProperty('boolList', RealmPropertyType.bool,
          collectionType: RealmCollectionType.list),
      SchemaProperty('dateList', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.list),
      SchemaProperty('doubleList', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
      SchemaProperty('objectIdList', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.list),
      SchemaProperty('uuidList', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.list),
      SchemaProperty('intList', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('decimalList', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.list),
      SchemaProperty('nullableStringList', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableBoolList', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDateList', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('dateMap', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.map),
      SchemaProperty('intMap', RealmPropertyType.int,
          collectionType: RealmCollectionType.map),
      SchemaProperty('nullableStringMap', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableObjectIdMap', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableIntMap', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('stringSet', RealmPropertyType.string,
          collectionType: RealmCollectionType.set),
      SchemaProperty('boolSet', RealmPropertyType.bool,
          collectionType: RealmCollectionType.set),
      SchemaProperty('dateSet', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.set),
      SchemaProperty('doubleSet', RealmPropertyType.double,
          collectionType: RealmCollectionType.set),
      SchemaProperty('objectIdSet', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.set),
      SchemaProperty('boolMap', RealmPropertyType.bool,
          collectionType: RealmCollectionType.map),
      SchemaProperty('intSet', RealmPropertyType.int,
          collectionType: RealmCollectionType.set),
      SchemaProperty('doubleMap', RealmPropertyType.double,
          collectionType: RealmCollectionType.map),
      SchemaProperty('uuidMap', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('decimalMap', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDateSet', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableBoolMap', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDoubleMap', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableUuidMap', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableIntSet', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDecimalMap', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('objectIdMap', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('uuidSet', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDoubleList', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('decimalSet', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.set),
      SchemaProperty('nullableObjectIdList', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableStringSet', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDateMap', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableBoolSet', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableUuidList', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDoubleSet', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableIntList', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableObjectIdSet', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('stringList', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('nullableUuidSet', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDecimalList', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDecimalSet', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.set),
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
    Decimal128? decimalProp,
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
    RealmObjectBase.set(this, 'decimalProp', decimalProp);
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
  Decimal128? get decimalProp =>
      RealmObjectBase.get<Decimal128>(this, 'decimalProp') as Decimal128?;
  @override
  set decimalProp(Decimal128? value) =>
      RealmObjectBase.set(this, 'decimalProp', value);

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
      SchemaProperty('decimalProp', RealmPropertyType.decimal128,
          optional: true),
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
    int intProp,
    Decimal128 decimalProp, {
    String? nullableStringProp,
    bool? nullableBoolProp,
    DateTime? nullableDateProp,
    double? nullableDoubleProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
    int? nullableIntProp,
    Decimal128? nullableDecimalProp,
    Iterable<String> strings = const [],
    Iterable<bool> bools = const [],
    Iterable<DateTime> dates = const [],
    Iterable<double> doubles = const [],
    Iterable<ObjectId> objectIds = const [],
    Iterable<Uuid> uuids = const [],
    Iterable<int> ints = const [],
    Iterable<Decimal128> decimals = const [],
  }) {
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'decimalProp', decimalProp);
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
    RealmObjectBase.set(this, 'nullableDecimalProp', nullableDecimalProp);
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
    RealmObjectBase.set<RealmList<Decimal128>>(
        this, 'decimals', RealmList<Decimal128>(decimals));
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
  Decimal128 get decimalProp =>
      RealmObjectBase.get<Decimal128>(this, 'decimalProp') as Decimal128;
  @override
  set decimalProp(Decimal128 value) =>
      RealmObjectBase.set(this, 'decimalProp', value);

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
  Decimal128? get nullableDecimalProp =>
      RealmObjectBase.get<Decimal128>(this, 'nullableDecimalProp')
          as Decimal128?;
  @override
  set nullableDecimalProp(Decimal128? value) =>
      RealmObjectBase.set(this, 'nullableDecimalProp', value);

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
  RealmList<Decimal128> get decimals =>
      RealmObjectBase.get<Decimal128>(this, 'decimals')
          as RealmList<Decimal128>;
  @override
  set decimals(covariant RealmList<Decimal128> value) =>
      throw RealmUnsupportedSetError();

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
      SchemaProperty('decimalProp', RealmPropertyType.decimal128),
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
      SchemaProperty('nullableDecimalProp', RealmPropertyType.decimal128,
          optional: true),
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
      SchemaProperty('decimals', RealmPropertyType.decimal128,
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

class ObjectWithDecimal extends _ObjectWithDecimal
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithDecimal(
    Decimal128 decimal, {
    Decimal128? nullableDecimal,
  }) {
    RealmObjectBase.set(this, 'decimal', decimal);
    RealmObjectBase.set(this, 'nullableDecimal', nullableDecimal);
  }

  ObjectWithDecimal._();

  @override
  Decimal128 get decimal =>
      RealmObjectBase.get<Decimal128>(this, 'decimal') as Decimal128;
  @override
  set decimal(Decimal128 value) => RealmObjectBase.set(this, 'decimal', value);

  @override
  Decimal128? get nullableDecimal =>
      RealmObjectBase.get<Decimal128>(this, 'nullableDecimal') as Decimal128?;
  @override
  set nullableDecimal(Decimal128? value) =>
      RealmObjectBase.set(this, 'nullableDecimal', value);

  @override
  Stream<RealmObjectChanges<ObjectWithDecimal>> get changes =>
      RealmObjectBase.getChanges<ObjectWithDecimal>(this);

  @override
  ObjectWithDecimal freeze() =>
      RealmObjectBase.freezeObject<ObjectWithDecimal>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ObjectWithDecimal._);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithDecimal, 'ObjectWithDecimal', [
      SchemaProperty('decimal', RealmPropertyType.decimal128),
      SchemaProperty('nullableDecimal', RealmPropertyType.decimal128,
          optional: true),
    ]);
  }
}

class Asymmetric extends _Asymmetric
    with RealmEntity, RealmObjectBase, AsymmetricObject {
  Asymmetric(
    ObjectId id, {
    Symmetric? symmetric,
    Iterable<Embedded> embeddedObjects = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'symmetric', symmetric);
    RealmObjectBase.set<RealmList<Embedded>>(
        this, 'embeddedObjects', RealmList<Embedded>(embeddedObjects));
  }

  Asymmetric._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Symmetric? get symmetric =>
      RealmObjectBase.get<Symmetric>(this, 'symmetric') as Symmetric?;
  @override
  set symmetric(covariant Symmetric? value) =>
      RealmObjectBase.set(this, 'symmetric', value);

  @override
  RealmList<Embedded> get embeddedObjects =>
      RealmObjectBase.get<Embedded>(this, 'embeddedObjects')
          as RealmList<Embedded>;
  @override
  set embeddedObjects(covariant RealmList<Embedded> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Asymmetric>> get changes =>
      RealmObjectBase.getChanges<Asymmetric>(this);

  @override
  Asymmetric freeze() => RealmObjectBase.freezeObject<Asymmetric>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Asymmetric._);
    return const SchemaObject(
        ObjectType.asymmetricObject, Asymmetric, 'Asymmetric', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('symmetric', RealmPropertyType.object,
          optional: true, linkTarget: 'Symmetric'),
      SchemaProperty('embeddedObjects', RealmPropertyType.object,
          linkTarget: 'Embedded', collectionType: RealmCollectionType.list),
    ]);
  }
}

class Embedded extends _Embedded
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  Embedded(
    int value, {
    RealmValue any = const RealmValue.nullValue(),
    Symmetric? symmetric,
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'any', any);
    RealmObjectBase.set(this, 'symmetric', symmetric);
  }

  Embedded._();

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  RealmValue get any =>
      RealmObjectBase.get<RealmValue>(this, 'any') as RealmValue;
  @override
  set any(RealmValue value) => RealmObjectBase.set(this, 'any', value);

  @override
  Symmetric? get symmetric =>
      RealmObjectBase.get<Symmetric>(this, 'symmetric') as Symmetric?;
  @override
  set symmetric(covariant Symmetric? value) =>
      RealmObjectBase.set(this, 'symmetric', value);

  @override
  Stream<RealmObjectChanges<Embedded>> get changes =>
      RealmObjectBase.getChanges<Embedded>(this);

  @override
  Embedded freeze() => RealmObjectBase.freezeObject<Embedded>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Embedded._);
    return const SchemaObject(ObjectType.embeddedObject, Embedded, 'Embedded', [
      SchemaProperty('value', RealmPropertyType.int),
      SchemaProperty('any', RealmPropertyType.mixed, optional: true),
      SchemaProperty('symmetric', RealmPropertyType.object,
          optional: true, linkTarget: 'Symmetric'),
    ]);
  }
}

class Symmetric extends _Symmetric
    with RealmEntity, RealmObjectBase, RealmObject {
  Symmetric(
    ObjectId id,
  ) {
    RealmObjectBase.set(this, '_id', id);
  }

  Symmetric._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Stream<RealmObjectChanges<Symmetric>> get changes =>
      RealmObjectBase.getChanges<Symmetric>(this);

  @override
  Symmetric freeze() => RealmObjectBase.freezeObject<Symmetric>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Symmetric._);
    return const SchemaObject(ObjectType.realmObject, Symmetric, 'Symmetric', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}
