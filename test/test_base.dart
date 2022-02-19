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
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

String? testName;

//Overrides test method so we can filter tests
@isTest
void test(String? name, dynamic Function() testFunction, {dynamic skip}) {
  if (testName != null && !name!.contains(testName!)) {
    return;
  }

  var timeout = 30;
  assert(() {
    timeout = Duration.secondsPerDay;
    return true;
  }());

  testing.test(name, testFunction, skip: skip);
}

void xtest(String? name, dynamic Function() testFunction) {
  testing.test(name, testFunction, skip: "Test is disabled");
}

void parseTestNameFromArguments(List<String>? arguments) {
  arguments = arguments ?? List.empty();
  int nameArgIndex = arguments.indexOf("--name");
  if (arguments.isNotEmpty) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      testName = arguments[nameArgIndex + 1];
      print("testName: $testName");
    }
  }
}

void setupTests(String filePath, void Function(String path) setDefaultPath) {
  setUp(() {
    String path = "${generateRandomString(10)}.realm";
    if (Platform.isAndroid || Platform.isIOS) {
      path = _path.join(filePath, path);
    }
    setDefaultPath(path);

    addTearDown(() async {
      var file = File(path);
      if (await file.exists() && file.path.endsWith(".realm")) {
        await tryDeleteFile(file);
      }

      file = File("$path.lock");
      if (await file.exists()) {
        await tryDeleteFile(file);
      }

      final dir = Directory("$path.management");
      if (await dir.exists()) {
        if ((await dir.stat()).type == FileSystemEntityType.directory) {
          await tryDeleteFile(dir, recursive: true);
        }
      }
    });
  });
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message', contains(message ?? '')));

final random = Random();
String generateRandomString(int len) {
  const _chars = 'abcdefghjklmnopqrstuvwxuz';
  return List.generate(len, (index) => _chars[random.nextInt(_chars.length)]).join();
}

Future<void> tryDeleteFile(FileSystemEntity fileEntity, {bool recursive = false}) async {
  for (var i = 0; i < 20; i++) {
    try {
      await fileEntity.delete(recursive: recursive);
      break;
    } catch (e) {
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
  }
}
