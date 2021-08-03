// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  Car._constructor() : super.constructor();
  Car() {}

  @RealmProperty()
  String get make => super['make'];
  set make(String value) => super['make'] = value;

  @RealmProperty(type: 'string')
  String get model => super['model'];
  set model(String value) => super['model'] = value;

  @RealmProperty(defaultValue: '50', optional: true)
  String get kilometers => super['kilometers'];
  set kilometers(String value) => super['kilometers'] = value;

  @RealmProperty(optional: true, defaultValue: '5')
  Car get secondCar => super['secondCar'];
  set secondCar(Car value) => super['secondCar'] = value;

  @RealmProperty(optional: true)
  List<Car> get allOtherCars => this.super_get<Car>('allOtherCars');
  set allOtherCars(List<Car> value) => this.super_set<Car>('allOtherCars', value);

  @override
  dynamic get _schema {
    return RealmObject.getSchema('Car', [
      new SchemaProperty('make', type: 'string'),
      new SchemaProperty('model', type: 'string'),
      new SchemaProperty('kilometers', type: 'string', defaultValue: '50', optional: true),
      new SchemaProperty('secondCar', type: 'Car', optional: true, defaultValue: '5'),
      new SchemaProperty('allOtherCars', type: 'Car[]', optional: true),
    ]);
  }
}
