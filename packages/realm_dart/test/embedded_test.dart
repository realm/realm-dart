// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';
// This is required to be able to use the API for querying embedded objects.
import 'package:realm_dart/src/realm_class.dart' show RealmInternal;
import 'package:realm_dart/src/realm_object.dart';

import 'test.dart';

void main() {
  setupTests();

  Realm getLocalRealm() {
    final config = Configuration.local(
        [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    return getRealm(config);
  }

  test('Local Realm with orphan embedded schemas works', () {
    final config = Configuration.local([AllTypesEmbedded.schema]);
    final realm = getRealm(config);
    realm.close();

    final dynamicRealm = getRealm(Configuration.local([], path: config.path));

    final schema = dynamicRealm.schema;
    expect(schema.single.baseType, ObjectType.embeddedObject);
  });

  test('Embedded object roundtrip', () {
    final realm = getLocalRealm();

    final now = DateTime.now();
    final oid = ObjectId();
    final uuid = Uuid.v4();
    realm.write(() {
      realm.add(ObjectWithEmbedded('abc', singleObject: AllTypesEmbedded('str', true, now, 1.23, oid, uuid, 99, Decimal128.ten)));
    });

    final obj = realm.all<ObjectWithEmbedded>().single;
    final json = obj.toJson();

    expect(json, contains('"stringProp":"str"'));
    expect(json, contains('"boolProp":true'));
    expect(json, contains('"dateProp":"${now.toCoreTimestampString()}"'));
    expect(json, contains('"doubleProp":1.23'));
    expect(json, contains('"objectIdProp":"$oid"'));
    expect(json, contains('"uuidProp":"$uuid"'));
    expect(json, contains('"intProp":99'));
    expect(json, contains('"decimalProp":"10"')); // note the quotes!

    expect(json, contains('"nullableStringProp":null'));
    expect(json, contains('"nullableBoolProp":null'));
    expect(json, contains('"nullableDateProp":null'));
    expect(json, contains('"nullableDoubleProp":null'));
    expect(json, contains('"nullableObjectIdProp":null'));
    expect(json, contains('"nullableUuidProp":null'));
    expect(json, contains('"nullableIntProp":null'));
    expect(json, contains('"nullableDecimalProp":null'));
  });

  test('Embedded object get/set properties', () {
    final config = Configuration.local(
        [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    final realm = getRealm(config);

    final graph = ObjectWithEmbedded('TopLevel1',
        recursiveObject: RecursiveEmbedded1('Child1', child: RecursiveEmbedded2('Child2'), children: [
          RecursiveEmbedded2('List1', child: RecursiveEmbedded3('Child3'), realmObject: ObjectWithEmbedded('TopLeve2')),
          RecursiveEmbedded2('List2'),
        ]));

    // Make a cycle
    graph.recursiveObject!.child!.realmObject = graph;
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
    expect(child1.realmObject, isNull);

    final child2 = child1.child;
    expect(child2, isNotNull);
    expect(child2!.isManaged, true);
    expect(child2.value, 'Child2');
    expect(child2.realmObject, refetched);
    expect(child2.child, isNull);
    expect(child2.children, isEmpty);

    final listChild1 = child1.children[0];
    expect(listChild1.isManaged, true);
    expect(listChild1.value, 'List1');
    expect(listChild1.child!.value, 'Child3');
    expect(listChild1.realmObject!.id, 'TopLeve2');

    final listChild2 = child1.children[1];
    expect(listChild2.isManaged, true);
    expect(listChild2.value, 'List2');
    expect(listChild2.child, isNull);
  });

  test('Embedded object when replaced invalidates old object', () {
    final realm = getLocalRealm();
    final realmObject = realm.write(() {
      return realm.add(ObjectWithEmbedded('', recursiveObject: RecursiveEmbedded1('first')));
    });

    final firstEmbeded = realmObject.recursiveObject!;
    expect(firstEmbeded.isManaged, true);
    expect(firstEmbeded.isValid, true);
    expect(firstEmbeded.value, 'first');

    realm.write(() {
      realmObject.recursiveObject = RecursiveEmbedded1('second');
    });

    // We replaced firstEmbedded with another one, so we expect it to be invalid
    expect(firstEmbeded.isManaged, true);
    expect(firstEmbeded.isValid, false);

    final secondEmbedded = realmObject.recursiveObject!;
    expect(secondEmbedded.value, 'second');

    realm.write(() {
      realmObject.recursiveObject = null;
    });

    // We replaced secondEmbedded with null, so we expect it to be invalid
    expect(secondEmbedded.isManaged, true);
    expect(secondEmbedded.isValid, false);

    expect(realmObject.recursiveObject, isNull);
  });

  test('Embedded object in list when replaced invalidates old object', () {
    final realm = getLocalRealm();
    final realmObject = realm.write(() {
      return realm.add(ObjectWithEmbedded('', recursiveList: [RecursiveEmbedded1('first'), RecursiveEmbedded1('second'), RecursiveEmbedded1('third')]));
    });

    final list = realmObject.recursiveList;

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
        recursiveObject: RecursiveEmbedded1('embedded 456', realmObject: ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('value')])));

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
      expect(child11.instanceSchema.baseType, ObjectType.embeddedObject);

      final list1 = parent.dynamic.getList<EmbeddedObject>('recursiveList');
      expect(list1.length, 1);
      expect(list1[0].dynamic.get<String>('value'), '1.2');
      expect(list1[0].instanceSchema.name, 'RecursiveEmbedded1');
      expect(list1[0].instanceSchema.baseType, ObjectType.embeddedObject);

      final child21 = child11.dynamic.get<EmbeddedObject?>('child')!;
      expect(child21.dynamic.get<String>('value'), '2.1');
      expect(child21.instanceSchema.name, 'RecursiveEmbedded2');
      expect(child21.instanceSchema.baseType, ObjectType.embeddedObject);

      final list2 = child11.dynamic.getList<EmbeddedObject>('children');
      expect(list2.length, 1);
      expect(list2[0].dynamic.get<String>('value'), '2.2');
      expect(list2[0].instanceSchema.name, 'RecursiveEmbedded2');
      expect(list2[0].instanceSchema.baseType, ObjectType.embeddedObject);

      final child31 = child21.dynamic.get<EmbeddedObject?>('child')!;
      expect(child31.dynamic.get<String>('value'), '3.1');
      expect(child31.instanceSchema.name, 'RecursiveEmbedded3');
      expect(child31.instanceSchema.baseType, ObjectType.embeddedObject);

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

    realm.write(() {
      parent.recursiveList.clear();
    });

    event = await waitForNotification(notifications);
    expect(event.isCleared, true);

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

  test('EmbeddedObject.equals returns expected results', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveObject: RecursiveEmbedded1('1.1'), recursiveList: [RecursiveEmbedded1('1.1')]);
    realm.write(() {
      realm.add(parent);
    });

    expect(parent.recursiveObject, parent.recursiveObject);
    expect(identical(parent.recursiveObject, parent.recursiveObject), false);

    expect(parent.recursiveObject, isNot(RecursiveEmbedded1('1.1')));
    expect(parent.recursiveObject, isNot(parent.recursiveList[0]));
    expect(parent.recursiveObject, isNot(parent));
  });

  test('Realm.delete deletes embedded object', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveObject: RecursiveEmbedded1('1'), recursiveList: [RecursiveEmbedded1('2')]);
    realm.write(() {
      realm.add(parent);
    });

    final allEmbedded = realm.allEmbedded<RecursiveEmbedded1>();
    expect(allEmbedded.length, 2);

    realm.write(() {
      realm.delete(parent.recursiveList[0]);
    });

    expect(parent.recursiveList, isEmpty);
    expect(allEmbedded.length, 1);
    expect(allEmbedded.single.value, '1');

    realm.write(() {
      realm.delete(parent.recursiveObject!);
    });

    expect(parent.recursiveObject, isNull);
    expect(allEmbedded, isEmpty);
  });

  test('List.clear deletes all embedded objects', () {
    final realm = getLocalRealm();

    final parent = ObjectWithEmbedded('123', recursiveList: [RecursiveEmbedded1('1'), RecursiveEmbedded1('2')]);

    realm.write(() => realm.add(parent));

    final allEmbedded = realm.allEmbedded<RecursiveEmbedded1>();
    expect(allEmbedded.length, 2);

    realm.write(() {
      parent.recursiveList.clear();
    });

    expect(parent.recursiveList, isEmpty);
  });

  test('EmbeddedObject.getParent returns parent', () async {
    final realm = getLocalRealm();

    final parent =
        ObjectWithEmbedded('123', recursiveObject: RecursiveEmbedded1('1.1', child: RecursiveEmbedded2('2.1')), recursiveList: [RecursiveEmbedded1('1.2')]);

    realm.write(() {
      realm.add(parent);
    });

    final child1 = parent.recursiveObject!;

    expect(child1.parent, parent);
    expect(child1.child!.parent, child1);

    expect(parent.recursiveList[0].parent, parent);
  });

  test('EmbeddedObject.getParent when unmanaged returns null', () async {
    final parent =
        ObjectWithEmbedded('123', recursiveObject: RecursiveEmbedded1('1.1', child: RecursiveEmbedded2('2.1')), recursiveList: [RecursiveEmbedded1('1.2')]);

    final child1 = parent.recursiveObject!;

    expect(child1.parent, null);
    expect(child1.child!.parent, null);

    expect(parent.recursiveList[0].parent, null);
  });

  test('Query embedded objects list with list argument with different type of values', () {
    final realm = getLocalRealm();
    final realmObject = realm.write(() {
      return realm.add(ObjectWithEmbedded('', list: [
        AllTypesEmbedded('text1', false, DateTime.now(), 1.1, ObjectId(), Uuid.v4(), 1, Decimal128.one, nullableDecimalProp: Decimal128.fromDouble(3.3)),
        AllTypesEmbedded('text2', true, DateTime.now(), 2.2, ObjectId(), Uuid.v4(), 2, Decimal128.ten),
        AllTypesEmbedded('text3', true, DateTime.now(), 3.3, ObjectId(), Uuid.v4(), 3, Decimal128.infinity),
      ]));
    });
    final results = realmObject.list.query(r"nullableDecimalProp IN $0 || stringProp IN $0", [
      ['text1', null, 2.2, 3] // Searching by different type of values and null
    ]);
    expect(results.length, 3);
  }, skip: true);
}

extension on RealmObjectBase {
  SchemaObject get instanceSchema => (accessor as RealmCoreAccessor).metadata.schema;
}
