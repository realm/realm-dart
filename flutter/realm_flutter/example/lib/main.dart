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

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
// import 'package:realm/realm_flutter.dart';
import 'package:realm/realm.dart';

part 'main.g.dart';

class _Car {
  @RealmProperty()
  String make;
}

void main() {
  initRealm();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    print("initState");
    var config = new Configuration();
    config.schema.add(Car);

    var realm = new Realm(config);

    realm.write(() {
      print("realm write callback");
      var car = realm.create(new Car()..make = "Audi");
      print("The car is ${car.make}");
      // car.make = "VW";
      // print("The car is ${car.make}");
    });

    var objects = realm.objects<Car>();
    var indexedCar = objects[0];
    print("The indexedCar is ${indexedCar.make}");

    super.initState();
    //initPlatformState();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await RealmFlutter.platformVersion;
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
