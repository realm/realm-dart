// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  // ignore_for_file: unused_element, unused_local_variable
  Car._constructor() : super.constructor();
  Car();

  @RealmProperty()
  String get make => super['make'] as String;
  set make(String value) => super['make'] = value;

  @RealmProperty()
  String get model => super['model'] as String;
  set model(String value) => super['model'] = value;

  @RealmProperty(defaultValue: "500", optional: true)
  int get kilometers => super['kilometers'] as int;
  set kilometers(int value) => super['kilometers'] = value;

  static dynamic getSchema() {
    const dynamic type = _Car;
    return RealmObject.getSchema('Car', [
      SchemaProperty('make', type: 'string'),
      SchemaProperty('model', type: 'string'),
      SchemaProperty('kilometers', type: 'int', defaultValue: "500", optional: true),
    ]);
  }
}

class Person extends RealmObject {
  // ignore_for_file: unused_element, unused_local_variable
  Person._constructor() : super.constructor();
  Person();

  @RealmProperty()
  String get name => super['name'] as String;
  set name(String value) => super['name'] = value;

  @RealmProperty()
  int get age => super['age'] as int;
  set age(int value) => super['age'] = value;

  @RealmProperty()
  List<Car> get cars => this.super_get<Car>('cars');
  set cars(List<Car> value) => this.super_set<Car>('cars', value);

  static dynamic getSchema() {
    const dynamic type = _Person;
    return RealmObject.getSchema('Person', [
      SchemaProperty('name', type: 'string'),
      SchemaProperty('age', type: 'int'),
      SchemaProperty('cars', type: 'Car[]'),
    ]);
  }
}

class ServicedCar extends RealmObject {
  // ignore_for_file: unused_element, unused_local_variable
  ServicedCar._constructor() : super.constructor();
  ServicedCar();

  @RealmProperty(primaryKey: true)
  int get id => super['id'] as int;
  set id(int value) => super['id'] = value;

  @RealmProperty()
  Car get car => super['car'] as Car;
  set car(Car value) => super['car'] = value;

  static dynamic getSchema() {
    const dynamic type = _ServicedCar;
    return RealmObject.getSchema('ServicedCar', [
      SchemaProperty('id', type: 'int', primaryKey: true),
      SchemaProperty('car', type: 'Car'),
    ]);
  }
}
