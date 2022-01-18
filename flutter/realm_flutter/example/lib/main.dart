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
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

part 'main.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make = "Tesla";
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
  @override
  void initState() {
    Configuration config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() {
      var car = realm.add(Car()..make = "Audi");
      print("The car is ${car.make}");
      car.make = "VW";
      print("The car is ${car.make}");
    });

    var objects = realm.all<Car>();
    var indexedCar = objects[0];
    print("The indexedCar is ${indexedCar.make}");

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
          child: Text('Running on: ${Platform.operatingSystem}\n'),
        ),
      ),
    );
  }
}
