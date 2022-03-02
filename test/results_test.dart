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
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  setupTests(args);

  test('Results all should not return null', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final cars = realm.all<Car>();
    expect(cars, isNotNull);

    realm.close();
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

    realm.close();
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

    realm.close();
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

    realm.close();
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

    realm.close();
  });

  test('Results get by index', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('');
    realm.write(() => realm.add(car));

    final cars = realm.all<Car>();
    expect(cars[0].make, car.make);

    realm.close();
  });

  test('Results requested wrong index throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('');
    realm.write(() => realm.add(car));

    final cars = realm.all<Car>();
    realm.write(() => realm.deleteMany(cars));

    expect(() => cars[0], throws<RealmException>("Requested index 0 in empty Results"));

    realm.close();
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
    realm.close();
  });

  test('Results snapshot iteration test', () {
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

    //Adding new teams to real while iterating through them.
    //Iterator use a snapshot of results collection and ignores newly added teams.
    List<Team> list = [];
    for (Team team in teams) {
      list.add(team);
      realm.write(() {
        realm.add(Team("new team"));
      });
    }
    //Ensure list size is the same like teams collection size was at the beginnig
    expect(list.length, 2);

    //Ensure teams collection is increased
    expect(teams.length, 4);

    //Iterating teams again will create a snapshot with the newly added items
    list.clear();
    for (Team team in teams) {
      list.add(team);
    }
    expect(list.length, teams.length);

    realm.close();
  });

  test('Results query', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");

    realm.close();
  });

  test('Results query with parameter', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");

    realm.close();
  });

  test('Results query with multiple parameters', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final p1 = Person('p1');
    final p2 = Person('p2');
    final t1 = Team("A1", players: [p1]); // match
    final t2 = Team("A2", players: [p2]); // correct prefix, but wrong player
    final t3 = Team("B1", players: [p1, p2]); // wrong prefix, but correct player

    realm.write(() => realm.addAll([t1, t2, t3]));

    expect(t1.players, [p1]);
    expect(t2.players, [p2]);
    expect(t3.players, [p1, p2]);

    final filteredTeams = realm.all<Team>().query(r'$0 IN players AND name BEGINSWITH $1', [p1, 'A']);
    expect(filteredTeams.length, 1);
    expect(filteredTeams, [t1]);

    realm.close();
  });

  test('Query results with no arguments throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0'), throws<RealmException>("no arguments are provided"));

    realm.close();
  });

  test('Results query with wrong argument types (int for string) throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0', [1]), throws<RealmException>("Unsupported comparison between type"));
    realm.close();
  });

  test('Results query with wrong argument types (bool for int) throws ', () {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Dog("Foxi")));
    expect(() => realm.all<Dog>().query(r'age == $0', [true]), throws<RealmException>("Unsupported comparison between type"));
    realm.close();
  });

  test('Results sort', () {
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
    realm.close();
  });

  test('Results sort order is preserved', () {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    final dog1 = Dog("Bella", age: 1);
    final dog2 = Dog("Fido", age: 2);
    final dog3 = Dog("Oliver", age: 3);

    realm.write(() => realm.addAll([dog1, dog2, dog3]));
    var result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)');
    final snapshot = result.toList();

    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));
    result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)'); // redoing query won't change that
    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));

    realm.write(() => realm.delete(dog1));
    expect(() => snapshot[0].name, throws<RealmException>());
    snapshot.removeAt(0); // remove dead object

    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));

    realm.write(() => realm.add(Dog("Bella", age: 4)));

    expect(result, isNot(orderedEquals(snapshot)));
    expect(result, containsAllInOrder(snapshot));
    realm.close();
  });

  test('Results - get query length after realm is closed throws', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    final teams = realm.query<Team>('name BEGINSWITH "Team"');
    realm.close();
    expect(() => teams.length, throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Results access after realm closed throws', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.close();
    expect(() => teams[0], throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Realm deleteMany from results', () {
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
    realm.close();
  });

  test('Results notifications', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    realm.write(() {
      realm.add(Dog("Fido"));
      realm.add(Dog("Fido1"));
      realm.add(Dog("Fido2"));
    });

    var firstCall = true;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      if (firstCall) {
        firstCall = false;
        expect(changes.inserted.isEmpty, true);
        expect(changes.modified.isEmpty, true);
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified.isEmpty, true);
        expect(changes.moved.isEmpty, true);
      } else {
        expect(changes.inserted, [3]); //new object at index 3
        expect(changes.modified, [0]); //object at index 0 changed
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified, [0]);
        expect(changes.moved.isEmpty, true);
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.write(() {
      realm.all<Dog>().first.age = 2;
      realm.add(Dog("Fido4"));
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    subscription.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.close();
  });

  test('Results notifications can be paused', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    realm.write(() {
      realm.add(Dog("Lassy"));
    });

    var callbackCalled = false;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      callbackCalled = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });

    expect(callbackCalled, false);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await subscription.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.close();
  });

  test('Results notifications can be resumed', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    var callbackCalled = false;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      callbackCalled = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy"));
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, false);

    subscription.resume();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    await subscription.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.close();
  });

  test('Results notifications can leak', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    final leak = realm.all<Dog>().changes.listen((data) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.close();
  });
}
