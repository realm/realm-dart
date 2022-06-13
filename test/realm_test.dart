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

// ignore_for_file: unused_local_variable, avoid_relative_lib_imports

import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Realm can be created', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
  });

  test('Realm can be closed', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    config = Configuration.local([Car.schema]);
    realm = getRealm(config);
    realm.close();

    //Calling close() twice should not throw exceptions
    realm.close();
  });

  test('Realm can be closed and opened again', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    config = Configuration.local([Car.schema]);
    //should not throw exception
    realm = getRealm(config);
  });

  test('Realm is closed', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    expect(realm.isClosed, false);

    realm.close();
    expect(realm.isClosed, true);
  });

  test('Realm open with schema subset', () {
    var config = Configuration.local([Car.schema, Person.schema]);
    var realm = getRealm(config);
    realm.close();

    config = Configuration.local([Car.schema]);
    realm = getRealm(config);
  });

  test('Realm open with schema superset', () {
    var config = Configuration.local([Person.schema]);
    var realm = getRealm(config);
    realm.close();

    var config1 = Configuration.local([Person.schema, Car.schema]);
    var realm1 = getRealm(config1);
  });

  test('Realm open twice with same schema', () async {
    var config = Configuration.local([Person.schema, Car.schema]);
    var realm = getRealm(config);

    var config1 = Configuration.local([Person.schema, Car.schema]);
    var realm1 = getRealm(config1);
  });

  test('Realm add throws when no write transaction', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    final car = Car('');
    expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
  });

  test('Realm existsSync', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    expect(Realm.existsSync(config.path), false);
    var realm = getRealm(config);
    expect(Realm.existsSync(config.path), true);
  });

  test('Realm exists', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    expect(await Realm.exists(config.path), false);
    var realm = getRealm(config);
    expect(await Realm.exists(config.path), true);
  });

  test('Realm deleteRealm succeeds', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    realm.close();
    Realm.deleteRealm(config.path);

    expect(File(config.path).existsSync(), false);
    expect(Directory("${config.path}.management").existsSync(), false);
  });

  test('Realm deleteRealm throws exception on an open realm', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    expect(() => Realm.deleteRealm(config.path), throws<RealmException>());

    expect(File(config.path).existsSync(), true);
    expect(Directory("${config.path}.management").existsSync(), true);
  });

  test('Realm add object', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(Car(''));
    });
  });

  test('Realm add multiple objects', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);

    final cars = [
      Car('Mercedes'),
      Car('Volkswagen'),
      Car('Tesla'),
    ];

    realm.write(() {
      realm.addAll(cars);
    });

    final allCars = realm.all<Car>();
    expect(allCars, cars);
  });

  test('Realm add object twice does not throw', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() {
      final car = Car('');
      realm.add(car);

      //second add of the same object does not throw and return the same object
      final car1 = realm.add(car);
      expect(car1, equals(car));
    });
  });

  test('Realm add object with list properties', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Realm adding not configured object throws exception', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    expect(() => realm.write(() => realm.add(Person(''))), throws<RealmError>("not configured"));
  });

  test('Realm add returns the same object', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('');
    Car? addedCar;
    realm.write(() {
      addedCar = realm.add(car);
    });

    expect(addedCar == car, isTrue);
  });

  test('Realm add object transaction rollbacks on exception', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    expect(() {
      realm.write(() {
        realm.add(Car("Tesla"));
        throw Exception("some exception while adding objects");
      });
    }, throws<Exception>("some exception while adding objects"));

    final car = realm.find<Car>("Tesla");
    expect(car, isNull);
  });

  test('Realm adding objects with duplicate primary keys throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(() => realm.write(() => realm.add(carTwo)), throws<RealmException>());
  });

  test('Realm adding objects with duplicate primary with update flag', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(realm.write(() => realm.add(carTwo, update: true)), carTwo);
  });

  test('Realm adding object graph with multiple existing objects with with update flag', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(realm.write(() => realm.add(carTwo, update: true)), carTwo);
  });

  test('Realm add object after realm is closed', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('Tesla');

    realm.close();
    expect(() => realm.write(() => realm.add(car)), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('Realm query', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Realm query with parameter', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Realm query with multiple parameters', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Realm find object by primary key', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("Opel");
    expect(car, isNotNull);
  });

  test('Realm find not configured object by primary key throws exception', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    expect(() => realm.find<Person>("Me"), throws<RealmError>("not configured"));
  });

  test('Realm find object by primary key default value', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car('Tesla')));

    final car = realm.find<Car>("Tesla");
    expect(car, isNotNull);
    expect(car?.make, equals("Tesla"));
  });

  test('Realm find non existing object by primary key returns null', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("NonExistingPrimaryKey");
    expect(car, isNull);
  });

  test('Realm delete object', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car("SomeNewNonExistingValue");
    realm.write(() => realm.add(car));

    final car1 = realm.find<Car>("SomeNewNonExistingValue");
    expect(car1, isNotNull);

    realm.write(() => realm.delete(car1!));

    var car2 = realm.find<Car>("SomeNewNonExistingValue");
    expect(car2, isNull);
  });

  test('Realm deleteMany from realm list', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Realm deleteMany from list referenced by two objects', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Realm deleteMany from list after realm is closed', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
    config = Configuration.local([Team.schema, Person.schema]);
    realm = getRealm(config);
    final allPersons = realm.all<Person>();
    expect(allPersons.length, 3);
  });

  test('Realm deleteMany from iterable', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Realm deleteAll', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final denmark = Team('Denmark', players: ['Arnesen', 'Laudrup', 'Mølby'].map(Person.new));
    final argentina = Team('Argentina', players: [Person('Maradona')]);
    realm.write(() => realm.addAll([denmark, argentina]));

    expect(realm.all<Person>().length, 4);
    expect(realm.all<Team>().length, 2);

    realm.write(realm.deleteAll<Team>);

    expect(realm.all<Person>().length, 4); // no cascading deletes
    expect(realm.all<Team>().length, 0);
  });

  test('Realm adding objects graph', () {
    var studentMichele = Student(1)
      ..name = "Michele Ernesto"
      ..yearOfBirth = 2005;
    var studentLoreta = Student(2, name: "Loreta Salvator", yearOfBirth: 2006);
    var studentPeter = Student(3, name: "Peter Ivanov", yearOfBirth: 2007);

    var school131 = School("JHS 131", city: "NY");
    school131.students.addAll([studentMichele, studentLoreta, studentPeter]);

    var school131Branch1 = School("First branch 131A", city: "NY Bronx")
      ..branchOfSchool = school131
      ..students.addAll([studentMichele, studentLoreta]);

    studentMichele.school = school131Branch1;
    studentLoreta.school = school131Branch1;

    var school131Branch2 = School("Second branch 131B", city: "NY Bronx")
      ..branchOfSchool = school131
      ..students.add(studentPeter);

    studentPeter.school = school131Branch2;

    school131.branches.addAll([school131Branch1, school131Branch2]);

    var config = Configuration.local([School.schema, Student.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(school131));

    //Check schools
    var schools = realm.all<School>();
    expect(schools.length, 3);

    //Check students
    var students = realm.all<Student>();
    expect(students.length, 3);

    //Check branches
    var branches = realm.all<School>().query('branchOfSchool != nil');
    expect(branches.length, 2);
    expect(branches[0].students.length + branches[1].students.length, 3);

    //Check main schools
    var mainSchools = realm.all<School>().query('branchOfSchool = nil');
    expect(mainSchools.length, 1);
    expect(mainSchools[0].branches.length, 2);
    expect(mainSchools[0].students.length, 3);
    expect(mainSchools[0].branches[0].students.length + mainSchools[0].branches[1].students.length, 3);
  });

  test('Opening Realm with same config does not throw', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);

    final realm1 = getRealm(config);
    final realm2 = getRealm(config);
    realm1.write(() {
      realm1.add(Person("Peter"));
    });

    // Wait for realm2 to see the changes. This would not be necessary if we
    // cache native instances.
    await Future<void>.delayed(Duration(milliseconds: 1));

    expect(realm2.all<Person>().length, 1);
    expect(realm2.all<Person>().single.name, "Peter");
  });

  test('Realm.operator== different config', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    final realm1 = getRealm(config);
    config = Configuration.local([Dog.schema, Person.schema, Team.schema]);
    final realm2 = getRealm(config);
    expect(realm1, isNot(realm2));
  });

  test('Realm write returns result', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    var car = Car('Mustang');

    var returnedCar = realm.write(() {
      return realm.add(car);
    });
    expect(returnedCar, car);
  });

  test('Realm write inside another write throws', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);
    realm.write(() {
      // Second write inside the first one fails but the error is caught
      expect(() => realm.write(() {}), throws<RealmException>('The Realm is already in a write transaction'));
    });
  });

  test('Realm isInTransaction returns true inside transaction', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);
    expect(realm.isInTransaction, false);
    realm.write(() {
      expect(realm.isInTransaction, true);
    });

    expect(realm.isInTransaction, false);
  });

  test('Realm write with error rolls back', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);
    expect(realm.isInTransaction, false);

    expect(() {
      realm.write(() {
        throw Exception('uh oh!');
      });
    }, throws<Exception>('uh oh!'));

    // We should not be in transaction here
    expect(realm.isInTransaction, false);
  });
}
