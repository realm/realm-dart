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


  group('RealmClass tests:', () {
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

  });
}
