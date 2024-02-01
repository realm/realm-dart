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
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart' hide test;
import 'package:test/test.dart' as testing;
import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/native/realm_core.dart';
import 'package:realm_dart/src/configuration.dart';

import 'baas_helper.dart';

export 'baas_helper.dart' show AppNames;

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

  @override
  String toString() => 'Task($id)';
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
class _Foo {
  late Uint8List requiredBinaryProp;
  var defaultValueBinaryProp = Uint8List(8);
  late Uint8List? nullableBinaryProp;
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
  var binaryProp = Uint8List(16);

  late String? nullableStringProp;
  late bool? nullableBoolProp;
  late DateTime? nullableDateProp;
  late double? nullableDoubleProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
  late int? nullableIntProp;
  late Decimal128? nullableDecimalProp;
  late Uint8List? nullableBinaryProp;
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
  final winnerByRound = <_Player>[];
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

@RealmModel(ObjectType.asymmetricObject)
class _Asymmetric {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  _Symmetric? symmetric;
  late List<_Embedded> embeddedObjects;
}

@RealmModel(ObjectType.embeddedObject)
class _Embedded {
  late int value;
  late RealmValue any;
  _Symmetric? symmetric;
}

@RealmModel()
class _Symmetric {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
}

String? testName;
final _openRealms = Queue<Realm>();

String testUsername = "realm-test@realm.io";
String testPassword = "123456";
final int encryptionKeySize = 64;

const int maxInt = 9223372036854775807;
const int minInt = -9223372036854775808;
const int jsMaxInt = 9007199254740991;
const int jsMinInt = -9007199254740991;

//Overrides test method so we can filter tests
void test(String name, dynamic Function() testFunction, {dynamic skip, Map<String, dynamic>? onPlatform}) {
  if (testName != null && !name.contains(testName!)) {
    return;
  }

  var timeout = 60;
  assert(() {
    if (Platform.environment['CI'] == null) {
      timeout = Duration(minutes: 5).inSeconds;
    }

    return true;
  }());

  testing.test(name, testFunction, skip: skip, onPlatform: onPlatform, timeout: Timeout(Duration(seconds: timeout)));
}

void xtest(String? name, dynamic Function() testFunction, {dynamic skip, Map<String, dynamic>? onPlatform}) {
  testing.test(name, testFunction, skip: "Test is disabled");
}

BaasHelper? baasHelper;

void setupTests() {
  setUpAll(() async {
    baasHelper = await BaasHelper.setupBaas();

    Realm.logger = Logger.detached('test run')
      ..level = Level.ALL
      ..onRecord.listen((record) {
        testing.printOnFailure('${record.time} ${record.level.name}: ${record.message}');
      });

    // Enable this to print platform info, including current PID
    _printPlatformInfo();
  });

  setUp(() {
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
RealmSet<T> freezeSet<T>(RealmSet<T> set) {
  final frozen = set.freeze();
  _openRealms.add(frozen.realm);
  return frozen;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
T freezeObject<T extends RealmObjectBase>(T object) {
  final frozen = object.freeze() as T;
  _openRealms.add(frozen.realm);
  return frozen;
}

/// This is needed to make sure the frozen Realm gets forcefully closed by the
/// time the test ends.
dynamic freezeDynamic(dynamic object) {
  dynamic frozen = object.freeze();
  _openRealms.add(frozen.realm as Realm);
  return frozen;
}

final dummy = File("");
Future<void> tryDeleteRealm(String path) async {
  //Skip on CI to speed it up. We are creating the realms in $TEMP anyways.
  if (Platform.environment.containsKey("REALM_CI")) {
    return;
  }

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

@isTest
Future<void> baasTest(
  String name,
  FutureOr<void> Function(AppConfiguration appConfig) testFunction, {
  AppNames appName = AppNames.flexible,
  dynamic skip,
}) async {
  BaasHelper.throwIfSetupFailed();

  skip = shouldSkip(skip);

  test(name, () async {
    baasHelper!.printSplunkLogLink(appName, baasHelper?.baseUrl);
    final config = await baasHelper!.getAppConfig(appName: appName);
    await testFunction(config);
  }, skip: skip);
}

dynamic shouldSkip(dynamic skip) {
  if (skip == null) {
    skip = BaasHelper.shouldRunBaasTests ? false : "BAAS URL not present";
  } else if (skip is bool) {
    if (!BaasHelper.shouldRunBaasTests) {
      skip = "BAAS URL not present";
    }
  }
  return skip;
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

Future<Realm> getIntegrationRealm({App? app, ObjectId? differentiator, AppConfiguration? appConfig}) async {
  app ??= App(appConfig ?? await baasHelper!.getAppConfig());
  final user = await getIntegrationUser(app);

  final config = Configuration.flexibleSync(user, getSyncSchema())..sessionStopPolicy = SessionStopPolicy.immediately;
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

extension on int {
  String pad(int width) => toString().padLeft(width, '0');
}

extension DateTimeTest on DateTime {
  String toCoreTimestampString() {
    final utc = toUtc();
    // Dart doesn't support nanoseconds, and core is not fully iso8601 compliant, hence this abomination
    // final nanoseconds = utc.microsecondsSinceEpoch.remainder(1000000) * 1000; // remaining microseconds as nanoseconds
    final nanoseconds = utc.microsecondsSinceEpoch % 1000000 * 1000; // remaining microseconds as nanoseconds
    final iso8601 = utc.toIso8601String();

    // use nanoseconds, and drop iso8601 utc Z at the end
    return iso8601
        .replaceFirst('T', ' ') //
        .replaceRange(
          iso8601.indexOf('.'),
          null,
          nanoseconds != 0 ? '.${nanoseconds.pad(9)}' : '',
        );
  }
}

void clearCachedApps() => realmCore.clearCachedApps();

void _printPlatformInfo() {
  final pointerSize = sizeOf<IntPtr>() * 8;
  final os = Platform.operatingSystem;
  String? cpu;

  if (!isFlutterPlatform) {
    if (Platform.isWindows) {
      cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
    } else {
      final info = Process.runSync('uname', ['-m']);
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

/// Schema list for default app service
/// used for all the flexible sync tests.
/// The full list of schemas is required when creating
/// a flexibleSync configuration to the default app service
/// to avoid causing breaking changes in development mode.
List<SchemaObject> getSyncSchema() {
  return [
    Task.schema,
    Schedule.schema,
    Product.schema,
    Event.schema,
    AllTypesEmbedded.schema,
    ObjectWithEmbedded.schema,
    RecursiveEmbedded1.schema,
    RecursiveEmbedded2.schema,
    RecursiveEmbedded3.schema,
    NullableTypes.schema,
    Asymmetric.schema,
    Embedded.schema,
    Symmetric.schema,
  ];
}

Future<bool> runWithRetries(bool Function() tester, {int retryDelay = 100, int attempts = 100}) async {
  var success = tester();
  var timeout = retryDelay * attempts;

  while (!success && attempts > 0) {
    await Future<void>.delayed(Duration(milliseconds: retryDelay));
    success = tester();
    attempts--;
  }

  if (!success) {
    throw TimeoutException('Failed to meet condition after $timeout ms.');
  }

  return success;
}

Future<void> _copyFile(String fromPath, String toPath) async {
  await File(fromPath).copy(toPath);
}

var copyFile = _copyFile; // default, but allow integration_test to override
