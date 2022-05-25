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
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart' hide test;
import 'package:test/test.dart' as testing;
import 'package:args/args.dart';
import '../lib/realm.dart';
import '../lib/src/cli/deployapps/baas_client.dart';
import '../lib/src/native/realm_core.dart';

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

@RealmModel()
@MapTo("myRemappedClass")
class $RemappedClass {
  @MapTo("primitive_property")
  late String remappedProperty;

  @MapTo("list-with-dashes")
  late List<$RemappedClass> listProperty;
}

@RealmModel()
class _Task {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
}

@RealmModel()
class _Schedule {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
  final tasks = <_Task>[];
}

@RealmModel()
class _AllTypes {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
  late Uuid uuidProp;
  late int intProp;
}

@RealmModel()
class _AllCollections {
  late List<String> strings;
  late List<bool> bools;
  late List<DateTime> dates;
  late List<double> doubles;
  late List<ObjectId> objectIds;
  late List<Uuid> uuids;
  late List<int> ints;
}

@RealmModel()
class _NullableTypes {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late ObjectId differentiator;

  late String? stringProp;
  late bool? boolProp;
  late DateTime? dateProp;
  late double? doubleProp;
  late ObjectId? objectIdProp;
  late Uuid? uuidProp;
  late int? intProp;
}

String? testName;
Map<String, String?> arguments = {};
final baasApps = <String, BaasApp>{};
final _openRealms = Queue<Realm>();
const String argBaasUrl = "BAAS_URL";
const String argBaasCluster = "BAAS_CLUSTER";
const String argBaasApiKey = "BAAS_API_KEY";
const String argBaasPrivateApiKey = "BAAS_PRIVATE_API_KEY";
const String argBaasProjectId = "BAAS_PROJECT_ID";

String testUsername = "realm-test@realm.io";
String testPassword = "123456";

enum AppNames {
  flexible,

  // For application with name 'autoConfirm' and with confirmationType = 'auto'
  // all the usernames are automatically confirmed.
  autoConfirm,

  emailConfirm,
}

