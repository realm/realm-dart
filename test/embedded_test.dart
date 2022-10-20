////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

import 'package:test/test.dart' hide test, throws;

import '../lib/realm.dart';
import '../lib/src/realm_object.dart';
import 'test.dart';

// This is required to be able to use the API for querying embedded objects.
import '../lib/src/realm_class.dart' show RealmInternal;

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  Realm getLocalRealm() {
    final config = Configuration.local(
        [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    return getRealm(config);
  }

  Future<Realm> getSyncRealm(AppConfiguration config) async {
    final app = App(config);
    final user = await getAnonymousUser(app);
    final realmConfig = Configuration.flexibleSync(
        user, [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    return getRealm(realmConfig);
  }

  test('Local Realm with orphan embedded schemas works', () {
    final config = Configuration.local([AllTypesEmbedded.schema]);
    final realm = getRealm(config);
    realm.close();

    final dynamicRealm = getRealm(Configuration.local([], path: config.path));

    final schema = dynamicRealm.schema;
    expect(schema.single.baseType, ObjectType.embedded);
  });

  baasTest('Synchronized Realm with orphan embedded schemas throws', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [AllTypesEmbedded.schema]);

    expect(() => getRealm(config), throws<RealmException>("Embedded object 'AllTypesEmbedded' is unreachable by any link path from top level objects"));
  });

  test('Embedded object roundtrip', () {
    final realm = getLocalRealm();

    final now = DateTime.now();
    final oid = ObjectId();
    final uuid = Uuid.v4();
    realm.write(() {
      realm.add(ObjectWithEmbedded('abc', singleObject: AllTypesEmbedded('str', true, now, 1.23, oid, uuid, 99)));
    });

    final obj = realm.all<ObjectWithEmbedded>().single;
    final json = obj.toJson();

    expect(json, contains('"stringProp":"str"'));
    expect(json, contains('"boolProp":true'));
    expect(json, contains('"dateProp":"${now.toNormalizedDateString()}"'));
    expect(json, contains('"doubleProp":1.23'));
    expect(json, contains('"objectIdProp":"$oid"'));
    expect(json, contains('"uuidProp":"$uuid"'));
    expect(json, contains('"intProp":99'));

    expect(json, contains('"nullableStringProp":null'));
    expect(json, contains('"nullableBoolProp":null'));
    expect(json, contains('"nullableDateProp":null'));
    expect(json, contains('"nullableDoubleProp":null'));
    expect(json, contains('"nullableObjectIdProp":null'));
    expect(json, contains('"nullableUuidProp":null'));
    expect(json, contains('"nullableIntProp":null'));
  });

  test('Embedded object get/set properties', () {
    final config = Configuration.local(
        [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    final realm = getRealm(config);

    final graph = ObjectWithEmbedded('TopLevel1',
        recursiveObject: RecursiveEmbedded1('Child1', child: RecursiveEmbedded2('Child2'), children: [
          RecursiveEmbedded2('List1', child: RecursiveEmbedded3('Child3'), topLevel: ObjectWithEmbedded('TopLeve2')),
          RecursiveEmbedded2('List2'),
        ]));

    // Make a cycle
    graph.recursiveObject!.child!.topLevel = graph;
    realm.write(() {
      realm.add(graph);
    });

    expect(graph.isManaged, true);
    expect(graph.recursiveObject!.isManaged, true);

    final refetched = realm.all<ObjectWithEmbedded>().first;

    expect(refetched, graph);
    expect(refetched.id, 'TopLevel1');

    final child1 = refetched.recursiveObject;
    expect(child1, isNotNull);
    expect(child1!.isManaged, true);
    expect(child1.value, 'Child1');
    expect(child1.topLevel, isNull);

    final child2 = child1.child;
    expect(child2, isNotNull);
    expect(child2!.isManaged, true);
    expect(child2.value, 'Child2');
    expect(child2.topLevel, refetched);
    expect(child2.child, isNull);
    expect(child2.children, isEmpty);

    final listChild1 = child1.children[0];
    expect(listChild1.isManaged, true);
    expect(listChild1.value, 'List1');
    expect(listChild1.child!.value, 'Child3');
    expect(listChild1.topLevel!.id, 'TopLeve2');

    final listChild2 = child1.children[1];
    expect(listChild2.isManaged, true);
    expect(listChild2.value, 'List2');
    expect(listChild2.child, isNull);
  });

  test('Embedded object when replaced invalidates old object', () {
    final realm = getLocalRealm();
    final topLevel = realm.write(() {
      return realm.add(ObjectWithEmbedded('', recursiveObject: RecursiveEmbedded1('first')));
    });

    final firstEmbeded = topLevel.recursiveObject!;
    expect(firstEmbeded.isManaged, true);
    expect(firstEmbeded.isValid, true);
    expect(firstEmbeded.value, 'first');

    realm.write(() {
      topLevel.recursiveObject = RecursiveEmbedded1('second');
    });

    // We replaced firstEmbedded with another one, so we expect it to be invalid
    expect(firstEmbeded.isManaged, true);
    expect(firstEmbeded.isValid, false);

    final secondEmbedded = topLevel.recursiveObject!;
    expect(secondEmbedded.value, 'second');

    realm.write(() {
      topLevel.recursiveObject = null;
    });

    // We replaced secondEmbedded with null, so we expect it to be invalid
    expect(secondEmbedded.isManaged, true);
    expect(secondEmbedded.isValid, false);

    expect(topLevel.recursiveObject, isNull);
  });

  test('Embedded object in list when replaced invalidates old object', () {
    final realm = getLocalRealm();
    final topLevel = realm.write(() {
      return realm.add(ObjectWithEmbedded('', recursiveList: [RecursiveEmbedded1('first'), RecursiveEmbedded1('second'), RecursiveEmbedded1('third')]));
    });

    final list = topLevel.recursiveList;

    final first = list[0];

    realm.write(() {
      list.remove(first);
    });

    expect(list.length, 2);
    expect(first.isManaged, true);
    expect(first.isValid, false);

    final second = list[0];
    realm.write(() {
      list.removeAt(0);
    });

    expect(list.length, 1);
    expect(second.isManaged, true);
    expect(second.isValid, false);

    final third = list.first;
    realm.write(() {
      list[0] = RecursiveEmbedded1('fourth');
    });

    expect(list.length, 1);
    expect(third.isManaged, true);
    expect(third.isValid, false);

    final fourth = list.first;

    realm.write(() {
      list.clear();
    });

    expect(list.length, 0);
    expect(fourth.isManaged, true);
    expect(fourth.isValid, false);
  });

  test('Embedded list .add', () {
    final realm = getLocalRealm();

    final obj = realm.write(() {
      return realm.add(ObjectWithEmbedded(''));
    });

    realm.write(() {
      obj.recursiveList.add(RecursiveEmbedded1('1'));
      obj.recursiveList.add(RecursiveEmbedded1('2'));
    });

    expect(obj.recursiveList.length, 2);
    expect(obj.recursiveList[0].value, '1');
    expect(obj.recursiveList[1].value, '2');
  });

  test('Embedded list .insert', () {
    final realm = getLocalRealm();

    final obj = realm.write(() {
      return realm.add(ObjectWithEmbedded(''));
    });

    realm.write(() {
      obj.recursiveList.insert(0, RecursiveEmbedded1('1'));
      obj.recursiveList.insert(0, RecursiveEmbedded1('2'));
    });

    expect(obj.recursiveList.length, 2);
    expect(obj.recursiveList[0].value, '2');
    expect(obj.recursiveList[1].value, '1');
  });

  test('Embedded list .set', () {
    final realm = getLocalRealm();

    final obj = realm.write(() {
      return realm.add(ObjectWithEmbedded(''));
    });

    realm.write(() {
      obj.recursiveList[0] = RecursiveEmbedded1('1');
    });

    expect(obj.recursiveList.length, 1);
    expect(obj.recursiveList[0].value, '1');

    realm.write(() {
      obj.recursiveList[0] = RecursiveEmbedded1('5');
    });

    expect(obj.recursiveList.length, 1);
    expect(obj.recursiveList[0].value, '5');
  });

  test('Embedded property when set to a managed object fails', () {
    final realm = getLocalRealm();
    final parent = realm.write(() {
      return realm.add(ObjectWithEmbedded('1', recursiveObject: RecursiveEmbedded1('1')));
    });

    realm.write(() {
      expect(() => realm.add(ObjectWithEmbedded('2', recursiveObject: parent.recursiveObject)), throws<RealmError>());
    });

    realm.write(() {
      expect(() => parent.recursiveObject = parent.recursiveObject, throws<RealmError>());
    });
  });

  test('Embedded list when adding managed object fails', () {
    final realm = getLocalRealm();
    final parent = realm.write(() {
      return realm.add(ObjectWithEmbedded('', recursiveList: [RecursiveEmbedded1('1')], recursiveObject: RecursiveEmbedded1('2')));
    });

    final list = parent.recursiveList;

    realm.write(() {
      expect(() => list.add(list[0]), throws<RealmError>());
      expect(() => list.add(parent.recursiveObject!), throws<RealmError>());
      expect(() => list[0] = list[0], throws<RealmError>());
      expect(() => list[0] = parent.recursiveObject!, throws<RealmError>());
      expect(() => list.insert(0, list[0]), throws<RealmError>());
      expect(() => list.insert(0, parent.recursiveObject!), throws<RealmError>());
    });
  });

  test('Parent with embedded addOrUpdate invalidates old embedded', () {
    final realm = getLocalRealm();

    final parent = realm.write(() {
      return realm.add(ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('list')], recursiveObject: RecursiveEmbedded1('link')));
    });

    final listObj = parent.recursiveList[0];
    final obj = parent.recursiveObject!;

    expect(listObj.isValid, true);
    expect(obj.isValid, true);

    realm.write(() {
      realm.add(ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('list 2')], recursiveObject: RecursiveEmbedded1('link 2')), update: true);
    });

    expect(listObj.isValid, false);
    expect(obj.isValid, false);

    expect(parent.recursiveList[0].value, 'list 2');
    expect(parent.recursiveObject!.value, 'link 2');
  });

  test('Parent with embedded addOrUpdate correctly propagates graph', () {
    final realm = getLocalRealm();

    final parent = realm.write(() {
      return realm.add(ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('list')], recursiveObject: RecursiveEmbedded1('link')));
    });

    final listObj = parent.recursiveList[0];
    final obj = parent.recursiveObject!;

    expect(listObj.isValid, true);
    expect(obj.isValid, true);

    final newGraph = ObjectWithEmbedded('456',
        recursiveObject: RecursiveEmbedded1('embedded 456', topLevel: ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('value')])));

    realm.write(() {
      realm.add(newGraph, update: true);
    });

    expect(realm.all<ObjectWithEmbedded>().length, 2);

    expect(listObj.isValid, false);
    expect(obj.isValid, false);

    expect(parent.recursiveList[0].value, 'value');
    expect(parent.recursiveObject, isNull);
  });

  test('Parent when deleted cleans up embedded graph', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123',
        recursiveList: [
          RecursiveEmbedded1('1.1', child: RecursiveEmbedded2('2.1', child: RecursiveEmbedded3('3.1'), children: [RecursiveEmbedded3('3.2')])),
          RecursiveEmbedded1('1.2', child: RecursiveEmbedded2('2.2', children: [RecursiveEmbedded3('3.3'), RecursiveEmbedded3('3.4')])),
        ],
        recursiveObject: RecursiveEmbedded1('1.3', child: RecursiveEmbedded2('2.3')));

    realm.write(() {
      realm.add(parent);
    });

    final embedded1s = realm.allEmbedded<RecursiveEmbedded1>();
    final embedded2s = realm.allEmbedded<RecursiveEmbedded2>();
    final embedded3s = realm.allEmbedded<RecursiveEmbedded3>();

    expect(embedded1s.length, 3);
    expect(embedded2s.length, 3);
    expect(embedded3s.length, 4);

    realm.write(() {
      realm.delete(parent);
    });

    expect(embedded1s.length, 0);
    expect(embedded2s.length, 0);
    expect(embedded3s.length, 0);
  });

  baasTest('Embedded objects synchronization', (config) async {
    final realm1 = await getSyncRealm(config);

    final differentiator = Uuid.v4();
    realm1.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm1.query<ObjectWithEmbedded>(r'differentiator = $0', [differentiator]));
    });

    final obj1 = realm1.write(() {
      return realm1.add(ObjectWithEmbedded(Uuid.v4().toString(),
          differentiator: differentiator,
          recursiveObject: RecursiveEmbedded1('1.1', child: RecursiveEmbedded2('2.1'), children: [RecursiveEmbedded2('2.2')]),
          recursiveList: [RecursiveEmbedded1('1.2')]));
    });

    await realm1.subscriptions.waitForSynchronization();
    await realm1.syncSession.waitForUpload();

    final realm2 = await getSyncRealm(config);
    realm2.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm2.query<ObjectWithEmbedded>(r'differentiator = $0', [differentiator]));
    });

    await realm2.subscriptions.waitForSynchronization();
    await realm2.syncSession.waitForDownload();

    final obj2 = realm2.all<ObjectWithEmbedded>().single;

    expect(obj2.recursiveObject!.value, '1.1');
    expect(obj2.recursiveObject!.child!.value, '2.1');
    expect(obj2.recursiveObject!.children.length, 1);
    expect(obj2.recursiveObject!.children[0].value, '2.2');
    expect(obj2.recursiveList.length, 1);
    expect(obj2.recursiveList[0].value, '1.2');
    expect(obj2.recursiveList[0].child, isNull);
    expect(obj2.recursiveList[0].children, isEmpty);

    realm2.write(() {
      obj2.recursiveObject = null;
    });

    await realm2.syncSession.waitForUpload();
    await realm1.syncSession.waitForDownload();

    expect(obj1.recursiveObject, isNull);

    expect(realm1.allEmbedded<RecursiveEmbedded1>().length, 1);
    expect(realm1.allEmbedded<RecursiveEmbedded2>().length, 0);
  });

  for (final isDynamic in [true, false]) {
    Realm getDynamicRealm(Realm original) {
      if (isDynamic) {
        original.close();
        return getRealm(Configuration.local([]));
      }

      return original;
    }

    test('Dynamic embedded object can read properties when isDynamic=$isDynamic', () {
      final realm = getLocalRealm();

      realm.write(() {
        realm.add(ObjectWithEmbedded('123',
            recursiveObject:
                RecursiveEmbedded1('1.1', child: RecursiveEmbedded2('2.1', child: RecursiveEmbedded3('3.1')), children: [RecursiveEmbedded2('2.2')]),
            recursiveList: [RecursiveEmbedded1('1.2')]));
      });

      final dynamicRealm = getDynamicRealm(realm);
      final parent = dynamicRealm.dynamic.find('ObjectWithEmbedded', '123')!;

      // String API with casting
      final child11 = parent.dynamic.get<EmbeddedObject?>('recursiveObject')!;
      expect(child11.dynamic.get<String>('value'), '1.1');
      expect(child11.instanceSchema.name, 'RecursiveEmbedded1');
      expect(child11.instanceSchema.baseType, ObjectType.embedded);

      final list1 = parent.dynamic.getList<EmbeddedObject>('recursiveList');
      expect(list1.length, 1);
      expect(list1[0].dynamic.get<String>('value'), '1.2');
      expect(list1[0].instanceSchema.name, 'RecursiveEmbedded1');
      expect(list1[0].instanceSchema.baseType, ObjectType.embedded);

      final child21 = child11.dynamic.get<EmbeddedObject?>('child')!;
      expect(child21.dynamic.get<String>('value'), '2.1');
      expect(child21.instanceSchema.name, 'RecursiveEmbedded2');
      expect(child21.instanceSchema.baseType, ObjectType.embedded);

      final list2 = child11.dynamic.getList<EmbeddedObject>('children');
      expect(list2.length, 1);
      expect(list2[0].dynamic.get<String>('value'), '2.2');
      expect(list2[0].instanceSchema.name, 'RecursiveEmbedded2');
      expect(list2[0].instanceSchema.baseType, ObjectType.embedded);

      final child31 = child21.dynamic.get<EmbeddedObject?>('child')!;
      expect(child31.dynamic.get<String>('value'), '3.1');
      expect(child31.instanceSchema.name, 'RecursiveEmbedded3');
      expect(child31.instanceSchema.baseType, ObjectType.embedded);

      // String API without casting
      final genericChild11 = parent.dynamic.get('recursiveObject');
      expect(genericChild11 is EmbeddedObject, true);
      final castChild11 = genericChild11 as EmbeddedObject;
      expect(castChild11.dynamic.get<String>('value'), '1.1');

      final genericList1 = parent.dynamic.getList('recursiveList');
      expect(genericList1 is List<EmbeddedObject>, true);

      final castList1 = genericList1 as List<EmbeddedObject>;
      expect(castList1.length, 1);

      // Dynamic API
      dynamic dynamicParent = parent;
      dynamic dynamicChild11 = dynamicParent.recursiveObject;
      expect(dynamicChild11.value, '1.1');

      dynamic dynamicList1 = dynamicParent.recursiveList;
      expect(dynamicList1.length, 1);
      expect(dynamicList1[0].value, '1.2');

      dynamic dynamicChild21 = dynamicChild11.child;
      expect(dynamicChild21.value, '2.1');

      dynamic dynamicList2 = dynamicChild11.children;
      expect(dynamicList2.length, 1);
      expect(dynamicList2[0].value, '2.2');

      dynamic dynamicChild31 = dynamicChild21.child;
      expect(dynamicChild31.value, '3.1');
    });
  }

  test('Embedded object can be frozen', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123',
        recursiveList: [
          RecursiveEmbedded1('1.1'),
          RecursiveEmbedded1('1.2'),
        ],
        recursiveObject: RecursiveEmbedded1('1.3', child: RecursiveEmbedded2('2.3')));

    realm.write(() {
      realm.add(parent);
    });

    final frozenEmbedded = freezeObject(parent.recursiveObject!);
    expect(() => frozenEmbedded.changes, throws<RealmStateError>('Object is frozen and cannot emit changes'));
    expect(frozenEmbedded.isFrozen, true);
    expect(frozenEmbedded.value, '1.3');
    expect(frozenEmbedded.child!.isFrozen, true);
    expect(frozenEmbedded.child!.value, '2.3');

    expect(parent.isFrozen, false);

    realm.write(() {
      parent.recursiveObject!.value = '1.4';
    });

    expect(frozenEmbedded.value, '1.3');

    final frozenListElement = freezeObject(parent.recursiveList[0]);

    expect(frozenListElement.isFrozen, true);
    expect(parent.isFrozen, false);
    expect(parent.recursiveList.isFrozen, false);

    realm.write(() {
      parent.recursiveList[0].value = '99';
    });

    expect(frozenListElement.value, '1.1');
  });

  test('Embedded list can be frozen', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveList: [
      RecursiveEmbedded1('1.1'),
      RecursiveEmbedded1('1.2'),
    ]);

    realm.write(() {
      realm.add(parent);
    });

    final frozenList = freezeList(parent.recursiveList);
    expect(frozenList.isFrozen, true);
    expect(frozenList[0].isFrozen, true);
    expect(parent.isFrozen, false);

    realm.write(() {
      parent.recursiveList[0].value = '99';
    });

    expect(frozenList[0].value, '1.1');
  });

  test('Embedded results can be frozen', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveList: [
      RecursiveEmbedded1('1.1'),
      RecursiveEmbedded1('1.2'),
    ]);

    realm.write(() {
      realm.add(parent);
    });

    final frozenResults = freezeResults(parent.recursiveList.query('TRUEPREDICATE'));
    expect(frozenResults.isFrozen, true);
    expect(frozenResults[0].isFrozen, true);
    expect(parent.isFrozen, false);

    realm.write(() {
      parent.recursiveList[0].value = '99';
    });

    expect(frozenResults[0].value, '1.1');
  });

  Future<T> waitForNotification<T>(List<T> notifications) async {
    await waitForCondition(() => notifications.length == 1, retryDelay: Duration(milliseconds: 10));
    return notifications.removeAt(0);
  }

  test('Embedded object notifications', () async {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveObject: RecursiveEmbedded1('1.3', child: RecursiveEmbedded2('2.3')));

    realm.write(() {
      realm.add(parent);
    });

    final notifications = <RealmObjectChanges>[];
    final subscription = parent.recursiveObject!.changes.listen((event) {
      notifications.add(event);
    });

    // Initial notification
    await waitForNotification(notifications);

    realm.write(() {
      parent.recursiveObject!.value = '1.4';
    });

    var event = await waitForNotification(notifications);
    expect(event.properties, ['value']);

    realm.write(() {
      parent.recursiveObject!.child = null;
    });

    event = await waitForNotification(notifications);
    expect(event.properties, ['child']);

    realm.write(() {
      parent.recursiveObject = null;
    });

    event = await waitForNotification(notifications);
    expect(event.isDeleted, true);
    expect(event.properties, isEmpty);

    await subscription.cancel();
  });

  test('Embedded list notifications', () async {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveList: [
      RecursiveEmbedded1('1.1'),
    ]);

    realm.write(() {
      realm.add(parent);
    });

    final notifications = <RealmListChanges>[];
    final subscription = parent.recursiveList.changes.listen((event) {
      notifications.add(event);
    });

    // Initial notification
    await waitForNotification(notifications);

    realm.write(() {
      parent.recursiveList.add(RecursiveEmbedded1('1.2'));
    });

    var event = await waitForNotification(notifications);
    expect(event.inserted, [1]);

    realm.write(() {
      parent.recursiveList[0].value = '99';
    });

    event = await waitForNotification(notifications);
    expect(event.modified, [0]);

    realm.write(() {
      parent.recursiveList.removeAt(0);
    });

    event = await waitForNotification(notifications);
    expect(event.deleted, [0]);

    await subscription.cancel();
  });

  test('Embedded results notifications', () async {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveList: [
      RecursiveEmbedded1('1.1'),
    ]);

    realm.write(() {
      realm.add(parent);
    });

    final notifications = <RealmResultsChanges>[];
    final subscription = parent.recursiveList.query('TRUEPREDICATE').changes.listen((event) {
      notifications.add(event);
    });

    // Initial notification
    await waitForNotification(notifications);

    realm.write(() {
      parent.recursiveList.add(RecursiveEmbedded1('1.2'));
    });

    var event = await waitForNotification(notifications);
    expect(event.inserted, [1]);

    realm.write(() {
      parent.recursiveList[0].value = '99';
    });

    event = await waitForNotification(notifications);
    expect(event.modified, [0]);

    realm.write(() {
      parent.recursiveList.removeAt(0);
    });

    event = await waitForNotification(notifications);
    expect(event.deleted, [0]);

    await subscription.cancel();
  });
}

extension on RealmObjectBase {
  SchemaObject get instanceSchema => (accessor as RealmCoreAccessor).metadata.schema;
}
