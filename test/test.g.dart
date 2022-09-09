// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Car(
    String make,
  ) {
    _makeProperty.setValue(this, make);
  }

  Car._();

  static const _makeProperty = ValueProperty<String>(
    'make',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get make => _makeProperty.getValue(this);
  @override
  set make(String value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Car>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Car>(
    ObjectType.topLevel,
    Car._,
    'Car',
    {
      'make': _makeProperty,
    },
    _makeProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Person extends _Person
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Person(
    String name,
  ) {
    _nameProperty.setValue(this, name);
  }

  Person._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => _nameProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<Person>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Person>(
    ObjectType.topLevel,
    Person._,
    'Person',
    {
      'name': _nameProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Dog extends _Dog
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Dog(
    String name, {
    int? age,
    Person? owner,
  }) {
    _nameProperty.setValue(this, name);
    _ageProperty.setValue(this, age);
    _ownerProperty.setValue(this, owner);
  }

  Dog._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  static const _ageProperty = ValueProperty<int?>(
    'age',
    RealmPropertyType.int,
  );
  @override
  int? get age => _ageProperty.getValue(this);
  @override
  set age(int? value) => _ageProperty.setValue(this, value);

  static const _ownerProperty = ObjectProperty<Person>('owner', 'Person');
  @override
  Person? get owner => _ownerProperty.getValue(this);
  @override
  set owner(covariant Person? value) => _ownerProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<Dog>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Dog>(
    ObjectType.topLevel,
    Dog._,
    'Dog',
    {
      'name': _nameProperty,
      'age': _ageProperty,
      'owner': _ownerProperty,
    },
    _nameProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Team extends _Team
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Team(
    String name, {
    Iterable<Person> players = const [],
    Iterable<int> scores = const [],
  }) {
    _nameProperty.setValue(this, name);
    _playersProperty.setValue(this, RealmList<Person>(players));
    _scoresProperty.setValue(this, RealmList<int>(scores));
  }

  Team._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => _nameProperty.setValue(this, value);

  static const _playersProperty = ListProperty<Person>(
      'players', RealmPropertyType.object,
      linkTarget: 'Person');
  @override
  RealmList<Person> get players => _playersProperty.getValue(this);
  @override
  set players(covariant RealmList<Person> value) =>
      throw RealmUnsupportedSetError();

  static const _scoresProperty =
      ListProperty<int>('scores', RealmPropertyType.int);
  @override
  RealmList<int> get scores => _scoresProperty.getValue(this);
  @override
  set scores(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Team>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Team>(
    ObjectType.topLevel,
    Team._,
    'Team',
    {
      'name': _nameProperty,
      'players': _playersProperty,
      'scores': _scoresProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Student extends _Student
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Student(
    int number, {
    String? name,
    int? yearOfBirth,
    School? school,
  }) {
    _numberProperty.setValue(this, number);
    _nameProperty.setValue(this, name);
    _yearOfBirthProperty.setValue(this, yearOfBirth);
    _schoolProperty.setValue(this, school);
  }

  Student._();

  static const _numberProperty = ValueProperty<int>(
    'number',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int get number => _numberProperty.getValue(this);
  @override
  set number(int value) => throw RealmUnsupportedSetError();

  static const _nameProperty = ValueProperty<String?>(
    'name',
    RealmPropertyType.string,
  );
  @override
  String? get name => _nameProperty.getValue(this);
  @override
  set name(String? value) => _nameProperty.setValue(this, value);

  static const _yearOfBirthProperty = ValueProperty<int?>(
    'yearOfBirth',
    RealmPropertyType.int,
  );
  @override
  int? get yearOfBirth => _yearOfBirthProperty.getValue(this);
  @override
  set yearOfBirth(int? value) => _yearOfBirthProperty.setValue(this, value);

  static const _schoolProperty = ObjectProperty<School>('school', 'School');
  @override
  School? get school => _schoolProperty.getValue(this);
  @override
  set school(covariant School? value) => _schoolProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<Student>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Student>(
    ObjectType.topLevel,
    Student._,
    'Student',
    {
      'number': _numberProperty,
      'name': _nameProperty,
      'yearOfBirth': _yearOfBirthProperty,
      'school': _schoolProperty,
    },
    _numberProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class School extends _School
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  School(
    String name, {
    String? city,
    School? branchOfSchool,
    Iterable<Student> students = const [],
    Iterable<School> branches = const [],
  }) {
    _nameProperty.setValue(this, name);
    _cityProperty.setValue(this, city);
    _branchOfSchoolProperty.setValue(this, branchOfSchool);
    _studentsProperty.setValue(this, RealmList<Student>(students));
    _branchesProperty.setValue(this, RealmList<School>(branches));
  }

  School._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  static const _cityProperty = ValueProperty<String?>(
    'city',
    RealmPropertyType.string,
  );
  @override
  String? get city => _cityProperty.getValue(this);
  @override
  set city(String? value) => _cityProperty.setValue(this, value);

  static const _studentsProperty = ListProperty<Student>(
      'students', RealmPropertyType.object,
      linkTarget: 'Student');
  @override
  RealmList<Student> get students => _studentsProperty.getValue(this);
  @override
  set students(covariant RealmList<Student> value) =>
      throw RealmUnsupportedSetError();

  static const _branchOfSchoolProperty =
      ObjectProperty<School>('branchOfSchool', 'School');
  @override
  School? get branchOfSchool => _branchOfSchoolProperty.getValue(this);
  @override
  set branchOfSchool(covariant School? value) =>
      _branchOfSchoolProperty.setValue(this, value);

  static const _branchesProperty = ListProperty<School>(
      'branches', RealmPropertyType.object,
      linkTarget: 'School');
  @override
  RealmList<School> get branches => _branchesProperty.getValue(this);
  @override
  set branches(covariant RealmList<School> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<School>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<School>(
    ObjectType.topLevel,
    School._,
    'School',
    {
      'name': _nameProperty,
      'city': _cityProperty,
      'students': _studentsProperty,
      'branchOfSchool': _branchOfSchoolProperty,
      'branches': _branchesProperty,
    },
    _nameProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RemappedClass extends $RemappedClass
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  RemappedClass(
    String remappedProperty, {
    Iterable<RemappedClass> listProperty = const [],
  }) {
    _remappedPropertyProperty.setValue(this, remappedProperty);
    _listPropertyProperty.setValue(
        this, RealmList<RemappedClass>(listProperty));
  }

  RemappedClass._();

  static const _remappedPropertyProperty = ValueProperty<String>(
    'primitive_property',
    RealmPropertyType.string,
  );
  @override
  String get remappedProperty => _remappedPropertyProperty.getValue(this);
  @override
  set remappedProperty(String value) =>
      _remappedPropertyProperty.setValue(this, value);

  static const _listPropertyProperty = ListProperty<RemappedClass>(
      'list-with-dashes', RealmPropertyType.object,
      linkTarget: 'myRemappedClass');
  @override
  RealmList<RemappedClass> get listProperty =>
      _listPropertyProperty.getValue(this);
  @override
  set listProperty(covariant RealmList<RemappedClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<RemappedClass>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<RemappedClass>(
    ObjectType.topLevel,
    RemappedClass._,
    'myRemappedClass',
    {
      'primitive_property': _remappedPropertyProperty,
      'list-with-dashes': _listPropertyProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Task extends _Task
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Task(
    ObjectId id,
  ) {
    _idProperty.setValue(this, id);
  }

  Task._();

  static const _idProperty = ValueProperty<ObjectId>(
    '_id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Task>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Task>(
    ObjectType.topLevel,
    Task._,
    'Task',
    {
      '_id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Schedule extends _Schedule
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Schedule(
    ObjectId id, {
    Iterable<Task> tasks = const [],
  }) {
    _idProperty.setValue(this, id);
    _tasksProperty.setValue(this, RealmList<Task>(tasks));
  }

  Schedule._();

  static const _idProperty = ValueProperty<ObjectId>(
    '_id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  static const _tasksProperty =
      ListProperty<Task>('tasks', RealmPropertyType.object, linkTarget: 'Task');
  @override
  RealmList<Task> get tasks => _tasksProperty.getValue(this);
  @override
  set tasks(covariant RealmList<Task> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Schedule>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Schedule>(
    ObjectType.topLevel,
    Schedule._,
    'Schedule',
    {
      '_id': _idProperty,
      'tasks': _tasksProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class AllTypes extends _AllTypes
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
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
    _stringPropProperty.setValue(this, stringProp);
    _boolPropProperty.setValue(this, boolProp);
    _datePropProperty.setValue(this, dateProp);
    _doublePropProperty.setValue(this, doubleProp);
    _objectIdPropProperty.setValue(this, objectIdProp);
    _uuidPropProperty.setValue(this, uuidProp);
    _intPropProperty.setValue(this, intProp);
    _nullableStringPropProperty.setValue(this, nullableStringProp);
    _nullableBoolPropProperty.setValue(this, nullableBoolProp);
    _nullableDatePropProperty.setValue(this, nullableDateProp);
    _nullableDoublePropProperty.setValue(this, nullableDoubleProp);
    _nullableObjectIdPropProperty.setValue(this, nullableObjectIdProp);
    _nullableUuidPropProperty.setValue(this, nullableUuidProp);
    _nullableIntPropProperty.setValue(this, nullableIntProp);
  }

  AllTypes._();

  static const _stringPropProperty = ValueProperty<String>(
    'stringProp',
    RealmPropertyType.string,
  );
  @override
  String get stringProp => _stringPropProperty.getValue(this);
  @override
  set stringProp(String value) => _stringPropProperty.setValue(this, value);

  static const _boolPropProperty = ValueProperty<bool>(
    'boolProp',
    RealmPropertyType.bool,
  );
  @override
  bool get boolProp => _boolPropProperty.getValue(this);
  @override
  set boolProp(bool value) => _boolPropProperty.setValue(this, value);

  static const _datePropProperty = ValueProperty<DateTime>(
    'dateProp',
    RealmPropertyType.timestamp,
  );
  @override
  DateTime get dateProp => _datePropProperty.getValue(this);
  @override
  set dateProp(DateTime value) => _datePropProperty.setValue(this, value);

  static const _doublePropProperty = ValueProperty<double>(
    'doubleProp',
    RealmPropertyType.double,
  );
  @override
  double get doubleProp => _doublePropProperty.getValue(this);
  @override
  set doubleProp(double value) => _doublePropProperty.setValue(this, value);

  static const _objectIdPropProperty = ValueProperty<ObjectId>(
    'objectIdProp',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId get objectIdProp => _objectIdPropProperty.getValue(this);
  @override
  set objectIdProp(ObjectId value) =>
      _objectIdPropProperty.setValue(this, value);

  static const _uuidPropProperty = ValueProperty<Uuid>(
    'uuidProp',
    RealmPropertyType.uuid,
  );
  @override
  Uuid get uuidProp => _uuidPropProperty.getValue(this);
  @override
  set uuidProp(Uuid value) => _uuidPropProperty.setValue(this, value);

  static const _intPropProperty = ValueProperty<int>(
    'intProp',
    RealmPropertyType.int,
  );
  @override
  int get intProp => _intPropProperty.getValue(this);
  @override
  set intProp(int value) => _intPropProperty.setValue(this, value);

  static const _nullableStringPropProperty = ValueProperty<String?>(
    'nullableStringProp',
    RealmPropertyType.string,
  );
  @override
  String? get nullableStringProp => _nullableStringPropProperty.getValue(this);
  @override
  set nullableStringProp(String? value) =>
      _nullableStringPropProperty.setValue(this, value);

  static const _nullableBoolPropProperty = ValueProperty<bool?>(
    'nullableBoolProp',
    RealmPropertyType.bool,
  );
  @override
  bool? get nullableBoolProp => _nullableBoolPropProperty.getValue(this);
  @override
  set nullableBoolProp(bool? value) =>
      _nullableBoolPropProperty.setValue(this, value);

  static const _nullableDatePropProperty = ValueProperty<DateTime?>(
    'nullableDateProp',
    RealmPropertyType.timestamp,
  );
  @override
  DateTime? get nullableDateProp => _nullableDatePropProperty.getValue(this);
  @override
  set nullableDateProp(DateTime? value) =>
      _nullableDatePropProperty.setValue(this, value);

  static const _nullableDoublePropProperty = ValueProperty<double?>(
    'nullableDoubleProp',
    RealmPropertyType.double,
  );
  @override
  double? get nullableDoubleProp => _nullableDoublePropProperty.getValue(this);
  @override
  set nullableDoubleProp(double? value) =>
      _nullableDoublePropProperty.setValue(this, value);

  static const _nullableObjectIdPropProperty = ValueProperty<ObjectId?>(
    'nullableObjectIdProp',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId? get nullableObjectIdProp =>
      _nullableObjectIdPropProperty.getValue(this);
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      _nullableObjectIdPropProperty.setValue(this, value);

  static const _nullableUuidPropProperty = ValueProperty<Uuid?>(
    'nullableUuidProp',
    RealmPropertyType.uuid,
  );
  @override
  Uuid? get nullableUuidProp => _nullableUuidPropProperty.getValue(this);
  @override
  set nullableUuidProp(Uuid? value) =>
      _nullableUuidPropProperty.setValue(this, value);

  static const _nullableIntPropProperty = ValueProperty<int?>(
    'nullableIntProp',
    RealmPropertyType.int,
  );
  @override
  int? get nullableIntProp => _nullableIntPropProperty.getValue(this);
  @override
  set nullableIntProp(int? value) =>
      _nullableIntPropProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<AllTypes>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<AllTypes>(
    ObjectType.topLevel,
    AllTypes._,
    'AllTypes',
    {
      'stringProp': _stringPropProperty,
      'boolProp': _boolPropProperty,
      'dateProp': _datePropProperty,
      'doubleProp': _doublePropProperty,
      'objectIdProp': _objectIdPropProperty,
      'uuidProp': _uuidPropProperty,
      'intProp': _intPropProperty,
      'nullableStringProp': _nullableStringPropProperty,
      'nullableBoolProp': _nullableBoolPropProperty,
      'nullableDateProp': _nullableDatePropProperty,
      'nullableDoubleProp': _nullableDoublePropProperty,
      'nullableObjectIdProp': _nullableObjectIdPropProperty,
      'nullableUuidProp': _nullableUuidPropProperty,
      'nullableIntProp': _nullableIntPropProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class LinksClass extends _LinksClass
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  LinksClass(
    Uuid id, {
    LinksClass? link,
    Iterable<LinksClass> list = const [],
  }) {
    _idProperty.setValue(this, id);
    _linkProperty.setValue(this, link);
    _listProperty.setValue(this, RealmList<LinksClass>(list));
  }

  LinksClass._();

  static const _idProperty = ValueProperty<Uuid>(
    'id',
    RealmPropertyType.uuid,
    primaryKey: true,
  );
  @override
  Uuid get id => _idProperty.getValue(this);
  @override
  set id(Uuid value) => throw RealmUnsupportedSetError();

  static const _linkProperty = ObjectProperty<LinksClass>('link', 'LinksClass');
  @override
  LinksClass? get link => _linkProperty.getValue(this);
  @override
  set link(covariant LinksClass? value) => _linkProperty.setValue(this, value);

  static const _listProperty = ListProperty<LinksClass>(
      'list', RealmPropertyType.object,
      linkTarget: 'LinksClass');
  @override
  RealmList<LinksClass> get list => _listProperty.getValue(this);
  @override
  set list(covariant RealmList<LinksClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<LinksClass>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<LinksClass>(
    ObjectType.topLevel,
    LinksClass._,
    'LinksClass',
    {
      'id': _idProperty,
      'link': _linkProperty,
      'list': _listProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class AllCollections extends _AllCollections
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
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
    _stringsProperty.setValue(this, RealmList<String>(strings));
    _boolsProperty.setValue(this, RealmList<bool>(bools));
    _datesProperty.setValue(this, RealmList<DateTime>(dates));
    _doublesProperty.setValue(this, RealmList<double>(doubles));
    _objectIdsProperty.setValue(this, RealmList<ObjectId>(objectIds));
    _uuidsProperty.setValue(this, RealmList<Uuid>(uuids));
    _intsProperty.setValue(this, RealmList<int>(ints));
    _nullableStringsProperty.setValue(
        this, RealmList<String?>(nullableStrings));
    _nullableBoolsProperty.setValue(this, RealmList<bool?>(nullableBools));
    _nullableDatesProperty.setValue(this, RealmList<DateTime?>(nullableDates));
    _nullableDoublesProperty.setValue(
        this, RealmList<double?>(nullableDoubles));
    _nullableObjectIdsProperty.setValue(
        this, RealmList<ObjectId?>(nullableObjectIds));
    _nullableUuidsProperty.setValue(this, RealmList<Uuid?>(nullableUuids));
    _nullableIntsProperty.setValue(this, RealmList<int?>(nullableInts));
  }

  AllCollections._();

  static const _stringsProperty =
      ListProperty<String>('strings', RealmPropertyType.string);
  @override
  RealmList<String> get strings => _stringsProperty.getValue(this);
  @override
  set strings(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  static const _boolsProperty =
      ListProperty<bool>('bools', RealmPropertyType.bool);
  @override
  RealmList<bool> get bools => _boolsProperty.getValue(this);
  @override
  set bools(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  static const _datesProperty =
      ListProperty<DateTime>('dates', RealmPropertyType.timestamp);
  @override
  RealmList<DateTime> get dates => _datesProperty.getValue(this);
  @override
  set dates(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  static const _doublesProperty =
      ListProperty<double>('doubles', RealmPropertyType.double);
  @override
  RealmList<double> get doubles => _doublesProperty.getValue(this);
  @override
  set doubles(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  static const _objectIdsProperty =
      ListProperty<ObjectId>('objectIds', RealmPropertyType.objectid);
  @override
  RealmList<ObjectId> get objectIds => _objectIdsProperty.getValue(this);
  @override
  set objectIds(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  static const _uuidsProperty =
      ListProperty<Uuid>('uuids', RealmPropertyType.uuid);
  @override
  RealmList<Uuid> get uuids => _uuidsProperty.getValue(this);
  @override
  set uuids(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  static const _intsProperty = ListProperty<int>('ints', RealmPropertyType.int);
  @override
  RealmList<int> get ints => _intsProperty.getValue(this);
  @override
  set ints(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

  static const _nullableStringsProperty =
      ListProperty<String?>('nullableStrings', RealmPropertyType.string);
  @override
  RealmList<String?> get nullableStrings =>
      _nullableStringsProperty.getValue(this);
  @override
  set nullableStrings(covariant RealmList<String?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableBoolsProperty =
      ListProperty<bool?>('nullableBools', RealmPropertyType.bool);
  @override
  RealmList<bool?> get nullableBools => _nullableBoolsProperty.getValue(this);
  @override
  set nullableBools(covariant RealmList<bool?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableDatesProperty =
      ListProperty<DateTime?>('nullableDates', RealmPropertyType.timestamp);
  @override
  RealmList<DateTime?> get nullableDates =>
      _nullableDatesProperty.getValue(this);
  @override
  set nullableDates(covariant RealmList<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableDoublesProperty =
      ListProperty<double?>('nullableDoubles', RealmPropertyType.double);
  @override
  RealmList<double?> get nullableDoubles =>
      _nullableDoublesProperty.getValue(this);
  @override
  set nullableDoubles(covariant RealmList<double?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableObjectIdsProperty =
      ListProperty<ObjectId?>('nullableObjectIds', RealmPropertyType.objectid);
  @override
  RealmList<ObjectId?> get nullableObjectIds =>
      _nullableObjectIdsProperty.getValue(this);
  @override
  set nullableObjectIds(covariant RealmList<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableUuidsProperty =
      ListProperty<Uuid?>('nullableUuids', RealmPropertyType.uuid);
  @override
  RealmList<Uuid?> get nullableUuids => _nullableUuidsProperty.getValue(this);
  @override
  set nullableUuids(covariant RealmList<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableIntsProperty =
      ListProperty<int?>('nullableInts', RealmPropertyType.int);
  @override
  RealmList<int?> get nullableInts => _nullableIntsProperty.getValue(this);
  @override
  set nullableInts(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllCollections>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<AllCollections>(
    ObjectType.topLevel,
    AllCollections._,
    'AllCollections',
    {
      'strings': _stringsProperty,
      'bools': _boolsProperty,
      'dates': _datesProperty,
      'doubles': _doublesProperty,
      'objectIds': _objectIdsProperty,
      'uuids': _uuidsProperty,
      'ints': _intsProperty,
      'nullableStrings': _nullableStringsProperty,
      'nullableBools': _nullableBoolsProperty,
      'nullableDates': _nullableDatesProperty,
      'nullableDoubles': _nullableDoublesProperty,
      'nullableObjectIds': _nullableObjectIdsProperty,
      'nullableUuids': _nullableUuidsProperty,
      'nullableInts': _nullableIntsProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableTypes extends _NullableTypes
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
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
    _idProperty.setValue(this, id);
    _differentiatorProperty.setValue(this, differentiator);
    _stringPropProperty.setValue(this, stringProp);
    _boolPropProperty.setValue(this, boolProp);
    _datePropProperty.setValue(this, dateProp);
    _doublePropProperty.setValue(this, doubleProp);
    _objectIdPropProperty.setValue(this, objectIdProp);
    _uuidPropProperty.setValue(this, uuidProp);
    _intPropProperty.setValue(this, intProp);
  }

  NullableTypes._();

  static const _idProperty = ValueProperty<ObjectId>(
    '_id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  static const _differentiatorProperty = ValueProperty<ObjectId>(
    'differentiator',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId get differentiator => _differentiatorProperty.getValue(this);
  @override
  set differentiator(ObjectId value) =>
      _differentiatorProperty.setValue(this, value);

  static const _stringPropProperty = ValueProperty<String?>(
    'stringProp',
    RealmPropertyType.string,
  );
  @override
  String? get stringProp => _stringPropProperty.getValue(this);
  @override
  set stringProp(String? value) => _stringPropProperty.setValue(this, value);

  static const _boolPropProperty = ValueProperty<bool?>(
    'boolProp',
    RealmPropertyType.bool,
  );
  @override
  bool? get boolProp => _boolPropProperty.getValue(this);
  @override
  set boolProp(bool? value) => _boolPropProperty.setValue(this, value);

  static const _datePropProperty = ValueProperty<DateTime?>(
    'dateProp',
    RealmPropertyType.timestamp,
  );
  @override
  DateTime? get dateProp => _datePropProperty.getValue(this);
  @override
  set dateProp(DateTime? value) => _datePropProperty.setValue(this, value);

  static const _doublePropProperty = ValueProperty<double?>(
    'doubleProp',
    RealmPropertyType.double,
  );
  @override
  double? get doubleProp => _doublePropProperty.getValue(this);
  @override
  set doubleProp(double? value) => _doublePropProperty.setValue(this, value);

  static const _objectIdPropProperty = ValueProperty<ObjectId?>(
    'objectIdProp',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId? get objectIdProp => _objectIdPropProperty.getValue(this);
  @override
  set objectIdProp(ObjectId? value) =>
      _objectIdPropProperty.setValue(this, value);

  static const _uuidPropProperty = ValueProperty<Uuid?>(
    'uuidProp',
    RealmPropertyType.uuid,
  );
  @override
  Uuid? get uuidProp => _uuidPropProperty.getValue(this);
  @override
  set uuidProp(Uuid? value) => _uuidPropProperty.setValue(this, value);

  static const _intPropProperty = ValueProperty<int?>(
    'intProp',
    RealmPropertyType.int,
  );
  @override
  int? get intProp => _intPropProperty.getValue(this);
  @override
  set intProp(int? value) => _intPropProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<NullableTypes>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<NullableTypes>(
    ObjectType.topLevel,
    NullableTypes._,
    'NullableTypes',
    {
      '_id': _idProperty,
      'differentiator': _differentiatorProperty,
      'stringProp': _stringPropProperty,
      'boolProp': _boolPropProperty,
      'dateProp': _datePropProperty,
      'doubleProp': _doublePropProperty,
      'objectIdProp': _objectIdPropProperty,
      'uuidProp': _uuidPropProperty,
      'intProp': _intPropProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Event extends _Event
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Event(
    ObjectId id, {
    String? name,
    bool? isCompleted,
    int? durationInMinutes,
    String? assignedTo,
  }) {
    _idProperty.setValue(this, id);
    _nameProperty.setValue(this, name);
    _isCompletedProperty.setValue(this, isCompleted);
    _durationInMinutesProperty.setValue(this, durationInMinutes);
    _assignedToProperty.setValue(this, assignedTo);
  }

  Event._();

  static const _idProperty = ValueProperty<ObjectId>(
    '_id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  static const _nameProperty = ValueProperty<String?>(
    'stringQueryField',
    RealmPropertyType.string,
  );
  @override
  String? get name => _nameProperty.getValue(this);
  @override
  set name(String? value) => _nameProperty.setValue(this, value);

  static const _isCompletedProperty = ValueProperty<bool?>(
    'boolQueryField',
    RealmPropertyType.bool,
  );
  @override
  bool? get isCompleted => _isCompletedProperty.getValue(this);
  @override
  set isCompleted(bool? value) => _isCompletedProperty.setValue(this, value);

  static const _durationInMinutesProperty = ValueProperty<int?>(
    'intQueryField',
    RealmPropertyType.int,
  );
  @override
  int? get durationInMinutes => _durationInMinutesProperty.getValue(this);
  @override
  set durationInMinutes(int? value) =>
      _durationInMinutesProperty.setValue(this, value);

  static const _assignedToProperty = ValueProperty<String?>(
    'assignedTo',
    RealmPropertyType.string,
  );
  @override
  String? get assignedTo => _assignedToProperty.getValue(this);
  @override
  set assignedTo(String? value) => _assignedToProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<Event>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Event>(
    ObjectType.topLevel,
    Event._,
    'Event',
    {
      '_id': _idProperty,
      'stringQueryField': _nameProperty,
      'boolQueryField': _isCompletedProperty,
      'intQueryField': _durationInMinutesProperty,
      'assignedTo': _assignedToProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Party extends _Party
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Party(
    int year, {
    Friend? host,
    Party? previous,
    Iterable<Friend> guests = const [],
  }) {
    _hostProperty.setValue(this, host);
    _yearProperty.setValue(this, year);
    _previousProperty.setValue(this, previous);
    _guestsProperty.setValue(this, RealmList<Friend>(guests));
  }

  Party._();

  static const _hostProperty = ObjectProperty<Friend>('host', 'Friend');
  @override
  Friend? get host => _hostProperty.getValue(this);
  @override
  set host(covariant Friend? value) => _hostProperty.setValue(this, value);

  static const _yearProperty = ValueProperty<int>(
    'year',
    RealmPropertyType.int,
  );
  @override
  int get year => _yearProperty.getValue(this);
  @override
  set year(int value) => _yearProperty.setValue(this, value);

  static const _guestsProperty = ListProperty<Friend>(
      'guests', RealmPropertyType.object,
      linkTarget: 'Friend');
  @override
  RealmList<Friend> get guests => _guestsProperty.getValue(this);
  @override
  set guests(covariant RealmList<Friend> value) =>
      throw RealmUnsupportedSetError();

  static const _previousProperty = ObjectProperty<Party>('previous', 'Party');
  @override
  Party? get previous => _previousProperty.getValue(this);
  @override
  set previous(covariant Party? value) =>
      _previousProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<Party>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Party>(
    ObjectType.topLevel,
    Party._,
    'Party',
    {
      'host': _hostProperty,
      'year': _yearProperty,
      'guests': _guestsProperty,
      'previous': _previousProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Friend extends _Friend
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Friend(
    String name, {
    int age = 42,
    Friend? bestFriend,
    Iterable<Friend> friends = const [],
  }) {
    _nameProperty.setValue(this, name);
    _ageProperty.setValue(this, age);
    _bestFriendProperty.setValue(this, bestFriend);
    _friendsProperty.setValue(this, RealmList<Friend>(friends));
  }

  Friend._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  static const _ageProperty = ValueProperty<int>(
    'age',
    RealmPropertyType.int,
    defaultValue: 42,
  );
  @override
  int get age => _ageProperty.getValue(this);
  @override
  set age(int value) => _ageProperty.setValue(this, value);

  static const _bestFriendProperty =
      ObjectProperty<Friend>('bestFriend', 'Friend');
  @override
  Friend? get bestFriend => _bestFriendProperty.getValue(this);
  @override
  set bestFriend(covariant Friend? value) =>
      _bestFriendProperty.setValue(this, value);

  static const _friendsProperty = ListProperty<Friend>(
      'friends', RealmPropertyType.object,
      linkTarget: 'Friend');
  @override
  RealmList<Friend> get friends => _friendsProperty.getValue(this);
  @override
  set friends(covariant RealmList<Friend> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Friend>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Friend>(
    ObjectType.topLevel,
    Friend._,
    'Friend',
    {
      'name': _nameProperty,
      'age': _ageProperty,
      'bestFriend': _bestFriendProperty,
      'friends': _friendsProperty,
    },
    _nameProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Player extends _Player
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Player(
    String name, {
    Game? game,
    Iterable<int?> scoresByRound = const [],
  }) {
    _nameProperty.setValue(this, name);
    _gameProperty.setValue(this, game);
    _scoresByRoundProperty.setValue(this, RealmList<int?>(scoresByRound));
  }

  Player._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  static const _gameProperty = ObjectProperty<Game>('game', 'Game');
  @override
  Game? get game => _gameProperty.getValue(this);
  @override
  set game(covariant Game? value) => _gameProperty.setValue(this, value);

  static const _scoresByRoundProperty =
      ListProperty<int?>('scoresByRound', RealmPropertyType.int);
  @override
  RealmList<int?> get scoresByRound => _scoresByRoundProperty.getValue(this);
  @override
  set scoresByRound(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Player>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Player>(
    ObjectType.topLevel,
    Player._,
    'Player',
    {
      'name': _nameProperty,
      'game': _gameProperty,
      'scoresByRound': _scoresByRoundProperty,
    },
    _nameProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Game extends _Game
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  Game({
    Iterable<Player> winnerByRound = const [],
  }) {
    _winnerByRoundProperty.setValue(this, RealmList<Player>(winnerByRound));
  }

  Game._();

  static const _winnerByRoundProperty = ListProperty<Player>(
      'winnerByRound', RealmPropertyType.object,
      linkTarget: 'Player');
  @override
  RealmList<Player> get winnerByRound => _winnerByRoundProperty.getValue(this);
  @override
  set winnerByRound(covariant RealmList<Player> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Game>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<Game>(
    ObjectType.topLevel,
    Game._,
    'Game',
    {
      'winnerByRound': _winnerByRoundProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class AllTypesEmbedded extends _AllTypesEmbedded
    with RealmEntityMixin, RealmObjectBaseMixin, EmbeddedObjectMixin {
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
    Iterable<String?> nullableStrings = const [],
    Iterable<bool?> nullableBools = const [],
    Iterable<DateTime?> nullableDates = const [],
    Iterable<double?> nullableDoubles = const [],
    Iterable<ObjectId?> nullableObjectIds = const [],
    Iterable<Uuid?> nullableUuids = const [],
    Iterable<int?> nullableInts = const [],
  }) {
    _stringPropProperty.setValue(this, stringProp);
    _boolPropProperty.setValue(this, boolProp);
    _datePropProperty.setValue(this, dateProp);
    _doublePropProperty.setValue(this, doubleProp);
    _objectIdPropProperty.setValue(this, objectIdProp);
    _uuidPropProperty.setValue(this, uuidProp);
    _intPropProperty.setValue(this, intProp);
    _nullableStringPropProperty.setValue(this, nullableStringProp);
    _nullableBoolPropProperty.setValue(this, nullableBoolProp);
    _nullableDatePropProperty.setValue(this, nullableDateProp);
    _nullableDoublePropProperty.setValue(this, nullableDoubleProp);
    _nullableObjectIdPropProperty.setValue(this, nullableObjectIdProp);
    _nullableUuidPropProperty.setValue(this, nullableUuidProp);
    _nullableIntPropProperty.setValue(this, nullableIntProp);
    _stringsProperty.setValue(this, RealmList<String>(strings));
    _boolsProperty.setValue(this, RealmList<bool>(bools));
    _datesProperty.setValue(this, RealmList<DateTime>(dates));
    _doublesProperty.setValue(this, RealmList<double>(doubles));
    _objectIdsProperty.setValue(this, RealmList<ObjectId>(objectIds));
    _uuidsProperty.setValue(this, RealmList<Uuid>(uuids));
    _intsProperty.setValue(this, RealmList<int>(ints));
    _nullableStringsProperty.setValue(
        this, RealmList<String?>(nullableStrings));
    _nullableBoolsProperty.setValue(this, RealmList<bool?>(nullableBools));
    _nullableDatesProperty.setValue(this, RealmList<DateTime?>(nullableDates));
    _nullableDoublesProperty.setValue(
        this, RealmList<double?>(nullableDoubles));
    _nullableObjectIdsProperty.setValue(
        this, RealmList<ObjectId?>(nullableObjectIds));
    _nullableUuidsProperty.setValue(this, RealmList<Uuid?>(nullableUuids));
    _nullableIntsProperty.setValue(this, RealmList<int?>(nullableInts));
  }

  AllTypesEmbedded._();

  static const _stringPropProperty = ValueProperty<String>(
    'stringProp',
    RealmPropertyType.string,
  );
  @override
  String get stringProp => _stringPropProperty.getValue(this);
  @override
  set stringProp(String value) => _stringPropProperty.setValue(this, value);

  static const _boolPropProperty = ValueProperty<bool>(
    'boolProp',
    RealmPropertyType.bool,
  );
  @override
  bool get boolProp => _boolPropProperty.getValue(this);
  @override
  set boolProp(bool value) => _boolPropProperty.setValue(this, value);

  static const _datePropProperty = ValueProperty<DateTime>(
    'dateProp',
    RealmPropertyType.timestamp,
  );
  @override
  DateTime get dateProp => _datePropProperty.getValue(this);
  @override
  set dateProp(DateTime value) => _datePropProperty.setValue(this, value);

  static const _doublePropProperty = ValueProperty<double>(
    'doubleProp',
    RealmPropertyType.double,
  );
  @override
  double get doubleProp => _doublePropProperty.getValue(this);
  @override
  set doubleProp(double value) => _doublePropProperty.setValue(this, value);

  static const _objectIdPropProperty = ValueProperty<ObjectId>(
    'objectIdProp',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId get objectIdProp => _objectIdPropProperty.getValue(this);
  @override
  set objectIdProp(ObjectId value) =>
      _objectIdPropProperty.setValue(this, value);

  static const _uuidPropProperty = ValueProperty<Uuid>(
    'uuidProp',
    RealmPropertyType.uuid,
  );
  @override
  Uuid get uuidProp => _uuidPropProperty.getValue(this);
  @override
  set uuidProp(Uuid value) => _uuidPropProperty.setValue(this, value);

  static const _intPropProperty = ValueProperty<int>(
    'intProp',
    RealmPropertyType.int,
  );
  @override
  int get intProp => _intPropProperty.getValue(this);
  @override
  set intProp(int value) => _intPropProperty.setValue(this, value);

  static const _nullableStringPropProperty = ValueProperty<String?>(
    'nullableStringProp',
    RealmPropertyType.string,
  );
  @override
  String? get nullableStringProp => _nullableStringPropProperty.getValue(this);
  @override
  set nullableStringProp(String? value) =>
      _nullableStringPropProperty.setValue(this, value);

  static const _nullableBoolPropProperty = ValueProperty<bool?>(
    'nullableBoolProp',
    RealmPropertyType.bool,
  );
  @override
  bool? get nullableBoolProp => _nullableBoolPropProperty.getValue(this);
  @override
  set nullableBoolProp(bool? value) =>
      _nullableBoolPropProperty.setValue(this, value);

  static const _nullableDatePropProperty = ValueProperty<DateTime?>(
    'nullableDateProp',
    RealmPropertyType.timestamp,
  );
  @override
  DateTime? get nullableDateProp => _nullableDatePropProperty.getValue(this);
  @override
  set nullableDateProp(DateTime? value) =>
      _nullableDatePropProperty.setValue(this, value);

  static const _nullableDoublePropProperty = ValueProperty<double?>(
    'nullableDoubleProp',
    RealmPropertyType.double,
  );
  @override
  double? get nullableDoubleProp => _nullableDoublePropProperty.getValue(this);
  @override
  set nullableDoubleProp(double? value) =>
      _nullableDoublePropProperty.setValue(this, value);

  static const _nullableObjectIdPropProperty = ValueProperty<ObjectId?>(
    'nullableObjectIdProp',
    RealmPropertyType.objectid,
  );
  @override
  ObjectId? get nullableObjectIdProp =>
      _nullableObjectIdPropProperty.getValue(this);
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      _nullableObjectIdPropProperty.setValue(this, value);

  static const _nullableUuidPropProperty = ValueProperty<Uuid?>(
    'nullableUuidProp',
    RealmPropertyType.uuid,
  );
  @override
  Uuid? get nullableUuidProp => _nullableUuidPropProperty.getValue(this);
  @override
  set nullableUuidProp(Uuid? value) =>
      _nullableUuidPropProperty.setValue(this, value);

  static const _nullableIntPropProperty = ValueProperty<int?>(
    'nullableIntProp',
    RealmPropertyType.int,
  );
  @override
  int? get nullableIntProp => _nullableIntPropProperty.getValue(this);
  @override
  set nullableIntProp(int? value) =>
      _nullableIntPropProperty.setValue(this, value);

  static const _stringsProperty =
      ListProperty<String>('strings', RealmPropertyType.string);
  @override
  RealmList<String> get strings => _stringsProperty.getValue(this);
  @override
  set strings(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  static const _boolsProperty =
      ListProperty<bool>('bools', RealmPropertyType.bool);
  @override
  RealmList<bool> get bools => _boolsProperty.getValue(this);
  @override
  set bools(covariant RealmList<bool> value) =>
      throw RealmUnsupportedSetError();

  static const _datesProperty =
      ListProperty<DateTime>('dates', RealmPropertyType.timestamp);
  @override
  RealmList<DateTime> get dates => _datesProperty.getValue(this);
  @override
  set dates(covariant RealmList<DateTime> value) =>
      throw RealmUnsupportedSetError();

  static const _doublesProperty =
      ListProperty<double>('doubles', RealmPropertyType.double);
  @override
  RealmList<double> get doubles => _doublesProperty.getValue(this);
  @override
  set doubles(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  static const _objectIdsProperty =
      ListProperty<ObjectId>('objectIds', RealmPropertyType.objectid);
  @override
  RealmList<ObjectId> get objectIds => _objectIdsProperty.getValue(this);
  @override
  set objectIds(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  static const _uuidsProperty =
      ListProperty<Uuid>('uuids', RealmPropertyType.uuid);
  @override
  RealmList<Uuid> get uuids => _uuidsProperty.getValue(this);
  @override
  set uuids(covariant RealmList<Uuid> value) =>
      throw RealmUnsupportedSetError();

  static const _intsProperty = ListProperty<int>('ints', RealmPropertyType.int);
  @override
  RealmList<int> get ints => _intsProperty.getValue(this);
  @override
  set ints(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

  static const _nullableStringsProperty =
      ListProperty<String?>('nullableStrings', RealmPropertyType.string);
  @override
  RealmList<String?> get nullableStrings =>
      _nullableStringsProperty.getValue(this);
  @override
  set nullableStrings(covariant RealmList<String?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableBoolsProperty =
      ListProperty<bool?>('nullableBools', RealmPropertyType.bool);
  @override
  RealmList<bool?> get nullableBools => _nullableBoolsProperty.getValue(this);
  @override
  set nullableBools(covariant RealmList<bool?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableDatesProperty =
      ListProperty<DateTime?>('nullableDates', RealmPropertyType.timestamp);
  @override
  RealmList<DateTime?> get nullableDates =>
      _nullableDatesProperty.getValue(this);
  @override
  set nullableDates(covariant RealmList<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableDoublesProperty =
      ListProperty<double?>('nullableDoubles', RealmPropertyType.double);
  @override
  RealmList<double?> get nullableDoubles =>
      _nullableDoublesProperty.getValue(this);
  @override
  set nullableDoubles(covariant RealmList<double?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableObjectIdsProperty =
      ListProperty<ObjectId?>('nullableObjectIds', RealmPropertyType.objectid);
  @override
  RealmList<ObjectId?> get nullableObjectIds =>
      _nullableObjectIdsProperty.getValue(this);
  @override
  set nullableObjectIds(covariant RealmList<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableUuidsProperty =
      ListProperty<Uuid?>('nullableUuids', RealmPropertyType.uuid);
  @override
  RealmList<Uuid?> get nullableUuids => _nullableUuidsProperty.getValue(this);
  @override
  set nullableUuids(covariant RealmList<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  static const _nullableIntsProperty =
      ListProperty<int?>('nullableInts', RealmPropertyType.int);
  @override
  RealmList<int?> get nullableInts => _nullableIntsProperty.getValue(this);
  @override
  set nullableInts(covariant RealmList<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AllTypesEmbedded>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<AllTypesEmbedded>(
    ObjectType.embedded,
    AllTypesEmbedded._,
    'AllTypesEmbedded',
    {
      'stringProp': _stringPropProperty,
      'boolProp': _boolPropProperty,
      'dateProp': _datePropProperty,
      'doubleProp': _doublePropProperty,
      'objectIdProp': _objectIdPropProperty,
      'uuidProp': _uuidPropProperty,
      'intProp': _intPropProperty,
      'nullableStringProp': _nullableStringPropProperty,
      'nullableBoolProp': _nullableBoolPropProperty,
      'nullableDateProp': _nullableDatePropProperty,
      'nullableDoubleProp': _nullableDoublePropProperty,
      'nullableObjectIdProp': _nullableObjectIdPropProperty,
      'nullableUuidProp': _nullableUuidPropProperty,
      'nullableIntProp': _nullableIntPropProperty,
      'strings': _stringsProperty,
      'bools': _boolsProperty,
      'dates': _datesProperty,
      'doubles': _doublesProperty,
      'objectIds': _objectIdsProperty,
      'uuids': _uuidsProperty,
      'ints': _intsProperty,
      'nullableStrings': _nullableStringsProperty,
      'nullableBools': _nullableBoolsProperty,
      'nullableDates': _nullableDatesProperty,
      'nullableDoubles': _nullableDoublesProperty,
      'nullableObjectIds': _nullableObjectIdsProperty,
      'nullableUuids': _nullableUuidsProperty,
      'nullableInts': _nullableIntsProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class ObjectWithEmbedded extends _ObjectWithEmbedded
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  ObjectWithEmbedded(
    String value, {
    AllTypesEmbedded? singleObject,
    RecursiveEmbedded1? recursiveObject,
    Iterable<AllTypesEmbedded> list = const [],
  }) {
    _valueProperty.setValue(this, value);
    _singleObjectProperty.setValue(this, singleObject);
    _recursiveObjectProperty.setValue(this, recursiveObject);
    _listProperty.setValue(this, RealmList<AllTypesEmbedded>(list));
  }

  ObjectWithEmbedded._();

  static const _valueProperty = ValueProperty<String>(
    'value',
    RealmPropertyType.string,
  );
  @override
  String get value => _valueProperty.getValue(this);
  @override
  set value(String value) => _valueProperty.setValue(this, value);

  static const _singleObjectProperty =
      ObjectProperty<AllTypesEmbedded>('singleObject', 'AllTypesEmbedded');
  @override
  AllTypesEmbedded? get singleObject => _singleObjectProperty.getValue(this);
  @override
  set singleObject(covariant AllTypesEmbedded? value) =>
      _singleObjectProperty.setValue(this, value);

  static const _listProperty = ListProperty<AllTypesEmbedded>(
      'list', RealmPropertyType.object,
      linkTarget: 'AllTypesEmbedded');
  @override
  RealmList<AllTypesEmbedded> get list => _listProperty.getValue(this);
  @override
  set list(covariant RealmList<AllTypesEmbedded> value) =>
      throw RealmUnsupportedSetError();

  static const _recursiveObjectProperty = ObjectProperty<RecursiveEmbedded1>(
      'recursiveObject', 'RecursiveEmbedded1');
  @override
  RecursiveEmbedded1? get recursiveObject =>
      _recursiveObjectProperty.getValue(this);
  @override
  set recursiveObject(covariant RecursiveEmbedded1? value) =>
      _recursiveObjectProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<ObjectWithEmbedded>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<ObjectWithEmbedded>(
    ObjectType.topLevel,
    ObjectWithEmbedded._,
    'ObjectWithEmbedded',
    {
      'value': _valueProperty,
      'singleObject': _singleObjectProperty,
      'list': _listProperty,
      'recursiveObject': _recursiveObjectProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RecursiveEmbedded1 extends _RecursiveEmbedded1
    with RealmEntityMixin, RealmObjectBaseMixin, EmbeddedObjectMixin {
  RecursiveEmbedded1(
    String value, {
    RecursiveEmbedded2? child,
    ObjectWithEmbedded? topLevel,
    Iterable<RecursiveEmbedded2> children = const [],
  }) {
    _valueProperty.setValue(this, value);
    _childProperty.setValue(this, child);
    _topLevelProperty.setValue(this, topLevel);
    _childrenProperty.setValue(this, RealmList<RecursiveEmbedded2>(children));
  }

  RecursiveEmbedded1._();

  static const _valueProperty = ValueProperty<String>(
    'value',
    RealmPropertyType.string,
  );
  @override
  String get value => _valueProperty.getValue(this);
  @override
  set value(String value) => _valueProperty.setValue(this, value);

  static const _childProperty =
      ObjectProperty<RecursiveEmbedded2>('child', 'RecursiveEmbedded2');
  @override
  RecursiveEmbedded2? get child => _childProperty.getValue(this);
  @override
  set child(covariant RecursiveEmbedded2? value) =>
      _childProperty.setValue(this, value);

  static const _childrenProperty = ListProperty<RecursiveEmbedded2>(
      'children', RealmPropertyType.object,
      linkTarget: 'RecursiveEmbedded2');
  @override
  RealmList<RecursiveEmbedded2> get children =>
      _childrenProperty.getValue(this);
  @override
  set children(covariant RealmList<RecursiveEmbedded2> value) =>
      throw RealmUnsupportedSetError();

  static const _topLevelProperty =
      ObjectProperty<ObjectWithEmbedded>('topLevel', 'ObjectWithEmbedded');
  @override
  ObjectWithEmbedded? get topLevel => _topLevelProperty.getValue(this);
  @override
  set topLevel(covariant ObjectWithEmbedded? value) =>
      _topLevelProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded1>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<RecursiveEmbedded1>(
    ObjectType.embedded,
    RecursiveEmbedded1._,
    'RecursiveEmbedded1',
    {
      'value': _valueProperty,
      'child': _childProperty,
      'children': _childrenProperty,
      'topLevel': _topLevelProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RecursiveEmbedded2 extends _RecursiveEmbedded2
    with RealmEntityMixin, RealmObjectBaseMixin, EmbeddedObjectMixin {
  RecursiveEmbedded2(
    String value, {
    RecursiveEmbedded3? child,
    ObjectWithEmbedded? topLevel,
    Iterable<RecursiveEmbedded3> children = const [],
  }) {
    _valueProperty.setValue(this, value);
    _childProperty.setValue(this, child);
    _topLevelProperty.setValue(this, topLevel);
    _childrenProperty.setValue(this, RealmList<RecursiveEmbedded3>(children));
  }

  RecursiveEmbedded2._();

  static const _valueProperty = ValueProperty<String>(
    'value',
    RealmPropertyType.string,
  );
  @override
  String get value => _valueProperty.getValue(this);
  @override
  set value(String value) => _valueProperty.setValue(this, value);

  static const _childProperty =
      ObjectProperty<RecursiveEmbedded3>('child', 'RecursiveEmbedded3');
  @override
  RecursiveEmbedded3? get child => _childProperty.getValue(this);
  @override
  set child(covariant RecursiveEmbedded3? value) =>
      _childProperty.setValue(this, value);

  static const _childrenProperty = ListProperty<RecursiveEmbedded3>(
      'children', RealmPropertyType.object,
      linkTarget: 'RecursiveEmbedded3');
  @override
  RealmList<RecursiveEmbedded3> get children =>
      _childrenProperty.getValue(this);
  @override
  set children(covariant RealmList<RecursiveEmbedded3> value) =>
      throw RealmUnsupportedSetError();

  static const _topLevelProperty =
      ObjectProperty<ObjectWithEmbedded>('topLevel', 'ObjectWithEmbedded');
  @override
  ObjectWithEmbedded? get topLevel => _topLevelProperty.getValue(this);
  @override
  set topLevel(covariant ObjectWithEmbedded? value) =>
      _topLevelProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded2>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<RecursiveEmbedded2>(
    ObjectType.embedded,
    RecursiveEmbedded2._,
    'RecursiveEmbedded2',
    {
      'value': _valueProperty,
      'child': _childProperty,
      'children': _childrenProperty,
      'topLevel': _topLevelProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RecursiveEmbedded3 extends _RecursiveEmbedded3
    with RealmEntityMixin, RealmObjectBaseMixin, EmbeddedObjectMixin {
  RecursiveEmbedded3(
    String value,
  ) {
    _valueProperty.setValue(this, value);
  }

  RecursiveEmbedded3._();

  static const _valueProperty = ValueProperty<String>(
    'value',
    RealmPropertyType.string,
  );
  @override
  String get value => _valueProperty.getValue(this);
  @override
  set value(String value) => _valueProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<RecursiveEmbedded3>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<RecursiveEmbedded3>(
    ObjectType.embedded,
    RecursiveEmbedded3._,
    'RecursiveEmbedded3',
    {
      'value': _valueProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}
