// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';
import 'test.dart';

void main() {
  setupTests();

  baasTest('Asymmetric objects die even before upload', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    realm.syncSession.pause();

    final oid = ObjectId();
    realm.write(() {
      realm.ingest(Asymmetric(oid, embeddedObjects: [1, 2, 3].map(Embedded.new)));
    });

    // Find & query on an Asymmetric object is compile time error, but you can cheat with dynamic
    expect(realm.dynamic.find('Asymmetric', oid), null);
    expect(() => realm.dynamic.all('Asymmetric'), throws<RealmException>('Query on ephemeral objects not allowed'));

    realm.syncSession.resume();
    await realm.syncSession.waitForUpload();
  });

  baasTest('Asymmetric re-add same PK', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);

    final oid = ObjectId();
    realm.write(() {
      realm.ingest(Asymmetric(oid, embeddedObjects: [1, 2, 3].map(Embedded.new)));
      expect(() => realm.ingest(Asymmetric(oid, embeddedObjects: [1, 2, 3, 4].map(Embedded.new))),
          throws<RealmException>("Attempting to create an object of type 'Asymmetric' with an existing primary key value"));
    });

    realm.write(() {
      // okay to ingest again in another transaction, because object already dead to us
      realm.ingest(Asymmetric(oid, embeddedObjects: [1, 2, 3, 5].map(Embedded.new)));
    });

    await realm.syncSession.waitForUpload();
  });

  baasTest('Asymmetric add non-embedded links', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);

    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Symmetric>());
    });

    realm.write(() {
      final s = realm.add(Symmetric(ObjectId()));
      realm.ingest(Asymmetric(ObjectId(), symmetric: s));
      realm.ingest(Asymmetric(ObjectId(), embeddedObjects: [Embedded(1, symmetric: s)]));
      realm.ingest(Asymmetric(ObjectId(), embeddedObjects: [Embedded(1, any: RealmValue.from(s))]));
    });

    await realm.syncSession.waitForUpload();
  });

  test("Asymmetric don't work local realms", () {
    expect(() => Realm(Configuration.local([Asymmetric.schema, Embedded.schema, Symmetric.schema])),
        throws<RealmException>("Asymmetric table 'Asymmetric' not allowed in a local Realm"));
  });

  test("Asymmetric don't work with disconnectedSync", () {
    final config = Configuration.disconnectedSync([Asymmetric.schema, Embedded.schema, Symmetric.schema], path: generateRandomRealmPath());
    expect(() => Realm(config), throws<RealmException>());
  });

  // TODO
  // Test that asymmetric objects are actually transferred to backend, once we have
  // a mongoClient to query the backend with.
}
