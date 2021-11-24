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
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

// ignore: avoid_relative_lib_imports
import '../lib/realm.dart';

part 'realm_test.gen.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make = "Tesla";
}

@RealmModel()
class _Person {
  late String name;
}

String? testName;

//Overrides test method so we can filter tests
void test(String? name, dynamic Function() testFunction, {dynamic skip}) {
  if (testName != null && !name!.contains(testName!)) {
    return;
  }

  testing.test(name, testFunction, skip: skip);
}

void parseTestNameFromArguments(List<String>? arguments) {
  arguments = arguments ?? List.empty();
  int nameArgIndex = arguments.indexOf("--name");
  if (arguments.isNotEmpty) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      print("testName: $testName");
      testName = arguments[nameArgIndex + 1];
    }
  }
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message', contains(message ?? '')));
Matcher notThrows<T>([String? message]) => isNot(throws<T>(message));

void main([List<String>? args]) {
  parseTestNameFromArguments(args);

  print("Current PID $pid");

  setUp(() async {
    var currentDir = Directory.current;
    if (Platform.isAndroid || Platform.isIOS) {
      currentDir = Directory(Configuration.filesPath);
    }

    var files = await currentDir.list().toList();
    for (var file in files) {
      if (file is! File || (!file.path.endsWith(".realm"))) {
        continue;
      }

      for (var i = 0; i <= 20; i++) {
        try {
          await file.delete();
        } catch (e) {
          //wait for Realm.close of a previous test and retry the delete before failing
          await Future<void>.delayed(Duration(milliseconds: 10));
        }
      }

      var lockFile = File("${file.path}.lock");
      await lockFile.delete();
    }
  });

  group('Configuration tests:', () {
    test('Configuration can be created', () {
      Configuration([Car.schema]);
    });

    test('Configuration exception if no schema', () {
      expect(() => Configuration([]), throws<RealmException>());
    });

    test('Configuration default path', () {
      if (Platform.isAndroid || Platform.isIOS) {
        expect(Configuration.defaultPath, endsWith("default.realm"));
        expect(Configuration.defaultPath, startsWith("/"), reason: "on Android and iOS the default path should contain the path to the user data directory");
      } else {
        expect(Configuration.defaultPath, equals("default.realm"));
      }
    });

    test('Configuration files path', () {
      if (Platform.isAndroid || Platform.isIOS) {
        expect(Configuration.filesPath, isNot(endsWith("default.realm")), reason: "on Android and iOS the files path should be a directory");
        expect(Configuration.filesPath, startsWith("/"), reason: "on Android and iOS the files path should be a directory");
      } else {
        expect(Configuration.filesPath, equals(""), reason: "on Dart standalone the files path should be an empty string");
      }
    });

    test('Configuration get/set path', () {
      Configuration config = Configuration([Car.schema]);
      expect(config.path, contains('default.realm'));

      const path = "my/path/default.realm";
      config.path = path;
      expect(config.path, equals(path));
    });

    test('Configuration get/set schema version', () {
      Configuration config = Configuration([Car.schema]);
      expect(config.schemaVersion, equals(0));

      config.schemaVersion = 3;
      expect(config.schemaVersion, equals(3));
    });
  });

  group('RealmClass tests:', () {
    test('Realm can be created', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
    });

    test('Realm can be closed', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      realm.close();

      realm = Realm(config);
      expect(() => realm.close(), notThrows<Exception>());

      expect(() => realm.close(), notThrows<Exception>(), reason: "Calling close() twice should not throw exceptions");
    });

    test('Realm can be closed and opened again', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      realm.close();
      expect(() => realm = Realm(config), notThrows<Exception>());
    });

    test('Realm open with schema subset', () {
      var config = Configuration([Car.schema, Person.schema]);
      var realm = Realm(config);
      realm.close();

      config = Configuration([Car.schema]);
      realm = Realm(config);
    });

    test('Realm open with schema superset', () {
      var config = Configuration([Person.schema]);
      var realm = Realm(config);
      realm.close();

      var config1 = Configuration([Person.schema, Car.schema]);
      var realm1 = Realm(config1);
    });

    test('Realm open twice with same schema', () async {
      var config = Configuration([Person.schema, Car.schema]);
      var realm = Realm(config);

      var config1 = Configuration([Person.schema, Car.schema]);
      var realm1 = Realm(config1);
    });

    test('Realm add throws when no write transaction', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      final car = Car();
      expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
    });

    test('Realm add object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() {
        realm.write(() => realm.add(Car()));
      }, notThrows<RealmException>(), reason: "Adding objects should not throw");
    });

    test('Realm add() returns the same object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      final car = Car();
      Car? addedCar;
      realm.write(() {
        addedCar = realm.add(car);
      });

      expect(addedCar == car, isTrue);
    });

    test('Realm add object transaction rollbacks on exception', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);

      expect(() {
        realm.write(() {
          realm.add(Car());
          throw Exception("some exception while adding objects");
        });
      }, allOf(throws<Exception>("some exception while adding objects"))); //TODO: validate the object does not exists in the database
    }, skip: "//TODO: validate the object does not exists in the database");
  });
}
