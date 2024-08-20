// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as _path;
import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/handles/realm_core.dart';
import 'package:realm_dart/src/logging.dart';
import 'package:realm_dart/src/realm_object.dart';
import 'package:test/test.dart';
import 'package:universal_platform/universal_platform.dart';

import 'utils/platform_util.dart';

export 'package:test/test.dart';

part 'test.realm.dart';

typedef Platform = UniversalPlatform;

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
  late Uint8List binaryProp;

  late String? nullableStringProp;
  late bool? nullableBoolProp;
  late DateTime? nullableDateProp;
  late double? nullableDoubleProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
  late int? nullableIntProp;
  late Decimal128? nullableDecimalProp;
  late Uint8List? nullableBinaryProp;

  late RealmValue realmValueProp;
}

@RealmModel()
class _LinksClass {
  @PrimaryKey()
  late Uuid id;

  late _LinksClass? link;
  late List<_LinksClass> list;
  late Set<_LinksClass> linksSet;
  late Map<String, _LinksClass?> map;
}

@RealmModel()
class _AllCollections {
  late List<String> stringList;
  late List<bool> boolList;
  late List<DateTime> dateList;
  late List<double> doubleList;
  late List<ObjectId> objectIdList;
  late List<Uuid> uuidList;
  late List<int> intList;
  late List<Decimal128> decimalList;

  late List<String?> nullableStringList;
  late List<bool?> nullableBoolList;
  late List<DateTime?> nullableDateList;
  late List<double?> nullableDoubleList;
  late List<ObjectId?> nullableObjectIdList;
  late List<Uuid?> nullableUuidList;
  late List<int?> nullableIntList;
  late List<Decimal128?> nullableDecimalList;

  late Set<String> stringSet;
  late Set<bool> boolSet;
  late Set<DateTime> dateSet;
  late Set<double> doubleSet;
  late Set<ObjectId> objectIdSet;
  late Set<Uuid> uuidSet;
  late Set<int> intSet;
  late Set<Decimal128> decimalSet;

  late Set<String?> nullableStringSet;
  late Set<bool?> nullableBoolSet;
  late Set<DateTime?> nullableDateSet;
  late Set<double?> nullableDoubleSet;
  late Set<ObjectId?> nullableObjectIdSet;
  late Set<Uuid?> nullableUuidSet;
  late Set<int?> nullableIntSet;
  late Set<Decimal128?> nullableDecimalSet;

  late Map<String, String> stringMap;
  late Map<String, bool> boolMap;
  late Map<String, DateTime> dateMap;
  late Map<String, double> doubleMap;
  late Map<String, ObjectId> objectIdMap;
  late Map<String, Uuid> uuidMap;
  late Map<String, int> intMap;
  late Map<String, Decimal128> decimalMap;

  late Map<String, String?> nullableStringMap;
  late Map<String, bool?> nullableBoolMap;
  late Map<String, DateTime?> nullableDateMap;
  late Map<String, double?> nullableDoubleMap;
  late Map<String, ObjectId?> nullableObjectIdMap;
  late Map<String, Uuid?> nullableUuidMap;
  late Map<String, int?> nullableIntMap;
  late Map<String, Decimal128?> nullableDecimalMap;
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

@RealmModel()
class _ObjectWithRealmValue {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
  late ObjectId? differentiator;

  @Indexed()
  late RealmValue oneAny;
  late List<RealmValue> manyAny;
  late Map<String, RealmValue> dictOfAny;
  late Set<RealmValue> setOfAny;
}

@RealmModel()
class _ObjectWithInt {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
  late ObjectId? differentiator;

  int i = 42;
}

String? testName;
final _openRealms = Queue<Realm>();

String testUsername = "realm-test@realm.io";
String testPassword = "123456";

final int maxInt = platformUtil.maxInt;
final int minInt = platformUtil.minInt;
const int jsMaxInt = 9007199254740991;
const int jsMinInt = -9007199254740991;

void xtest(String? name, dynamic Function() testFunction, {dynamic skip, Map<String, dynamic>? onPlatform}) {
  test(name, testFunction, skip: "Test is disabled");
}

void setupTests() {
  setUpAll(() {
    Realm.logger.setLogLevel(LogLevel.detail);
    Realm.logger.onRecord.listen((record) {
      printOnFailure('${DateTime.now().toUtc()} ${record.category} ${record.level.name}: ${record.message}');
    });

    if (Platform.isIOS) {
      final maxFiles = realmCore.setAndGetRLimit(1024);
      print('Max files: $maxFiles');
    }

    // Enable this to print platform info, including current PID
    platformUtil.printPlatformInfo();
  });

  setUp(() {
    final path = generateRandomRealmPath();
    Configuration.defaultRealmPath = path;

    addTearDown(() async {
      final paths = HashSet<String>();
      paths.add(path);

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

String generateRandomRealmPath({bool useUnicodeCharacters = false}) {
  final path = _path.join(platformUtil.createTempPathSync(), "${useUnicodeCharacters ? generateRandomUnicodeString() : generateRandomString(10)}.realm");
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
  final realm = Realm(config);
  _openRealms.add(realm);
  return realm;
}

Future<Realm> getRealmAsync(Configuration config, {CancellationToken? cancellationToken}) async {
  final realm = await Realm.open(config, cancellationToken: cancellationToken);
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

Future<void> tryDeleteRealm(String path) async {
  //Skip on CI to speed it up. We are creating the realms in $TEMP anyways.
  if (platformUtil.environment.containsKey("REALM_CI")) {
    return;
  }

  const duration = Duration(milliseconds: 100);
  for (var i = 0; i < 5; i++) {
    try {
      Realm.deleteRealm(path);
      return;
    } catch (e) {
      Realm.logger.log(LogLevel.info, 'Failed to delete realm at path $path. Trying again in ${duration.inMilliseconds}ms');
      await Future<void>.delayed(duration);
    }
  }

  // TODO: File deletions does not work after tests so don't fail for now https://github.com/realm/realm-dart/issues/751
  // throw Exception('Failed to delete realm at path $path. Did you forget to close it?');
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
  String toJson() => handle.objectToString();
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

var copyFile = platformUtil.copy; // default, but allow integration_test to override
