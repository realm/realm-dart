// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  Car._constructor() : super.constructor();
  Car() {}

  @RealmProperty()
  String get make => super['make'];
  set make(String value) => super['make'] = value;

  @RealmProperty()
  String get model => super['model'];
  set model(String value) => super['model'] = value;

  @RealmProperty(defaultValue: '500', optional: true)
  int get kilometers => super['kilometers'];
  set kilometers(int value) => super['kilometers'] = value;

  static dynamic getSchema() {
    return RealmObject.getSchema('Car', [
      new SchemaProperty('make', type: 'string'),
      new SchemaProperty('model', type: 'string'),
      new SchemaProperty('kilometers', type: 'int', defaultValue: '500', optional: true),
    ]);
  }
}

class Person extends RealmObject {
  Person._constructor() : super.constructor();
  Person() {}

  @RealmProperty()
  String get name => super['name'];
  set name(String value) => super['name'] = value;

  @RealmProperty()
  int get age => super['age'];
  set age(int value) => super['age'] = value;

  @RealmProperty()
  List<Car> get cars => this.super_get<Car>('cars');
  set cars(List<Car> value) => this.super_set<Car>('cars', value);

  static dynamic getSchema() {
    return RealmObject.getSchema('Person', [
      new SchemaProperty('name', type: 'string'),
      new SchemaProperty('age', type: 'int'),
      new SchemaProperty('cars', type: 'Car[]'),
    ]);
  }
}

class ServicedCar extends RealmObject {
  ServicedCar._constructor() : super.constructor();
  ServicedCar() {}

  @RealmProperty(primaryKey: true)
  int get id => super['id'];
  set id(int value) => super['id'] = value;

  @RealmProperty()
  Car get car => super['car'];
  set car(Car value) => super['car'] = value;

  static dynamic getSchema() {
    return RealmObject.getSchema('ServicedCar', [
      new SchemaProperty('id', type: 'int', primaryKey: true),
      new SchemaProperty('car', type: 'Car'),
    ]);
  }
}
