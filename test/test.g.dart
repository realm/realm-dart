// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Car>(
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

class Person extends _Person with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Person>(
    Person._,
    'Person',
    {
      'name': _nameProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class Dog extends _Dog with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Dog>(
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

class Team extends _Team with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Team>(
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

class Student extends _Student with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Student>(
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

class School extends _School with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<School>(
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
    with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<RemappedClass>(
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

class Task extends _Task with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Task>(
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

class Schedule extends _Schedule with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Schedule>(
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

class AllTypes extends _AllTypes with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<AllTypes>(
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

class LinksClass extends _LinksClass with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<LinksClass>(
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
    with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<AllCollections>(
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
    with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<NullableTypes>(
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

class Event extends _Event with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Event>(
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

class Party extends _Party with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Party>(
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

class Friend extends _Friend with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Friend>(
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

class Player extends _Player with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Player>(
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

class Game extends _Game with RealmEntityMixin, RealmObjectMixin {
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
      RealmObjectMixin.getChanges(this);

  static const schema = SchemaObject<Game>(
    Game._,
    'Game',
    {
      'winnerByRound': _winnerByRoundProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}
