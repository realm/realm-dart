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

import 'package:realm_dart/realm.dart';
import 'test.dart';

part 'backlinks_test.realm.dart';

@RealmModel()
class _Source {
  String name = 'source';
  @MapTo('et mål') // to throw a curve ball..
  _Target? oneTarget;
  late List<_Target> manyTargets;

  // These are the same as the properties above, but don't have defined backlinks
  // on Target
  @MapTo('dynamisk mål')
  _Target? dynamicTarget;
  late List<_Target> dynamicManyTargets;
}

@RealmModel()
class _Target {
  @Backlink(#oneTarget)
  late Iterable<_Source> oneToMany;

  String name = 'target';

  @Backlink(#manyTargets)
  late Iterable<_Source> manyToMany;

  _Source? source;
}

void main() {
  setupTests();

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
              // Backlinks don't have a natural order - removing the element at 0, then adding a new one will
              // appear like the new one was added at position 0.
              .having((ch) => ch.inserted, 'inserted', [0, 2]) //
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

  group('getBacklinks() tests', () {
    (Target theOne, List<Target> targets, Iterable<String> expectedSources) populateData() {
      final config = Configuration.local([Target.schema, Source.schema]);
      final realm = getRealm(config);

      final theOne = Target(name: 'the one');
      final targets = List.generate(100, (i) => Target(name: 'T$i'));
      final sources = List.generate(100, (i) {
        return i % 2 == 0
            ? Source(name: 'TargetLessSource$i')
            : Source(name: 'S$i', manyTargets: targets, oneTarget: theOne, dynamicManyTargets: targets, dynamicTarget: theOne);
      });

      final expectedSources = sources.where((e) => e.name.startsWith('S')).map((e) => e.name);

      realm.write(() {
        realm.addAll(sources);
        realm.addAll(targets);
        realm.add(theOne);
      });

      return (theOne, targets, expectedSources);
    }

    test('pointing to a valid property', () {
      final (theOne, targets, expectedSources) = populateData();

      // getBacklinks should work with both the public and the @MapTo property names
      expect(theOne.getBacklinks<Source>('oneTarget').map((s) => s.name), expectedSources);
      expect(theOne.getBacklinks<Source>('et mål').map((s) => s.name), expectedSources);

      expect(theOne.getBacklinks<Source>('dynamicTarget').map((s) => s.name), expectedSources);
      expect(theOne.getBacklinks<Source>('dynamisk mål').map((s) => s.name), expectedSources);

      for (final t in targets) {
        expect(t.getBacklinks<Source>('manyTargets').map((s) => s.name), expectedSources);
        expect(t.getBacklinks<Source>('dynamicManyTargets').map((s) => s.name), expectedSources);
      }
    });

    test('notifications', () {
      final config = Configuration.local([Target.schema, Source.schema]);
      final realm = getRealm(config);

      final target = realm.write(() => realm.add(Target()));

      expectLater(
          target.getBacklinks<Source>('oneTarget').changes,
          emitsInOrder(<Matcher>[
            isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', <int>[]),
            isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', [0]),
            isA<RealmResultsChanges<Source>>().having((ch) => ch.inserted, 'inserted', [1]),
            isA<RealmResultsChanges<Source>>() //
                // Backlinks don't have a natural order - removing the element at 0, then adding a new one will
                // appear like the new one was added at position 0.
                .having((ch) => ch.inserted, 'inserted', [0, 2]) //
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

    test('pointing to a non-existent property throws', () {
      final (theOne, _, _) = populateData();

      expect(() => theOne.getBacklinks<Source>('foo'),
          throwsA(isA<RealmException>().having((p0) => p0.message, 'message', 'Property foo does not exist on class Source')));
    });

    test('on an unmanaged object throws', () {
      final theOne = Target(name: 'the one');
      expect(() => theOne.getBacklinks<Source>('oneTarget'),
          throwsA(isA<RealmStateError>().having((p0) => p0.message, 'message', "Can't look up backlinks of unmanaged objects.")));
    });

    test('on a deleted object throws', () {
      final (theOne, _, _) = populateData();
      theOne.realm.write(() => theOne.realm.delete(theOne));

      expect(theOne.isValid, false);
      expect(theOne.isManaged, true);

      expect(
          () => theOne.getBacklinks<Source>('oneTarget'),
          throwsA(
              isA<RealmException>().having((p0) => p0.message, 'message', contains("Accessing object of type Target which has been invalidated or deleted."))));
    });

    test('with a dynamic type argument throws', () {
      final (theOne, _, _) = populateData();
      expect(() => theOne.getBacklinks('oneTarget'),
          throwsA(isA<RealmError>().having((p0) => p0.message, 'message', contains("Object type dynamic not configured in the current Realm's schema."))));
    });

    test('with an invalid type argument throws', () {
      final (theOne, _, _) = populateData();
      expect(() => theOne.getBacklinks('oneTarget'),
          throwsA(isA<RealmError>().having((p0) => p0.message, 'message', contains("Object type dynamic not configured in the current Realm's schema."))));
    });

    test('pointing to a non-link property throws', () {
      final (theOne, _, _) = populateData();

      expect(
          () => theOne.getBacklinks<Source>('name'),
          throwsA(isA<RealmError>()
              .having((p0) => p0.message, 'message', 'Property Source.name is not a link property - it is a property of type RealmPropertyType.string')));
    });

    test('pointing to a link property of incorrect type throws', () {
      final (theOne, _, _) = populateData();

      expect(
          () => theOne.getBacklinks<Target>('source'),
          throwsA(isA<RealmError>().having((p0) => p0.message, 'message',
              'Property Target.source is a link property that links to Source which is different from the type of the current object, which is Target.')));
    });
  });
}
