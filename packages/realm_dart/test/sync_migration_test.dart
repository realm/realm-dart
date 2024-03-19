// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/configuration.dart';
import 'package:test/test.dart' hide test, throws;

import 'test.dart';

part 'sync_migration_test.realm.dart';

@RealmModel()
@MapTo("NullableTypes")
class _NullableTypesV2 {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late ObjectId differentiator;

  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
  late Uuid uuidProp;
  late int intProp;
  late Decimal128 decimalProp;
}

void main() {
  setupTests();

  baasTest('Can migrate property optionality', (appConfig) async {
    final differentiator = ObjectId();
    final oid = ObjectId();
    final uuid = Uuid.v4();
    final date = DateTime.now();

    final user = await getIntegrationUser(appConfig: appConfig);
    final config = Configuration.flexibleSync(user, getSyncSchema())..sessionStopPolicy = SessionStopPolicy.immediately;

    final realm = await Realm.open(config);

    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<NullableTypes>('differentiator == \$0', [differentiator]));
    });

    realm.write(() {
      realm.add(NullableTypes(ObjectId(), differentiator,
          boolProp: true,
          dateProp: date,
          decimalProp: Decimal128.fromDouble(123.456),
          doubleProp: -123.987,
          intProp: 42,
          objectIdProp: oid,
          stringProp: 'abc',
          uuidProp: uuid));
    });

    await realm.syncSession.waitForUpload();

    realm.close();

    final schemav2 = getSyncSchema();
    schemav2.remove(NullableTypes.schema);
    schemav2.add(NullableTypesV2.schema);

    final configv2 = Configuration.flexibleSync(user, schemav2, schemaVersion: 2)..sessionStopPolicy = SessionStopPolicy.immediately;
    final realmv2 = await Realm.open(configv2);

    realmv2.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmv2.query<NullableTypesV2>('differentiator == \$0', [differentiator]));
    });

    final obj = realmv2.all<NullableTypesV2>().single;

    expect(obj.boolProp, true);
    expect(obj.dateProp, date);
    expect(obj.decimalProp, Decimal128.fromDouble(123.456));
    expect(obj.doubleProp, -123.987);
    expect(obj.intProp, 42);
    expect(obj.objectIdProp, oid);
    expect(obj.stringProp, 'abc');
    expect(obj.uuidProp, uuid);
  });
}
