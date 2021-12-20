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

// ignore_for_file: unused_local_variable

import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

import '../lib/realm.dart';
import '../lib/src/native/realm_core.dart' as core;

part 'realm_test.gen.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make = "Tesla";
}

@RealmModel()
class _Person {
  late String name;
}

@RealmModel()
class _Dog {
  @PrimaryKey()
  late String name;

  late int? age;

  _Person? owner;
}

@RealmModel()
class _Team {
  late String name;
  late List<_Person> players;
}

String? testName;

//Overrides test method so we can filter tests
void test(String? name, dynamic Function() testFunction, {dynamic skip}) {
  if (testName != null && !name!.contains(testName!)) {
    return;
  }
  testing.test(name, testFunction, skip: skip);
}

void xtest(String? name, dynamic Function() testFunction) {
  testing.test(name, testFunction, skip: "Test is disabled");
}

void parseTestNameFromArguments(List<String>? arguments) {
  arguments = arguments ?? List.empty();
  int nameArgIndex = arguments.indexOf("--name");
  if (arguments.isNotEmpty) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      print("testName: $testName");
      testName = arguments[nameArgIndex + 1];
    }
  }
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message', contains(message ?? '')));

final random = Random();
String generateRandomString(int len) {
  const _chars = 'abcdefghjklmnopqrstuvwxuz';
  return List.generate(len, (index) => _chars[random.nextInt(_chars.length)]).join();
}

