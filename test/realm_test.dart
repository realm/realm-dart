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

part 'realm_test.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late final String make;
}

@RealmModel()
class _Person {
  late String name;
}

@RealmModel()
class _Dog {
  @PrimaryKey()
  late final String name;

  late int? age;

  _Person? owner;
}

@RealmModel()
class _Team {
  late String name;
  late final List<_Person> players;
  late final List<int> scores;
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
      testName = arguments[nameArgIndex + 1];
      print("testName: $testName");
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
      final car = Car('');
      expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
    });

    test('Realm add object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() {
        realm.add(Car(''));
      });
    });

    test('Realm add multiple objects', () {
      final config = Configuration([Car.schema]);
      final realm = Realm(config);

      final cars = [
        Car('Mercedes'),
        Car('Volkswagen'),
        Car('Tesla'),
      ];

      realm.write(() {
        realm.addAll(cars);
      });

      // RealmResults<T> does no implement Iterable<T> yet, hence the explicit loop.
      // Also, generated classes don't handle equality correct yet, hence we compare 'make'.
      final allCars = realm.all<Car>();
      for (int i = 0; i < cars.length; ++i) {
        expect(allCars[i].make, cars[i].make);
      }
    });

    test('Realm add object twice does not throw', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() {
        final car = Car('');
        realm.add(car);

        //second add of the same object does not throw and return the same object
        final car1 = realm.add(car);
        expect(car1, equals(car));
      });
    });

    test('Realm adding not configured object throws exception', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() => realm.write(() => realm.add(Person(''))), throws<RealmException>("not configured"));
    });

    test('Realm add() returns the same object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car('');
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
          realm.add(Car("Tesla"));
          throw Exception("some exception while adding objects");
        });
      }, throws<Exception>("some exception while adding objects"));

      final car = realm.find<Car>("Telsa");
      expect(car, isNull);
    });

    test('Realm adding objects with duplicate primary keys throws', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final carOne = Car("Toyota");
      final carTwo = Car("Toyota");
      realm.write(() => realm.add(carOne));
      expect(() => realm.write(() => realm.add(carTwo)), throws<RealmException>());
    });

    test('RealmObject get property', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car('Tesla');
      realm.write(() {
        realm.add(car);
      });

      expect(car.make, equals('Tesla'));
    });

    test('RealmObject set property', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car('Tesla');
      realm.write(() {
        realm.add(car);
      });

      expect(car.make, equals('Tesla'));

      expect(() {
        realm.write(() {
          car.make = "Audi"; // setting late final is a runtime error :-/
        });
      }, throws<RealmUnsupportedSetError>());
    });

    test('RealmObject set object type property (link)', () {
      var config = Configuration([Person.schema, Dog.schema]);
      var realm = Realm(config);

      final dog = Dog(
        "MyDog",
        owner: Person("MyOwner"),
      );
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

      final dog = Dog(
        "MyDog",
        owner: Person("MyOwner"),
        age: 5,
      );
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

      realm.write(() => realm.add(Car("Opel")));

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

      realm.write(() => realm.add(Car('Tesla')));

      final car = realm.find<Car>("Tesla");
      expect(car, isNotNull);
      expect(car?.make, equals("Tesla"));
    });

    test('Realm find non existing object by primary key returns null', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      realm.write(() => realm.add(Car("Opel")));

      final car = realm.find<Car>("NonExistingPrimaryKey");
      expect(car, isNull);
    });

    test('Realm delete object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car("SomeNewNonExistingValue");
      realm.write(() => realm.add(car));

      final car1 = realm.find<Car>("SomeNewNonExistingValue");
      expect(car1, isNotNull);

      realm.write(() => realm.delete(car1!));

      var car2 = realm.find<Car>("SomeNewNonExistingValue");
      expect(car2, isNull);
    });

    test('Results.all() should not return null', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final cars = realm.all<Car>();
      expect(cars, isNotNull);
    });

    test('Results length after deletedMany', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      var cars = realm.all<Car>();
      expect(cars.length, 0);

      final carOne = Car("Toyota 1");
      final carTwo = Car("Toyota 2");
      final carThree = Car("Renault");
      realm.write(() => realm.addAll([carOne, carTwo, carThree]));

      expect(cars.length, 3);

      final filteredCars = realm.query<Car>('make BEGINSWITH "Toyot"');
      expect(filteredCars.length, 2);

      realm.write(() => realm.deleteMany(filteredCars));
      expect(filteredCars.length, 0);

      expect(cars.length, 1);
    });

    test('Results length', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      var cars = realm.all<Car>();
      expect(cars.length, 0);

      final carOne = Car("Toyota");
      final carTwo = Car("Toyota 1");
      realm.write(() => realm.addAll([carOne, carTwo]));

      expect(cars.length, 2);

      final filteredCars = realm.query<Car>('make == "Toyota"');
      expect(filteredCars.length, 1);
    });

    test('Results isEmpty', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      var cars = realm.all<Car>();
      expect(cars.isEmpty, true);

      final car = Car("Opel");
      realm.write(() => realm.add(car));

      expect(cars.isEmpty, false);

      realm.write(() => realm.delete(car));

      expect(cars.isEmpty, true);
    });

    test('Results from query isEmpty', () {
      var config = Configuration([Dog.schema, Person.schema]);
      var realm = Realm(config);

      final dogOne = Dog("Pupu", age: 1);
      final dogTwo = Dog("Ostin", age: 2);

      realm.write(() => realm.addAll([dogOne, dogTwo]));

      var dogs = realm.query<Dog>('age == 0');
      expect(dogs.isEmpty, true);

      dogs = realm.query<Dog>('age == 1');
      expect(dogs.isEmpty, false);

      realm.write(() => realm.deleteMany(dogs));
      expect(dogs.isEmpty, true);

      dogs = realm.all<Dog>();
      expect(dogs.isEmpty, false);
    });

    test('Results get by index', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car('');
      realm.write(() => realm.add(car));

      final cars = realm.all<Car>();
      expect(cars[0].make, car.make);
    });

    group('Query and sort tests:', () {
      test('Query results', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm
          ..add(Car("Audi"))
          ..add(Car("Tesla")));
        final cars = realm.all<Car>().query('make == "Tesla"');
        expect(cars.length, 1);
        expect(cars[0].make, "Tesla");
      });

      test('Query class', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm
          ..add(Car("Audi"))
          ..add(Car("Tesla")));
        final cars = realm.query<Car>('make == "Tesla"');
        expect(cars.length, 1);
        expect(cars[0].make, "Tesla");
      });

      test('Query results with parameter', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm
          ..add(Car("Audi"))
          ..add(Car("Tesla")));
        final cars = realm.all<Car>().query(r'make == $0', ['Tesla']);
        expect(cars.length, 1);
        expect(cars[0].make, "Tesla");
      });

      test('Query results with multiple parameters', () {
        var config = Configuration([Team.schema, Person.schema]);
        var realm = Realm(config);

        final x = Person('x');
        final y = Person('y');
        final t1 = Team("A1", players: [x]); // match
        final t2 = Team("A2", players: [y]); // correct prefix, but wrong player
        final t3 = Team("B1", players: [x, y]); // wrong prefix, but correct player

        realm.write(() => realm.addAll([t1, t2, t3]));

        expect(t1.players, [x]);
        expect(t2.players, [y]);
        expect(t3.players, [x, y]);

        final filteredTeams = realm.all<Team>().query(r'$0 IN players AND name BEGINSWITH $1', [x, 'A']);
        expect(filteredTeams.length, 1);
        expect(filteredTeams, [t1]);
      });

      test('Query class with parameter', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm
          ..add(Car("Audi"))
          ..add(Car("Tesla")));
        final cars = realm.query<Car>(r'make == $0', ['Tesla']);
        expect(cars.length, 1);
        expect(cars[0].make, "Tesla");
      });

      test('Query class with multiple parameters', () {
        var config = Configuration([Team.schema, Person.schema]);
        var realm = Realm(config);

        final x = Person('x');
        final y = Person('y');
        final t1 = Team("A1");
        final t2 = Team("A2");
        final t3 = Team("B1");

        realm.write(() => realm
          ..add(t1)
          ..add(t2)
          ..add(t3));

        // TODO: Ugly that we need to add players in separate transaction :-/
        realm.write(() {
          t1.players.addAll([x]); // match!
          t2.players.addAll([y]); // correct prefix, but wrong play
          t3.players.addAll([x, y]); // wrong prefix, but correct player
        });

        // TODO: Still no equality :-/
        expect(t1.players.map((p) => p.name), [x.name]);
        expect(t2.players.map((p) => p.name), [y.name]);
        expect(t3.players.map((p) => p.name), [x, y].map((p) => p.name));
        final filteredTeams = realm.query<Team>(r'$0 IN players AND name BEGINSWITH $1', [x, 'A']);
        expect(filteredTeams.length, 1);
        expect(filteredTeams[0].name, "A1");
      });

      test('Query results with no arguments throws', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm.add(Car("Audi")));
        expect(() => realm.all<Car>().query(r'make == $0'), throws<RealmException>("no arguments are provided"));
      });

      test('Query results with wrong argument types (int for string) throws', () {
        var config = Configuration([Car.schema]);
        var realm = Realm(config);
        realm.write(() => realm.add(Car("Audi")));
        expect(() => realm.all<Car>().query(r'make == $0', [1]), throws<RealmException>("Unsupported comparison between type"));
      });

      test('Query results with wrong argument types (bool for int) throws ', () {
        var config = Configuration([Dog.schema, Person.schema]);
        var realm = Realm(config);
        realm.write(() => realm.add(Dog("Foxi")));
        expect(() => realm.all<Dog>().query(r'age == $0', [true]), throws<RealmException>("Unsupported comparison between type"));
      });

      test('Sort result', () {
        var config = Configuration([Person.schema]);
        var realm = Realm(config);

        realm.write(() => realm.addAll([
              Person("Michael"),
              Person("Sebastian"),
              Person("Kimi"),
            ]));

        final result = realm.query<Person>('TRUEPREDICATE SORT(name ASC)');
        final resultNames = result.map((p) => p.name).toList();
        final sortedNames = [...resultNames]..sort();
        expect(resultNames, sortedNames);
      });

      test('Sort order preserved under db ops', () {
        var config = Configuration([Dog.schema, Person.schema]);
        var realm = Realm(config);

        final dog1 = Dog("Bella", age: 1);
        final dog2 = Dog("Fido", age: 2);
        final dog3 = Dog("Oliver", age: 3);

        realm.write(() => realm.addAll([dog1, dog2, dog3]));
        var result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)');
        final snapshot = result.toList(); // poor mans snapshot

        expect(result, orderedEquals(snapshot));
        expect(result.map((d) => d.name), snapshot.map((d) => d.name));
        result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)'); // redoing query won't change that
        expect(result, orderedEquals(snapshot));
        expect(result.map((d) => d.name), snapshot.map((d) => d.name));

        realm.write(() => realm.delete(dog1)); // result will update, snapshot will not, but an object has died

        expect(() => snapshot[0].name, throws<RealmException>());
        snapshot.removeAt(0); // remove dead object

        expect(result, orderedEquals(snapshot));
        expect(result.map((d) => d.name), snapshot.map((d) => d.name));

        realm.write(() => realm.add(Dog("Bella", age: 4)));

        expect(result, isNot(orderedEquals(snapshot)));
        expect(result, containsAllInOrder(snapshot));
      });
    });
    test('Lists create object with a list property', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      expect(teams.length, 1);
      expect(teams[0].name, "Ferrari");
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 0);
    });

    test('RealmObject add with list properties', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team("Ferrari")
        ..players.addAll([Person("Michael"), Person("Kimi")])
        ..scores.addAll([1, 2, 3]);

      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      expect(teams.length, 1);
      expect(teams[0].name, "Ferrari");
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 2);
      expect(teams[0].players[0].name, "Michael");
      expect(teams[0].players[1].name, "Kimi");

      expect(teams[0].scores.length, 3);
      expect(teams[0].scores[0], 1);
      expect(teams[0].scores[1], 2);
      expect(teams[0].scores[2], 3);
    });

    test('Lists get set', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      expect(teams.length, 1);
      final players = teams[0].players;
      expect(players, isNotNull);
      expect(players.length, 0);

      realm.write(() => players.add(Person("Michael")));
      expect(players.length, 1);

      realm.write(() => players.addAll([
            Person("Sebastian"),
            Person("Kimi"),
          ]));

      expect(players.length, 3);

      expect(players[0].name, "Michael");
      expect(players[1].name, "Sebastian");
      expect(players[2].name, "Kimi");
    });

    test('Lists get invalid index throws exception', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      final players = teams[0].players;

      expect(() => players[-1], throws<RealmException>("Index out of range"));
      expect(() => players[800], throws<RealmException>());
    });

    test('Lists set invalid index throws', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      final teams = realm.all<Team>();
      final players = teams[0].players;

      expect(() => realm.write(() => players[-1] = Person('')), throws<RealmException>("Index out of range"));
      expect(() => realm.write(() => players[800] = Person('')), throws<RealmException>());
    });

    test('List clear items from list', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create a team
      final team = Team("Team");
      realm.write(() => realm.add(team));

      //Add players to the team
      final newPlayers = [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ];

      realm.write(() {
        team.players.addAll(newPlayers);
      });

      //Ensure teams and players are in realm
      var teams = realm.all<Team>();
      expect(teams.length, 1);

      var players = teams[0].players;
      expect(players, isNotNull);
      expect(players.length, 3);

      //Clear list of team players
      realm.write(() => teams[0].players.clear());

      expect(teams[0].players.length, 0);

      //Ensure that players objects still exist in realm detached from the team
      final allPlayers = realm.all<Person>();
      expect(allPlayers.length, 3);
    });

    test('List clear - same list related to two objects', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two teams
      final teamOne = Team("TeamOne");
      final teamTwo = Team("TeamTwo");
      realm.write(() {
        realm.add(teamOne);
        realm.add(teamTwo);
      });

      //Create common players list for both teams
      final newPlayers = [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ];
      realm.write(() {
        teamOne.players.addAll(newPlayers);
        teamTwo.players.addAll(newPlayers);
      });

      //Ensure that teams and players exist in realm
      var teams = realm.all<Team>();
      expect(teams.length, 2);
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 3);
      expect(teams[1].players, isNotNull);
      expect(teams[1].players.length, 3);

      //Clear first team's players only
      realm.write(() => teams[0].players.clear());

      //Ensure that second team is still related to players
      expect(teams[0].players.length, 0);
      expect(teams[1].players.length, 3);

      //Ensure players still exist in realm
      final players = realm.all<Person>();
      expect(players.length, 3);
    });

    test('List clear - same item added to two lists', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two Teams
      final teamOne = Team("TeamOne");
      final teamTwo = Team("TeamTwo");
      realm.write(() {
        realm.add(teamOne);
        realm.add(teamTwo);
      });

      //Add the same player to both teams
      Person player = Person("Michael Schumacher");
      realm.write(() {
        teamOne.players.add(player);
        teamTwo.players.add(player);
      });

      //Ensure teams and player are in realm
      var teams = realm.all<Team>();
      expect(teams.length, 2);
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 1);
      expect(teams[1].players, isNotNull);
      expect(teams[1].players.length, 1);

      //Clear player from the first team
      realm.write(() => teams[0].players.clear());

      //Ensure that the second team has no more players
      // but the first team is still related to the player
      expect(teams[0].players.length, 0);
      expect(teams[1].players.length, 1);

      //Ensure the player still exists in realm
      final allPlayers = realm.all<Person>();
      expect(allPlayers.length, 1);
    });

    test('List clear in closed realm - expected exception', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create a team
      var team = Team("TeamOne");
      realm.write(() => realm.add(team));

      //Add the player to the team
      realm.write(() => team.players.add(Person("Michael Schumacher")));

      //Ensure teams and player are in realm
      var teams = realm.all<Team>();
      expect(teams.length, 1);
      expect(teams[0].players, isNotNull);
      expect(teams[0].players.length, 1);

      var players = teams[0].players;

      realm.close();
      expect(
          () => realm.write(() {
                players.clear();
              }),
          throws<RealmException>());

      realm = Realm(config);

      //Teams must be reloaded since realm was reopened
      teams = realm.all<Team>();

      //Ensure that the team is still related to the player
      expect(teams.length, 1);
      expect(teams[0].players.length, 1);
    });

    test('Realm.deleteMany from iterable', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two teams
      final teamOne = Team("Team one");
      final teamTwo = Team("Team two");
      final teamThree = Team("Team three");
      realm.write(() {
        realm.add(teamOne);
        realm.add(teamTwo);
        realm.add(teamThree);
      });

      //Ensure the teams exist in realm
      var teams = realm.all<Team>();
      expect(teams.length, 3);

      //Delete teams one and three from realm
      realm.write(() => realm.deleteMany([teamOne, teamThree]));

      //Ensure both teams are deleted and only teamTwo has left
      expect(teams.length, 1);
      expect(teams[0].name, teamTwo.name);
    });

    test('Realm.deleteMany from realm list', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create a team
      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      //Add players to the team
      final newPlayers = [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ];
      realm.write(() => team.players.addAll(newPlayers));

      //Ensure the team exists in realm
      var teams = realm.all<Team>();
      expect(teams.length, 1);

      //Delete team players
      realm.write(() => realm.deleteMany(teams[0].players));

      //Ensure players are deleted from collection
      expect(teams[0].players.length, 0);

      //Reload all persons from realm and ensure they are deleted
      final allPersons = realm.all<Person>();
      expect(allPersons.length, 0);
    });

    test('Realm.deleteMany from list referenced by two objects', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two teams
      final teamOne = Team("Ferrari");
      final teamTwo = Team("Maserati");
      realm.write(() {
        realm.add(teamOne);
        realm.add(teamTwo);
      });

      //Create common players list for both teams
      final newPlayers = [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ];
      realm.write(() {
        teamOne.players.addAll(newPlayers);
        teamTwo.players.addAll(newPlayers);
      });

      //Ensule teams exist in realm
      var teams = realm.all<Team>();
      expect(teams.length, 2);

      //Delete all players in a team from realm
      realm.write(() => realm.deleteMany(teams[0].players));

      //Ensure all players are deleted from collection
      expect(teams[0].players.length, 0);

      //Reload all persons from realm and ensure they are deleted
      final allPersons = realm.all<Person>();
      expect(allPersons.length, 0);
    });

    test('Realm.deleteMany from results', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two teams
      realm.write(() {
        realm.add(Team("Ferrari"));
        realm.add(Team("Maserati"));
      });

      //Ensule teams exist in realm
      var teams = realm.all<Team>();
      expect(teams.length, 2);

      //Delete all objects in realmResults from realm
      realm.write(() => realm.deleteMany(teams));
      expect(teams.length, 0);

      //Reload teams from realm and ensure they are deleted
      teams = realm.all<Team>();
      expect(teams.length, 0);
    });

    test('Realm.deleteMany from list after realm is closed', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create a team
      final team = Team("Ferrari");
      realm.write(() => realm.add(team));

      //Add players to the team
      final newPlayers = [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ];
      realm.write(() => team.players.addAll(newPlayers));

      //Ensure team exists in realm
      var teams = realm.all<Team>();
      expect(teams.length, 1);

      //Try to delete team players while realm is closed
      final players = teams[0].players;
      realm.close();
      expect(
          () => realm.write(() {
                realm.deleteMany(players);
              }),
          throws<RealmException>());

      //Ensure all persons still exists in realm
      realm = Realm(config);
      final allPersons = realm.all<Person>();
      expect(allPersons.length, 3);
    });

    test('Results iteration test', () {
      var config = Configuration([Team.schema, Person.schema]);
      var realm = Realm(config);

      //Create two teams
      realm.write(() {
        realm.add(Team("team One"));
        realm.add(Team("team Two"));
      });

      //Reload teams from realm and ensure they exist
      var teams = realm.all<Team>();
      expect(teams.length, 2);

      //Iterate through teams and add realm objects to a list
      List<Team> list = [];
      for (Team team in teams) {
        list.add(team);
      }

      //Ensure list size is the same like teams collection size
      expect(list.length, teams.length);
    });

    test('Realm existsSync', () {
      var config = Configuration([Dog.schema, Person.schema]);
      expect(Realm.existsSync(config.path), false);
      var realm = Realm(config);
      expect(Realm.existsSync(config.path), true);
    });

    test('Realm exists', () async {
      var config = Configuration([Dog.schema, Person.schema]);
      expect(await Realm.exists(config.path), false);
      var realm = Realm(config);
      expect(await Realm.exists(config.path), true);
    });

    test('Realm deleteRealm succeeds', () {
      var config = Configuration([Dog.schema, Person.schema]);
      var realm = Realm(config);

      realm.close();
      Realm.deleteRealm(config.path);

      expect(File(config.path).existsSync(), false);
      expect(Directory("${config.path}.management").existsSync(), false);
    });

    test('Realm deleteRealm throws exception on an open realm', () {
      var config = Configuration([Dog.schema, Person.schema]);
      var realm = Realm(config);

      expect(() => Realm.deleteRealm(config.path), throws<RealmException>());

      expect(File(config.path).existsSync(), true);
      expect(Directory("${config.path}.management").existsSync(), true);
    });

    test('Equals', () {
      var config = Configuration([Dog.schema, Person.schema]);
      var realm = Realm(config);

      final person = Person('Kasper');
      final dog = Dog('Fido', owner: person);

      expect(person, person);
      expect(person, isNot(1));
      expect(person, isNot(dog));

      realm.write(() {
        realm
          ..add(person)
          ..add(dog);
      });

      expect(person, person);
      expect(person, isNot(1));
      expect(person, isNot(dog));

      final read = realm.query<Person>("name == 'Kasper'");

      expect(read, [person]);
    });
  });
}
