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

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Results all should not return null', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final cars = realm.all<Car>();
    expect(cars, isNotNull);
  });

  test('Results length after deletedMany', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    var cars = realm.all<Car>();
    expect(cars.isEmpty, true);

    final car = Car("Opel");
    realm.write(() => realm.add(car));

    expect(cars.isEmpty, false);

    realm.write(() => realm.delete(car));

    expect(cars.isEmpty, true);
  });

  test('Results from query isEmpty', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('');
    realm.write(() => realm.add(car));

    final cars = realm.all<Car>();
    expect(cars[0].make, car.make);
  });

  test('Results requested wrong index throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final cars = realm.all<Car>();

    expect(() => cars[0], throws<RealmException>("Requested index 0 in empty Results"));
  });

  test('Results iteration test', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Results snapshot iteration test', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Results query', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Results query with parameter', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Results query with multiple parameters', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Query results with no arguments throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0'), throws<RealmException>("no arguments are provided"));
  });

  test('Results query with wrong argument types (int for string) throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0', [1]), throws<RealmException>("Unsupported comparison between type"));
  });

  test('Results query with wrong argument types (bool for int) throws ', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Dog("Foxi")));
    expect(() => realm.all<Dog>().query(r'age == $0', [true]), throws<RealmException>("Unsupported comparison between type"));
  });

  test('Results sort', () {
    var config = Configuration.local([Person.schema]);
    var realm = getRealm(config);

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

  test('Results sort order is preserved', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Results - get query length after realm is closed throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    final teams = realm.query<Team>('name BEGINSWITH "Team"');
    realm.close();
    expect(() => teams.length, throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Results - query with null', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    var ben = Person('Ben');
    final fido = Dog('Fido', owner: ben);
    final laika = Dog('Laika'); // no owner;
    realm.write(() {
      realm.addAll([fido, laika]);
    });
    expect(realm.query<Dog>(r'owner = $0', [ben]), [fido]);
    expect(realm.query<Dog>(r'owner = $0', [null]), [laika]);
  });

  test('Results access after realm closed throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.close();
    expect(() => teams[0], throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Realm deleteMany from results', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Results notifications', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Results notifications can be paused', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Results notifications can be resumed', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

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
  });

  test('Results notifications can leak', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final leak = realm.all<Dog>().changes.listen((data) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('Results.freeze freezes query', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(Person('Peter'));
    });

    final livePeople = realm.all<Person>();
    final frozenPeople = freezeResults(livePeople);

    expect(frozenPeople.length, 1);
    expect(frozenPeople.isFrozen, true);
    expect(frozenPeople.realm.isFrozen, true);
    expect(frozenPeople.single.isFrozen, true);

    realm.write(() {
      livePeople.single.name = 'Peter II';
      realm.add(Person('George'));
    });

    expect(livePeople.length, 2);
    expect(livePeople.first.name, 'Peter II');
    expect(frozenPeople.length, 1);
    expect(frozenPeople.single.name, 'Peter');
  });

  test("FrozenResults.changes throws", () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenPeople = freezeResults(realm.all<Person>());

    expect(() => frozenPeople.changes, throws<RealmStateError>('Results are frozen and cannot emit changes'));
  });

  test('Results.freeze when frozen returns same object', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final people = realm.all<Person>();

    final frozenPeople = freezeResults(people);
    final deepFrozenPeople = freezeResults(frozenPeople);

    expect(identical(frozenPeople, deepFrozenPeople), true);

    final frozenPeopleAgain = freezeResults(people);
    expect(identical(frozenPeople, frozenPeopleAgain), false);
  });

  test('Results.query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];

    final team = Team('Class of 92', players: [alice, bob]);

    realm.write(() {
      realm.addAll(players);
      return realm.add(team);
    });

    expect(realm.all<Person>(), [alice, bob, carol, dan]);
    expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty);
    expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(realm.query<Person>("name CONTAINS 'a'"), [carol, dan]); // Alice is capital 'a'
    expect(realm.query<Person>("name CONTAINS 'l'"), [alice, carol]);
    expect(realm.query<Person>("name CONTAINS 'a'").query("name CONTAINS 'l'"), isNot([alice, carol]));
    expect(realm.query<Person>("name CONTAINS 'a'").query("name CONTAINS 'l'"), [carol]);
  });

  test('Results of primitives', () {
    var config = Configuration.local([Player.schema, Game.schema]);
    var realm = getRealm(config);

    final scores = [-1, null, 0, 1];
    final alice = Player('Alice', scoresByRound: scores);
    realm.write(() => realm.add(alice));

    expect(alice.scoresByRound, scores);
    expect(alice.scoresByRound.asResults(), scores);
  });

  test('Results of primitives notifications', () {
    var config = Configuration.local([Player.schema, Game.schema]);
    var realm = getRealm(config);

    final scores = [-1, null, 0, 1];
    final alice = Player('Alice', scoresByRound: scores);
    realm.write(() => realm.add(alice));

    final results = alice.scoresByRound.asResults();
    expectLater(
        results.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges>().having((ch) => ch.inserted, 'inserted', <int>[]),
          isA<RealmResultsChanges>().having((ch) => ch.inserted, 'inserted', [4]),
          isA<RealmResultsChanges>() //
              .having((ch) => ch.inserted, 'inserted', [0]) //
              .having((ch) => ch.deleted, 'deleted', [1]),
          isA<RealmResultsChanges>().having((ch) => ch.deleted, 'deleted', [2, 4]),
        ]));

    realm.write(() => alice.scoresByRound.add(2));
    realm.write(() {
      alice.scoresByRound.insert(0, 3);
      alice.scoresByRound.remove(null);
    });
    realm.write(() {
      alice.scoresByRound.removeAt(2);
      alice.scoresByRound.removeAt(3); // index 4 in old list
    });
  });

  test('List.asResults().query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');

    final team = realm.write(() {
      return realm.add(Team('Class of 92', players: [alice, bob, carol, dan]));
    });

    final playersAsResults = team.players.asResults();

    expect(playersAsResults, [alice, bob, carol, dan]);
    expect(playersAsResults.query('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty);
    expect(playersAsResults.query('FALSEPREDICATE').query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(playersAsResults.query("name CONTAINS 'a'"), [carol, dan]); // Alice is capital 'a'
    expect(playersAsResults.query("name CONTAINS 'l'"), [alice, carol]);
    expect(playersAsResults.query("name CONTAINS 'a'").query("name CONTAINS 'l'"), isNot([alice, carol]));
    expect(playersAsResults.query("name CONTAINS 'a'").query("name CONTAINS 'l'"), [carol]);

    expect(() => realm.write(() => realm.deleteMany(playersAsResults.query("name CONTAINS 'a'"))), returnsNormally);
    expect(team.players, [alice, bob]); // Alice is capital 'a'
  });

  test('Results.query with remapped property', () {
    final config = Configuration.local([RemappedClass.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(RemappedClass('Peter'));
      realm.add(RemappedClass('George'));
    });

    final queryByModelName = realm.query<RemappedClass>('remappedProperty = "Peter"');
    expect(queryByModelName.single.remappedProperty, 'Peter');

    final queryByInternalName = realm.query<RemappedClass>('primitive_property = "Peter"');
    expect(queryByInternalName.single.remappedProperty, 'Peter');
  });
}
