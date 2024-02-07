import 'dart:async';
import 'dart:io';
import 'package:realm_dart/realm.dart';

part 'myapp.realm.dart';

@RealmModel()
class _Car {
  late String make;
  String? model;
  int? kilometers = 500;
  _Person? owner;
}

@RealmModel()
class _Person {
  late String name;
  int age = 1;
}

void main(List<String> arguments) async {
  print("Current PID $pid");
  var config = Configuration.local([Car.schema, Person.schema]);

  var realm = Realm(config);

  realm.all<Car>().changes.listen((e) {
    print("listen callback called");
  });

  //allow changes event to fire
  await Future<void>.delayed(Duration(milliseconds: 1));

  var myCar = Car("Tesla", model: "Model Y", kilometers: 1);
  realm.write(() {
    print('Adding a Car to Realm.');
    var car = realm.add(Car("Tesla", owner: Person("John")));
    print("Updating the car's model and kilometers");
    car.model = "Model 3";
    car.kilometers = 5000;

    print('Adding another Car to Realm.');
    realm.add(myCar);

    print("Changing the owner of the car.");
    myCar.owner = Person("me", age: 18);
    print("The car has a new owner ${car.owner!.name}");
  });

  print("Getting all cars from the Realm.");
  var cars = realm.all<Car>();
  print("There are ${cars.length} cars in the Realm.");

  var indexedCar = cars[0];
  print('The first car is ${indexedCar.make} ${indexedCar.model}');

  print("Getting all Tesla cars from the Realm.");
  var filteredCars = realm.all<Car>().query("make == 'Tesla'");
  print('Found ${filteredCars.length} Tesla cars');

  //allow changes event to fire
  await Future<void>.delayed(Duration(milliseconds: 1));

  realm.close();
  
  //This is only needed in Dart apps as a workaround for https://github.com/dart-lang/sdk/issues/49083
  Realm.shutdown();
  print("Done");
}
