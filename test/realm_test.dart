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

import 'dart:async';
import 'dart:io';

import '../lib/realm.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

part 'realm_test.g.dart';

class _Car {
  @RealmProperty()
  late String make;

  @RealmProperty()
  late String model;
  
  @RealmProperty(defaultValue: "500", optional: true)
  late int kilometers;
}

class _Person {
  @RealmProperty()
  late String name;

  @RealmProperty()
  late int age;

  @RealmProperty()
  late List<_Car> cars;
}

class _ServicedCar {
  @RealmProperty(primaryKey: true)
  late int id;

  @RealmProperty()
  late _Car car;
}

String? testName;

/**
 * Overrides other tests
 */
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
    if (!isFlutterPlatform) {

      //Dart: this will clear everything else but deleting the file
      Realm.clearTestState();
    
      var currentDir = Directory.current;
      var files = currentDir.listSync();
      for (var file in files) {
        if (file is! File || (!file.path.endsWith(".realm"))) {
          continue;
        }

        file.deleteSync();

        var lockFile = File("${file.path}.lock");
        lockFile.deleteSync();
      }
    }
  });

  group('RealmClass tests', () {
    test('Realm version', () {
      expect(Realm.version, contains('11.'));
    });
  });
}
