# Description
Generates RealmObject files based on schema classes using naming convention

Every dart class defined as `class _ClassName` that defines at least a single field with `@RealmProperty` annotation is considered a realm schema file and the code generator will generate a RealmObject class that can be used with Realm Dart. 

* The dart file containg Realm schema classes needs to have a part defintion name in the format `part "filename.g.dart"`.
    For example: In file `cars.dat ` there should be a part definition `part "cars.g.dart"`
* The underscore in the class name is requried by convention. `class _Car`
* Every field that references another RealmObject must use the schema class name of that RealmObject. For example `_Car secondCar`
* The generator will infer the Realm type from the dart type of the annotated `@RealmProperty` field `String make` is Realm `string`
* The @RealmProperty annotation has a `type:` property which can be used to override the type inference if needed

# Example  
Filename: `cars.dart`

```Dart
part "cars.g.dart"

class _Car {
  @RealmProperty()
  String make;

  @RealmProperty(type: "string")
  String model;

  @RealmProperty(defaultValue: "50", optional: true)
  String kilometers;

  @RealmProperty(optional: true, defaultValue: "5")
  _Car secondCar;

  @RealmProperty(optional: true)
  List<_Car> allOtherCars;
}
```

Generated output 
fileName `cars.g.dart`
```Dart
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
  static dynamic schema() {
    return RealmObject.getSchema('Car', [
      new SchemaProperty('make', type: 'string'),
      new SchemaProperty('model', type: 'string'),
      new SchemaProperty('kilometers', type: 'string', defaultValue: '50', optional: true),
      new SchemaProperty('secondCar', type: 'Car', optional: true, defaultValue: '5'),
      new SchemaProperty('allOtherCars', type: 'Car[]', optional: true),
    ]);
  }
}
```





on first use .dart_tool/build/entrypoint/build.dart needs to be generated with pub run build_runeer build

use a terminal to launch a debuggee with command
dart --observe --pause-isolates-on-start  --enable-vm-service:5858/127.0.0.1  --disable-service-auth-codes .dart_tool/build/entrypoint/build.dart build
to run build in usage dir use: cd usage && pub run build_runner build