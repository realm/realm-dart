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

import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:ejson/ejson.dart';

import 'package:test/expect.dart' hide throws;

import '../lib/realm.dart';
import 'test.dart';

part 'backlinks_test.realm.dart';
part 'backlinks_test.g.dart';

@RealmModel()
class _Source {
  String name = 'source';
  @MapTo('et mål') // to throw a curve ball..
  _Target? oneTarget;
  late List<_Target> manyTargets;
}

@RealmModel()
class _Target {
  @Backlink(#oneTarget)
  late Iterable<_Source> oneToMany;

  String name = 'target';

  @Backlink(#manyTargets)
  late Iterable<_Source> manyToMany;
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Backlinks empty', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final target = realm.write(() => realm.add(Target()));

    expect(target.oneToMany, isEmpty);
  });

  test('Backlink property getter throws for unmanaged objects', () {
    final target = Target();
    expect(() => target.oneToMany, throws<RealmError>("Using backlinks is only possible for managed objects."));
    expect(() => target.manyToMany, throws<RealmError>("Using backlinks is only possible for managed objects."));
  });

  test('Backlinks 1-1(ish)', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final target = Target();
    final source = realm.write(() => realm.add(Source(oneTarget: target)));

    expect(source.oneTarget, target);
    expect(target.oneToMany, [source]);
  });

  test('Backlinks 1-many', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final target = Target();
    final sources = List.generate(100, (i) => Source(oneTarget: target, name: '$i'));
    realm.write(() => realm.addAll(sources));

    expect(target.oneToMany, sources);
  });

  test('Backlinks many-many', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final targets = List.generate(100, (i) => Target(name: '$i'));
    final sources = List.generate(100, (i) => Source(manyTargets: targets));

    realm.write(() => realm.addAll(sources));

    for (final t in targets) {
      expect(t.manyToMany, sources);
    }

    for (final s in sources) {
      expect(s.manyTargets, targets);
    }
  });

  test('Backlinks query', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final target = Target();
    final sources = List.generate(100, (i) => Source(oneTarget: target, name: '$i'));
    realm.write(() => realm.addAll(sources));

    final fortyTwo = realm.query<Source>(r'name == $0', ['42']).single;
    expect(target.oneToMany[42], fortyTwo);
    expect(target.oneToMany.query(r'name = $0', ['42']), [fortyTwo]);
  });

  test('Backlinks notifications', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final target = realm.write(() => realm.add(Target()));

    expectLater(
        target.oneToMany.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', <int>[]),
          isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', [0]),
          isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', [1]),
          isA<RealmResultsChanges<Source>>() //
              .having((ch) => ch.inserted, 'inserted', [0, 2]) // is this surprising?
              .having((ch) => ch.deleted, 'deleted', [0]) //
              .having((ch) => ch.modified, 'modified', [1]),
        ]));

    final first = realm.write(() => realm.add(Source(oneTarget: target)));

    final second = realm.write(() => realm.add(Source(oneTarget: target)));

    realm.write(() {
      realm.add(Source(oneTarget: target));
      realm.add(Source(oneTarget: target));
      second.name = "changed second";
      realm.delete(first);
    });
  });

  test('Backlinks read properties', () {
    final config = Configuration.local([Target.schema, Source.schema]);
    final realm = getRealm(config);

    final theOne = Target(name: 'the one');
    final targets = List.generate(100, (i) => Target(name: 'T$i'));
    final sources = List.generate(100, (i) => Source(name: 'S$i', manyTargets: targets, oneTarget: theOne));

    realm.write(() {
      realm.addAll(sources);
      realm.addAll(targets);
      realm.add(theOne);
    });

    expect(theOne.oneToMany[0].name, 'S0');
    expect(theOne.oneToMany.map((s) => s.name), sources.map((s) => s.name));

    for (final t in targets) {
      expect(t.manyToMany.map((s) => s.name), sources.map((s) => s.name));
    }

    for (final s in sources) {
      expect(s.manyTargets.map((t) => t.name), targets.map((t) => t.name));
    }
  });
}
