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
  late String make;
}

@RealmModel()
class _Person {
  late String name;
}

String? testName;

//Overrides test method so we can filter it
void test(String? name, dynamic Function() testFunction) {
  if (testName != null && !name!.contains(testName!)) {
    return;
  }

  testing.test(name, testFunction);
}

void parseTestNameFromArguments(List<String>? arguments) {
  arguments = arguments ?? List.empty();
  int nameArgIndex = arguments.indexOf("--name");
  if (arguments.length != 0) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      testName = arguments[nameArgIndex + 1];
      print("testName: ${testName}");
    }
  }
}

void main([List<String>? args]) {
  parseTestNameFromArguments(args);

  print("Current PID ${pid}");

  initRealm();

  setUp(() {
    // Do not clear state on Flutter. Test app is reinstalled on every test run so the state is clear.
    if (!IsFlutterPlatform) {
      var currentDir = Directory.current;
      var files = currentDir.listSync();
      for (var file in files) {
        if (!(file is File) || (!file.path.endsWith(".realm"))) {
          continue;
        }

        file.deleteSync();

        var lockFile = new File("${file.path}.lock");
        lockFile.deleteSync();
      }
    }
  });

  group('Configuration tests:', () {
    test('Configuration can be created', () async {
      Configuration([Car.schema]);
    });

    test('Configuration get/set path', () async {
      Configuration config = Configuration([Car.schema]);
      expect(config.path, equals('default.realm'));

      const path = "my/path/default.realm";
      config.path = path;
      expect(config.path, equals(path));
    });

    test('Configuration get/set schema version', () async {
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
  });
}
