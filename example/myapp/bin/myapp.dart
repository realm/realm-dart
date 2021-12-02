import 'dart:math';
import 'dart:typed_data';

import 'package:realm_dart/realm.dart';

part 'myapp.g.dart';

@RealmModel()
class _Car {
  late String make;
  late _Person person;
  var bytes = Uint8List(10);
  int? who;

  late bool b;
  late String text;
  late int i;
  // late Float f;
  late double d;
  late Uint8List data;
  late DateTime timestamp;
  late ObjectId id;
  late Decimal128 decimal;
  late Uuid uuid;

  late RealmAny any;

  // List<int> with complex default value!
  var serviceAt = [
    10000,
    20000,
    Random().nextInt(15000) + 20000,
  ];

  var part = {'engine', 'wheel'};
  var properties = {'color': 'yellow'};

  // List<List<int>> .. not allowed
  //var bad = [[1]];
  //late List<Set<int>> stuff;
}

@RealmModel()
class _Person {
  @MapTo('navn')
  @PrimaryKey()
  late final String name;
  @Indexed()
  int? age = 47;
  @Ignored()
  var friends = <_Person>[];
  late int born;
  late _Car car;
}

void main(List<String> arguments) {
  var config = Configuration([Car.schema]);

  var realm = Realm(config);

  // realm.write(() {
  //   print('Creating Realm object of type Car');
  //   var car = realm.create(new Car()..make = "Audi");
  //   print('The car is ${car.make}');

  //   car.make = "VW";
  //   print("The car is ${car.make}");
  // });

  // var objects = realm.objects<Car>();
  // var indexedCar = objects[0];
  // print('The indexedCar is ${indexedCar.make}');

  // print("Done");
}
