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

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:path/path.dart' as p;
import 'package:cancellation_token/cancellation_token.dart';
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
    expect(realm.write(() => realm.add(carTwo, update: true)), carOne);
  });

  test('Realm adding object graph with multiple existing objects with with update flag', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(realm.write(() => realm.add(carTwo, update: true)), carTwo);
  });

  test('Realm write after realm is closed', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('Tesla');

    realm.close();
    expect(() => realm.write(() {}), throws<RealmClosedError>("Cannot access realm that has been closed"));
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

  test('Transitive updates', () {
    final realm = getRealm(Configuration.local([Friend.schema, Party.schema]));

    // A group of friends (all 42)
    final alice = Friend('alice');
    final bob = Friend('bob', bestFriend: alice);
    final carol = Friend('carol', bestFriend: bob);
    final dan = Friend('dan', bestFriend: bob);
    alice.bestFriend = bob;
    final friends = [alice, bob, carol, dan];
    for (final f in friends) {
      f.friends.addAll(friends.except(f));
    }

    // In 92 everybody is invited
    final partyOf92 = Party(1992, host: alice, guests: friends.except(alice));

    // Store everything transitively by adding the party
    realm.write(() => realm.add(partyOf92));

    // As a prelude check that every object is added correctly
    for (final f in friends) {
      expect(f.isManaged, isTrue);
      final friend = realm.find<Friend>(f.name);
      expect(friend, isNotNull);
      expect(friend!.name, f.name);
      expect(friend.age, 42);
      expect(friend.friends, friends.except(f)); // all are friends
      if (f != bob) expect(friend.bestFriend, bob); // everybody loves bob
    }
    expect(realm.all<Party>(), [partyOf92]);

    // 7 years pass, dan falls out of favor, and carol and alice becomes BFF
    final aliceAgain = Friend('alice', age: 50);
    final bobAgain = Friend('bob', age: 50); // alice prefer carol
    final carolAgain = Friend('carol', bestFriend: aliceAgain, age: 50);
    final danAgain = Friend('dan', bestFriend: bobAgain, age: 50);
    aliceAgain.bestFriend = carolAgain;
    final everyOne = [aliceAgain, bobAgain, carolAgain, danAgain];
    for (final f in everyOne) {
      f.friends.addAll(everyOne.except(f).except(danAgain)); // nobody likes dan anymore
    }

    // In 99, dan is not invited
    final partyOf99 = Party(
      1999,
      host: bobAgain,
      guests: everyOne.except(bobAgain).except(danAgain),
      previous: partyOf92,
    );

    // Cannot just add the party of 99, as it transitively updates a lot of existing objects
    //expect(() => realm.write(() => realm.add(partyOf99)), throwsA(TypeMatcher<RealmException>()));

    // So let's use the update flag..
    expect(() => realm.write(() => realm.add(partyOf99, update: true)), returnsNormally);

    // Now let's test that the original added objects are all correctly updated,
    // except dan who is not in the graph
    for (final f in friends.except(dan)) {
      //friends) {
      expect(f.isManaged, isTrue);
      expect(f.age, 50);
      expect(f.friends, friends.except(f).except(dan));
      expect(f.friends, everyOne.except(realm.find(f.name)!).except(danAgain)); // same
    }
    expect(alice.bestFriend, carol);
    expect(carol.bestFriend, alice);
    expect(bob.bestFriend, isNull);
    expect(dan.bestFriend, bob);
    expect(dan.age, 42);
    expect(dan.friends, [alice, bob, carol]);
    expect(danAgain.isManaged, isFalse); // dan wasn't updated
  });

  test('Realm.freeze returns frozen Realm', () {
    final config = Configuration.local([Person.schema, Team.schema]);
    final realm = getRealm(config);

    realm.write(() {
      final person = Person('Peter');
      final team = Team('Man U', players: [person], scores: [1, 2, 3]);
      realm.add(team);
    });

    final frozenRealm = freezeRealm(realm);
    expect(frozenRealm.isFrozen, true);
    expect(realm.isFrozen, false);

    final frozenTeams = frozenRealm.all<Team>();
    expect(frozenTeams.isFrozen, true);

    final manU = frozenTeams.single;
    expect(manU.isFrozen, true);
    expect(manU.scores.isFrozen, true);
    expect(manU.players.isFrozen, true);
    expect(manU.players.single.isFrozen, true);

    expect(frozenRealm.all<Person>().length, 1);

    realm.write(() {
      realm.deleteAll<Person>();
    });

    expect(frozenRealm.all<Person>().length, 1);
    expect(realm.all<Person>().length, 0);
  });

  test('FrozenRealm cannot write', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    expect(() => frozenRealm.write(() {}), throws<RealmError>("Starting a write transaction on a frozen Realm is not allowed."));
  });

  test('FrozenRealm cannot beginWrite', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    expect(() => frozenRealm.beginWrite(), throws<RealmError>("Starting a write transaction on a frozen Realm is not allowed."));
  });

  test('FrozenRealm cannot writeAsync', () async {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    await expectLater(() => frozenRealm.writeAsync(() {}), throws<RealmError>("Starting a write transaction on a frozen Realm is not allowed."));
  });

  test('FrozenRealm cannot beginWriteAsync', () async {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    await expectLater(() => frozenRealm.beginWriteAsync(), throws<RealmError>("Starting a write transaction on a frozen Realm is not allowed."));
  });

  test('realm.freeze when frozen returns the same instance', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    final deepFrozenRealm = freezeRealm(frozenRealm);
    expect(identical(frozenRealm, deepFrozenRealm), true);

    final frozenAgain = freezeRealm(realm);
    expect(identical(frozenAgain, frozenRealm), false);
  });

  test("FrozenRealm.close doesn't close other instances", () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozen1 = freezeRealm(realm);
    final frozen2 = freezeRealm(realm);
    expect(identical(frozen2, frozen1), false);

    expect(frozen1.isClosed, false);
    expect(frozen2.isClosed, false);

    frozen1.close();

    expect(frozen1.isClosed, true);
    expect(frozen2.isClosed, false);
    expect(realm.isClosed, false);
  });

  test("Realm.close doesn't close frozen instances", () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozen = freezeRealm(realm);

    expect(realm.isClosed, false);
    expect(frozen.isClosed, false);

    realm.close();
    expect(realm.isClosed, true);
    expect(frozen.isClosed, false);

    frozen.close();
    expect(realm.isClosed, true);
    expect(frozen.isClosed, true);
  });

  test('Subtype of supported type (TZDateTime)', () {
    final realm = getRealm(Configuration.local([When.schema]));
    tz.initializeTimeZones();

    final cph = tz.getLocation('Europe/Copenhagen');
    final now = tz.TZDateTime.now(cph);
    final when = newWhen(now);

    realm.write(() => realm.add(when));

    final stored = realm.all<When>().first.dateTime;

    expect(stored, now);
    expect(stored.timeZone, now.timeZone);
    expect(stored.location, now.location);
    expect(stored.location.name, 'Europe/Copenhagen');
  });

  test('Realm - encryption works', () {
    var config = Configuration.local([Friend.schema], path: p.join(Configuration.defaultStoragePath, "${generateRandomString(8)}.realm"));
    var realm = getRealm(config);
    readFile(String path) {
      final bytes = File(path).readAsBytesSync();
      return utf8.decode(bytes, allowMalformed: true);
    }

    var decoded = readFile(realm.config.path);
    expect(decoded, contains("bestFriend"));

    config = Configuration.local([Friend.schema],
        encryptionKey: generateEncryptionKey(), path: p.join(Configuration.defaultStoragePath, "${generateRandomString(8)}.realm"));
    realm = getRealm(config);
    decoded = readFile(realm.config.path);
    expect(decoded, isNot(contains("bestFriend")));
  });

  test('Realm - open local not encrypted realm with an encryption key', () {
    openEncryptedRealm(null, generateEncryptionKey());
  });

  test('Realm - open local encrypted realm with an empty encryption key', () {
    openEncryptedRealm(generateEncryptionKey(), null);
  });

  test('Realm  - open local encrypted realm with an invalid encryption key', () {
    openEncryptedRealm(generateEncryptionKey(), generateEncryptionKey());
  });

  test('Realm - open local encrypted realm with the correct encryption key', () {
    List<int> key = generateEncryptionKey();
    openEncryptedRealm(key, key);
  });

  test('Realm - open existing local encrypted realm with the correct encryption key', () {
    List<int> key = generateEncryptionKey();
    openEncryptedRealm(key, key, afterEncrypt: (realm) => realm.close());
  });

  test('Realm - open existing local encrypted realm with an invalid encryption key', () {
    openEncryptedRealm(generateEncryptionKey(), generateEncryptionKey(), afterEncrypt: (realm) => realm.close());
  });

  baasTest('Realm - open synced encrypted realm with encryption key', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    List<int> key = List<int>.generate(encryptionKeySize, (i) => random.nextInt(256));
    final configuration = Configuration.flexibleSync(user, [Task.schema], encryptionKey: key);

    final realm = getRealm(configuration);
    expect(realm.isClosed, false);
    expect(
      () => getRealm(Configuration.flexibleSync(user, [Task.schema])),
      throws<RealmException>("already opened with a different encryption key"),
    );
  });

  test('Realm.beginWriteAsync starts write transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();

    expect(transaction.isOpen, true);
  });

  test('Realm.beginWriteAsync with sync commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    transaction.commit();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync with async commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    await transaction.commitAsync();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWrite with sync commit persists changes', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = realm.beginWrite();
    realm.add(Person('John'));
    transaction.commit();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWrite with async commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = realm.beginWrite();
    realm.add(Person('John'));
    await transaction.commitAsync();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync rollback undoes changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    transaction.rollback();

    expect(realm.all<Person>().length, 0);
  });

  test('Realm.writeAsync allows persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    await realm.writeAsync(() {
      realm.add(Person('John'));
    });

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync when realm is closed undoes changes', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));

    await realm1.beginWriteAsync();
    realm1.add(Person('John'));
    realm1.close();

    expect(realm2.all<Person>().length, 0);
  });

  test("Realm.writeAsync with multiple transactions doesnt't deadlock", () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final t1 = await realm.beginWriteAsync();
    realm.add(Person('Marco'));

    final writeFuture = realm.writeAsync(() {
      realm.add(Person('Giovanni'));
    });

    await t1.commitAsync();
    await writeFuture;

    final people = realm.all<Person>();
    expect(people.length, 2);
    expect(people[0].name, 'Marco');
    expect(people[1].name, 'Giovanni');
  });

  test('Realm.writeAsync returns valid objects', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final person = await realm.writeAsync(() {
      return realm.add(Person('John'));
    });

    expect(person.name, 'John');
  });

  test('Realm.writeAsync throws user exception', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    try {
      await realm.writeAsync(() {
        throw Exception('User exception');
      });
    } on Exception catch (e) {
      expect(e.toString(), 'Exception: User exception');
    }
  });

  test('Realm.writeAsync FIFO order ensured', () async {
    final acquisitionOrder = <int>[];
    final futures = <Future<void>>[];

    final realm = getRealm(Configuration.local([Person.schema]));

    for (var i = 0; i < 5; i++) {
      futures.add(realm.writeAsync(() {
        acquisitionOrder.add(i);
      }));
    }

    await Future.wait(futures);

    expect(acquisitionOrder, [0, 1, 2, 3, 4]);
  });

  test('Realm.beginWriteAsync with cancellation token', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));
    final t1 = realm1.beginWrite();

    final token = TimeoutCancellationToken(const Duration(milliseconds: 1), timeoutException: CancelledException());

    await expectLater(realm2.beginWriteAsync(token), throwsA(isA<CancelledException>()));

    t1.rollback();
  });

  test('Realm.writeAsync with cancellation token', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));
    final t1 = realm1.beginWrite();

    final token = CancellationToken();
    Future<void>.delayed(Duration(milliseconds: 1)).then((value) => token.cancel());

    await expectLater(realm2.writeAsync(() {}, token), throwsA(isA<CancelledException>()));

    t1.rollback();
  });

  test('Realm.beginWriteAsync when canceled after write lock obtained is a no-op', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    final transaction = await realm.beginWriteAsync(token);
    token.cancel();

    expect(transaction.isOpen, true);
    expect(realm.isInTransaction, true);

    transaction.rollback();
  });

  test('Realm.writeAsync when canceled after write lock obtained rolls it back', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    await expectLater(
        realm.writeAsync(() {
          realm.add(Person('A'));
          token.cancel();
          realm.add(Person('B'));
        }, token),
        throwsA(isA<CancelledException>()));

    expect(realm.all<Person>().length, 0);
    expect(realm.isInTransaction, false);
  });

  test('Realm.writeAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    token.cancel();

    await expectLater(realm.writeAsync(() {}, token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, false);
  });

  test('Realm.beginWriteAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    token.cancel();

    await expectLater(realm.beginWriteAsync(token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, false);
  });

  test('Transaction.commitAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final transaction = await realm.beginWriteAsync();

    final token = CancellationToken();
    token.cancel();

    await expectLater(transaction.commitAsync(token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, true);
  });

  baasTest('Realm.open (flexibleSync)', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final realm = await getRealmAsync(configuration);
    expect(realm.isClosed, false);
  });

  test('Realm.open (local)', () async {
    final configuration = Configuration.local([Car.schema]);
    final realm = await getRealmAsync(configuration);
    expect(realm.isClosed, false);
  });

  test('Realm.open (local) - cancel before open', () async {
    final configuration = Configuration.local([Car.schema]);
    final cancellationToken = CancellationToken();
    cancellationToken.cancel();
    await expectLater(getRealmAsync(configuration, cancellationToken: cancellationToken), throwsA(isA<CancelledException>()));
  });

  baasTest('Realm.open (flexibleSync) - cancel before open', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final cancellationToken = CancellationToken();
    cancellationToken.cancel();
    await expectLater(getRealmAsync(configuration, cancellationToken: cancellationToken), throwsA(isA<CancelledException>()));
  });

  baasTest('Realm.open (flexibleSync) - cancel right after open', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final cancellationToken = CancellationToken();
    final isRealmCancelled = getRealmAsync(configuration, cancellationToken: cancellationToken).isCancelled();
    cancellationToken.cancel();
    expect(await isRealmCancelled, isTrue);
  });

  baasTest('Realm.open (flexibleSync) - open twice the same realm with the same CancelationToken cancels all', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final cancellationToken = CancellationToken();

    Future<void>.delayed(const Duration(milliseconds: 10), () => cancellationToken.cancel());
    final isRealm1Cancelled = getRealmAsync(configuration, cancellationToken: cancellationToken).isCancelled();
    final isRealm2Cancelled = getRealmAsync(configuration, cancellationToken: cancellationToken).isCancelled();
    expect(await isRealm1Cancelled, isTrue);
    expect(await isRealm2Cancelled, isTrue);
  });

  baasTest('Realm.open (flexibleSync) - open the same realm twice and only cancel the first call', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final cancellationToken1 = CancellationToken();
    final isRealm1Cancelled = getRealmAsync(configuration, cancellationToken: cancellationToken1).isCancelled();

    final cancellationToken2 = CancellationToken();
    final isRealm2Cancelled = getRealmAsync(configuration, cancellationToken: cancellationToken2).isCancelled();
    cancellationToken1.cancel();
    expect(await isRealm1Cancelled, isTrue);
    expect(await isRealm2Cancelled, isFalse);
  });

  baasTest('Realm.open (flexibleSync) - open two different Realms for two different users and cancel only the second call', (appConfiguration) async {
    final app = App(appConfiguration);

    final user1 = await app.logIn(Credentials.anonymous());
    final configuration1 = Configuration.flexibleSync(user1, [Task.schema]);
    final cancellationToken1 = CancellationToken();
    final isRealm1Cancelled = getRealmAsync(configuration1, cancellationToken: cancellationToken1).isCancelled();

    final user2 = await app.logIn(Credentials.anonymous(reuseCredentials: false));
    final configuration2 = Configuration.flexibleSync(user2, [Task.schema]);
    final cancellationToken2 = CancellationToken();
    final isRealm2Cancelled = getRealmAsync(configuration2, cancellationToken: cancellationToken2).isCancelled();

    cancellationToken2.cancel();
    expect(await isRealm2Cancelled, isTrue);
    expect(await isRealm1Cancelled, isFalse);
  });

  baasTest('Realm.open (flexibleSync) - cancel after realm is returned is no-op', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    final cancellationToken = CancellationToken();
    final realm = await getRealmAsync(configuration, cancellationToken: cancellationToken);

    expect(realm, isNotNull);
    expect(realm.isClosed, false);

    cancellationToken.cancel();
    expect(realm.isClosed, false);
  });

  baasTest('Realm.open (flexibleSync) - listen for download progress on an empty realm', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema]);

    int transferredBytes = -1;

    var syncedRealm = await getRealmAsync(configuration, onProgressCallback: (syncProgress) {
      transferredBytes = syncProgress.transferredBytes;
    });

    expect(syncedRealm.isClosed, false);
    expect(transferredBytes, greaterThan(-1));
  });

  baasTest('Realm.open (flexibleSync) - download a populated realm', (appConfiguration) async {
    final app = App(appConfiguration);
    final queryDifferentiator = generateRandomString(10);
    const itemCount = 200;
    final config = await _addDataToAtlas(app, queryDifferentiator: queryDifferentiator, itemCount: itemCount);
    var syncedRealm = await getRealmAsync(config);
    expect(syncedRealm.isClosed, false);
    final data = syncedRealm.query<Product>(r'stringQueryField BEGINSWITH $0', [queryDifferentiator]);
    expect(data.length, itemCount);
  });

  baasTest('Realm.open (flexibleSync) - listen for download progress of a populated realm', (appConfiguration) async {
    final app = App(appConfiguration);
    final config = await _addDataToAtlas(app);

    int printCount = 0;
    int transferredBytes = 0;

    final syncedRealm = await getRealmAsync(config, onProgressCallback: (syncProgress) {
      printCount++;
      transferredBytes = syncProgress.transferredBytes;
    });

    expect(syncedRealm.isClosed, false);
    expect(printCount, isNot(0));
    expect(transferredBytes, greaterThan(19)); //19 bytes is the empty realm
  });

  baasTest('Realm.open (flexibleSync) - listen and cancel download progress of a populated realm', (appConfiguration) async {
    final app = App(appConfiguration);
    final config = await _addDataToAtlas(app);

    final cancellationToken = CancellationToken();
    bool progressReturned = false;
    final realmIsCancelled = getRealmAsync(config, cancellationToken: cancellationToken, onProgressCallback: (syncProgress) {
      progressReturned = true;
    }).isCancelled();
    cancellationToken.cancel();
    expect(await realmIsCancelled, isTrue);
    expect(progressReturned, isFalse);
  });
}

