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

import 'dart:io';

import 'realm.dart';

// import 'package:realm/realm.dart'

part 'main.gen.dart';

@RealmModel()
class _Car {
  late String make;
}

@RealmModel()
class _Person {
  late String name; 
}

void main() {
  print("Current PID ${pid}");

  //can read the default config
  {
    var config = new Configuration([Car.schema, Person.schema]);
    
  }


  var config = new Configuration([Car.schema, Person.schema]);



  var realm2 = new Realm(config);

  // realm.write(() {
  //   print("realm write callback");
  //   var car = realm.create(new Car()..make = "Audi");
  //   print("The car is ${car.make}");
  //   // car.make = "VW";
  //   // print("The car is ${car.make}");
  // });

  // var objects = realm.objects<Car>();
  // var indexedCar = objects[0];
  // print("The indexedCar is ${indexedCar.make}");

  print("Exit");
}