// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';
import 'test.dart';

//TODO This file is called list_test, while the one for maps and sets are called realm_map/set_test
void main() {
  setupTests();

  test('Lists add object with a list property', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    expect(teams.length, 1);
    expect(teams[0].name, "Ferrari");
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 0);
  });

  test('Lists get set', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => players[-1], throws<RealmException>("Index out of range"));
    expect(() => players[800], throws<RealmException>());
  });

  test('Lists set invalid index throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => realm.write(() => players[-1] = Person('')), throws<RealmException>("Index can not be negative"));
    expect(() => realm.write(() => players[800] = Person('')), throws<RealmException>());
  });

  test('List clear items from list', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

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

  test('Read list property of a deleted object', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.write(() => realm.delete(team));
    expect(() => team.players, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('Delete a list of objects through a deleted parent', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var players = team.players;
    realm.write(() => realm.delete(team));
    expect(() => realm.write(() => realm.deleteMany(players)),
        throws<RealmException>("List is no longer valid. Either the parent object was deleted or the containing Realm has been invalidated or closed"));
  });

  test('Get length of list property on a deleted object', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne")..players.add(Person("Nikos"));
    realm.write(() {
      realm.add(team);
      realm.delete(team);
    });
    expect(() => team.players.length, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('List isValid', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(Team("Speed Team", players: [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ]));
    });

    var teams = realm.all<Team>();

    expect(teams, isNotNull);
    expect(teams.length, 1);
    final players = teams[0].players;
    expect(players.isValid, true);
    realm.close();
    expect(players.isValid, false);
  });

  test('List notifications', () async {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team('t1', players: [Person("p1")]);
    realm.write(() => realm.add(team));

    var firstCall = true;
    final subscription = team.players.changes.listen((changes) {
      if (firstCall) {
        firstCall = false;
        expect(changes.inserted.isEmpty, true);
        expect(changes.modified.isEmpty, true);
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified.isEmpty, true);
        expect(changes.moved.isEmpty, true);
      } else {
        expect(changes.inserted, [1]); //new object at index 1
        expect(changes.modified, [0]); //object at index 0 changed
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified, [0]);
        expect(changes.moved.isEmpty, true);
      }
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    realm.write(() {
      team.players.add(Person("p2"));
      team.players.first.name = "p3";
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 20));
  });

  void testListNotificationsHelper<T>(
    String opName,
    RealmList<T> Function(AllCollections c) getList,
    List<int> Function(RealmListChanges<T> ch) getIndexes,
    void Function(RealmList<T> list, int index) op,
    List<List<int>> listOfIndexes, {
    Iterable<T> Function()? factory,
  }) {
    test('RealmList<$T>.$opName notifications', () {
      final config = Configuration.local([AllCollections.schema]);
      final realm = getRealm(config);

      final allCollections = realm.write(() => realm.add(AllCollections()));

      final list = getList(allCollections);
      if (factory != null) {
        realm.write(() => list.addAll(factory()));
      }

      expectLater(
        list.changes.map((e) => getIndexes(e)),
        emitsInOrder([
          <int>[],
          ...listOfIndexes.map(
            (l) => l.sorted((a, b) => a - b),
          )
        ].map<Matcher>((indexes) => equals(indexes))),
      );

      for (final indexes in listOfIndexes) {
        realm.write(() {
          for (final i in indexes) {
            op(list, i);
          }
        });
        realm.refresh();
      }
    });
  }

  // Here you can add more insert patterns
  final inserts = [
    [0],
    [1],
    [1, 2, 3],
    [0, 4],
    [1, 2],
    [8, 10],
    [0],
    [11],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  ];

  @isTest
  void testListInsertNotifications<T>(
    RealmList<T> Function(AllCollections c) getList,
    void Function(RealmList<T> list, int index) op,
  ) {
    testListNotificationsHelper<T>('insert', getList, (ch) => ch.inserted, op, inserts);
  }

  testListInsertNotifications<bool?>((c) => c.nullableBoolList, (c, i) => c.insert(i, null));
  testListInsertNotifications<bool>((c) => c.boolList, (c, i) => c.insert(i, i % 2 == 0));
  testListInsertNotifications<DateTime?>((c) => c.nullableDateList, (c, i) => c.insert(i, null));
  testListInsertNotifications<DateTime>((c) => c.dateList, (c, i) => c.insert(i, DateTime(i)));
  testListInsertNotifications<double?>((c) => c.nullableDoubleList, (c, i) => c.insert(i, null));
  testListInsertNotifications<double>((c) => c.doubleList, (c, i) => c.insert(i, i.toDouble()));
  testListInsertNotifications<int?>((c) => c.nullableIntList, (c, i) => c.insert(i, null));
  testListInsertNotifications<int>((c) => c.intList, (c, i) => c.insert(i, i));
  testListInsertNotifications<ObjectId?>((c) => c.nullableObjectIdList, (c, i) => c.insert(i, null));
  testListInsertNotifications<ObjectId>((c) => c.objectIdList, (c, i) => c.insert(i, ObjectId()));
  testListInsertNotifications<String?>((c) => c.nullableStringList, (c, i) => c.insert(i, null));
  testListInsertNotifications<String>((c) => c.stringList, (c, i) => c.insert(i, '$i'));
  testListInsertNotifications<Uuid?>((c) => c.nullableUuidList, (c, i) => c.insert(i, null));
  testListInsertNotifications<Uuid>((c) => c.uuidList, (c, i) => c.insert(i, Uuid.v4()));

  final deletes = [
    [0],
    [1],
    [3, 2, 1],
    [4, 0],
    [2, 1],
    [10, 8],
    [0],
    [11],
    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
  ];

  @isTest
  void testListDeleteNotifications<T>(
    RealmList<T> Function(AllCollections c) getList,
    T Function(int i) indexToValue,
  ) {
    testListNotificationsHelper<T>('deleted', getList, (ch) => ch.deleted, (c, i) => c.removeAt(i), deletes,
        factory: () => List.generate(
              100,
              (i) => indexToValue(i),
            ));
  }

  testListDeleteNotifications<bool?>((c) => c.nullableBoolList, (i) => null);
  testListDeleteNotifications<bool>((c) => c.boolList, (i) => i % 2 == 0);
  testListDeleteNotifications<DateTime?>((c) => c.nullableDateList, (i) => null);
  testListDeleteNotifications<DateTime>((c) => c.dateList, (i) => DateTime(i));
  testListDeleteNotifications<double?>((c) => c.nullableDoubleList, (i) => null);
  testListDeleteNotifications<double>((c) => c.doubleList, (i) => i.toDouble());
  testListDeleteNotifications<int?>((c) => c.nullableIntList, (i) => null);
  testListDeleteNotifications<int>((c) => c.intList, (i) => i);
  testListDeleteNotifications<ObjectId?>((c) => c.nullableObjectIdList, (i) => null);
  testListDeleteNotifications<ObjectId>((c) => c.objectIdList, (i) => ObjectId());
  testListDeleteNotifications<String?>((c) => c.nullableStringList, (i) => null);
  testListDeleteNotifications<String>((c) => c.stringList, (i) => '$i');
  testListDeleteNotifications<Uuid?>((c) => c.nullableUuidList, (i) => null);
  testListDeleteNotifications<Uuid>((c) => c.uuidList, (i) => Uuid.v4());

  final modifications = [
    [0],
    [1],
    [2, 1, 3],
    [4, 0],
    [1, 2],
    [10, 8],
    [0],
    [11],
    [10, 7, 8, 9, 3, 2, 6, 5, 1, 0, 4]
  ];

  @isTest
  void testListModificationNotifications<T>(
    RealmList<T> Function(AllCollections c) getList,
    T Function(int i) indexToValue,
  ) {
    testListNotificationsHelper<T>('modified', getList, (ch) => ch.modified, (c, i) => c[i] = indexToValue(i), modifications,
        factory: () => List.generate(
              100,
              (i) => indexToValue(i),
            ));
  }

  testListModificationNotifications<bool?>((c) => c.nullableBoolList, (i) => null);
  testListModificationNotifications<bool>((c) => c.boolList, (i) => i % 2 == 0);
  testListModificationNotifications<DateTime?>((c) => c.nullableDateList, (i) => null);
  testListModificationNotifications<DateTime>((c) => c.dateList, (i) => DateTime(i));
  testListModificationNotifications<double?>((c) => c.nullableDoubleList, (i) => null);
  testListModificationNotifications<double>((c) => c.doubleList, (i) => i.toDouble());
  testListModificationNotifications<int?>((c) => c.nullableIntList, (i) => null);
  testListModificationNotifications<int>((c) => c.intList, (i) => i);
  testListModificationNotifications<ObjectId?>((c) => c.nullableObjectIdList, (i) => null);
  testListModificationNotifications<ObjectId>((c) => c.objectIdList, (i) => ObjectId());
  testListModificationNotifications<String?>((c) => c.nullableStringList, (i) => null);
  testListDeleteNotifications<String>((c) => c.stringList, (i) => '$i');
  testListDeleteNotifications<Uuid?>((c) => c.nullableUuidList, (i) => null);
  testListDeleteNotifications<Uuid>((c) => c.uuidList, (i) => Uuid.v4());

  test('List query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final person = Person('John');
    final team = Team('team1', players: [
      Person('Pavel'),
      person,
      Person('Alex'),
    ]);

    realm.write(() => realm.add(team));

    final result = team.players.query(r'name BEGINSWITH $0', ['J']);
    expect(result, [person]);
  });

  test('List.freeze freezes the list', () {
    final config = Configuration.local([Person.schema, Team.schema]);
    final realm = getRealm(config);

    final livePlayers = realm.write(() {
      return realm.add(Team('team', players: [Person('Peter')], scores: [123]));
    }).players;

    final frozenPlayers = freezeList(livePlayers);

    expect(frozenPlayers.length, 1);
    expect(frozenPlayers.isFrozen, true);
    expect(frozenPlayers.realm.isFrozen, true);
    expect(frozenPlayers.single.isFrozen, true);

    realm.write(() {
      livePlayers.single.name = 'Peter II';
      livePlayers.add(Person('George'));
    });

    expect(livePlayers.length, 2);
    expect(livePlayers.first.name, 'Peter II');
    expect(frozenPlayers.length, 1);
    expect(frozenPlayers.single.name, 'Peter');
  });

  test("FrozenList.changes throws", () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(Team('team'));
    });

    final frozenPlayers = freezeList(realm.all<Team>().single.players);

    expect(() => frozenPlayers.changes, throws<RealmStateError>('List is frozen and cannot emit changes'));
  });

  test('UnmanagedList.freeze throws', () {
    final team = Team('team');

    expect(() => freezeList(team.players), throws<RealmStateError>("Unmanaged lists can't be frozen"));
  });

  test('UnmanagedList.changes throws', () {
    final team = Team('team');

    expect(() => team.players.changes, throws<RealmStateError>("Unmanaged lists don't support changes"));
    expect(() => team.players.changesFor(["test"]), throws<RealmStateError>("Unmanaged lists don't support changes"));
  });

  test('List.changesFor throws of collection of non-objects', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);
    final intList = realm.write(() {
      return realm.add(Team("s"));
    }).scores;

    expect(() => intList.changesFor(["test"]), throws<RealmStateError>("Key paths can be used only with collections of Realm objects"));
  });

  test('RealmList.changesFor works with keypaths', () async {
    var config = Configuration.local([School.schema, Student.schema]);
    var realm = getRealm(config);

    final students = realm.write(() {
      return realm.add(School("Liceo Pizzi"));
    }).students;

    final externalChanges = <RealmListChanges<Student?>>[];
    final subscription = students.changesFor(["yearOfBirth"]).listen((changes) {
      externalChanges.add(changes);
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(externalChanges.length, 1);

    final firstNotification = externalChanges[0];
    expect(firstNotification.inserted.isEmpty, true);
    expect(firstNotification.deleted.isEmpty, true);
    expect(firstNotification.modified.isEmpty, true);
    expect(firstNotification.isCleared, false);
    externalChanges.clear();

    final student = Student(222);
    realm.write(() {
      students.add(student);
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(externalChanges.length, 1);

    var notification = externalChanges[0];
    expect(notification.inserted, [0]);
    expect(notification.deleted.isEmpty, true);
    expect(notification.modified.isEmpty, true);
    expect(notification.isCleared, false);
    externalChanges.clear();

    // We expect notifications because "yearOfBirth" is in the keypaths
    realm.write(() {
      student.yearOfBirth = 1999;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(externalChanges.length, 1);

    notification = externalChanges[0];
    expect(notification.inserted.isEmpty, true);
    expect(notification.deleted.isEmpty, true);
    expect(notification.modified, [0]);
    expect(notification.isCleared, false);
    externalChanges.clear();

    // We don't expect notifications because "name" is not in the keypaths
    realm.write(() {
      student.name = "Luis";
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(externalChanges.length, 0);

    subscription.cancel();

    // No more notifications after cancelling subscription
    realm.write(() {
      student.yearOfBirth = 1299;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(externalChanges.length, 0);
  });

  test('List.freeze when frozen returns same object', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = realm.write(() => realm.add(Team('Barcelona', players: [Person('Peter')])));

    final frozenPlayers = freezeList(team.players);
    final deepFrozenPlayers = freezeList(frozenPlayers);

    expect(identical(frozenPlayers, deepFrozenPlayers), true);

    final frozenPlayersAgain = freezeList(team.players);
    expect(identical(frozenPlayers, frozenPlayersAgain), false);
  });

  test('ManagedRealmList.removeAt', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    expect(realm.write(() => team.players.removeAt(2)), carol);
    expect(team.players.length, 3);
    expect(team.players, [alice, bob, dan]);

    expect(realm.write(() => team.players.removeAt(0)), alice);
    expect(team.players.length, 2);
    expect(team.players, [bob, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.length set', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.length = 2);
    expect(team.players.length, 2);
    expect(team.players, [alice, bob]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.contains', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));

    for (var p in players) {
      expect(team.players.contains(p), isTrue);
    }

    realm.write(() => team.players.clear());

    for (var p in players) {
      expect(team.players.contains(p), isFalse);
    }
  });

  test('ManagedRealmList.removeRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeRange(1, 3)); // removes [1; 3)
    expect(team.players.length, 2);
    expect(team.players, [alice, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.removeWhere', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeWhere((p) => p.name.contains('a')));
    expect(team.players.length, 2);
    expect(team.players, [alice, bob]); // Alice is capital 'a'

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.retainWhere', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.retainWhere((p) => p.name.contains('a')));
    expect(team.players.length, 2);
    expect(team.players, [carol, dan]); // Alice is capital 'a', so not included

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.removeLast', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeLast());
    expect(team.players.length, 3);
    expect(team.players, [alice, bob, carol]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.replaceRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.replaceRange(1, 3, [dan, alice]));
    expect(team.players, [alice, dan, alice, dan]);

    realm.write(() => team.players.replaceRange(0, 3, [bob, carol]));
    expect(team.players, [bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.setAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.setAll(1, [dan, alice]));
    expect(team.players, [alice, dan, alice, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.fillRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.fillRange(1, 3, dan));
    expect(team.players, [alice, dan, dan, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.insert', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.insert(1, dan));
    expect(team.players, [alice, dan, bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('UnmanagedRealmList<RealmObject> deleteMany', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('Class of 92');
    final unmanagedRealmList = team.players;

    realm.write(() => realm.add(team));

    realm.write(() => realm.addAll([Person('Alice'), Person('Bob'), Person('Carol'), Person('Dan')]));
    var players = realm.all<Person>();
    unmanagedRealmList.addAll(players);

    realm.write(() => realm.deleteMany(unmanagedRealmList));
    expect(unmanagedRealmList.length, 4);

    players = realm.all<Person>();
    expect(players.length, 0);
  });

  test('ManagedRealmList.insertAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.insertAll(1, [dan, bob]));
    expect(team.players, [alice, dan, bob, bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.remove', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, dan, bob, carol, dan]; // extra dan after alice!
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 5);
    expect(team.players, players);

    expect(realm.write(() => team.players.remove(dan)), isTrue); // only removes first instance
    expect(team.players, [alice, bob, carol, dan]);

    expect(realm.write(() => team.players.remove(dan)), isTrue);
    expect(team.players, [alice, bob, carol]);

    expect(realm.write(() => team.players.remove(dan)), isFalse);

    expect(team.players.every((p) => p.isValid && p.isManaged), isTrue);

    expect(
      () => (team.players as List<Object>).indexOf("wrong type"), // ignore: unnecessary_cast
      throwsA(isA<TypeError>()),
    );

    expect(
      () => team.players.remove(Person('alice')),
      throws<RealmStateError>('Cannot call remove on a managed list with an element that is an unmanaged object'),
    );
  });

  test('ManagedRealmList.setRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.setRange(1, 3, [dan, dan, dan, bob, carol], 2));
    expect(team.players, [alice, dan, bob, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.insertAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    final r = Random(42);
    realm.write(() => team.players.shuffle(r));
    expect(team.players, isNot(players));
    expect(team.players, unorderedMatches(players));
  });

  test('ManagedRealmList.length= throws on increase', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team');

    realm.write(() => realm.add(team));

    expect(() => realm.write(() => team.players.length = 100), throws<RealmException>('You cannot increase length on a realm list without adding elements'));
  });

  test('ManagedRealmList.length= truncates on decrease', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team', players: [for (int i = 0; i < 100; ++i) Person('$i')]);
    realm.write(() => realm.add(team));
    expect(team.players.length, 100);
    expect(realm.all<Person>().length, 100);

    expect(realm.write(() => team.players.length = 10), 10);
    expect(team.players.length, 10);
    expect(realm.all<Person>().length, 100);
  });

  test('List.query when other objects exists', () {
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
    expect(team.players.query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(team.players.query('TRUEPREDICATE'), [alice, bob]);
  });

  test('ManagedRealmList.indexOf', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team', players: [for (int i = 0; i < 100; ++i) Person('$i')]);
    realm.write(() => realm.add(team));
    final players = team.players;

    expect(players, isA<RealmList<Person>>());
    expect(players.isManaged, isTrue);
    expect(players.indexOf(players.first, -1), 0); // okay to start from negative index
    expect(players.indexOf(players.first, 1), -1); // start respected
    expect(players.indexOf(players.first, 101), -1); // okay to start from non-existent index

    var index = 0;
    final r = Random(42); // deterministic
    for (final p in players) {
      expect(players.indexOf(p, r.nextInt(index + 1) - 1), index++);
    }

    // List.indexOf with wrong type of element, just returns -1.
    // Proof:
    final dartList = <int>[1, 2, 3];
    expect((dartList as List<Object>).indexOf("abc"), -1); // ignore: unnecessary_cast

    // .. but realm list behaves differently in this regard.
    expect(() => (players as List<Object>).indexOf(1), throwsA(isA<TypeError>())); // ignore: unnecessary_cast

    // .. Also it is a state error to lookup an unmanaged object in a managed list,
    // even if the static type is right.
    expect(
      () => players.indexOf(Person('10')),
      throwsA(isA<RealmStateError>().having(
        (e) => e.message,
        'message',
        'Cannot call indexOf on a managed list with an element that is an unmanaged object',
      )),
    );
  });

  test('List of nullables', () {
    final config = Configuration.local([Player.schema, Game.schema]);
    final realm = getRealm(config);

    final game = Game();
    final alice = Player('alice', game: game);
    final bob = Player('bob', game: game);
    final carol = Player('carol', game: game);
    final players = [alice, bob, carol];

    realm.write(() => realm.addAll(players));

    void checkResult(List<Player> winnerByRound, Map<Player, List<int?>> scoresByPlayer) {
      expect(game.winnerByRound, winnerByRound);
      for (final p in players) {
        expect(p.scoresByRound, scoresByPlayer[p] ?? []);
      }
    }

    checkResult([], {});

    int currentRound = 0;
    void playRound(Map<Player, int> scores) {
      realm.write(() {
        for (final p in players) {
          p.scoresByRound.add(scores[p]);
        }
        final bestResult =
            scores.entries.fold<MapEntry<Player, int>?>(null, (bestResult, result) => result.value > (bestResult?.value ?? 0) ? result : bestResult);
        game.winnerByRound[currentRound++] = bestResult!.key;
      });
    }

    playRound({alice: 1, bob: 2});

    checkResult([
      bob
    ], {
      alice: [1],
      bob: [2],
      carol: [null]
    });

    playRound({alice: 3, carol: 1});

    checkResult([
      bob,
      alice
    ], {
      alice: [1, 3],
      bob: [2, null],
      carol: [null, 1]
    });

    playRound({alice: 2, bob: 3, carol: 1});

    checkResult([
      bob,
      alice,
      bob
    ], {
      alice: [1, 3, 2],
      bob: [2, null, 3],
      carol: [null, 1, 1]
    });
  });

  test('RealmList<T> is a RealmList<T?> (covariance)', () {
    // List<T> in dart is covariant. So is RealmList<T>.
    // In particular (since a T is also a T?) a RealmList<T> is also a RealmList<T?>.
    // Here follows a few tests to prove it, as it came up in a PR review
    final list = RealmList([1, 2, 3]);
    expect(list, isA<RealmList<int>>());
    expect(list, isA<RealmList<int?>>());

    final nullableList = RealmList<int?>([1, 2, 3]);
    expect(nullableList, isNot(isA<RealmList<int>>()));
    expect(nullableList, isA<RealmList<int?>>());

    // .. also when managed
    final config = Configuration.local([Player.schema, Game.schema]);
    final realm = getRealm(config);

    final game = Game();
    realm.write(() => realm.add(game));

    expect(game.winnerByRound.isManaged, isTrue);

    expect(game.winnerByRound, isA<RealmList<Player>>());
    expect(game.winnerByRound, isA<RealmList<Player?>>());
  });

  test('Move equality & hash', () {
    expect(Move(1, 1), equals(Move(1, 1)));
    expect(Move(1, 1), isNot(equals(Move(2, 2))));
    expect(Move(1, 1).hashCode, equals(Move(1, 1).hashCode));
    expect(Move(1, 1).hashCode, isNot(equals(Move(2, 2).hashCode)));
  });

  test('List.move', () {
    final list = [0, 1, 2, 3];
    list.move(1, 0);
    expect(list, [1, 0, 2, 3]);
    list.move(2, 3);
    expect(list, [1, 0, 3, 2]);
    list.move(0, 0); // no-op
    expect(list, [1, 0, 3, 2]);
    final length = list.length;
    expect(() => list.move(-1, 0), throwsRangeError);
    expect(() => list.move(0, -1), throwsRangeError);
    expect(() => list.move(length, 0), throwsRangeError);
    expect(() => list.move(0, length), throwsRangeError);
  });

  test('ManagedRealmList.move', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.move(1, 0));
    expect(team.players, [bob, alice, carol, dan]);

    realm.write(() => team.players.move(2, 3));
    expect(team.players, [bob, alice, dan, carol]);

    realm.write(() => team.players.move(0, 0)); // no-op
    expect(team.players, [bob, alice, dan, carol]);

    final length = team.players.length;
    expect(() => realm.write(() => team.players.move(-1, 0)), throwsRangeError);
    expect(() => realm.write(() => team.players.move(0, -1)), throwsRangeError);
    expect(() => realm.write(() => team.players.move(length, 0)), throwsRangeError);
    expect(() => realm.write(() => team.players.move(0, length)), throwsRangeError);

    expect(realm.all<Person>(), unorderedEquals(players)); // nothing was added or disappeared from the realm

    // .. when outside a write transaction
    expect(() => team.players.move(3, 1), throws<RealmException>('Cannot modify managed List outside of a write transaction'));
    expect(() => realm.write(() => team.players.move(0, length)), throwsRangeError); // range error takes precedence
  });

  test('ManagedRealmList.move notifications', () async {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));

    expectLater(
        team.players.changes,
        emitsInOrder(<Matcher>[
          isA<RealmListChanges<Person>>().having((ch) => ch.inserted, 'inserted', <int>[]), // always an empty event on subscription
          isA<RealmListChanges<Person>>().having((ch) => ch.moved, 'moved', [Move(1, 0)]),
          // no Move(0, 0)
          isA<RealmListChanges<Person>>().having((ch) => ch.moved, 'moved', [Move(2, 3)]),
        ]));

    realm.write(() => team.players.move(1, 0));
    expect(team.players, [bob, alice, carol, dan]);

    realm.write(() => team.players.move(0, 0)); // no-op

    realm.write(() => team.players.move(2, 3));
    expect(team.players, [bob, alice, dan, carol]);
  });

  test('RealmList.isCleared notifications', () async {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);
    final team = Team('Team 1', players: [Person('Alice'), Person('Bob')]);
    realm.write(() => realm.add(team));

    expectLater(
        team.players.changes,
        emitsInOrder(<Matcher>[
          isA<RealmListChanges<Person>>()
              .having((changes) => changes.inserted, 'inserted', <int>[])
              .having((changes) => changes.isCleared, 'isCleared', false)
              .having((changes) => changes.isCollectionDeleted, 'isCollectionDeleted', false), // always an empty event on subscription
          isA<RealmListChanges<Person>>()
              .having((changes) => changes.isCleared, 'isCleared', true)
              .having((changes) => changes.isCollectionDeleted, 'isCollectionDeleted', false),
          isA<RealmListChanges<Person>>()
              .having((changes) => changes.isCleared, 'isCleared', false)
              .having((changes) => changes.isCollectionDeleted, 'isCollectionDeleted', true),
        ]));
    realm.write(() => team.players.clear());
    realm.refresh();
    realm.write(() => realm.delete(team));
  });

  test('RealmList.changes - await for with yield', () async {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);
    final team = Team('Team 1', players: [Person('Alice'), Person('Bob')]);
    realm.write(() => realm.add(team));

    final wait = const Duration(seconds: 1);

    Stream<bool> trueWaitFalse() async* {
      yield true;
      await Future<void>.delayed(wait);
      yield false; // nothing has happened in the meantime
    }

    // ignore: prefer_function_declarations_over_variables
    final awaitForWithYield = () async* {
      await for (final c in team.players.changes) {
        yield c;
      }
    };

    int count = 0;
    await for (final c in awaitForWithYield().map((_) => trueWaitFalse()).switchLatest()) {
      if (!c) break; // saw false after waiting
      ++count; // saw true due to new event from changes
      if (count > 1) fail('Should only receive one event');
    }
  });

  test('List.asResults().isCleared notifications', () async {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);
    final team = Team('Team 1', players: [Person('Alice'), Person('Bob')]);
    realm.write(() => realm.add(team));
    final playersAsResults = team.players.asResults();
    expectLater(
        playersAsResults.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges<Person>>().having((changes) => changes.inserted, 'inserted', <int>[]), // always an empty event on subscription
          isA<RealmResultsChanges<Person>>().having((changes) => changes.results.isEmpty, 'isCleared', true),
        ]));
    realm.write(() => team.players.clear());
    expect(playersAsResults.length, 0);
    realm.refresh();
  });

  test('Query on RealmList with IN-operator', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = realm.write(() => realm.add(Team('team', players: [
          Person('Paul'),
          Person('John'),
          Person('Alex'),
        ])));

    final result = team.players.query(r'name IN $0', [
      ['Paul', 'Alex']
    ]);
    expect(result.length, 2);
  });

  test('Query on RealmList allows null in arguments', () {
    final config = Configuration.local([School.schema, Student.schema]);
    final realm = getRealm(config);

    final school = realm.write(() => realm.add(School('primary school 1', branches: [
          School('131', city: "NY city"),
          School('144'),
          School('128'),
        ])));

    final result = school.branches.query(r'city = $0', [null]);
    expect(result.length, 2);
  });
}
