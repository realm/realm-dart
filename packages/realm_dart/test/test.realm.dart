// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
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
  Stream<RealmObjectChanges<Car>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Car>(this, keyPaths);

  @override
  Car freeze() => RealmObjectBase.freezeObject<Car>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'make': make.toEJson(),
    };
  }

  static EJsonValue _toEJson(Car value) => value.toEJson();
  static Car _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'make': EJsonValue make,
      } =>
        Car(
          fromEJson(make),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Car._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Car, 'Car', [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Person>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Person>(this, keyPaths);

  @override
  Person freeze() => RealmObjectBase.freezeObject<Person>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
    };
  }

  static EJsonValue _toEJson(Person value) => value.toEJson();
  static Person _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        Person(
          fromEJson(name),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Person._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Person, 'Person', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Dog>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Dog>(this, keyPaths);

  @override
  Dog freeze() => RealmObjectBase.freezeObject<Dog>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'age': age.toEJson(),
      'owner': owner.toEJson(),
    };
  }

  static EJsonValue _toEJson(Dog value) => value.toEJson();
  static Dog _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        Dog(
          fromEJson(name),
          age: fromEJson(ejson['age']),
          owner: fromEJson(ejson['owner']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Dog._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Dog, 'Dog', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int, optional: true),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true, linkTarget: 'Person'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Team>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Team>(this, keyPaths);

  @override
  Team freeze() => RealmObjectBase.freezeObject<Team>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'players': players.toEJson(),
      'scores': scores.toEJson(),
    };
  }

  static EJsonValue _toEJson(Team value) => value.toEJson();
  static Team _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        Team(
          fromEJson(name),
          players: fromEJson(ejson['players']),
          scores: fromEJson(ejson['scores']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Team._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Team, 'Team', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('players', RealmPropertyType.object,
          linkTarget: 'Person', collectionType: RealmCollectionType.list),
      SchemaProperty('scores', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Student>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Student>(this, keyPaths);

  @override
  Student freeze() => RealmObjectBase.freezeObject<Student>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'number': number.toEJson(),
      'name': name.toEJson(),
      'yearOfBirth': yearOfBirth.toEJson(),
      'school': school.toEJson(),
    };
  }

  static EJsonValue _toEJson(Student value) => value.toEJson();
  static Student _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'number': EJsonValue number,
      } =>
        Student(
          fromEJson(number),
          name: fromEJson(ejson['name']),
          yearOfBirth: fromEJson(ejson['yearOfBirth']),
          school: fromEJson(ejson['school']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Student._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Student, 'Student', [
      SchemaProperty('number', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
      SchemaProperty('school', RealmPropertyType.object,
          optional: true, linkTarget: 'School'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class School extends _School with RealmEntity, RealmObjectBase, RealmObject {
  School(
    String name, {
    String? city,
    Iterable<Student> students = const [],
    School? branchOfSchool,
    Iterable<School> branches = const [],
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set<RealmList<Student>>(
        this, 'students', RealmList<Student>(students));
    RealmObjectBase.set(this, 'branchOfSchool', branchOfSchool);
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
  Stream<RealmObjectChanges<School>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<School>(this, keyPaths);

  @override
  School freeze() => RealmObjectBase.freezeObject<School>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'city': city.toEJson(),
      'students': students.toEJson(),
      'branchOfSchool': branchOfSchool.toEJson(),
      'branches': branches.toEJson(),
    };
  }

  static EJsonValue _toEJson(School value) => value.toEJson();
  static School _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        School(
          fromEJson(name),
          city: fromEJson(ejson['city']),
          students: fromEJson(ejson['students'], defaultValue: const []),
          branchOfSchool: fromEJson(ejson['branchOfSchool']),
          branches: fromEJson(ejson['branches']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(School._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<RemappedClass>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RemappedClass>(this, keyPaths);

  @override
  RemappedClass freeze() => RealmObjectBase.freezeObject<RemappedClass>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'primitive_property': remappedProperty.toEJson(),
      'list-with-dashes': listProperty.toEJson(),
    };
  }

  static EJsonValue _toEJson(RemappedClass value) => value.toEJson();
  static RemappedClass _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'primitive_property': EJsonValue remappedProperty,
      } =>
        RemappedClass(
          fromEJson(remappedProperty),
          listProperty: fromEJson(ejson['list-with-dashes']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RemappedClass._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, RemappedClass, 'myRemappedClass', [
      SchemaProperty('remappedProperty', RealmPropertyType.string,
          mapTo: 'primitive_property'),
      SchemaProperty('listProperty', RealmPropertyType.object,
          mapTo: 'list-with-dashes',
          linkTarget: 'myRemappedClass',
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Task>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Task>(this, keyPaths);

  @override
  Task freeze() => RealmObjectBase.freezeObject<Task>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(Task value) => value.toEJson();
  static Task _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        Task(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Task._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Task, 'Task', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Product>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Product>(this, keyPaths);

  @override
  Product freeze() => RealmObjectBase.freezeObject<Product>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'stringQueryField': name.toEJson(),
    };
  }

  static EJsonValue _toEJson(Product value) => value.toEJson();
  static Product _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'stringQueryField': EJsonValue name,
      } =>
        Product(
          fromEJson(id),
          fromEJson(name),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Product._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Product, 'Product', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string,
          mapTo: 'stringQueryField'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Schedule>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Schedule>(this, keyPaths);

  @override
  Schedule freeze() => RealmObjectBase.freezeObject<Schedule>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'tasks': tasks.toEJson(),
    };
  }

  static EJsonValue _toEJson(Schedule value) => value.toEJson();
  static Schedule _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        Schedule(
          fromEJson(id),
          tasks: fromEJson(ejson['tasks'], defaultValue: const []),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Schedule._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Schedule, 'Schedule', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('tasks', RealmPropertyType.object,
          linkTarget: 'Task', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Foo extends _Foo with RealmEntity, RealmObjectBase, RealmObject {
  Foo(
    Uint8List requiredBinaryProp, {
    Uint8List? nullableBinaryProp,
  }) {
    RealmObjectBase.set(this, 'requiredBinaryProp', requiredBinaryProp);
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
  Uint8List? get nullableBinaryProp =>
      RealmObjectBase.get<Uint8List>(this, 'nullableBinaryProp') as Uint8List?;
  @override
  set nullableBinaryProp(Uint8List? value) =>
      RealmObjectBase.set(this, 'nullableBinaryProp', value);

  @override
  Stream<RealmObjectChanges<Foo>> get changes =>
      RealmObjectBase.getChanges<Foo>(this);

  @override
  Stream<RealmObjectChanges<Foo>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Foo>(this, keyPaths);

  @override
  Foo freeze() => RealmObjectBase.freezeObject<Foo>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'requiredBinaryProp': requiredBinaryProp.toEJson(),
      'nullableBinaryProp': nullableBinaryProp.toEJson(),
    };
  }

  static EJsonValue _toEJson(Foo value) => value.toEJson();
  static Foo _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'requiredBinaryProp': EJsonValue requiredBinaryProp,
      } =>
        Foo(
          fromEJson(requiredBinaryProp),
          nullableBinaryProp: fromEJson(ejson['nullableBinaryProp']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Foo._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Foo, 'Foo', [
      SchemaProperty('requiredBinaryProp', RealmPropertyType.binary),
      SchemaProperty('nullableBinaryProp', RealmPropertyType.binary,
          optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
    Decimal128 decimalProp,
    Uint8List binaryProp, {
    String? nullableStringProp,
    bool? nullableBoolProp,
    DateTime? nullableDateProp,
    double? nullableDoubleProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
    int? nullableIntProp,
    Decimal128? nullableDecimalProp,
    Uint8List? nullableBinaryProp,
    RealmValue realmValueProp = const RealmValue.nullValue(),
  }) {
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'decimalProp', decimalProp);
    RealmObjectBase.set(this, 'binaryProp', binaryProp);
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
    RealmObjectBase.set(this, 'nullableDecimalProp', nullableDecimalProp);
    RealmObjectBase.set(this, 'nullableBinaryProp', nullableBinaryProp);
    RealmObjectBase.set(this, 'realmValueProp', realmValueProp);
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
  RealmValue get realmValueProp =>
      RealmObjectBase.get<RealmValue>(this, 'realmValueProp') as RealmValue;
  @override
  set realmValueProp(RealmValue value) =>
      RealmObjectBase.set(this, 'realmValueProp', value);

  @override
  Stream<RealmObjectChanges<AllTypes>> get changes =>
      RealmObjectBase.getChanges<AllTypes>(this);

  @override
  Stream<RealmObjectChanges<AllTypes>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AllTypes>(this, keyPaths);

  @override
  AllTypes freeze() => RealmObjectBase.freezeObject<AllTypes>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringProp': stringProp.toEJson(),
      'boolProp': boolProp.toEJson(),
      'dateProp': dateProp.toEJson(),
      'doubleProp': doubleProp.toEJson(),
      'objectIdProp': objectIdProp.toEJson(),
      'uuidProp': uuidProp.toEJson(),
      'intProp': intProp.toEJson(),
      'decimalProp': decimalProp.toEJson(),
      'binaryProp': binaryProp.toEJson(),
      'nullableStringProp': nullableStringProp.toEJson(),
      'nullableBoolProp': nullableBoolProp.toEJson(),
      'nullableDateProp': nullableDateProp.toEJson(),
      'nullableDoubleProp': nullableDoubleProp.toEJson(),
      'nullableObjectIdProp': nullableObjectIdProp.toEJson(),
      'nullableUuidProp': nullableUuidProp.toEJson(),
      'nullableIntProp': nullableIntProp.toEJson(),
      'nullableDecimalProp': nullableDecimalProp.toEJson(),
      'nullableBinaryProp': nullableBinaryProp.toEJson(),
      'realmValueProp': realmValueProp.toEJson(),
    };
  }

  static EJsonValue _toEJson(AllTypes value) => value.toEJson();
  static AllTypes _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'stringProp': EJsonValue stringProp,
        'boolProp': EJsonValue boolProp,
        'dateProp': EJsonValue dateProp,
        'doubleProp': EJsonValue doubleProp,
        'objectIdProp': EJsonValue objectIdProp,
        'uuidProp': EJsonValue uuidProp,
        'intProp': EJsonValue intProp,
        'decimalProp': EJsonValue decimalProp,
        'binaryProp': EJsonValue binaryProp,
      } =>
        AllTypes(
          fromEJson(stringProp),
          fromEJson(boolProp),
          fromEJson(dateProp),
          fromEJson(doubleProp),
          fromEJson(objectIdProp),
          fromEJson(uuidProp),
          fromEJson(intProp),
          fromEJson(decimalProp),
          fromEJson(binaryProp),
          nullableStringProp: fromEJson(ejson['nullableStringProp']),
          nullableBoolProp: fromEJson(ejson['nullableBoolProp']),
          nullableDateProp: fromEJson(ejson['nullableDateProp']),
          nullableDoubleProp: fromEJson(ejson['nullableDoubleProp']),
          nullableObjectIdProp: fromEJson(ejson['nullableObjectIdProp']),
          nullableUuidProp: fromEJson(ejson['nullableUuidProp']),
          nullableIntProp: fromEJson(ejson['nullableIntProp']),
          nullableDecimalProp: fromEJson(ejson['nullableDecimalProp']),
          nullableBinaryProp: fromEJson(ejson['nullableBinaryProp']),
          realmValueProp: fromEJson(ejson['realmValueProp']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AllTypes._);
    register(_toEJson, _fromEJson);
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
      SchemaProperty('realmValueProp', RealmPropertyType.mixed, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class LinksClass extends _LinksClass
    with RealmEntity, RealmObjectBase, RealmObject {
  LinksClass(
    Uuid id, {
    LinksClass? link,
    Iterable<LinksClass> list = const [],
    Set<LinksClass> linksSet = const {},
    Map<String, LinksClass?> map = const {},
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'link', link);
    RealmObjectBase.set<RealmList<LinksClass>>(
        this, 'list', RealmList<LinksClass>(list));
    RealmObjectBase.set<RealmSet<LinksClass>>(
        this, 'linksSet', RealmSet<LinksClass>(linksSet));
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
  RealmSet<LinksClass> get linksSet =>
      RealmObjectBase.get<LinksClass>(this, 'linksSet') as RealmSet<LinksClass>;
  @override
  set linksSet(covariant RealmSet<LinksClass> value) =>
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
  Stream<RealmObjectChanges<LinksClass>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<LinksClass>(this, keyPaths);

  @override
  LinksClass freeze() => RealmObjectBase.freezeObject<LinksClass>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'link': link.toEJson(),
      'list': list.toEJson(),
      'linksSet': linksSet.toEJson(),
      'map': map.toEJson(),
    };
  }

  static EJsonValue _toEJson(LinksClass value) => value.toEJson();
  static LinksClass _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        LinksClass(
          fromEJson(id),
          link: fromEJson(ejson['link']),
          list: fromEJson(ejson['list']),
          linksSet: fromEJson(ejson['linksSet']),
          map: fromEJson(ejson['map']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(LinksClass._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, LinksClass, 'LinksClass', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('link', RealmPropertyType.object,
          optional: true, linkTarget: 'LinksClass'),
      SchemaProperty('list', RealmPropertyType.object,
          linkTarget: 'LinksClass', collectionType: RealmCollectionType.list),
      SchemaProperty('linksSet', RealmPropertyType.object,
          linkTarget: 'LinksClass', collectionType: RealmCollectionType.set),
      SchemaProperty('map', RealmPropertyType.object,
          optional: true,
          linkTarget: 'LinksClass',
          collectionType: RealmCollectionType.map),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AllCollections extends _AllCollections
    with RealmEntity, RealmObjectBase, RealmObject {
  AllCollections({
    Iterable<String> stringList = const [],
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
    Iterable<Decimal128?> nullableDecimalList = const [],
    Set<String> stringSet = const {},
    Set<bool> boolSet = const {},
    Set<DateTime> dateSet = const {},
    Set<double> doubleSet = const {},
    Set<ObjectId> objectIdSet = const {},
    Set<Uuid> uuidSet = const {},
    Set<int> intSet = const {},
    Set<Decimal128> decimalSet = const {},
    Set<String?> nullableStringSet = const {},
    Set<bool?> nullableBoolSet = const {},
    Set<DateTime?> nullableDateSet = const {},
    Set<double?> nullableDoubleSet = const {},
    Set<ObjectId?> nullableObjectIdSet = const {},
    Set<Uuid?> nullableUuidSet = const {},
    Set<int?> nullableIntSet = const {},
    Set<Decimal128?> nullableDecimalSet = const {},
    Map<String, String> stringMap = const {},
    Map<String, bool> boolMap = const {},
    Map<String, DateTime> dateMap = const {},
    Map<String, double> doubleMap = const {},
    Map<String, ObjectId> objectIdMap = const {},
    Map<String, Uuid> uuidMap = const {},
    Map<String, int> intMap = const {},
    Map<String, Decimal128> decimalMap = const {},
    Map<String, String?> nullableStringMap = const {},
    Map<String, bool?> nullableBoolMap = const {},
    Map<String, DateTime?> nullableDateMap = const {},
    Map<String, double?> nullableDoubleMap = const {},
    Map<String, ObjectId?> nullableObjectIdMap = const {},
    Map<String, Uuid?> nullableUuidMap = const {},
    Map<String, int?> nullableIntMap = const {},
    Map<String, Decimal128?> nullableDecimalMap = const {},
  }) {
    RealmObjectBase.set<RealmList<String>>(
        this, 'stringList', RealmList<String>(stringList));
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
    RealmObjectBase.set<RealmSet<Uuid>>(
        this, 'uuidSet', RealmSet<Uuid>(uuidSet));
    RealmObjectBase.set<RealmSet<int>>(this, 'intSet', RealmSet<int>(intSet));
    RealmObjectBase.set<RealmSet<Decimal128>>(
        this, 'decimalSet', RealmSet<Decimal128>(decimalSet));
    RealmObjectBase.set<RealmSet<String?>>(
        this, 'nullableStringSet', RealmSet<String?>(nullableStringSet));
    RealmObjectBase.set<RealmSet<bool?>>(
        this, 'nullableBoolSet', RealmSet<bool?>(nullableBoolSet));
    RealmObjectBase.set<RealmSet<DateTime?>>(
        this, 'nullableDateSet', RealmSet<DateTime?>(nullableDateSet));
    RealmObjectBase.set<RealmSet<double?>>(
        this, 'nullableDoubleSet', RealmSet<double?>(nullableDoubleSet));
    RealmObjectBase.set<RealmSet<ObjectId?>>(
        this, 'nullableObjectIdSet', RealmSet<ObjectId?>(nullableObjectIdSet));
    RealmObjectBase.set<RealmSet<Uuid?>>(
        this, 'nullableUuidSet', RealmSet<Uuid?>(nullableUuidSet));
    RealmObjectBase.set<RealmSet<int?>>(
        this, 'nullableIntSet', RealmSet<int?>(nullableIntSet));
    RealmObjectBase.set<RealmSet<Decimal128?>>(
        this, 'nullableDecimalSet', RealmSet<Decimal128?>(nullableDecimalSet));
    RealmObjectBase.set<RealmMap<String>>(
        this, 'stringMap', RealmMap<String>(stringMap));
    RealmObjectBase.set<RealmMap<bool>>(
        this, 'boolMap', RealmMap<bool>(boolMap));
    RealmObjectBase.set<RealmMap<DateTime>>(
        this, 'dateMap', RealmMap<DateTime>(dateMap));
    RealmObjectBase.set<RealmMap<double>>(
        this, 'doubleMap', RealmMap<double>(doubleMap));
    RealmObjectBase.set<RealmMap<ObjectId>>(
        this, 'objectIdMap', RealmMap<ObjectId>(objectIdMap));
    RealmObjectBase.set<RealmMap<Uuid>>(
        this, 'uuidMap', RealmMap<Uuid>(uuidMap));
    RealmObjectBase.set<RealmMap<int>>(this, 'intMap', RealmMap<int>(intMap));
    RealmObjectBase.set<RealmMap<Decimal128>>(
        this, 'decimalMap', RealmMap<Decimal128>(decimalMap));
    RealmObjectBase.set<RealmMap<String?>>(
        this, 'nullableStringMap', RealmMap<String?>(nullableStringMap));
    RealmObjectBase.set<RealmMap<bool?>>(
        this, 'nullableBoolMap', RealmMap<bool?>(nullableBoolMap));
    RealmObjectBase.set<RealmMap<DateTime?>>(
        this, 'nullableDateMap', RealmMap<DateTime?>(nullableDateMap));
    RealmObjectBase.set<RealmMap<double?>>(
        this, 'nullableDoubleMap', RealmMap<double?>(nullableDoubleMap));
    RealmObjectBase.set<RealmMap<ObjectId?>>(
        this, 'nullableObjectIdMap', RealmMap<ObjectId?>(nullableObjectIdMap));
    RealmObjectBase.set<RealmMap<Uuid?>>(
        this, 'nullableUuidMap', RealmMap<Uuid?>(nullableUuidMap));
    RealmObjectBase.set<RealmMap<int?>>(
        this, 'nullableIntMap', RealmMap<int?>(nullableIntMap));
    RealmObjectBase.set<RealmMap<Decimal128?>>(
        this, 'nullableDecimalMap', RealmMap<Decimal128?>(nullableDecimalMap));
  }

  AllCollections._();

  @override
  RealmList<String> get stringList =>
      RealmObjectBase.get<String>(this, 'stringList') as RealmList<String>;
  @override
  set stringList(covariant RealmList<String> value) =>
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
  RealmList<double?> get nullableDoubleList =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleList')
          as RealmList<double?>;
  @override
  set nullableDoubleList(covariant RealmList<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ObjectId?> get nullableObjectIdList =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdList')
          as RealmList<ObjectId?>;
  @override
  set nullableObjectIdList(covariant RealmList<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Uuid?> get nullableUuidList =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidList') as RealmList<Uuid?>;
  @override
  set nullableUuidList(covariant RealmList<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int?> get nullableIntList =>
      RealmObjectBase.get<int?>(this, 'nullableIntList') as RealmList<int?>;
  @override
  set nullableIntList(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Decimal128?> get nullableDecimalList =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalList')
          as RealmList<Decimal128?>;
  @override
  set nullableDecimalList(covariant RealmList<Decimal128?> value) =>
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
  RealmSet<Uuid> get uuidSet =>
      RealmObjectBase.get<Uuid>(this, 'uuidSet') as RealmSet<Uuid>;
  @override
  set uuidSet(covariant RealmSet<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int> get intSet =>
      RealmObjectBase.get<int>(this, 'intSet') as RealmSet<int>;
  @override
  set intSet(covariant RealmSet<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<Decimal128> get decimalSet =>
      RealmObjectBase.get<Decimal128>(this, 'decimalSet')
          as RealmSet<Decimal128>;
  @override
  set decimalSet(covariant RealmSet<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<String?> get nullableStringSet =>
      RealmObjectBase.get<String?>(this, 'nullableStringSet')
          as RealmSet<String?>;
  @override
  set nullableStringSet(covariant RealmSet<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<bool?> get nullableBoolSet =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolSet') as RealmSet<bool?>;
  @override
  set nullableBoolSet(covariant RealmSet<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime?> get nullableDateSet =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateSet')
          as RealmSet<DateTime?>;
  @override
  set nullableDateSet(covariant RealmSet<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<double?> get nullableDoubleSet =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleSet')
          as RealmSet<double?>;
  @override
  set nullableDoubleSet(covariant RealmSet<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId?> get nullableObjectIdSet =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdSet')
          as RealmSet<ObjectId?>;
  @override
  set nullableObjectIdSet(covariant RealmSet<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid?> get nullableUuidSet =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidSet') as RealmSet<Uuid?>;
  @override
  set nullableUuidSet(covariant RealmSet<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int?> get nullableIntSet =>
      RealmObjectBase.get<int?>(this, 'nullableIntSet') as RealmSet<int?>;
  @override
  set nullableIntSet(covariant RealmSet<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Decimal128?> get nullableDecimalSet =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalSet')
          as RealmSet<Decimal128?>;
  @override
  set nullableDecimalSet(covariant RealmSet<Decimal128?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<String> get stringMap =>
      RealmObjectBase.get<String>(this, 'stringMap') as RealmMap<String>;
  @override
  set stringMap(covariant RealmMap<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<bool> get boolMap =>
      RealmObjectBase.get<bool>(this, 'boolMap') as RealmMap<bool>;
  @override
  set boolMap(covariant RealmMap<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime> get dateMap =>
      RealmObjectBase.get<DateTime>(this, 'dateMap') as RealmMap<DateTime>;
  @override
  set dateMap(covariant RealmMap<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<double> get doubleMap =>
      RealmObjectBase.get<double>(this, 'doubleMap') as RealmMap<double>;
  @override
  set doubleMap(covariant RealmMap<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId> get objectIdMap =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdMap') as RealmMap<ObjectId>;
  @override
  set objectIdMap(covariant RealmMap<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid> get uuidMap =>
      RealmObjectBase.get<Uuid>(this, 'uuidMap') as RealmMap<Uuid>;
  @override
  set uuidMap(covariant RealmMap<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int> get intMap =>
      RealmObjectBase.get<int>(this, 'intMap') as RealmMap<int>;
  @override
  set intMap(covariant RealmMap<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128> get decimalMap =>
      RealmObjectBase.get<Decimal128>(this, 'decimalMap')
          as RealmMap<Decimal128>;
  @override
  set decimalMap(covariant RealmMap<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<String?> get nullableStringMap =>
      RealmObjectBase.get<String?>(this, 'nullableStringMap')
          as RealmMap<String?>;
  @override
  set nullableStringMap(covariant RealmMap<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<bool?> get nullableBoolMap =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolMap') as RealmMap<bool?>;
  @override
  set nullableBoolMap(covariant RealmMap<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime?> get nullableDateMap =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateMap')
          as RealmMap<DateTime?>;
  @override
  set nullableDateMap(covariant RealmMap<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<double?> get nullableDoubleMap =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleMap')
          as RealmMap<double?>;
  @override
  set nullableDoubleMap(covariant RealmMap<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId?> get nullableObjectIdMap =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdMap')
          as RealmMap<ObjectId?>;
  @override
  set nullableObjectIdMap(covariant RealmMap<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid?> get nullableUuidMap =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidMap') as RealmMap<Uuid?>;
  @override
  set nullableUuidMap(covariant RealmMap<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int?> get nullableIntMap =>
      RealmObjectBase.get<int?>(this, 'nullableIntMap') as RealmMap<int?>;
  @override
  set nullableIntMap(covariant RealmMap<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128?> get nullableDecimalMap =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalMap')
          as RealmMap<Decimal128?>;
  @override
  set nullableDecimalMap(covariant RealmMap<Decimal128?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllCollections>> get changes =>
      RealmObjectBase.getChanges<AllCollections>(this);

  @override
  Stream<RealmObjectChanges<AllCollections>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AllCollections>(this, keyPaths);

  @override
  AllCollections freeze() => RealmObjectBase.freezeObject<AllCollections>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringList': stringList.toEJson(),
      'boolList': boolList.toEJson(),
      'dateList': dateList.toEJson(),
      'doubleList': doubleList.toEJson(),
      'objectIdList': objectIdList.toEJson(),
      'uuidList': uuidList.toEJson(),
      'intList': intList.toEJson(),
      'decimalList': decimalList.toEJson(),
      'nullableStringList': nullableStringList.toEJson(),
      'nullableBoolList': nullableBoolList.toEJson(),
      'nullableDateList': nullableDateList.toEJson(),
      'nullableDoubleList': nullableDoubleList.toEJson(),
      'nullableObjectIdList': nullableObjectIdList.toEJson(),
      'nullableUuidList': nullableUuidList.toEJson(),
      'nullableIntList': nullableIntList.toEJson(),
      'nullableDecimalList': nullableDecimalList.toEJson(),
      'stringSet': stringSet.toEJson(),
      'boolSet': boolSet.toEJson(),
      'dateSet': dateSet.toEJson(),
      'doubleSet': doubleSet.toEJson(),
      'objectIdSet': objectIdSet.toEJson(),
      'uuidSet': uuidSet.toEJson(),
      'intSet': intSet.toEJson(),
      'decimalSet': decimalSet.toEJson(),
      'nullableStringSet': nullableStringSet.toEJson(),
      'nullableBoolSet': nullableBoolSet.toEJson(),
      'nullableDateSet': nullableDateSet.toEJson(),
      'nullableDoubleSet': nullableDoubleSet.toEJson(),
      'nullableObjectIdSet': nullableObjectIdSet.toEJson(),
      'nullableUuidSet': nullableUuidSet.toEJson(),
      'nullableIntSet': nullableIntSet.toEJson(),
      'nullableDecimalSet': nullableDecimalSet.toEJson(),
      'stringMap': stringMap.toEJson(),
      'boolMap': boolMap.toEJson(),
      'dateMap': dateMap.toEJson(),
      'doubleMap': doubleMap.toEJson(),
      'objectIdMap': objectIdMap.toEJson(),
      'uuidMap': uuidMap.toEJson(),
      'intMap': intMap.toEJson(),
      'decimalMap': decimalMap.toEJson(),
      'nullableStringMap': nullableStringMap.toEJson(),
      'nullableBoolMap': nullableBoolMap.toEJson(),
      'nullableDateMap': nullableDateMap.toEJson(),
      'nullableDoubleMap': nullableDoubleMap.toEJson(),
      'nullableObjectIdMap': nullableObjectIdMap.toEJson(),
      'nullableUuidMap': nullableUuidMap.toEJson(),
      'nullableIntMap': nullableIntMap.toEJson(),
      'nullableDecimalMap': nullableDecimalMap.toEJson(),
    };
  }

  static EJsonValue _toEJson(AllCollections value) => value.toEJson();
  static AllCollections _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return AllCollections(
      stringList: fromEJson(ejson['stringList']),
      boolList: fromEJson(ejson['boolList']),
      dateList: fromEJson(ejson['dateList']),
      doubleList: fromEJson(ejson['doubleList']),
      objectIdList: fromEJson(ejson['objectIdList']),
      uuidList: fromEJson(ejson['uuidList']),
      intList: fromEJson(ejson['intList']),
      decimalList: fromEJson(ejson['decimalList']),
      nullableStringList: fromEJson(ejson['nullableStringList']),
      nullableBoolList: fromEJson(ejson['nullableBoolList']),
      nullableDateList: fromEJson(ejson['nullableDateList']),
      nullableDoubleList: fromEJson(ejson['nullableDoubleList']),
      nullableObjectIdList: fromEJson(ejson['nullableObjectIdList']),
      nullableUuidList: fromEJson(ejson['nullableUuidList']),
      nullableIntList: fromEJson(ejson['nullableIntList']),
      nullableDecimalList: fromEJson(ejson['nullableDecimalList']),
      stringSet: fromEJson(ejson['stringSet']),
      boolSet: fromEJson(ejson['boolSet']),
      dateSet: fromEJson(ejson['dateSet']),
      doubleSet: fromEJson(ejson['doubleSet']),
      objectIdSet: fromEJson(ejson['objectIdSet']),
      uuidSet: fromEJson(ejson['uuidSet']),
      intSet: fromEJson(ejson['intSet']),
      decimalSet: fromEJson(ejson['decimalSet']),
      nullableStringSet: fromEJson(ejson['nullableStringSet']),
      nullableBoolSet: fromEJson(ejson['nullableBoolSet']),
      nullableDateSet: fromEJson(ejson['nullableDateSet']),
      nullableDoubleSet: fromEJson(ejson['nullableDoubleSet']),
      nullableObjectIdSet: fromEJson(ejson['nullableObjectIdSet']),
      nullableUuidSet: fromEJson(ejson['nullableUuidSet']),
      nullableIntSet: fromEJson(ejson['nullableIntSet']),
      nullableDecimalSet: fromEJson(ejson['nullableDecimalSet']),
      stringMap: fromEJson(ejson['stringMap']),
      boolMap: fromEJson(ejson['boolMap']),
      dateMap: fromEJson(ejson['dateMap']),
      doubleMap: fromEJson(ejson['doubleMap']),
      objectIdMap: fromEJson(ejson['objectIdMap']),
      uuidMap: fromEJson(ejson['uuidMap']),
      intMap: fromEJson(ejson['intMap']),
      decimalMap: fromEJson(ejson['decimalMap']),
      nullableStringMap: fromEJson(ejson['nullableStringMap']),
      nullableBoolMap: fromEJson(ejson['nullableBoolMap']),
      nullableDateMap: fromEJson(ejson['nullableDateMap']),
      nullableDoubleMap: fromEJson(ejson['nullableDoubleMap']),
      nullableObjectIdMap: fromEJson(ejson['nullableObjectIdMap']),
      nullableUuidMap: fromEJson(ejson['nullableUuidMap']),
      nullableIntMap: fromEJson(ejson['nullableIntMap']),
      nullableDecimalMap: fromEJson(ejson['nullableDecimalMap']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AllCollections._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, AllCollections, 'AllCollections', [
      SchemaProperty('stringList', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
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
      SchemaProperty('nullableDoubleList', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableObjectIdList', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableUuidList', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableIntList', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('nullableDecimalList', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.list),
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
      SchemaProperty('uuidSet', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.set),
      SchemaProperty('intSet', RealmPropertyType.int,
          collectionType: RealmCollectionType.set),
      SchemaProperty('decimalSet', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.set),
      SchemaProperty('nullableStringSet', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableBoolSet', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDateSet', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDoubleSet', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableObjectIdSet', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableUuidSet', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableIntSet', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDecimalSet', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('stringMap', RealmPropertyType.string,
          collectionType: RealmCollectionType.map),
      SchemaProperty('boolMap', RealmPropertyType.bool,
          collectionType: RealmCollectionType.map),
      SchemaProperty('dateMap', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.map),
      SchemaProperty('doubleMap', RealmPropertyType.double,
          collectionType: RealmCollectionType.map),
      SchemaProperty('objectIdMap', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('uuidMap', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('intMap', RealmPropertyType.int,
          collectionType: RealmCollectionType.map),
      SchemaProperty('decimalMap', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.map),
      SchemaProperty('nullableStringMap', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableBoolMap', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDateMap', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDoubleMap', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableObjectIdMap', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableUuidMap', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableIntMap', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDecimalMap', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.map),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<NullableTypes>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<NullableTypes>(this, keyPaths);

  @override
  NullableTypes freeze() => RealmObjectBase.freezeObject<NullableTypes>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'stringProp': stringProp.toEJson(),
      'boolProp': boolProp.toEJson(),
      'dateProp': dateProp.toEJson(),
      'doubleProp': doubleProp.toEJson(),
      'objectIdProp': objectIdProp.toEJson(),
      'uuidProp': uuidProp.toEJson(),
      'intProp': intProp.toEJson(),
      'decimalProp': decimalProp.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullableTypes value) => value.toEJson();
  static NullableTypes _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'differentiator': EJsonValue differentiator,
      } =>
        NullableTypes(
          fromEJson(id),
          fromEJson(differentiator),
          stringProp: fromEJson(ejson['stringProp']),
          boolProp: fromEJson(ejson['boolProp']),
          dateProp: fromEJson(ejson['dateProp']),
          doubleProp: fromEJson(ejson['doubleProp']),
          objectIdProp: fromEJson(ejson['objectIdProp']),
          uuidProp: fromEJson(ejson['uuidProp']),
          intProp: fromEJson(ejson['intProp']),
          decimalProp: fromEJson(ejson['decimalProp']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullableTypes._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Event>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Event>(this, keyPaths);

  @override
  Event freeze() => RealmObjectBase.freezeObject<Event>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'stringQueryField': name.toEJson(),
      'boolQueryField': isCompleted.toEJson(),
      'intQueryField': durationInMinutes.toEJson(),
      'assignedTo': assignedTo.toEJson(),
    };
  }

  static EJsonValue _toEJson(Event value) => value.toEJson();
  static Event _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        Event(
          fromEJson(id),
          name: fromEJson(ejson['stringQueryField']),
          isCompleted: fromEJson(ejson['boolQueryField']),
          durationInMinutes: fromEJson(ejson['intQueryField']),
          assignedTo: fromEJson(ejson['assignedTo']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Event._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Party extends _Party with RealmEntity, RealmObjectBase, RealmObject {
  Party(
    int year, {
    Friend? host,
    Iterable<Friend> guests = const [],
    Party? previous,
  }) {
    RealmObjectBase.set(this, 'host', host);
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set<RealmList<Friend>>(
        this, 'guests', RealmList<Friend>(guests));
    RealmObjectBase.set(this, 'previous', previous);
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
  Stream<RealmObjectChanges<Party>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Party>(this, keyPaths);

  @override
  Party freeze() => RealmObjectBase.freezeObject<Party>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'host': host.toEJson(),
      'year': year.toEJson(),
      'guests': guests.toEJson(),
      'previous': previous.toEJson(),
    };
  }

  static EJsonValue _toEJson(Party value) => value.toEJson();
  static Party _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'year': EJsonValue year,
      } =>
        Party(
          fromEJson(year),
          host: fromEJson(ejson['host']),
          guests: fromEJson(ejson['guests'], defaultValue: const []),
          previous: fromEJson(ejson['previous']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Party._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Party, 'Party', [
      SchemaProperty('host', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
      SchemaProperty('year', RealmPropertyType.int),
      SchemaProperty('guests', RealmPropertyType.object,
          linkTarget: 'Friend', collectionType: RealmCollectionType.list),
      SchemaProperty('previous', RealmPropertyType.object,
          optional: true, linkTarget: 'Party'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Friend>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Friend>(this, keyPaths);

  @override
  Friend freeze() => RealmObjectBase.freezeObject<Friend>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'age': age.toEJson(),
      'bestFriend': bestFriend.toEJson(),
      'friends': friends.toEJson(),
    };
  }

  static EJsonValue _toEJson(Friend value) => value.toEJson();
  static Friend _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        Friend(
          fromEJson(name),
          age: fromEJson(ejson['age'], defaultValue: 42),
          bestFriend: fromEJson(ejson['bestFriend']),
          friends: fromEJson(ejson['friends'], defaultValue: const []),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Friend._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Friend, 'Friend', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int),
      SchemaProperty('bestFriend', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
      SchemaProperty('friends', RealmPropertyType.object,
          linkTarget: 'Friend', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<When>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<When>(this, keyPaths);

  @override
  When freeze() => RealmObjectBase.freezeObject<When>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'dateTimeUtc': dateTimeUtc.toEJson(),
      'locationName': locationName.toEJson(),
    };
  }

  static EJsonValue _toEJson(When value) => value.toEJson();
  static When _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'dateTimeUtc': EJsonValue dateTimeUtc,
        'locationName': EJsonValue locationName,
      } =>
        When(
          fromEJson(dateTimeUtc),
          fromEJson(locationName),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(When._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, When, 'When', [
      SchemaProperty('dateTimeUtc', RealmPropertyType.timestamp),
      SchemaProperty('locationName', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Player>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Player>(this, keyPaths);

  @override
  Player freeze() => RealmObjectBase.freezeObject<Player>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'game': game.toEJson(),
      'scoresByRound': scoresByRound.toEJson(),
    };
  }

  static EJsonValue _toEJson(Player value) => value.toEJson();
  static Player _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        Player(
          fromEJson(name),
          game: fromEJson(ejson['game']),
          scoresByRound:
              fromEJson(ejson['scoresByRound'], defaultValue: const []),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Player._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Player, 'Player', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('game', RealmPropertyType.object,
          optional: true, linkTarget: 'Game'),
      SchemaProperty('scoresByRound', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Game>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Game>(this, keyPaths);

  @override
  Game freeze() => RealmObjectBase.freezeObject<Game>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'winnerByRound': winnerByRound.toEJson(),
    };
  }

  static EJsonValue _toEJson(Game value) => value.toEJson();
  static Game _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Game(
      winnerByRound: fromEJson(ejson['winnerByRound'], defaultValue: const []),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Game._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Game, 'Game', [
      SchemaProperty('winnerByRound', RealmPropertyType.object,
          linkTarget: 'Player', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<AllTypesEmbedded>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AllTypesEmbedded>(this, keyPaths);

  @override
  AllTypesEmbedded freeze() =>
      RealmObjectBase.freezeObject<AllTypesEmbedded>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringProp': stringProp.toEJson(),
      'boolProp': boolProp.toEJson(),
      'dateProp': dateProp.toEJson(),
      'doubleProp': doubleProp.toEJson(),
      'objectIdProp': objectIdProp.toEJson(),
      'uuidProp': uuidProp.toEJson(),
      'intProp': intProp.toEJson(),
      'decimalProp': decimalProp.toEJson(),
      'nullableStringProp': nullableStringProp.toEJson(),
      'nullableBoolProp': nullableBoolProp.toEJson(),
      'nullableDateProp': nullableDateProp.toEJson(),
      'nullableDoubleProp': nullableDoubleProp.toEJson(),
      'nullableObjectIdProp': nullableObjectIdProp.toEJson(),
      'nullableUuidProp': nullableUuidProp.toEJson(),
      'nullableIntProp': nullableIntProp.toEJson(),
      'nullableDecimalProp': nullableDecimalProp.toEJson(),
      'strings': strings.toEJson(),
      'bools': bools.toEJson(),
      'dates': dates.toEJson(),
      'doubles': doubles.toEJson(),
      'objectIds': objectIds.toEJson(),
      'uuids': uuids.toEJson(),
      'ints': ints.toEJson(),
      'decimals': decimals.toEJson(),
    };
  }

  static EJsonValue _toEJson(AllTypesEmbedded value) => value.toEJson();
  static AllTypesEmbedded _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'stringProp': EJsonValue stringProp,
        'boolProp': EJsonValue boolProp,
        'dateProp': EJsonValue dateProp,
        'doubleProp': EJsonValue doubleProp,
        'objectIdProp': EJsonValue objectIdProp,
        'uuidProp': EJsonValue uuidProp,
        'intProp': EJsonValue intProp,
        'decimalProp': EJsonValue decimalProp,
      } =>
        AllTypesEmbedded(
          fromEJson(stringProp),
          fromEJson(boolProp),
          fromEJson(dateProp),
          fromEJson(doubleProp),
          fromEJson(objectIdProp),
          fromEJson(uuidProp),
          fromEJson(intProp),
          fromEJson(decimalProp),
          nullableStringProp: fromEJson(ejson['nullableStringProp']),
          nullableBoolProp: fromEJson(ejson['nullableBoolProp']),
          nullableDateProp: fromEJson(ejson['nullableDateProp']),
          nullableDoubleProp: fromEJson(ejson['nullableDoubleProp']),
          nullableObjectIdProp: fromEJson(ejson['nullableObjectIdProp']),
          nullableUuidProp: fromEJson(ejson['nullableUuidProp']),
          nullableIntProp: fromEJson(ejson['nullableIntProp']),
          nullableDecimalProp: fromEJson(ejson['nullableDecimalProp']),
          strings: fromEJson(ejson['strings']),
          bools: fromEJson(ejson['bools']),
          dates: fromEJson(ejson['dates']),
          doubles: fromEJson(ejson['doubles']),
          objectIds: fromEJson(ejson['objectIds']),
          uuids: fromEJson(ejson['uuids']),
          ints: fromEJson(ejson['ints']),
          decimals: fromEJson(ejson['decimals']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AllTypesEmbedded._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ObjectWithEmbedded extends _ObjectWithEmbedded
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithEmbedded(
    String id, {
    Uuid? differentiator,
    AllTypesEmbedded? singleObject,
    Iterable<AllTypesEmbedded> list = const [],
    RecursiveEmbedded1? recursiveObject,
    Iterable<RecursiveEmbedded1> recursiveList = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'singleObject', singleObject);
    RealmObjectBase.set<RealmList<AllTypesEmbedded>>(
        this, 'list', RealmList<AllTypesEmbedded>(list));
    RealmObjectBase.set(this, 'recursiveObject', recursiveObject);
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
  Stream<RealmObjectChanges<ObjectWithEmbedded>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ObjectWithEmbedded>(this, keyPaths);

  @override
  ObjectWithEmbedded freeze() =>
      RealmObjectBase.freezeObject<ObjectWithEmbedded>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'singleObject': singleObject.toEJson(),
      'list': list.toEJson(),
      'recursiveObject': recursiveObject.toEJson(),
      'recursiveList': recursiveList.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectWithEmbedded value) => value.toEJson();
  static ObjectWithEmbedded _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        ObjectWithEmbedded(
          fromEJson(id),
          differentiator: fromEJson(ejson['differentiator']),
          singleObject: fromEJson(ejson['singleObject']),
          list: fromEJson(ejson['list']),
          recursiveObject: fromEJson(ejson['recursiveObject']),
          recursiveList: fromEJson(ejson['recursiveList']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithEmbedded._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RecursiveEmbedded1 extends _RecursiveEmbedded1
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecursiveEmbedded1(
    String value, {
    RecursiveEmbedded2? child,
    Iterable<RecursiveEmbedded2> children = const [],
    ObjectWithEmbedded? realmObject,
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'child', child);
    RealmObjectBase.set<RealmList<RecursiveEmbedded2>>(
        this, 'children', RealmList<RecursiveEmbedded2>(children));
    RealmObjectBase.set(this, 'realmObject', realmObject);
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
  Stream<RealmObjectChanges<RecursiveEmbedded1>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RecursiveEmbedded1>(this, keyPaths);

  @override
  RecursiveEmbedded1 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded1>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'value': value.toEJson(),
      'child': child.toEJson(),
      'children': children.toEJson(),
      'realmObject': realmObject.toEJson(),
    };
  }

  static EJsonValue _toEJson(RecursiveEmbedded1 value) => value.toEJson();
  static RecursiveEmbedded1 _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'value': EJsonValue value,
      } =>
        RecursiveEmbedded1(
          fromEJson(value),
          child: fromEJson(ejson['child']),
          children: fromEJson(ejson['children']),
          realmObject: fromEJson(ejson['realmObject']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RecursiveEmbedded1._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RecursiveEmbedded2 extends _RecursiveEmbedded2
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecursiveEmbedded2(
    String value, {
    RecursiveEmbedded3? child,
    Iterable<RecursiveEmbedded3> children = const [],
    ObjectWithEmbedded? realmObject,
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'child', child);
    RealmObjectBase.set<RealmList<RecursiveEmbedded3>>(
        this, 'children', RealmList<RecursiveEmbedded3>(children));
    RealmObjectBase.set(this, 'realmObject', realmObject);
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
  Stream<RealmObjectChanges<RecursiveEmbedded2>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RecursiveEmbedded2>(this, keyPaths);

  @override
  RecursiveEmbedded2 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded2>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'value': value.toEJson(),
      'child': child.toEJson(),
      'children': children.toEJson(),
      'realmObject': realmObject.toEJson(),
    };
  }

  static EJsonValue _toEJson(RecursiveEmbedded2 value) => value.toEJson();
  static RecursiveEmbedded2 _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'value': EJsonValue value,
      } =>
        RecursiveEmbedded2(
          fromEJson(value),
          child: fromEJson(ejson['child']),
          children: fromEJson(ejson['children']),
          realmObject: fromEJson(ejson['realmObject']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RecursiveEmbedded2._);
    register(_toEJson, _fromEJson);
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
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<RecursiveEmbedded3>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RecursiveEmbedded3>(this, keyPaths);

  @override
  RecursiveEmbedded3 freeze() =>
      RealmObjectBase.freezeObject<RecursiveEmbedded3>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'value': value.toEJson(),
    };
  }

  static EJsonValue _toEJson(RecursiveEmbedded3 value) => value.toEJson();
  static RecursiveEmbedded3 _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'value': EJsonValue value,
      } =>
        RecursiveEmbedded3(
          fromEJson(value),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RecursiveEmbedded3._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.embeddedObject, RecursiveEmbedded3, 'RecursiveEmbedded3', [
      SchemaProperty('value', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<ObjectWithDecimal>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ObjectWithDecimal>(this, keyPaths);

  @override
  ObjectWithDecimal freeze() =>
      RealmObjectBase.freezeObject<ObjectWithDecimal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'decimal': decimal.toEJson(),
      'nullableDecimal': nullableDecimal.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectWithDecimal value) => value.toEJson();
  static ObjectWithDecimal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'decimal': EJsonValue decimal,
      } =>
        ObjectWithDecimal(
          fromEJson(decimal),
          nullableDecimal: fromEJson(ejson['nullableDecimal']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithDecimal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithDecimal, 'ObjectWithDecimal', [
      SchemaProperty('decimal', RealmPropertyType.decimal128),
      SchemaProperty('nullableDecimal', RealmPropertyType.decimal128,
          optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Embedded>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Embedded>(this, keyPaths);

  @override
  Embedded freeze() => RealmObjectBase.freezeObject<Embedded>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'value': value.toEJson(),
      'any': any.toEJson(),
      'symmetric': symmetric.toEJson(),
    };
  }

  static EJsonValue _toEJson(Embedded value) => value.toEJson();
  static Embedded _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'value': EJsonValue value,
      } =>
        Embedded(
          fromEJson(value),
          any: fromEJson(ejson['any']),
          symmetric: fromEJson(ejson['symmetric']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Embedded._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, Embedded, 'Embedded', [
      SchemaProperty('value', RealmPropertyType.int),
      SchemaProperty('any', RealmPropertyType.mixed, optional: true),
      SchemaProperty('symmetric', RealmPropertyType.object,
          optional: true, linkTarget: 'Symmetric'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<Symmetric>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Symmetric>(this, keyPaths);

  @override
  Symmetric freeze() => RealmObjectBase.freezeObject<Symmetric>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(Symmetric value) => value.toEJson();
  static Symmetric _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        Symmetric(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Symmetric._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Symmetric, 'Symmetric', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ObjectWithRealmValue extends _ObjectWithRealmValue
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithRealmValue(
    ObjectId id, {
    ObjectId? differentiator,
    RealmValue oneAny = const RealmValue.nullValue(),
    Iterable<RealmValue> manyAny = const [],
    Map<String, RealmValue> dictOfAny = const {},
    Set<RealmValue> setOfAny = const {},
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'oneAny', oneAny);
    RealmObjectBase.set<RealmList<RealmValue>>(
        this, 'manyAny', RealmList<RealmValue>(manyAny));
    RealmObjectBase.set<RealmMap<RealmValue>>(
        this, 'dictOfAny', RealmMap<RealmValue>(dictOfAny));
    RealmObjectBase.set<RealmSet<RealmValue>>(
        this, 'setOfAny', RealmSet<RealmValue>(setOfAny));
  }

  ObjectWithRealmValue._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId? get differentiator =>
      RealmObjectBase.get<ObjectId>(this, 'differentiator') as ObjectId?;
  @override
  set differentiator(ObjectId? value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  RealmValue get oneAny =>
      RealmObjectBase.get<RealmValue>(this, 'oneAny') as RealmValue;
  @override
  set oneAny(RealmValue value) => RealmObjectBase.set(this, 'oneAny', value);

  @override
  RealmList<RealmValue> get manyAny =>
      RealmObjectBase.get<RealmValue>(this, 'manyAny') as RealmList<RealmValue>;
  @override
  set manyAny(covariant RealmList<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<RealmValue> get dictOfAny =>
      RealmObjectBase.get<RealmValue>(this, 'dictOfAny')
          as RealmMap<RealmValue>;
  @override
  set dictOfAny(covariant RealmMap<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<RealmValue> get setOfAny =>
      RealmObjectBase.get<RealmValue>(this, 'setOfAny') as RealmSet<RealmValue>;
  @override
  set setOfAny(covariant RealmSet<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<ObjectWithRealmValue>> get changes =>
      RealmObjectBase.getChanges<ObjectWithRealmValue>(this);

  @override
  Stream<RealmObjectChanges<ObjectWithRealmValue>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ObjectWithRealmValue>(this, keyPaths);

  @override
  ObjectWithRealmValue freeze() =>
      RealmObjectBase.freezeObject<ObjectWithRealmValue>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'oneAny': oneAny.toEJson(),
      'manyAny': manyAny.toEJson(),
      'dictOfAny': dictOfAny.toEJson(),
      'setOfAny': setOfAny.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectWithRealmValue value) => value.toEJson();
  static ObjectWithRealmValue _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        ObjectWithRealmValue(
          fromEJson(id),
          differentiator: fromEJson(ejson['differentiator']),
          oneAny: fromEJson(ejson['oneAny']),
          manyAny: fromEJson(ejson['manyAny']),
          dictOfAny: fromEJson(ejson['dictOfAny']),
          setOfAny: fromEJson(ejson['setOfAny']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithRealmValue._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithRealmValue, 'ObjectWithRealmValue', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('oneAny', RealmPropertyType.mixed,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('manyAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('dictOfAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('setOfAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.set),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ObjectWithInt extends _ObjectWithInt
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ObjectWithInt(
    ObjectId id, {
    ObjectId? differentiator,
    int i = 42,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ObjectWithInt>({
        'i': 42,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'i', i);
  }

  ObjectWithInt._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId? get differentiator =>
      RealmObjectBase.get<ObjectId>(this, 'differentiator') as ObjectId?;
  @override
  set differentiator(ObjectId? value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  int get i => RealmObjectBase.get<int>(this, 'i') as int;
  @override
  set i(int value) => RealmObjectBase.set(this, 'i', value);

  @override
  Stream<RealmObjectChanges<ObjectWithInt>> get changes =>
      RealmObjectBase.getChanges<ObjectWithInt>(this);

  @override
  Stream<RealmObjectChanges<ObjectWithInt>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ObjectWithInt>(this, keyPaths);

  @override
  ObjectWithInt freeze() => RealmObjectBase.freezeObject<ObjectWithInt>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'i': i.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectWithInt value) => value.toEJson();
  static ObjectWithInt _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
      } =>
        ObjectWithInt(
          fromEJson(id),
          differentiator: fromEJson(ejson['differentiator']),
          i: fromEJson(ejson['i'], defaultValue: 42),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithInt._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithInt, 'ObjectWithInt', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('i', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
