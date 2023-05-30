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
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart' hide test;
import 'package:test/test.dart' as testing;
import 'package:args/args.dart';
import '../lib/realm.dart';
import '../lib/src/cli/atlas_apps/baas_client.dart';
import '../lib/src/native/realm_core.dart';
import '../lib/src/configuration.dart';

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
class _Product {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
  @MapTo('stringQueryField')
  late String name;
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
  late Decimal128 decimalProp;

  late String? nullableStringProp;
  late bool? nullableBoolProp;
  late DateTime? nullableDateProp;
  late double? nullableDoubleProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
  late int? nullableIntProp;
  late Decimal128? nullableDecimalProp;
}

@RealmModel()
class _LinksClass {
  @PrimaryKey()
  late Uuid id;

  late _LinksClass? link;
  late List<_LinksClass> list;
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
  late List<Decimal128> decimals;

  late List<String?> nullableStrings;
  late List<bool?> nullableBools;
  late List<DateTime?> nullableDates;
  late List<double?> nullableDoubles;
  late List<ObjectId?> nullableObjectIds;
  late List<Uuid?> nullableUuids;
  late List<int?> nullableInts;
  late List<Decimal128?> nullableDecimals;
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
  late Decimal128? decimalProp;
}

@RealmModel()
class _Event {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
  @MapTo('stringQueryField')
  late String? name;
  @MapTo('boolQueryField')
  late bool? isCompleted;
  @MapTo('intQueryField')
  late int? durationInMinutes;
  late String? assignedTo;
}

@RealmModel()
class _Party {
  // no primary key!
  _Friend? host;
  late int year;
  final guests = <_Friend>[];
  _Party? previous;
}

@RealmModel()
class _Friend {
  @PrimaryKey()
  late String name;
  var age = 42;
  _Friend? bestFriend;
  final friends = <_Friend>[];
}

@RealmModel()
class _When {
  late DateTime dateTimeUtc;
  late String locationName; // tz database/Olson name
}

@RealmModel()
class _Player {
  @PrimaryKey()
  late String name;
  _Game? game;
  final scoresByRound = <int?>[]; // null means player didn't finish
}

@RealmModel()
class _Game {
  final winnerByRound = <_Player>[]; // null means no winner yet
  int get rounds => winnerByRound.length;
}

@RealmModel(ObjectType.embeddedObject)
class _AllTypesEmbedded {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
  late Uuid uuidProp;
  late int intProp;
  late Decimal128 decimalProp;

  late String? nullableStringProp;
  late bool? nullableBoolProp;
  late DateTime? nullableDateProp;
  late double? nullableDoubleProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
  late int? nullableIntProp;
  late Decimal128? nullableDecimalProp;

  late List<String> strings;
  late List<bool> bools;
  late List<DateTime> dates;
  late List<double> doubles;
  late List<ObjectId> objectIds;
  late List<Uuid> uuids;
  late List<int> ints;
  late List<Decimal128> decimals;
}

@RealmModel()
class _ObjectWithEmbedded {
  @PrimaryKey()
  @MapTo('_id')
  late String id;

  late Uuid? differentiator;

  late _AllTypesEmbedded? singleObject;

  late List<_AllTypesEmbedded> list;

  late _RecursiveEmbedded1? recursiveObject;

  late List<_RecursiveEmbedded1> recursiveList;
}

@RealmModel(ObjectType.embeddedObject)
class _RecursiveEmbedded1 {
  late String value;

  late _RecursiveEmbedded2? child;
  late List<_RecursiveEmbedded2> children;

  late _ObjectWithEmbedded? realmObject;
}

@RealmModel(ObjectType.embeddedObject)
class _RecursiveEmbedded2 {
  late String value;

  late _RecursiveEmbedded3? child;
  late List<_RecursiveEmbedded3> children;

  late _ObjectWithEmbedded? realmObject;
}

@RealmModel(ObjectType.embeddedObject)
class _RecursiveEmbedded3 {
  late String value;
}