List<int> generateEncryptionKey() {
  return List<int>.generate(encryptionKeySize, (i) => random.nextInt(256));
}

void openEncryptedRealm(List<int>? encryptionKey, List<int>? decryptionKey, {void Function(Realm)? afterEncrypt}) {
  final config1 = Configuration.local([Car.schema], encryptionKey: encryptionKey);
  final config2 = Configuration.local([Car.schema], encryptionKey: decryptionKey);
  final realm = getRealm(config1);
  if (afterEncrypt != null) {
    afterEncrypt(realm);
  }
  if (encryptionKey == decryptionKey) {
    final decriptedRealm = getRealm(config2);
    expect(decriptedRealm.isClosed, false);
  } else {
    expect(
      () => getRealm(config2),
      throws<RealmException>(realm.isClosed ? "Realm file decryption failed" : "already opened with a different encryption key"),
    );
  }
}

extension on Future<Realm> {
  Future<bool> isCancelled() async {
    try {
      final value = await this;
      expect(value, isNotNull);
      expect(value.isClosed, false);
      return false;
    } on CancelledException {
      return true;
    }
  }
}

Future<Configuration> _addDataToAtlas(App app, {String? queryDifferentiator, int itemCount = 100}) async {
  final productNamePrefix = queryDifferentiator ?? generateRandomString(10);
  final user1 = await app.logIn(Credentials.anonymous(reuseCredentials: false));
  final config1 = Configuration.flexibleSync(user1, [Product.schema]);
  final realm1 = getRealm(config1);
  final query1 = realm1.query<Product>(r'stringQueryField BEGINSWITH $0', [productNamePrefix]);
  if (realm1.subscriptions.find(query1) == null) {
    realm1.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.add(query1));
  }
  await realm1.subscriptions.waitForSynchronization();
  realm1.close();

  final user2 = await app.logIn(Credentials.anonymous(reuseCredentials: false));
  final config2 = Configuration.flexibleSync(user2, [Product.schema]);
  final realm2 = getRealm(config2);
  final query2 = realm2.query<Product>(r'stringQueryField BEGINSWITH $0', [productNamePrefix]);

  if (realm2.subscriptions.find(query2) == null) {
    realm2.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.add(query2));
  }
  await realm2.subscriptions.waitForSynchronization();
  realm2.write(() {
    for (var i = 0; i < itemCount; i++) {
      realm2.add(Product(ObjectId(), "${productNamePrefix}_${i + 1}"));
    }
  });
  await realm2.syncSession.waitForUpload();
  realm2.close();
  return config1;
}

extension on When {
  tz.TZDateTime get dateTime => tz.TZDateTime.from(dateTimeUtc, tz.getLocation(locationName));
}

When newWhen([tz.TZDateTime? time]) {
  time ??= tz.TZDateTime(tz.UTC, 0);
  return When(time.toUtc(), time.location.name);
}

extension _IterableEx<T> on Iterable<T> {
  Iterable<T> except(T exclude) => where((o) => o != exclude);
}
