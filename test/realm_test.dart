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

import 'dart:io';
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

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
  if (arguments.length != 0) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      print("testName: ${testName}");
      testName = arguments[nameArgIndex + 1];
    }
  }
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message',  contains(message ?? '')));

void main([List<String>? args]) {
  parseTestNameFromArguments(args);

  print("Current PID ${pid}");

  initRealm();

  setUp(() async {
    // Do not clear state on Flutter. Test app is reinstalled on every test run so the state is clear.
    if (!isFlutterPlatform) {
      var currentDir = Directory.current;
      var files = await currentDir.list().toList();
      for (var file in files) {
        if (file is! File || (!file.path.endsWith(".realm"))) {
          continue;
        }

        try {
          await file.delete();
        } catch(e) {
          //wait for Realm.close of a previous test and retry the delete before failing
          await Future<void>.delayed(Duration(milliseconds: 120));
          await file.delete();
        }

        var lockFile = File("${file.path}.lock");
        await lockFile.delete();
      }
    }
  });

  group('Configuration tests:', () {
    test('Configuration can be created', () {
      Configuration([Car.schema]);
    });

    test('Configuration exception if no schema', () {
      expect(() => Configuration([]), throws<RealmException>());
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

    test('Configuration open with schema subset object', () {
      var config = Configuration([Car.schema, Person.schema]);
      var realm = Realm(config);

      var config1 = Configuration([Car.schema]);
      var realm1 = Realm(config1);
    }, skip: "Needs investigation");

    test('Configuration open with schema superset object', () {
      var config = Configuration([Person.schema]);
      var realm = Realm(config);
      realm.close();

      config = Configuration([Person.schema]);
      realm = Realm(config);


      var config1 = Configuration([Person.schema, Car.schema]);
      var realm1 = Realm(config1);

      print("config: ${config.schemaVersion}");
      print("config1: ${config1.schemaVersion}");
    }, skip: "Needs investigation");
  });

  group('RealmClass tests:', () {
    test('Realm can be created', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
    });

     test('Realm can be closed', () async {
      var config = Configuration([Car.schema]);
      Realm? realm = Realm(config);
      realm.close();
      realm = null;
      await Future<void>.delayed(Duration(milliseconds: 50));
      realm = Realm(config);
      realm.close();
    });

    test('Realm add object', () {
      var config = Configuration([Car.schema]);
      var realm = Realm(config);
      final car = Car();
      expect(() => realm.add(car), throws<RealmException>("Wrong transactional state"));
    });
  });
}
