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

import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart' hide test;
import 'package:test/test.dart' as testing;
import '../lib/realm.dart';
import '../lib/src/cli/deployapps/baas_client.dart';

part 'test.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
}

@RealmModel()
class _Person {
  late String name;
}

@RealmModel()
class _Dog {
  @PrimaryKey()
  late String name;

  late int? age;

  _Person? owner;
}

@RealmModel()
class _Team {
  late String name;
  late List<_Person> players;
  late List<int> scores;
}

@RealmModel()
class _Student {
  @PrimaryKey()
  late int number;
  late String? name;
  late int? yearOfBirth;
  late _School? school;
}

@RealmModel()
class _School {
  @PrimaryKey()
  late String name;
  late String? city;
  List<_Student> students = [];
  late _School? branchOfSchool;
  late List<_School> branches;
}

String? testName;
Map<String, BaasApp> baasApps = <String, BaasApp>{};

final _openRealms = Queue<Realm>();

//Overrides test method so we can filter tests
void test(String? name, dynamic Function() testFunction, {dynamic skip}) {
  if (testName != null && !name!.contains(testName!)) {
    return;
  }

  var timeout = 30;
  assert(() {
    timeout = Duration.secondsPerDay;
    return true;
  }());

  testing.test(name, testFunction, skip: skip, timeout: Timeout(Duration(seconds: timeout)));
}

void xtest(String? name, dynamic Function() testFunction) {
  testing.test(name, testFunction, skip: "Test is disabled");
}

Future<void> setupTests(List<String>? args) async {
  parseTestNameFromArguments(args);

  await setupBaas();

  setUp(() {
    final path = generateRandomRealmPath();
    Configuration.defaultPath = path;

    addTearDown(() async {
      final paths = HashSet<String>();
      paths.add(path);

      while (_openRealms.isNotEmpty) {
        final realm = _openRealms.removeFirst();
        paths.add(realm.config.path);
        realm.close();
      }

      for (final path in paths) {
        var file = File(path);
        try {
          Realm.deleteRealm(path);
        } catch (e) {
          fail("Can not delete realm at path: $path. Did you forget to close it?");
        }

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
      }
    });
  });
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message', contains(message ?? '')));

String generateRandomRealmPath() {
  var path = "${generateRandomString(10)}.realm";
  if (Platform.isAndroid || Platform.isIOS) {
    path = _path.join(Configuration.filesPath, path);
  } else {
    path = _path.join(Directory.systemTemp.createTempSync("rt_").path, path);
  }

  return path;
}

final random = Random();
String generateRandomString(int len) {
  const _chars = 'abcdefghjklmnopqrstuvwxuz';
  return List.generate(len, (index) => _chars[random.nextInt(_chars.length)]).join();
}

Realm getRealm(Configuration config) {
  final realm = Realm(config);
  _openRealms.add(realm);
  return realm;
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

void parseTestNameFromArguments(List<String>? arguments) {
  if (testName != null || arguments == null || arguments.isEmpty) {
    return;
  }

  int nameArgIndex = arguments.indexOf("--name");
  if (nameArgIndex >= 0 && arguments.length > nameArgIndex) {
    testName = arguments[nameArgIndex + 1];
  }
}

Future<void> setupBaas() async {
  final baasUrl = Platform.environment['BAAS_URL'];
  if (baasUrl == null) {
    return;
  }

  final cluster = Platform.environment['BAAS_CLUSTER'];
  final apiKey = Platform.environment['BAAS_API_KEY'];
  final privateApiKey = Platform.environment['BAAS_PRIVATE_API_KEY'];
  final projectId = Platform.environment['BAAS_PROJECT_ID'];

  final client = await (cluster == null ? BaasClient.docker(baasUrl) : BaasClient.atlas(baasUrl, cluster, apiKey!, privateApiKey!, projectId!));

  baasApps.addAll(await client.getOrCreateApps());
}
