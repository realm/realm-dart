// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/configuration.dart';
import 'package:test/test.dart' hide test, throws;

import 'test.dart';

part 'sync_migration_test.realm.dart';

@RealmModel()
@MapTo("Nullables")
class _NullablesV0 {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late ObjectId differentiator;

  late bool? boolValue;
  late int? intValue;
  late double? doubleValue;
  late Decimal128? decimalValue;
  late DateTime? dateValue;
  late String? stringValue;
  late ObjectId? objectIdValue;
  late Uuid? uuidValue;
  late Uint8List? binaryValue;
}

@RealmModel()
@MapTo("Nullables")
class _NullablesV1 {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late ObjectId differentiator;

  late bool boolValue;
  late int intValue;
  late double doubleValue;
  late Decimal128 decimalValue;
  late DateTime dateValue;
  late String stringValue;
  late ObjectId objectIdValue;
  late Uuid uuidValue;
  late Uint8List binaryValue;
}

Future<Realm> openRealm(AppConfiguration appConfig, SchemaObject schema, ObjectId differentiator, {required int schemaVersion}) async {
  final user = await getIntegrationUser(appConfig: appConfig);
  final config = Configuration.flexibleSync(user, [schema], schemaVersion: schemaVersion)..sessionStopPolicy = SessionStopPolicy.immediately;

  final realm = await Realm.open(config);

  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add(realm.dynamic.all(schema.name).query('differentiator == \$0', [differentiator]));
  });

  await realm.subscriptions.waitForSynchronization();

  return realm;
}

void main() {
  setupTests();

  baasTest('Can migrate property optionality', (appConfig) async {
    final differentiator = ObjectId();
    final oid = ObjectId();
    final uuid = Uuid.v4();
    final date = DateTime(1999, 12, 21, 4, 53, 17).toUtc();
    final binary = Uint8List.fromList([1, 2, 3]);

    final realmv0 = await openRealm(appConfig, NullablesV0.schema, differentiator, schemaVersion: 0);
    final objv0 = realmv0.write(() {
      return realmv0.add(NullablesV0(ObjectId(), differentiator,
          boolValue: true,
          dateValue: date,
          decimalValue: Decimal128.fromDouble(123.456),
          doubleValue: -123.987,
          intValue: 42,
          objectIdValue: oid,
          stringValue: 'abc',
          uuidValue: uuid,
          binaryValue: binary));
    });

    await realmv0.syncSession.waitForUpload();

    final realmv1 = await openRealm(appConfig, NullablesV1.schema, differentiator, schemaVersion: 1);

    final objv1 = realmv1.all<NullablesV1>().single;

    expect(objv1.boolValue, true);
    expect(objv1.dateValue, date);
    expect(objv1.decimalValue, Decimal128.fromDouble(123.456));
    expect(objv1.doubleValue, -123.987);
    expect(objv1.intValue, 42);
    expect(objv1.objectIdValue, oid);
    expect(objv1.stringValue, 'abc');
    expect(objv1.uuidValue, uuid);
    expect(objv1.binaryValue, binary);

    final realmv2 = await openRealm(appConfig, NullablesV0.schema, differentiator, schemaVersion: 2);
    final objv2 = realmv2.all<NullablesV0>().single;

    expect(objv2.boolValue, true);
    expect(objv2.dateValue, date);
    expect(objv2.decimalValue, Decimal128.fromDouble(123.456));
    expect(objv2.doubleValue, -123.987);
    expect(objv2.intValue, 42);
    expect(objv2.objectIdValue, oid);
    expect(objv2.stringValue, 'abc');
    expect(objv2.uuidValue, uuid);
    expect(objv2.binaryValue, binary);

    realmv0.write(() {
      objv0.boolValue = null;
      objv0.dateValue = null;
      objv0.decimalValue = null;
      objv0.doubleValue = null;
      objv0.intValue = null;
      objv0.objectIdValue = null;
      objv0.stringValue = null;
      objv0.uuidValue = null;
      objv0.binaryValue = null;
    });

    await realmv0.syncSession.waitForUpload();
    await realmv1.syncSession.waitForDownload();
    await realmv2.syncSession.waitForDownload();

    expect(objv1.boolValue, false);
    expect(objv1.dateValue, DateTime.utc(1));
    expect(objv1.decimalValue, Decimal128.fromDouble(0));
    expect(objv1.doubleValue, 0);
    expect(objv1.intValue, 0);
    expect(objv1.objectIdValue, ObjectId.fromBytes(List.generate(12, (index) => 0)));
    expect(objv1.stringValue, '');
    expect(objv1.uuidValue, Uuid.nil);
    expect(objv1.binaryValue, Uint8List(0));

    expect(objv2.boolValue, isNull);
    expect(objv2.dateValue, isNull);
    expect(objv2.decimalValue, isNull);
    expect(objv2.doubleValue, isNull);
    expect(objv2.intValue, isNull);
    expect(objv2.objectIdValue, isNull);
    expect(objv2.stringValue, isNull);
    expect(objv2.uuidValue, isNull);
    expect(objv2.binaryValue, isNull);
  }, appName: AppNames.staticSchema);
}
