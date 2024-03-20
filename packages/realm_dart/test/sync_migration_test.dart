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

    final realmv0 = await openRealm(appConfig, NullablesV0.schema, differentiator, schemaVersion: 0);
    realmv0.write(() {
      realmv0.add(NullablesV0(ObjectId(), differentiator,
          boolValue: true,
          dateValue: date,
          decimalValue: Decimal128.fromDouble(123.456),
          doubleValue: -123.987,
          intValue: 42,
          objectIdValue: oid,
          stringValue: 'abc',
          uuidValue: uuid));
    });

    await realmv0.syncSession.waitForUpload();

    final realmv1 = await openRealm(appConfig, NullablesV1.schema, differentiator, schemaVersion: 1);

    final obj = realmv1.all<NullablesV1>().single;

    expect(obj.boolValue, true);
    expect(obj.dateValue, date);
    expect(obj.decimalValue, Decimal128.fromDouble(123.456));
    expect(obj.doubleValue, -123.987);
    expect(obj.intValue, 42);
    expect(obj.objectIdValue, oid);
    expect(obj.stringValue, 'abc');
    expect(obj.uuidValue, uuid);
  }, appName: AppNames.staticSchema);
}
