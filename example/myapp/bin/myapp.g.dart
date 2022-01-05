// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myapp.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  static var _defaultsSet = false;

  Car(
    String make,
    bool b,
    String text,
    int i,
    double d,
    Uint8List data,
    DateTime timestamp,
    ObjectId id,
    Decimal128 decimal,
    Uuid uuid,
    RealmAny any, {
    Person? person,
    Uint8List? bytes,
    int? who,
  }) {
    this.make = make;
    if (person != null) this.person = person;
    if (bytes != null) this.bytes = bytes;
    if (who != null) this.who = who;
    this.b = b;
    this.text = text;
    this.i = i;
    this.d = d;
    this.data = data;
    this.timestamp = timestamp;
    this.id = id;
    this.decimal = decimal;
    this.uuid = uuid;
    this.any = any;
    _defaultsSet = _defaultsSet ||
        RealmObject.setDefaults<Car>({
          'bytes': Uint8List(10),
        });
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObject.set(this, 'make', value);

  @override
  Person? get person => RealmObject.get<Person>(this, 'person') as Person?;
  @override
  set person(covariant Person? value) => RealmObject.set(this, 'person', value);

  @override
  Uint8List get bytes => RealmObject.get<Uint8List>(this, 'bytes') as Uint8List;
  @override
  set bytes(Uint8List value) => RealmObject.set(this, 'bytes', value);

  @override
  int? get who => RealmObject.get<int>(this, 'who') as int?;
  @override
  set who(int? value) => RealmObject.set(this, 'who', value);

  @override
  bool get b => RealmObject.get<bool>(this, 'b') as bool;
  @override
  set b(bool value) => RealmObject.set(this, 'b', value);

  @override
  String get text => RealmObject.get<String>(this, 'text') as String;
  @override
  set text(String value) => RealmObject.set(this, 'text', value);

  @override
  int get i => RealmObject.get<int>(this, 'i') as int;
  @override
  set i(int value) => RealmObject.set(this, 'i', value);

  @override
  double get d => RealmObject.get<double>(this, 'd') as double;
  @override
  set d(double value) => RealmObject.set(this, 'd', value);

  @override
  Uint8List get data => RealmObject.get<Uint8List>(this, 'data') as Uint8List;
  @override
  set data(Uint8List value) => RealmObject.set(this, 'data', value);

  @override
  DateTime get timestamp =>
      RealmObject.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) => RealmObject.set(this, 'timestamp', value);

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObject.set(this, 'id', value);

  @override
  Decimal128 get decimal =>
      RealmObject.get<Decimal128>(this, 'decimal') as Decimal128;
  @override
  set decimal(Decimal128 value) => RealmObject.set(this, 'decimal', value);

  @override
  Uuid get uuid => RealmObject.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObject.set(this, 'uuid', value);

  @override
  RealmAny get any => RealmObject.get<RealmAny>(this, 'any') as RealmAny;
  @override
  set any(RealmAny value) => RealmObject.set(this, 'any', value);

  @override
  List<int> get serviceAt =>
      RealmObject.get<int>(this, 'serviceAt') as List<int>;
  set _serviceAt(List<int> value) => RealmObject.set(this, 'serviceAt', value);

  @override
  Set<String> get part => RealmObject.get<String>(this, 'part') as Set<String>;
  set _part(Set<String> value) => RealmObject.set(this, 'part', value);

  @override
  Map<String, String> get properties =>
      RealmObject.get<String>(this, 'properties') as Map<String, String>;
  set _properties(Map<String, String> value) =>
      RealmObject.set(this, 'properties', value);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory<Car>(() => Car._());
    return const SchemaObject(Car, [
      SchemaProperty('make', RealmPropertyType.string),
      SchemaProperty('person', RealmPropertyType.object,
          optional: true, linkTarget: 'Person'),
      SchemaProperty('bytes', RealmPropertyType.binary),
      SchemaProperty('who', RealmPropertyType.int, optional: true),
      SchemaProperty('b', RealmPropertyType.bool),
      SchemaProperty('text', RealmPropertyType.string),
      SchemaProperty('i', RealmPropertyType.int),
      SchemaProperty('d', RealmPropertyType.double),
      SchemaProperty('data', RealmPropertyType.binary),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('id', RealmPropertyType.objectid),
      SchemaProperty('decimal', RealmPropertyType.decimal128),
      SchemaProperty('uuid', RealmPropertyType.uuid),
      SchemaProperty('any', RealmPropertyType.mixed),
      SchemaProperty('serviceAt', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('part', RealmPropertyType.string,
          collectionType: RealmCollectionType.set),
      SchemaProperty('properties', RealmPropertyType.string,
          collectionType: RealmCollectionType.dictionary),
    ]);
  }
}

class Person extends _Person with RealmObject {
  static var _defaultsSet = false;

  Person(
    String name,
    int born, {
    int? age,
    Car? car,
  }) {
    _name = name;
    if (age != null) this.age = age;
    this.born = born;
    if (car != null) this.car = car;
    _defaultsSet = _defaultsSet ||
        RealmObject.setDefaults<Person>({
          'age': 47,
        });
  }

  Person._();

  @override
  String get name => RealmObject.get<String>(this, 'navn') as String;
  set _name(String value) => RealmObject.set(this, 'navn', value);

  @override
  int? get age => RealmObject.get<int>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObject.set(this, 'age', value);

  @override
  int get born => RealmObject.get<int>(this, 'born') as int;
  @override
  set born(int value) => RealmObject.set(this, 'born', value);

  @override
  Car? get car => RealmObject.get<Car>(this, 'car') as Car?;
  @override
  set car(covariant Car? value) => RealmObject.set(this, 'car', value);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory<Person>(() => Person._());
    return const SchemaObject(Person, [
      SchemaProperty('navn', RealmPropertyType.string,
          mapTo: 'navn', primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int, optional: true),
      SchemaProperty('born', RealmPropertyType.int),
      SchemaProperty('car', RealmPropertyType.object,
          optional: true, linkTarget: 'Car'),
    ]);
  }
}