@RealmModel()
class _ObjectWithDecimal {
  late Decimal128 decimal;
  Decimal128? nullableDecimal;
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
const String argDifferentiator = "BAAS_DIFFERENTIATOR";

String testUsername = "realm-test@realm.io";
String testPassword = "123456";
const String publicRSAKeyForJWTValidation = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNHHs8T0AHD7SJ+CKvVR
leeJa4wqYTnaVYV+5bX9FmFXVoN+vHbMLEteMvSw4L3kSRZdcqxY7cTuhlpAvkXP
Yq6qSI+bW8T4jGW963uCc83UhVMx4MH/PzipAlfcPjVO2u4c+dmpgZQpgEmA467u
tauXUhmTsGpgNg2Gvc61B7Ny4LphshsyrfaJ9WjA/NM6LOmEBW3JPNcVG2qyU+gt
O8BM8KOSx9wGyoGs4+OusvRkJizhPaIwa3FInLs4r+xZW9Bp6RndsmVECtvXRv5d
87ztpg6o3DZJRmTp2lAnkNLmxXlFkOSNIwiT3qqyRZOh4DuxPOpfg9K+vtFmRdEJ
RwIDAQAB
-----END PUBLIC KEY-----''';
final int encryptionKeySize = 64;
// final _appsWithDisabledAutoRecovery = <String>[];

enum AppNames {
  flexible,

  // For application with name 'autoConfirm' and with confirmationType = 'auto'
  // all the usernames are automatically confirmed.
  autoConfirm,

  emailConfirm,
}

const int maxInt = 9223372036854775807;
const int minInt = -9223372036854775808;
const int jsMaxInt = 9007199254740991;
const int jsMinInt = -9007199254740991;

//Overrides test method so we can filter tests
void test(String name, dynamic Function() testFunction, {dynamic skip, Map<String, dynamic>? onPlatform}) {
  if (testName != null && !name.contains(testName!)) {
    return;
  }

  var timeout = 30;
  assert(() {
    timeout = Duration.secondsPerDay;
    return true;
  }());

  testing.test(name, testFunction, skip: skip, onPlatform: onPlatform, timeout: Timeout(Duration(seconds: timeout)));
}

void xtest(String? name, dynamic Function() testFunction, {dynamic skip, Map<String, dynamic>? onPlatform}) {
  testing.test(name, testFunction, skip: "Test is disabled");
}

Future<void> setupTests(List<String>? args) async {
  arguments = parseTestArguments(args);
  testName = arguments["name"];
  
  setUpAll(() async => await (_baasSetupResult ??= setupBaas()));

  setUp(() {
    Realm.logger = Logger.detached('test run')
      ..level = Level.INFO
      ..onRecord.listen((record) {
        testing.printOnFailure('${record.time} ${record.level.name}: ${record.message}');
      });

    final path = generateRandomRealmPath();
    Configuration.defaultRealmPath = path;

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
        await tryDeleteRealm(path);
      }
    });
  });

  // Enable this to print platform info, including current PID
  await _printPlatformInfo();
}

Matcher throws<T>([String? message]) => throwsA(isA<T>().having((dynamic exception) => exception.message, 'message', contains(message ?? '')));

String generateRandomRealmPath() {
  final path = _path.join(Directory.systemTemp.createTempSync("realm_test_").path, "${generateRandomString(10)}.realm");
  return path;
}

final random = Random();
String generateRandomString(int length, {String characterSet = 'abcdefghjklmnopqrstuvwxuz'}) {
  return List.generate(length, (index) => characterSet[random.nextInt(characterSet.length)]).join();
}

String generateRandomUnicodeString({int length = 10}) {
  return generateRandomString(length, characterSet: r"uvwxuzфоо-барΛορεμლორემ植物החללجمعتsøren");
}

String generateRandomEmail({int length = 5}) {
  String randomString = generateRandomString(length, characterSet: r"abcdefghjklmnopqrstuvwxuz!#$%&*+-'/=?^_`{|}~0123456789");
  return "$randomString@realm.io";
}

Realm getRealm(Configuration config) {
  if (config is FlexibleSyncConfiguration) {
    config.sessionStopPolicy = SessionStopPolicy.immediately;
  }

  final realm = Realm(config);
  _openRealms.add(realm);
  return realm;
}

Future<Realm> getRealmAsync(Configuration config, {CancellationToken? cancellationToken, ProgressCallback? onProgressCallback}) async {
  if (config is FlexibleSyncConfiguration) {
    config.sessionStopPolicy = SessionStopPolicy.immediately;
  }
  final realm = await Realm.open(config, cancellationToken: cancellationToken, onProgressCallback: onProgressCallback);
  _openRealms.add(realm);
  return realm;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
Realm freezeRealm(Realm realm) {
  final frozen = realm.freeze();
  _openRealms.add(frozen);
  return frozen;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
RealmResults<T> freezeResults<T extends RealmObjectBase>(RealmResults<T> results) {
  final frozen = results.freeze();
  _openRealms.add(frozen.realm);
  return frozen;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
RealmList<T> freezeList<T>(RealmList<T> list) {
  final frozen = list.freeze();
  _openRealms.add(frozen.realm);
  return frozen;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
T freezeObject<T extends RealmObjectBase>(T object) {
  final frozen = object.freeze();
  _openRealms.add(frozen.realm);
  return frozen as T;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
dynamic freezeDynamic(dynamic object) {
  dynamic frozen = object.freeze();
  _openRealms.add(frozen.realm as Realm);
  return frozen;
}

Future<void> tryDeleteRealm(String path) async {
  //Skip on CI to speed it up. We are creating the realms in $TEMP anyways.
  if (Platform.environment.containsKey("REALM_CI")) {
    return;
  }

  final dummy = File("");
  const duration = Duration(milliseconds: 100);
  for (var i = 0; i < 5; i++) {
    try {
      Realm.deleteRealm(path);

      //delete lock file
      await File('$path.lock').delete().onError((error, stackTrace) => dummy);

      return;
    } catch (e) {
      Realm.logger.info('Failed to delete realm at path $path. Trying again in ${duration.inMilliseconds}ms');
      await Future<void>.delayed(duration);
    }
  }

  // TODO: File deletions does not work after tests so don't fail for now https://github.com/realm/realm-dart/issues/751
  // throw Exception('Failed to delete realm at path $path. Did you forget to close it?');
}

Map<String, String?> parseTestArguments(List<String>? arguments) {
  Map<String, String?> testArgs = {};
  final parser = ArgParser()
    ..addOption("name")
    ..addOption(argBaasUrl)
    ..addOption(argBaasCluster)
    ..addOption(argBaasApiKey)
    ..addOption(argBaasPrivateApiKey)
    ..addOption(argBaasProjectId)
    ..addOption(argDifferentiator);

  final result = parser.parse(arguments ?? []);
  testArgs
    ..addArgument(result, "name")
    ..addArgument(result, argBaasUrl)
    ..addArgument(result, argBaasCluster)
    ..addArgument(result, argBaasApiKey)
    ..addArgument(result, argBaasPrivateApiKey)
    ..addArgument(result, argBaasProjectId)
    ..addArgument(result, argDifferentiator);

  return testArgs;
}

extension on Map<String, String?> {
  void addArgument(ArgResults parsedResult, String argName) {
    late String? value;
    if (parsedResult.wasParsed(argName)) {
      if (parsedResult[argName] != null && parsedResult[argName] != "null") {
        value = parsedResult[argName]!.toString();
      } else {
        value = null;
      }
    } else {
      value = Platform.environment[argName];
    }

    if (value != null && value.isNotEmpty) {
      this[argName] = value;
    }
  }
}

BaasClient? baasClient;
Future<Object>? _baasSetupResult;

Future<Object> setupBaas() async {
  if (_baasSetupResult != null) {
    return _baasSetupResult!;
  }

  try {
    final baasUrl = arguments[argBaasUrl];
    if (baasUrl == null) {
      return true;
    }

    final cluster = arguments[argBaasCluster];
    final apiKey = arguments[argBaasApiKey];
    final privateApiKey = arguments[argBaasPrivateApiKey];
    final projectId = arguments[argBaasProjectId];
    final differentiator = arguments[argDifferentiator];

    final client = await (cluster == null
        ? BaasClient.docker(baasUrl, differentiator)
        : BaasClient.atlas(baasUrl, cluster, apiKey!, privateApiKey!, projectId!, differentiator));

    client.publicRSAKey = publicRSAKeyForJWTValidation;

    final apps = await client.getOrCreateApps();
    baasApps.addAll(apps);
    baasClient = client;
    await Future<void>.delayed(Duration(seconds: 10));
    return true;
  } catch (error) {
    print(error);
    return error;
  }
}

@isTest
Future<void> baasTest(
  String name,
  FutureOr<void> Function(AppConfiguration appConfig) testFunction, {
  AppNames appName = AppNames.flexible,
  dynamic skip,
}) async {
  if (_baasSetupResult is Error) {
    throw _baasSetupResult!;
  }

  final baasUri = arguments[argBaasUrl];
  skip = shouldSkip(baasUri, skip);

  test(name, () async {
    try {
      final config = await getAppConfig(appName: appName);
      await testFunction(config);
    } catch (error) {
      printSplunkLogLink(appName, baasUri);
      rethrow;
    }
  }, skip: skip);
}

dynamic shouldSkip(String? baasUri, dynamic skip) {
  final url = baasUri != null ? Uri.tryParse(baasUri) : null;

  if (skip == null) {
    skip = url == null ? "BAAS URL not present" : false;
  } else if (skip is bool) {
    if (url == null) skip = "BAAS URL not present";
  }

  return skip;
}

Future<AppConfiguration> getAppConfig({AppNames appName = AppNames.flexible}) async {
  final baasUrl = arguments[argBaasUrl];

  final app = baasApps[appName.name] ??
      baasApps.values.firstWhere((element) => element.name == BaasClient.defaultAppName, orElse: () => throw RealmError("No BAAS apps"));
  if (app.error != null) {
    throw app.error!;
  }

  final temporaryDir = await Directory.systemTemp.createTemp('realm_test_');
  return AppConfiguration(
    app.clientAppId,
    baseUrl: Uri.parse(baasUrl!),
    baseFilePath: temporaryDir,
    maxConnectionTimeout: Duration(minutes: 10),
    defaultRequestTimeout: Duration(minutes: 7),
  );
}

Future<User> getIntegrationUser(App app) async {
  final email = 'realm_tests_do_autoverify_${generateRandomEmail()}';
  final password = 'password';
  await app.emailPasswordAuthProvider.registerUser(email, password);

  return await loginWithRetry(app, Credentials.emailPassword(email, password));
}

Future<User> getAnonymousUser(App app) {
  return app.logIn(Credentials.anonymous(reuseCredentials: false));
}

Future<String> createServerApiKey(App app, String name, {bool enabled = true}) async {
  final baasApp = baasApps.values.firstWhere((ba) => ba.clientAppId == app.id);
  final client = baasClient ?? (throw StateError("No BAAS client"));
  return await client.createApiKey(baasApp, name, enabled);
}

Future<Realm> getIntegrationRealm({App? app, ObjectId? differentiator}) async {
  app ??= App(await getAppConfig());
  final user = await getIntegrationUser(app);

  final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema, NullableTypes.schema]);
  final realm = getRealm(config);
  if (differentiator != null) {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<NullableTypes>(r'differentiator = $0', [differentiator]));
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

Future<void> waitForCondition(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 1),
  Duration retryDelay = const Duration(milliseconds: 100),
  String? message,
}) {
  return waitForConditionWithResult<bool>(() => condition(), (value) => value == true, timeout: timeout, retryDelay: retryDelay, message: message);
}

Future<T> waitForConditionWithResult<T>(FutureOr<T> Function() getter, FutureOr<bool> Function(T value) condition,
    {Duration timeout = const Duration(seconds: 1), Duration retryDelay = const Duration(milliseconds: 100), String? message}) async {
  final start = DateTime.now();
  while (true) {
    final value = await getter();
    if (await condition(value)) {
      return value;
    }

    if (DateTime.now().difference(start) > timeout) {
      throw TimeoutException('Condition not met within $timeout. Message: ${message != null ? ': $message' : ''}');
    }

    await Future<void>.delayed(retryDelay);
  }
}

extension RealmObjectTest on RealmObjectBase {
  String toJson() => realmCore.objectToString(this);
}

extension DateTimeTest on DateTime {
  String toNormalizedDateString() {
    final utc = toUtc();
    // This is kind of silly, but Core serializes negative dates as -003-01-01 12:34:56
    final utcYear = utc.year < 0 ? '-${utc.year.abs().toString().padLeft(3, '0')}' : utc.year.toString().padLeft(4, '0');

    // For some reason Core always rounds up to the next second for negative dates, so we need to do the same
    final seconds = utc.microsecondsSinceEpoch < 0 && utc.microsecondsSinceEpoch % 1000000 != 0 ? utc.second + 1 : utc.second;
    return '$utcYear-${_format(utc.month)}-${_format(utc.day)} ${_format(utc.hour)}:${_format(utc.minute)}:${_format(seconds)}';
  }

  static String _format(int value) => value.toString().padLeft(2, '0');
}

void clearCachedApps() => realmCore.clearCachedApps();

Future<void> _printPlatformInfo() async {
  final pointerSize = sizeOf<IntPtr>() * 8;
  final os = Platform.operatingSystem;
  String? cpu;

  if (!isFlutterPlatform) {
    if (Platform.isWindows) {
      cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
    } else {
      final info = await Process.run('uname', ['-m']);
      cpu = info.stdout.toString().replaceAll('\n', '');
    }
  }

  print('Current PID $pid; OS $os, $pointerSize bit, CPU ${cpu ?? 'unknown'}');
}

extension StreamEx<T> on Stream<Stream<T>> {
  Stream<T> switchLatest() async* {
    StreamSubscription<T>? inner;
    final controller = StreamController<T>();
    final outer = listen((stream) {
      inner?.cancel();
      inner = stream.listen(controller.add, onError: controller.addError, onDone: controller.close);
    }, onError: controller.addError, onDone: controller.close);
    yield* controller.stream;
    await outer.cancel();
    await inner?.cancel();
  }
}

void printSplunkLogLink(AppNames appName, String? uriVariable) {
  if (uriVariable == null) {
    return;
  }
  final app = baasApps[appName.name] ??
      baasApps.values.firstWhere((element) => element.name == BaasClient.defaultAppName, orElse: () => throw RealmError("No BAAS apps"));
  final baasUri = Uri.parse(uriVariable);

  print("App service name: ${app.uniqueName}");
  final host = baasUri.host.endsWith('-qa.mongodb.com') ? "-qa" : "";
  final splunk = Uri.encodeFull(
      "https://splunk.corp.mongodb.com/en-US/app/search/search?q=search index=baas$host \"${app.uniqueName}-*\" | reverse | top error msg&earliest=-7d&latest=now&display.general.type=visualizations");
  print("Splunk logs: $splunk");
}
