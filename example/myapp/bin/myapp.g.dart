// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myapp.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  Car({
    required String make,
    required Person person,
    Uint8List? bytes,
    int? who,
    required bool b,
    required String text,
    required int i,
    required double d,
    required Uint8List data,
    required DateTime timestamp,
    required ObjectId id,
    required Decimal128 decimal,
    required Uuid uuid,
    required RealmAny any,
    List<int>? serviceAt,
    Set<String>? part,
    Map<String, String>? properties,
  }) {
    this.make = make;
    this.person = person;
    this.bytes = bytes ?? Uint8List(10);
    this.who = who;
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
    this.serviceAt = serviceAt ?? [10000, 20000, Random().nextInt(15000) + 20000];
    this.part = part ?? {'engine', 'wheel'};
    this.properties = properties ?? {'color': 'yellow'};
  }

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObject.set(this, 'make', value);

  @override
  Person get person => RealmObject.get<Person>(this, 'person') as Person;
  @override
  set person(covariant Person value) => RealmObject.set(this, 'person', value);

  @override
  Uint8List get bytes => RealmObject.get<Uint8List>(this, 'bytes') as Uint8List;
  @override
  set bytes(Uint8List value) => RealmObject.set(this, 'bytes', value);

  @override
  int? get who => RealmObject.get<int?>(this, 'who') as int?;
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
  DateTime get timestamp => RealmObject.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) => RealmObject.set(this, 'timestamp', value);

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObject.set(this, 'id', value);

  @override
  Decimal128 get decimal => RealmObject.get<Decimal128>(this, 'decimal') as Decimal128;
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
  List<int> get serviceAt => RealmObject.get<List<int>>(this, 'serviceAt') as List<int>;
  @override
  set serviceAt(List<int> value) => RealmObject.set(this, 'serviceAt', value);

  @override
  Set<String> get part => RealmObject.get<Set<String>>(this, 'part') as Set<String>;
  @override
  set part(Set<String> value) => RealmObject.set(this, 'part', value);

  @override
  Map<String, String> get properties => RealmObject.get<Map<String, String>>(this, 'properties') as Map<String, String>;
  @override
  set properties(Map<String, String> value) => RealmObject.set(this, 'properties', value);

  static const schema = SchemaObject(Car, [
    SchemaProperty('make', RealmPropertyType.string),
    SchemaProperty('person', RealmPropertyType.object),
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
    SchemaProperty('serviceAt', RealmPropertyType.int),
    SchemaProperty('part', RealmPropertyType.string),
    SchemaProperty('properties', RealmPropertyType.string),
  ]);
}

class Person extends _Person with RealmObject {
  Person({
    required String name,
    int? age,
    required int born,
    required Car car,
  }) {
    _name = name;
    this.age = age ?? 47;
    this.born = born;
    this.car = car;
  }

  @override
  String get name => RealmObject.get<String>(this, 'navn') as String;
  set _name(String value) => RealmObject.set(this, 'navn', value);

  @override
  int? get age => RealmObject.get<int?>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObject.set(this, 'age', value);

  @override
  int get born => RealmObject.get<int>(this, 'born') as int;
  @override
  set born(int value) => RealmObject.set(this, 'born', value);

  @override
  Car get car => RealmObject.get<Car>(this, 'car') as Car;
  @override
  set car(covariant Car value) => RealmObject.set(this, 'car', value);

  static const schema = SchemaObject(Person, [
    SchemaProperty('navn', RealmPropertyType.string, mapTo: 'navn', primaryKey: true),
    SchemaProperty('age', RealmPropertyType.int, optional: true),
    SchemaProperty('born', RealmPropertyType.int),
    SchemaProperty('car', RealmPropertyType.object),
  ]);
}
