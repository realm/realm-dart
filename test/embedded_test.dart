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

// ignore_for_file: unused_local_variable

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('local Realm with orphan embedded schemas works', () {
    final config = Configuration.local([AllTypesEmbedded.schema]);
    final realm = getRealm(config);
    realm.close();

    final dynamicRealm = getRealm(Configuration.local([], path: config.path));

    final schema = dynamicRealm.schema;
    expect(schema.values.single.baseType, ObjectType.embedded);
  });

  baasTest('synchronized Realm with orphan embedded schemas throws', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [AllTypesEmbedded.schema]);

    expect(() => getRealm(config), throws<RealmException>("Embedded object 'AllTypesEmbedded' is unreachable by any link path from top level objects"));
  });

  test('Embedded object roundtrip', () {
    final config = Configuration.local(
        [AllTypesEmbedded.schema, ObjectWithEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);
    final realm = getRealm(config);

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
    expect(refetched.value, 'TopLevel1');

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
    expect(listChild1.topLevel!.value, 'TopLeve2');

    final listChild2 = child1.children[1];
    expect(listChild2.isManaged, true);
    expect(listChild2.value, 'List2');
    expect(listChild2.child, isNull);
  });
}
