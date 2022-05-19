////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

part 'main.g.dart';

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

void main() {
  print("Current PID $pid");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Realm realm;

  _MyAppState() {
    final config = Configuration.local([Car.schema, Person.schema]);
    realm = Realm(config);
  }

  int get carsCount => realm.all<Car>().length;

  @override
  void initState() {
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: ${Platform.operatingSystem}.\n\nThere are $carsCount cars in the Realm.\n'),
        ),
      ),
    );
  }
}