//Overrides test method so we can filter tests
void test(String name, dynamic Function() testFunction, {dynamic skip}) {
  if (testName != null && !name.contains(testName!)) {
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
  arguments = parseTestArguments(args);
  testName = arguments["name"];
  setUpAll(() async => await setupBaas());

  setUp(() {
    final path = generateRandomRealmPath();
    Configuration.defaultPath = path;

    addTearDown(() async {
      final paths = HashSet<String>();
      paths.add(path);

      realmCore.clearCachedApps();

      while (_openRealms.isNotEmpty) {
        final realm = _openRealms.removeFirst();
        paths.add(realm.config.path);
        realm.close();
      }

      for (final path in paths) {
        try {
          Realm.deleteRealm(path);
        } catch (e) {
          print("Can not delete realm at path: $path. Did you forget to close it?");
        }
        String pathKey = _path.basenameWithoutExtension(path);
        String realmDir = _path.dirname(path);
        await Directory(realmDir).list().forEach((f) {
          if (f.path.contains(pathKey)) tryDeleteFile(f, recursive: true);
        });
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
    path = _path.join(Directory.systemTemp.createTempSync("realm_test_").path, path);
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
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

Map<String, String?> parseTestArguments(List<String>? arguments) {
  Map<String, String?> testArgs = {};
  final parser = ArgParser()
    ..addOption("name")
    ..addOption(argBaasUrl)
    ..addOption(argBaasCluster)
    ..addOption(argBaasApiKey)
    ..addOption(argBaasPrivateApiKey)
    ..addOption(argBaasProjectId);

  final result = parser.parse(arguments ?? []);
  testArgs
    ..addArgument(result, "name")
    ..addArgument(result, argBaasUrl)
    ..addArgument(result, argBaasCluster)
    ..addArgument(result, argBaasApiKey)
    ..addArgument(result, argBaasPrivateApiKey)
    ..addArgument(result, argBaasProjectId);
  return testArgs;
}

extension on Map<String, String?> {
  void addArgument(ArgResults parsedResult, String argName) {
    this[argName] = parsedResult.wasParsed(argName) ? parsedResult[argName]?.toString() : Platform.environment[argName];
  }
}

Future<void> setupBaas() async {
  final baasUrl = arguments[argBaasUrl];
  if (baasUrl == null) {
    return;
  }

  final cluster = arguments[argBaasCluster];
  final apiKey = arguments[argBaasApiKey];
  final privateApiKey = arguments[argBaasPrivateApiKey];
  final projectId = arguments[argBaasProjectId];

  final client = await (cluster == null ? BaasClient.docker(baasUrl) : BaasClient.atlas(baasUrl, cluster, apiKey!, privateApiKey!, projectId!));
  var apps = await client.getOrCreateApps();
  baasApps.addAll(apps);
}

@isTest
Future<void> baasTest(
  String name,
  FutureOr<void> Function(AppConfiguration appConfig) testFunction, {
  AppNames appName = AppNames.flexible,
  dynamic skip,
}) async {
  final uriVariable = arguments[argBaasUrl];
  final url = uriVariable != null ? Uri.tryParse(uriVariable) : null;

  if (skip == null) {
    skip = url == null ? "BAAS URL not present" : false;
  } else if (skip is bool) {
    skip = skip || url == null ? "BAAS URL not present" : false;
  }

  test(name, () async {
    final config = await getAppConfig(appName: appName);
    return await testFunction(config);
  }, skip: skip);
}

Future<AppConfiguration> getAppConfig({AppNames appName = AppNames.flexible}) async {
  final baasUrl = arguments[argBaasUrl];

  final app = baasApps[appName.name] ??
      baasApps.values.firstWhere((element) => element.name == BaasClient.defaultAppName, orElse: () => throw RealmError("No BAAS apps"));

  final temporaryDir = await Directory.systemTemp.createTemp('realm_test_');
  return AppConfiguration(
    app.clientAppId,
    baseUrl: Uri.parse(baasUrl!),
    baseFilePath: temporaryDir,
  );
}

Future<User> getIntegrationUser(App app) async {
  final email = 'realm_tests_do_autoverify_${generateRandomString(10)}@realm.io';
  final password = 'password';
  await app.emailPasswordAuthProvider.registerUser(email, password);

  return await loginWithRetry(app, Credentials.emailPassword(email, password));
}

Future<Realm> getIntegrationRealm({App? app, ObjectId? differentiator, String? path}) async {
  app ??= App(await getAppConfig());
  final user = await getIntegrationUser(app);

  // TODO: path will not be needed after https://github.com/realm/realm-dart/pull/574
  final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema, NullableTypes.schema], path: path);
  final realm = getRealm(config);
  if (differentiator != null) {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<NullableTypes>('differentiator = \$0', [differentiator]));
    });

    await realm.subscriptions.waitForSynchronization();
  }

  return realm;
}

Future<User> loginWithRetry(App app, Credentials credentials, {int retryCount = 3}) async {
  try {
    return await app.logIn(credentials);
  } catch (e) {
    if (retryCount > 1) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return await loginWithRetry(app, credentials, retryCount: retryCount - 1);
    }
    rethrow;
  }
}

Future<void> waitForCondition(bool Function() condition,
    {Duration timeout = const Duration(seconds: 1), Duration retryDelay = const Duration(milliseconds: 100), String? message}) async {
  final start = DateTime.now();
  while (!condition()) {
    if (DateTime.now().difference(start) > timeout) {
      throw TimeoutException('Condition not met within $timeout${message != null ? ': $message' : ''}');
    }

    await Future<void>.delayed(retryDelay);
  }
}

extension RealmObjectTest on RealmObject {
  String toJson() => realmCore.objectToString(this);
}
