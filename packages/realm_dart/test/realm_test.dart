// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:realm_dart/realm.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'test.dart';
import 'utils/platform_util.dart';

void main() {
  setupTests();

  test('Realm can be created', () {
    final config = Configuration.local([Car.schema]);
    expect(() => getRealm(config), returnsNormally);
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
    final config = Configuration.local([Car.schema]);
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
    final config = Configuration.local([Person.schema]);
    var realm = getRealm(config);
    expect(realm.schema.any((s) => s.name == Person.schema.name), true);
    expect(realm.schema.any((s) => s.name == Car.schema.name), false);
    realm.close();

    final config1 = Configuration.local([Person.schema, Car.schema]);
    var realm1 = getRealm(config1);
    expect(realm1.schema.any((s) => s.name == Person.schema.name), true);
    expect(realm1.schema.any((s) => s.name == Car.schema.name), true);
  });

  test('Realm open twice with same schema', () async {
    final config = Configuration.local([Person.schema, Car.schema]);
    final realm = getRealm(config);

    final config1 = Configuration.local([Person.schema, Car.schema]);
    final realm1 = getRealm(config1);

    expect(realm.schema, realm1.schema);
  });

  test('Realm add throws when no write transaction', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    final car = Car('');
    expect(() => realm.add(car), throws<RealmException>("Trying to modify database while in read transaction"));
  });

  test('Realm existsSync', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    expect(Realm.existsSync(config.path), false);
    expect(() => getRealm(config), returnsNormally);
    expect(Realm.existsSync(config.path), true);
  });

  test('Realm exists', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    expect(await Realm.exists(config.path), false);
    expect(() => getRealm(config), returnsNormally);
    expect(await Realm.exists(config.path), true);
  });

  test('Realm deleteRealm succeeds', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    realm.close();
    Realm.deleteRealm(config.path);

    expect(Realm.existsSync(config.path), false);
  });

  test('Realm deleteRealm throws exception on an open realm', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    expect(() => Realm.deleteRealm(config.path), throws<RealmException>());

    expect(Realm.existsSync(config.path), true);

    realm.close();

    expect(() => Realm.deleteRealm(config.path), returnsNormally);
  });

  test('Realm add object', () {
    final config = Configuration.local([Car.schema]);
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
    final config = Configuration.local([Car.schema]);
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
    final config = Configuration.local([Team.schema, Person.schema]);
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
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    expect(() => realm.write(() => realm.add(Person(''))), throws<RealmError>("not configured"));
  });

  test('Realm add returns the same object', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('');
    Car? addedCar;
    realm.write(() {
      addedCar = realm.add(car);
    });

    expect(addedCar == car, isTrue);
  });

  test('Realm add object transaction rollbacks on exception', () {
    final config = Configuration.local([Car.schema]);
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
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(() => realm.write(() => realm.add(carTwo)), throws<RealmException>());
  });

  test('Realm adding objects with duplicate primary with update flag', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(realm.write(() => realm.add(carTwo, update: true)), carOne);
  });

  test('Realm adding object graph with multiple existing objects with with update flag', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(realm.write(() => realm.add(carTwo, update: true)), carTwo);
  });

  test('Realm write after realm is closed', () async {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);

    realm.close();
    _expectAllWritesToThrow<RealmClosedError>(realm, "Cannot access realm that has been closed");
    _expectAllAsyncWritesToThrow<RealmClosedError>(realm, "Cannot access realm that has been closed");
  });

  test('Realm write on read-only realms throws', () async {
    Configuration config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    config = Configuration.local([Car.schema], isReadOnly: true);
    realm = getRealm(config);
    _expectAllWritesToThrow<RealmException>(realm, "Can't perform transactions on read-only Realms.");
    _expectAllAsyncWritesToThrow<RealmException>(realm, "Can't perform transactions on read-only Realms.");
  });

  test('Realm query', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Realm query with parameter', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.query<Car>(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Realm query with multiple parameters', () {
    final config = Configuration.local([Team.schema, Person.schema]);
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
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("Opel");
    expect(car, isNotNull);
  });

  test('Realm find not configured object by primary key throws exception', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    expect(() => realm.find<Person>("Me"), throws<RealmError>("not configured"));
  });

  test('Realm find object by primary key default value', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car('Tesla')));

    final car = realm.find<Car>("Tesla");
    expect(car, isNotNull);
    expect(car?.make, equals("Tesla"));
  });

  test('Realm find non existing object by primary key returns null', () {
    final config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("NonExistingPrimaryKey");
    expect(car, isNull);
  });

  test('Realm delete object', () {
    final config = Configuration.local([Car.schema]);
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
    final config = Configuration.local([Team.schema, Person.schema]);
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
    expect(teams[0].players, newPlayers);
    final allPersons = realm.all<Person>();
    expect(allPersons.length, 3);

    //Delete team players
    realm.write(() => realm.deleteMany(teams[0].players));

    //Ensure players are deleted from collection
    expect(teams[0].players.length, 0);

    //Reload all persons from realm and ensure they are deleted
    expect(allPersons.length, 0);
  });

  test('Realm deleteMany from list referenced by two objects', () {
    final config = Configuration.local([Team.schema, Person.schema]);
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
    final config = Configuration.local([Team.schema, Person.schema]);
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
    final config = Configuration.local([Team.schema, Person.schema]);
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

    final config = Configuration.local([School.schema, Student.schema]);
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
    await Future<void>.delayed(Duration(milliseconds: 10));

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
    final config = Configuration.local([Car.schema]);
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
      _expectAllWritesToThrow<RealmException>(realm, "The Realm is already in a write transaction");
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

  test('FrozenRealm cannot write', () async {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenRealm = freezeRealm(realm);
    _expectAllWritesToThrow<RealmException>(frozenRealm, "Can't perform transactions on a frozen Realm");
    _expectAllAsyncWritesToThrow<RealmException>(frozenRealm, "Can't perform transactions on a frozen Realm");
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

  test('Realm.add with frozen object argument throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final frozenPeter = freezeObject(realm.write(() {
      return realm.add(Person('Peter'));
    }));

    realm.write(() {
      expect(() => realm.add(frozenPeter), throws<RealmError>('Cannot add object to Realm because the object is managed by a frozen Realm'));
    });
  });

  test('Realm.delete frozen object throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final frozenPeter = freezeObject(realm.write(() {
      return realm.add(Person('Peter'));
    }));

    realm.write(() {
      expect(() => realm.delete(frozenPeter), throws<RealmError>('Cannot delete object from Realm because the object is managed by a frozen Realm'));
    });
  });

  test('Realm.delete unmanaged object throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    realm.write(() {
      expect(() => realm.delete(Person('Peter')), throws<RealmError>('Cannot delete an unmanaged object'));
    });
  });

  test('Realm.deleteMany frozen results throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    realm.write(() {
      realm.add(Person('Peter'));
    });

    final frozenPeople = freezeResults(realm.all<Person>());

    realm.write(() {
      expect(() => realm.deleteMany(frozenPeople), throws<RealmError>('Cannot delete objects from Realm because the object is managed by a frozen Realm'));
    });
  });

  test('Realm.deleteMany frozen list throws', () {
    final realm = getRealm(Configuration.local([Person.schema, Team.schema]));
    final team = realm.write(() {
      return realm.add(Team('Team 1', players: [Person('Peter')]));
    });

    final frozenPlayers = freezeList(team.players);

    realm.write(() {
      expect(() => realm.deleteMany(frozenPlayers), throws<RealmError>('Cannot delete objects from Realm because the object is managed by a frozen Realm'));
    });
  });

  test('Realm.deleteMany regular list with frozen elements throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final peter = realm.write(() {
      return realm.add(Person('Peter'));
    });

    final frozenPeter = freezeObject(peter);

    realm.write(() {
      expect(
          () => realm.deleteMany([peter, frozenPeter]), throws<RealmError>('Cannot delete object from Realm because the object is managed by a frozen Realm'));
    });
  });

  test('Realm.add with object from another Realm throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final otherRealm = getRealm(Configuration.local([Person.schema]));

    final peter = realm.write(() {
      return realm.add(Person('Peter'));
    });

    otherRealm.write(() {
      expect(() => otherRealm.add(peter), throws<RealmError>('Cannot add object to Realm because the object is managed by another Realm instance'));
    });
  });

  test('Realm.delete object from another Realm throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final otherRealm = getRealm(Configuration.local([Person.schema]));

    final peter = realm.write(() {
      return realm.add(Person('Peter'));
    });

    otherRealm.write(() {
      expect(() => otherRealm.delete(peter), throws<RealmError>('Cannot delete object from Realm because the object is managed by another Realm instance'));
    });
  });

  test('Realm.deleteMany results from another Realm throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final otherRealm = getRealm(Configuration.local([Person.schema]));

    realm.write(() {
      realm.add(Person('Peter'));
    });

    final people = realm.all<Person>();

    otherRealm.write(() {
      expect(
          () => otherRealm.deleteMany(people), throws<RealmError>('Cannot delete objects from Realm because the object is managed by another Realm instance'));
    });
  });

  test('Realm.deleteMany list from another Realm throws', () {
    final realm = getRealm(Configuration.local([Person.schema, Team.schema]));
    final otherRealm = getRealm(Configuration.local([Person.schema]));

    final team = realm.write(() {
      return realm.add(Team('Team 1', players: [Person('Peter')]));
    });

    otherRealm.write(() {
      expect(() => otherRealm.deleteMany(team.players),
          throws<RealmError>('Cannot delete objects from Realm because the object is managed by another Realm instance'));
    });
  });

  test('Realm.deleteMany regular list with elements from another Realm throws', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final otherRealm = getRealm(Configuration.local([Person.schema]));

    final peter = realm.write(() {
      return realm.add(Person('Peter'));
    });

    otherRealm.write(() {
      expect(
          () => otherRealm.deleteMany([peter]), throws<RealmError>('Cannot delete object from Realm because the object is managed by another Realm instance'));
    });
  });

  test('Realm - encryption works', () async {
    var config = Configuration.local([Friend.schema], path: generateRandomRealmPath());
    var realm = getRealm(config);
    readFile(String path) async {
      final bytes = await platformUtil.readAsBytes(path);
      return utf8.decode(bytes, allowMalformed: true);
    }

    var decoded = await readFile(realm.config.path);
    expect(decoded, contains("bestFriend"));

    config = Configuration.local([Friend.schema], encryptionKey: generateEncryptionKey(), path: generateRandomRealmPath());
    realm = getRealm(config);
    decoded = await readFile(realm.config.path);
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

  test('Realm.beginWriteAsync starts write transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    expect(transaction.isOpen, true);
  });

  test('Realm.beginWriteAsync from inside an existing write transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    Future<void>.delayed(Duration(milliseconds: 10), () => transaction.commit());

    final transaction1 = await realm.beginWriteAsync();

    await transaction1.commitAsync();

    expect(transaction.isOpen, false);
    expect(transaction1.isOpen, false);
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

  test("Realm.writeAsync with multiple transactions doesn't deadlock", () async {
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

  test('Realm.writeAsync with async callback fails with assert', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    await expectLater(realm.writeAsync(() async {}), throwsA(isA<AssertionError>()));
  });

  test('Realm.write with async callback', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    expect(() => realm.write(() async {}), throwsA(isA<AssertionError>()));
  });

  test('Transaction.commitAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final transaction = await realm.beginWriteAsync();

    final token = CancellationToken();
    token.cancel();

    await expectLater(transaction.commitAsync(token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, true);
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

  void addDataForCompact(Realm realm, String compactTest) {
    realm.write(() {
      for (var i = 0; i < 2500; i++) {
        realm.add(Product(ObjectId(), compactTest));
      }
    });

    realm.write(() => realm.deleteMany(realm.query<Product>("name CONTAINS '$compactTest'")));

    realm.write(() {
      for (var i = 0; i < 10; i++) {
        realm.add(Product(ObjectId(), compactTest));
      }
    });
  }

  Future<int> createRealmForCompact(Configuration config) async {
    var realm = getRealm(config);
    final compactTest = generateRandomString(10);

    addDataForCompact(realm, compactTest);

    final beforeSize = platformUtil.sizeOnStorage(config);

    realm.close();
    return beforeSize;
  }

  void validateCompact(bool compacted, Configuration config, int beforeCompactSizeSize) async {
    expect(compacted, true);
    final afterCompactSize = await platformUtil.sizeOnStorage(config);
    expect(beforeCompactSizeSize, greaterThan(afterCompactSize));
  }

  test('Realm - local realm can be compacted', () async {
    final config = Configuration.local([Product.schema], path: generateRandomRealmPath());
    final beforeCompactSizeSize = await createRealmForCompact(config);

    final compacted = Realm.compact(config);

    validateCompact(compacted, config, beforeCompactSizeSize);

    //test the realm can be opened.
    expect(() => getRealm(config), returnsNormally);
  });

  test('Realm - non existing realm can not be compacted', () async {
    final config = Configuration.local([Product.schema], path: generateRandomRealmPath());
    final compacted = Realm.compact(config);
    expect(compacted, false);
  });

  test('Realm - local realm can be compacted in worker isolate', () async {
    final config = Configuration.local([Product.schema], path: generateRandomRealmPath());
    final beforeCompactSizeSize = await createRealmForCompact(config);

    final receivePort = ReceivePort();
    await Isolate.spawn((List<Object> args) async {
      SendPort sendPort = args[0] as SendPort;
      final path = args[1] as String;
      final config = Configuration.local([Product.schema], path: path);
      final compacted = Realm.compact(config);
      Isolate.exit(sendPort, compacted);
    }, [receivePort.sendPort, config.path]);

    final compacted = await receivePort.first as bool;

    validateCompact(compacted, config, beforeCompactSizeSize);

    //test the realm can be opened.
    expect(() => getRealm(config), returnsNormally);
  });

  test('Realm - local encrypted realm can be compacted', () async {
    final config = Configuration.local([Product.schema], encryptionKey: generateEncryptionKey(), path: generateRandomRealmPath());

    final beforeCompactSizeSize = await createRealmForCompact(config);

    final compacted = Realm.compact(config);

    validateCompact(compacted, config, beforeCompactSizeSize);

    //test the realm can be opened.
    expect(() => getRealm(config), returnsNormally);
  });

  test('Realm - in-memory realm can not be compacted', () async {
    final config = Configuration.inMemory([Product.schema], path: generateRandomRealmPath());
    expect(() => Realm.compact(config), throws<RealmException>("Can't compact an in-memory Realm"));
  });

  test('Realm - readonly realm can not be compacted', () async {
    final path = generateRandomRealmPath();
    var config = Configuration.local([Product.schema], path: path);
    await createRealmForCompact(config);

    config = Configuration.local([Product.schema], isReadOnly: true, path: path);
    expect(() => Realm.compact(config), throws<RealmException>("Can't compact a read-only Realm"));

    //test the realm can be opened.
    expect(() => getRealm(config), returnsNormally);
  });

  test('Realm writeCopy local to existing file', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);
    expect(() => realm.writeCopy(config),
        throws<RealmException>(Platform.isWindows ? "The file exists" : "Failed to open file at path '${config.path}': File exists"));
  });

  test('Realm writeCopy Local to not existing directory', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);
    final path = '';
    expect(
        () => realm.writeCopy(Configuration.local([Car.schema], path: path)),
        throws<RealmException>(
            Platform.isWindows ? "The system cannot find the path specified." : "Failed to open file at path '$path': parent directory does not exist"));
  });

  test('Realm writeCopy Local->Local inside a write block is not allowed.', () {
    final originalConfig = Configuration.local([Car.schema]);
    final originalRealm = getRealm(originalConfig);
    final pathCopy = originalConfig.path.replaceFirst(p.basenameWithoutExtension(originalConfig.path), generateRandomString(10));
    final configCopy = Configuration.local([Car.schema], path: pathCopy);
    originalRealm.write(() {
      expect(() => originalRealm.writeCopy(configCopy), throws<RealmError>("Copying a Realm is not allowed within a write transaction or during migration."));
    });
    originalRealm.close();
  });

  test('Realm writeCopy Local->Local during migration is not allowed', () {
    getRealm(Configuration.local([Car.schema], schemaVersion: 1)).close();

    final configWithMigrationCallback = Configuration.local([Car.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      final pathCopy = migration.newRealm.config.path.replaceFirst(p.basenameWithoutExtension(migration.newRealm.config.path), generateRandomString(10));
      final configCopy = Configuration.local([Car.schema], path: pathCopy);
      expect(
          () => migration.newRealm.writeCopy(configCopy), throws<RealmError>("Copying a Realm is not allowed within a write transaction or during migration."));
    });
    getRealm(configWithMigrationCallback);
  });

  test('Realm writeCopy Local->Local read-only', () {
    final originalConfig = Configuration.local([Car.schema]);
    final originalRealm = getRealm(originalConfig);
    final pathCopy = originalConfig.path.replaceFirst(p.basenameWithoutExtension(originalConfig.path), generateRandomString(10));
    final configCopy = Configuration.local([Car.schema], path: pathCopy, isReadOnly: true);
    final itemsCount = 2;
    originalRealm.write(() {
      for (var i = 0; i < itemsCount; i++) {
        originalRealm.add(Car("make_${i + 1}"));
      }
    });
    originalRealm.writeCopy(configCopy);
    originalRealm.close();

    expect(Realm.existsSync(pathCopy), isTrue);
    final copiedRealm = getRealm(configCopy);
    expect(copiedRealm.all<Car>().length, itemsCount);
    copiedRealm.close();
  });

  test('Realm writeCopy in-memory Local->Local', () {
    final originalConfig = Configuration.inMemory([Car.schema]);
    final originalRealm = getRealm(originalConfig);
    final pathCopy = originalConfig.path.replaceFirst(p.basenameWithoutExtension(originalConfig.path), generateRandomString(10));
    final configCopy = Configuration.local([Car.schema], path: pathCopy);
    final itemsCount = 2;
    originalRealm.write(() {
      for (var i = 0; i < itemsCount; i++) {
        originalRealm.add(Car("make_${i + 1}"));
      }
    });
    originalRealm.writeCopy(configCopy);
    originalRealm.close();

    final copiedRealm = getRealm(configCopy);
    expect(copiedRealm.all<Car>().length, itemsCount);
    copiedRealm.close();

    final realmSecondTimeOpened = getRealm(configCopy);
    expect(realmSecondTimeOpened.all<Car>().length, itemsCount);
    realmSecondTimeOpened.close();
  });

  // writeCopy Local to Local realm
  for (bool isEmpty in [true, false]) {
    for (List<int>? sourceEncryptedKey in [null, generateEncryptionKey()]) {
      for (List<int>? destinationEncryptedKey in [sourceEncryptedKey, generateEncryptionKey()]) {
        final dataState = isEmpty ? "empty" : "populated";
        final sourceEncryptedState = '${sourceEncryptedKey != null ? "encrypted " : ""}Local';
        final destinationEncryptedState =
            'to ${destinationEncryptedKey != null ? "encrypted with ${sourceEncryptedKey != null && sourceEncryptedKey == destinationEncryptedKey ? "the same" : "different"} key " : ""}Local';
        final testDescription = '$dataState $sourceEncryptedState $destinationEncryptedState can be opened';
        test('Realm writeCopy Local->Local - $testDescription', () {
          final originalConfig = Configuration.local([Car.schema], encryptionKey: sourceEncryptedKey, path: generateRandomRealmPath());
          final originalRealm = getRealm(originalConfig);
          var itemsCount = 0;
          if (!isEmpty) {
            itemsCount = 2;
            originalRealm.write(() {
              for (var i = 0; i < itemsCount; i++) {
                originalRealm.add(Car("make_${i + 1}"));
              }
            });
          }
          final pathCopy = originalConfig.path.replaceFirst(p.basenameWithoutExtension(originalConfig.path), generateRandomString(10));
          final configCopy = Configuration.local([Car.schema], path: pathCopy, encryptionKey: destinationEncryptedKey);
          originalRealm.writeCopy(configCopy);
          originalRealm.close();

          expect(Realm.existsSync(pathCopy), isTrue);
          final copiedRealm = getRealm(configCopy);
          expect(copiedRealm.all<Car>().length, itemsCount);
          copiedRealm.close();
        });
      }
    }
  }

  test('Realm.refresh no changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final result = realm.refresh();
    expect(result, false);
  });

  test('Realm.refreshAsync() sync transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    var called = false;
    bool isRefreshed = false;
    final transaction = realm.beginWrite();
    realm.refreshAsync().then((refreshed) {
      called = true;
      isRefreshed = refreshed;
    });
    realm.add(Person("name"));
    transaction.commit();

    await Future<void>.delayed(Duration(milliseconds: 1));
    expect(isRefreshed, false);
    expect(called, true);
    expect(realm.all<Person>().length, 1);
  });

  test('Realm.refreshAsync from within a write block', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    var called = false;
    bool isRefreshed = false;
    realm.write(() {
      realm.refreshAsync().then((refreshed) {
        called = true;
        isRefreshed = refreshed;
      });
      realm.add(Person("name"));
    });

    await Future<void>.delayed(Duration(milliseconds: 1));
    expect(isRefreshed, false);
    expect(called, true);
    expect(realm.all<Person>().length, 1);
  });

  test('Realm.refreshAsync from within an async transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    bool called = false;
    bool isRefreshed = false;
    final transaction = await realm.beginWriteAsync();
    realm.refreshAsync().then((refreshed) {
      called = true;
      isRefreshed = refreshed;
    });
    realm.add(Person("name"));
    await transaction.commitAsync();
    expect(isRefreshed, false);
    expect(called, true);
    expect(realm.all<Person>().length, 1);
  });

  test('Realm.refresh on frozen realm should be no-op', () async {
    var realm = getRealm(Configuration.local([Person.schema]));
    realm = realm.freeze();
    expect(realm.refresh(), false);
  });

  test('Realm.refresh', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    String personName = generateRandomString(5);
    final path = realm.config.path;
    final results = realm.query<Person>(r"name == $0", [personName]);

    expect(realm.refresh(), false);
    realm.disableAutoRefreshForTesting();

    ReceivePort receivePort = ReceivePort();
    Isolate.spawn((SendPort sendPort) async {
      final externalRealm = Realm(Configuration.local([Person.schema], path: path));
      externalRealm.write(() => externalRealm.add(Person(personName)));
      externalRealm.close();
      sendPort.send(true);
    }, receivePort.sendPort);

    await receivePort.first;
    expect(results.length, 0);
    expect(realm.refresh(), true);
    expect(results.length, 1);
    receivePort.close();
  });

  test('Realm path with unicode symbols', () {
    final config = Configuration.local([Car.schema], path: generateRandomRealmPath(useUnicodeCharacters: true));
    var realm = getRealm(config);
    expect(realm.isClosed, false);
  }, skip: Platform.isAndroid || Platform.isIOS); // TODO: Enable test after fixing https://github.com/realm/realm-dart/issues/1230

  test('Realm local add/query data with unicode symbols', () {
    final productName = generateRandomUnicodeString();
    final config = Configuration.local([Product.schema]);
    final realm = getRealm(config);
    realm.write(() => realm.add(Product(ObjectId(), productName)));
    final query = realm.query<Product>(r'name == $0', [productName]);
    expect(query.length, 1);
    expect(query[0].name, productName);
  });

  test('Realm case-insensitive query', () {
    final productName = generateRandomString(10).toUpperCase();
    final config = Configuration.local([Product.schema]);
    final realm = getRealm(config);
    realm.write(() => realm.add(Product(ObjectId(), productName)));
    final query = realm.query<Product>(r'name LIKE[c] $0', [productName.toLowerCase()]);
    expect(query.length, 1);
    expect(query[0].name, productName);
  });

  test('Local realm can be opened with orphaned embedded objects', () {
    final config = Configuration.local([Car.schema, AllTypesEmbedded.schema], path: generateRandomRealmPath());
    expect(() => getRealm(config), returnsNormally);
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
    final decryptedRealm = getRealm(config2);
    expect(decryptedRealm.isClosed, false);
  } else {
    expect(
      () => getRealm(config2),
      throws<RealmException>(realm.isClosed ? "Realm file decryption failed" : "already opened with a different encryption key"),
    );
  }
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

void _expectAllWritesToThrow<T>(Realm realm, String exceptionMessage) {
  expect(() => realm.write(() {}), throws<T>(exceptionMessage));
  expect(() => realm.beginWrite(), throws<T>(exceptionMessage));
}

void _expectAllAsyncWritesToThrow<T>(Realm realm, String exceptionMessage) {
  expect(() => realm.writeAsync(() {}), throws<T>(exceptionMessage));
  expect(() => realm.beginWriteAsync(), throws<T>(exceptionMessage));
}
