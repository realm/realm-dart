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
import 'package:test/test.dart' hide throws;
import '../lib/realm.dart';

import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  setupTests();

  test('Realm can be created', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.close();
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
    realm.close();
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
    realm.close();
  });

  test('Realm open with schema superset', () {
    var config = Configuration([Person.schema]);
    var realm = Realm(config);
    realm.close();

    var config1 = Configuration([Person.schema, Car.schema]);
    var realm1 = Realm(config1);
    realm1.close();
  });

  test('Realm open twice with same schema', () async {
    var config = Configuration([Person.schema, Car.schema]);
    var realm = Realm(config);

    var config1 = Configuration([Person.schema, Car.schema]);
    var realm1 = Realm(config1);
    realm.close();
    realm1.close();
  });

  test('Realm add throws when no write transaction', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);
    final car = Car('');
    expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
    realm.close();
  });

  test('Realm existsSync', () {
    var config = Configuration([Dog.schema, Person.schema]);
    expect(Realm.existsSync(config.path), false);
    var realm = Realm(config);
    expect(Realm.existsSync(config.path), true);
    realm.close();
  });

  test('Realm exists', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    expect(await Realm.exists(config.path), false);
    var realm = Realm(config);
    expect(await Realm.exists(config.path), true);
    realm.close();
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
    realm.close();
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
    realm.close();
  });

  test('Realm add object', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() {
      realm.add(Car(''));
    });

    realm.close();
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

    final allCars = realm.all<Car>();
    expect(allCars, cars);

    realm.close();
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

    realm.close();
  });

  test('Realm adding not configured object throws exception', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    expect(() => realm.write(() => realm.add(Person(''))), throws<RealmException>("not configured"));
    realm.close();
  });

  test('Realm add returns the same object', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('');
    Car? addedCar;
    realm.write(() {
      addedCar = realm.add(car);
    });

    expect(addedCar == car, isTrue);

    realm.close();
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

    realm.close();
  });

  test('Realm adding objects with duplicate primary keys throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(() => realm.write(() => realm.add(carTwo)), throws<RealmException>());

    realm.close();
  });

  test('RealmObject get property', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('Tesla');
    realm.write(() {
      realm.add(car);
    });

    expect(car.make, equals('Tesla'));

    realm.close();
  });

  test('Realm query', () {
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

  
  test('Realm query with parameter', () {
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

  
  test('Realm query with multiple parameters', () {
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
        car.make = "Audi";
      });
    }, throws<RealmUnsupportedSetError>());

    realm.close();
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

    realm.close();
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

    realm.close();
  });

  test('Realm find object by primary key', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("Opel");
    expect(car, isNotNull);

    realm.close();
  });

  test('Realm find not configured object by primary key throws exception', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    expect(() => realm.find<Person>("Me"), throws<RealmException>("not configured"));

    realm.close();
  });

  test('Realm find object by primary key default value', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car('Tesla')));

    final car = realm.find<Car>("Tesla");
    expect(car, isNotNull);
    expect(car?.make, equals("Tesla"));

    realm.close();
  });

  test('Realm find non existing object by primary key returns null', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("NonExistingPrimaryKey");
    expect(car, isNull);

    realm.close();
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

    realm.close();
  });

  test('Realm deleteMany from realm list', () {
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
    realm.close();
  });

  test('Realm deleteMany from list referenced by two objects', () {
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
    realm.close();
  });

  test('Realm deleteMany from list after realm is closed', () {
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
    realm.close();
  });

  test('Realm deleteMany from iterable', () {
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
    realm.close();
  });

  test('RealmObject equals', () {
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
    realm.close();
  });

  test('RealmObject isValid', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("team one");
    expect(team.isValid, true);
    realm.write(() {
      realm.add(team);
    });
    expect(team.isValid, true);
    realm.close();
    expect(team.isValid, false);
  });

  test('Access deleted object', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    var teamBeforeDelete = teams[0];
    realm.write(() => realm.delete(team));
    expect(team.isValid, false);
    expect(teamBeforeDelete.isValid, false);
    expect(team, teamBeforeDelete);
    expect(() => team.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
    expect(() => teamBeforeDelete.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
    realm.close();
  });

  test('Add object after realm is closed', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('Tesla');

    realm.close();
    expect(() => realm.write(() => realm.add(car)), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('Edit object after realm is closed', () {
    var config = Configuration([Person.schema]);
    var realm = Realm(config);

    final person = Person('Markos');

    realm.write(() => realm.add(person));
    realm.close();
    expect(() => realm.write(() => person.name = "Markos Sanches"), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('Edit deleted object', () {
    var config = Configuration([Person.schema]);
    var realm = Realm(config);

    final person = Person('Markos');

    realm.write(() {
      realm.add(person);
      realm.delete(person);
    });
    expect(() => realm.write(() => person.name = "Markos Sanches"),
        throws<RealmException>("Accessing object of type Person which has been invalidated or deleted"));
    realm.close();
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

    var config = Configuration([School.schema, Student.schema]);
    var realm = Realm(config);

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
    realm.close();
  });
}
