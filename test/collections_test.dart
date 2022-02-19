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

    await Future<void>.delayed(Duration(milliseconds: 10));
    realm.write(() {
      realm.all<Dog>().first.age = 2;
      realm.add(Dog("Fido4"));
    });

    await Future<void>.delayed(Duration(milliseconds: 10));
    subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 10));
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

    await Future<void>.delayed(Duration(milliseconds: 10));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });

    expect(callbackCalled, false);

    await Future<void>.delayed(Duration(milliseconds: 10));
    await subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 10));
    realm.close();
  });

  test('Results notifications can be resumed', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    var callbackCalled = false;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      callbackCalled = true;
    });

    await Future<void>.delayed(Duration(milliseconds: 10));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy"));
    });
    await Future<void>.delayed(Duration(milliseconds: 10));
    expect(callbackCalled, false);

    subscription.resume();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });
    await Future<void>.delayed(Duration(milliseconds: 10));
    expect(callbackCalled, true);

    await subscription.cancel();
    await Future<void>.delayed(Duration(milliseconds: 10));
    realm.close();
  });

  test('Results notifications can leak', () async {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

    final leak = realm.all<Dog>().changes.listen((data) {});
    await Future<void>.delayed(Duration(milliseconds: 1));
    realm.close();
  });

  test('List notifications', () async {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final team = Team('t1', players: [Person("p1")]);
    realm.write(() => realm.add(team));

    var firstCall = true;
    final subscription = (team.players as RealmList<Person>).changes.listen((changes) {
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

    await Future<void>.delayed(Duration(milliseconds: 10));
    realm.write(() {
      team.players.add(Person("p2"));
      team.players.first.name = "p3";
    });

    await Future<void>.delayed(Duration(milliseconds: 10));
    subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 10));
    realm.close();
  });
}