Future<void> tryDeleteFile(FileSystemEntity fileEntity, {bool recursive = false}) async {
  for (var i = 0; i < 20; i++) {
    try {
      await fileEntity.delete(recursive: recursive);
      break;
    } catch (e) {
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
  }
}

Future<void> main([List<String>? args]) async {
  parseTestNameFromArguments(args);

  print("Current PID $pid");

  setUp(() {
    String path = "${generateRandomString(10)}.realm";
    if (Platform.isAndroid || Platform.isIOS) {
      path = _path.join(Configuration.filesPath, path);
    }
    Configuration.defaultPath = path;

    addTearDown(() async {
      var file = File(path);
      if (await file.exists() && file.path.endsWith(".realm")) {
        await tryDeleteFile(file);
      }

      file = File("$path.lock");
      if (await file.exists()) {
        await tryDeleteFile(file);
      }

      final dir = Directory("$path.management");
      if (await dir.exists()) {
        if ((await dir.stat()).type == FileSystemEntityType.directory) {
          await tryDeleteFile(dir, recursive: true);
        }
      }
    });
  });

  group('Configuration tests:', () {
    test('Configuration can be created', () {
      Configuration([Car.schema]);
    });

    test('Configuration exception if no schema', () {
      expect(() => Configuration([]), throws<RealmException>());
    });

    test('Configuration default path', () {
      if (Platform.isAndroid || Platform.isIOS) {
        expect(Configuration.defaultPath, endsWith(".realm"));
        expect(Configuration.defaultPath, startsWith("/"), reason: "on Android and iOS the default path should contain the path to the user data directory");
      } else {
        expect(Configuration.defaultPath, endsWith(".realm"));
      }
    });

    test('Configuration files path', () {
      if (Platform.isAndroid || Platform.isIOS) {
        expect(Configuration.filesPath, isNot(endsWith(".realm")), reason: "on Android and iOS the files path should be a directory");
        expect(Configuration.filesPath, startsWith("/"), reason: "on Android and iOS the files path should be a directory");
      } else {
        expect(Configuration.filesPath, equals(""), reason: "on Dart standalone the files path should be an empty string");
      }
    });

    test('Configuration get/set path', () {
      Configuration config = Configuration([Car.schema]);
      expect(config.path, endsWith('.realm'));

      const path = "my/path/default.realm";
      config.path = path;
      expect(config.path, equals(path));
    });

    test('Configuration get/set schema version', () {
      Configuration config = Configuration([Car.schema]);
      expect(config.schemaVersion, equals(0));

      config.schemaVersion = 3;
      expect(config.schemaVersion, equals(3));
    });
  });

  group('RealmClass tests:', () {
    test('Realm can be created', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
    });

    test('Realm can be closed', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      realm.close();

      realm = Realm(config);
      realm.close();

      //Calling close() twice should not throw exceptions
      realm.close();
    });

    test('Realm can be closed and opened again', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      realm.close();

      //should not throw exception
      realm = Realm(config);
    });

    test('Realm is closed', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);     
      expect(realm.isClosed, false);

      realm.close();    
      expect(realm.isClosed, true);
    });

    test('Realm open with schema subset', () {
      var config = Configuration([Car.schema, Person.schema]);
      var realm = Realm(config);
      realm.close();

      config = Configuration([Car.schema]);
      realm = Realm(config);
    });

    test('Realm open with schema superset', () {
      var config = Configuration([Person.schema]);
      var realm = Realm(config);
      realm.close();

      var config1 = Configuration([Person.schema, Car.schema]);
      var realm1 = Realm(config1);
    });

    test('Realm open twice with same schema', () async {
      var config = Configuration([Person.schema, Car.schema]);
      var realm = Realm(config);

      var config1 = Configuration([Person.schema, Car.schema]);
      var realm1 = Realm(config1);
    });

    test('Realm add throws when no write transaction', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      final car = Car();
      expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
    });

    test('Realm add object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() {
        realm.add(Car());
      });
    });

    test('Realm add object twice does not throw', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() {
        final car = Car();
        realm.add(car);

        //second add of the same object does not throw and return the same object
        final car1 = realm.add(car);
        expect(car1, equals(car));
      });
    });

    test('Realm adding not configured object throws exception', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() => realm.write(() => realm.add(Person())), throws<RealmException>("not configured"));
    });

    test('Realm add() returns the same object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car();
      Car? addedCar;
      realm.write(() {
        addedCar = realm.add(car);
      });

      expect(addedCar == car, isTrue);
    });

    test('Realm add object transaction rollbacks on exception', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() {
        realm.write(() {
          realm.add(Car()..make = "Tesla");
          throw Exception("some exception while adding objects");
        });
      }, throws<Exception>("some exception while adding objects"));

      final car = realm.find<Car>("Telsa");
      expect(car, isNull);
    });

    test('RealmObject get property', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car();
      realm.write(() {
        realm.add(car);
      });

      expect(car.make, equals('Tesla'));
    });

    test('RealmObject set property', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car();
      realm.write(() {
        realm.add(car);
      });

      expect(car.make, equals('Tesla'));

      realm.write(() {
        car.make = "Audi";
      });

      expect(car.make, equals('Audi'));
    });

    test('RealmObject set object type property (link)', () {
      var config = Configuration([Person.schema, Dog.schema]);
      var realm = Realm(config);

      final dog = Dog()
        ..name = "MyDog"
        ..owner = (Person()..name = "MyOwner");
      realm.write(() {
        realm.add(dog);
      });

      expect(dog.name, 'MyDog');
      expect(dog.owner, isNotNull);
      expect(dog.owner!.name, 'MyOwner');
    });

    test('RealmObject set property null', () {
      var config = Configuration([Person.schema, Dog.schema]);
      var realm = Realm(config);

      final dog = Dog()
        ..name = "MyDog"
        ..owner = (Person()..name = "MyOwner")
        ..age = 5;
      realm.write(() {
        realm.add(dog);
      });

      expect(dog.name, 'MyDog');
      expect(dog.age, 5);
      expect(dog.owner, isNotNull);
      expect(dog.owner!.name, 'MyOwner');

      realm.write(() {
        dog.age = null;
      });

      expect(dog.age, null);

      realm.write(() {
        dog.owner = null;
      });

      expect(dog.owner, null);
    });

    test('Realm find object by primary key', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() => realm.add(Car()..make = "Opel"));

      final car = realm.find<Car>("Opel");
      expect(car, isNotNull);
    });

    test('Realm find not configured object by primary key throws exception', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() => realm.find<Person>("Me"), throws<RealmException>("not configured"));
    });

    test('Realm find object by primary key default value', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() => realm.add(Car()));

      final car = realm.find<Car>("Tesla");
      expect(car, isNotNull);
      expect(car?.make, equals("Tesla"));
    });

    test('Realm find non existing object by primary key returns null', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() => realm.add(Car()..make = "Opel"));

      final car = realm.find<Car>("NonExistingPrimaryKey");
      expect(car, isNull);
    });

    test('Realm remove object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car()..make = "SomeNewNonExistingValue";
      realm.write(() => realm.add(car));

      final car1 = realm.find<Car>("SomeNewNonExistingValue");
      expect(car1, isNotNull);

      realm.write(() => realm.remove(car1!));

      var car2 = realm.find<Car>("SomeNewNonExistingValue");
      expect(car2, isNull);
    });

    test('Results.all() should not return null', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final cars = realm.all<Car>();
      expect(cars, isNotNull);
    });

    test('Results.all() length', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      var cars = realm.all<Car>();
      expect(cars.length, 0);

      final car = Car();
      realm.write(() => realm.add(car));

      expect(cars.length, 1);

      realm.write(() => realm.remove(car));

      expect(cars.length, 0);
    });

    test('Results.all() isEmpty', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      var cars = realm.all<Car>();
      expect(cars.isEmpty(), true);

      final car = Car();
      realm.write(() => realm.add(car));

      expect(cars.isEmpty(), false);

      realm.write(() => realm.remove(car));

      expect(cars.isEmpty(), true);
    });

    test('Results get by index', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      realm.write(() => realm.add(Car()));

      final car = Car();
      final cars = realm.all<Car>();
      expect(cars[0].make, car.make);
    });

    test('Lists create object with a list property', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team()..name = "Ferrari";
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      expect(teams.length, 1);
      expect(teams[0].name, "Ferrari");
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 0);
    });

    test('Lists get set', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team()..name = "Ferrari";
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      expect(teams.length, 1);
      final players = teams[0].players;
      expect(players, isNotNull);
      expect(players.length, 0);

      realm.write(() => players.add(Person()..name = "Michael Schumacher"));
      expect(players.length, 1);

      realm.write(() => players.addAll([Person()..name = "Sebastian Vettel", Person()..name = "Kimi Räikkönen"]));

      expect(players.length, 3);

      expect(players[0].name, "Michael Schumacher");
      expect(players[1].name, "Sebastian Vettel");
      expect(players[2].name, "Kimi Räikkönen");
    });

    test('Lists get invalid index throws exception', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team()..name = "Ferrari";
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      final players = teams[0].players;

      expect(() => players[-1], throws<RealmException>("Index out of range"));
      expect(() => players[800], throws<RealmException>());
    });

    test('Lists set invalid index throws', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team()..name = "Ferrari";
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      final players = teams[0].players;

      expect(() => realm.write(() => players[-1] = Person()), throws<RealmException>("Index out of range"));
      expect(() => realm.write(() => players[800] = Person()), throws<RealmException>());
    });

     test('Lists clear objects', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team()..name = "Team";
      realm.write(() => realm.add(team));
      final teams = realm.all<Team>();
      expect(teams.length, 1);
      final players = teams[0].players;
      expect(players, isNotNull);
      expect(players.length, 0);

      realm.write(() => players.addAll([
            Person()..name = "Michael Schumacher",
            Person()..name = "Sebastian Vettel",
            Person()..name = "Kimi Räikkönen"
          ]));

      expect(players.length, 3);
      realm.write(() => players.clear());

      expect(players.length, 0);
      expect(teams[0].players.length, 0);

      final allPersons = realm.all<Person>();
      expect(allPersons.length, 0);
      expect(allPersons.length, 0);     
    });
  });
}
