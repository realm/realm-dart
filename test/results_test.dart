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
import 'test_base.dart';
import '../lib/realm.dart';
import 'test_model.dart';

Future<void> main([List<String>? args]) async {
  parseTestNameFromArguments(args);

  print("Current PID $pid");

  setupTests(Configuration.filesPath, (path) => {Configuration.defaultPath = path});

  test('Results.all() should not return null', () {
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

  test('Query results', () {
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

  test('Query class', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");

    realm.close();
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

    realm.close();
  });

  test('Query results with multiple parameters', () {
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

  test('Query class with parameter', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");

    realm.close();
  });

  test('Query class with multiple parameters', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final p1 = Person('p1');
    final p2 = Person('p2');
    final t1 = Team("A1", players: [p1]);
    final t2 = Team("A2", players: [p2]);
    final t3 = Team("B1", players: [p1, p2]);

    realm.write(() => realm
      ..add(t1)
      ..add(t2)
      ..add(t3));

    expect(t1.players, [p1]);
    expect(t2.players, [p2]);
    expect(t3.players, [p1, p2]);
    final filteredTeams = realm.query<Team>(r'$0 IN players AND name BEGINSWITH $1', [p1, 'A']);
    expect(filteredTeams.length, 1);
    expect(filteredTeams[0].name, "A1");

    realm.close();
  });

  test('Query results with no arguments throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0'), throws<RealmException>("no arguments are provided"));

    realm.close();
  });

  test('Query results with wrong argument types (int for string) throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0', [1]), throws<RealmException>("Unsupported comparison between type"));
    realm.close();
  });

  test('Query results with wrong argument types (bool for int) throws ', () {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Dog("Foxi")));
    expect(() => realm.all<Dog>().query(r'age == $0', [true]), throws<RealmException>("Unsupported comparison between type"));
    realm.close();
  });

  test('Query list', () {
    final config = Configuration([Team.schema, Person.schema]);
    final realm = Realm(config);

    final person = Person('John');
    final team = Team('team1', players: [
      Person('Pavel'),
      person,
      Person('Alex'),
    ]);

    realm.write(() => realm.add(team));

    // TODO: Get rid of cast, once type signature of team.players is a RealmList<Person>
    // as opposed to the List<Person> we have today.
    final result = (team.players as RealmList<Person>).query(r'name BEGINSWITH $0', ['J']);

    expect(result, [person]);

    realm.close();
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
    realm.close();
  });

  test('Sort order preserved under db ops', () {
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

    realm.write(() => realm.delete(dog1)); // result will update, snapshot will not, but an object has died

    expect(() => snapshot[0].name, throws<RealmException>());
    snapshot.removeAt(0); // remove dead object

    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));

    realm.write(() => realm.add(Dog("Bella", age: 4)));

    expect(result, isNot(orderedEquals(snapshot)));
    expect(result, containsAllInOrder(snapshot));
    realm.close();
  });

  test('Get query results length after realm is clodes', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    final teams = realm.query<Team>('name BEGINSWITH "Team"');
    realm.close();
    expect(() => teams.length, throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Access results after realm closed', () {
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
}
