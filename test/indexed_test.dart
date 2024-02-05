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

import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'package:test/test.dart' hide test, throws;
import 'test.dart';

import 'package:realm_dart/realm.dart';

part 'indexed_test.g.dart';

// Don't import our own test.dart here. It will break AOT compilation.
// We may use AOT compilation locally to manually run the performance
// tests in this file

@RealmModel()
class _WithIndexes {
  @Indexed()
  late int anInt;

  @Indexed()
  late bool aBool;

  @Indexed()
  late String string;

  @Indexed()
  late DateTime timestamp;

  @Indexed()
  late ObjectId objectId;

  @Indexed()
  late Uuid uuid;
}

@RealmModel()
class _NoIndexes {
  late int anInt;
  late bool aBool;
  late String string;
  late DateTime timestamp;
  late ObjectId objectId;
  late Uuid uuid;
}

@RealmModel()
class _ObjectWithFTSIndex {
  late String title;

  @Indexed(RealmIndexType.fullText)
  late String summary;

  @Indexed(RealmIndexType.fullText)
  late String? nullableSummary;
}

class FtsTestData {
  final String query;
  final Set<String> expectedResults;

  FtsTestData(this.query, this.expectedResults);
}

const String animalFarm = 'Animal Farm';
const String lordOfTheRings = 'The Lord of the Rings';
const String lordOfTheFlies = 'Lord of the Flies';
const String wheelOfTime = 'The Wheel of Time';
const String silmarillion = 'The Silmarillion';

@RealmModel()
class _ParentWithFts {
  @Indexed(RealmIndexType.fullText)
  late String name;
  List<_EmbeddedWithFts> embedded = [];
}

@RealmModel(ObjectType.embeddedObject)
class _EmbeddedWithFts {
  @Indexed(RealmIndexType.fullText)
  late String nameSingular;
  @Indexed(RealmIndexType.fullText)
  late String namePlural;
}

void main() {
  setupTests();

  intFactory(int i) => i.hashCode;
  boolFactory(int i) => i % 2 == 0;
  stringFactory(int i) => '${i.hashCode} $i';
  timestampFactory(int i) => DateTime.fromMillisecondsSinceEpoch(i.hashCode);
  objectIdFactory(int i) => ObjectId.fromValues(i.hashCode * 1000000, i.hashCode, i);
  uuidFactory(int i) => Uuid.fromBytes(Uint8List(16).buffer..asByteData().setInt64(0, i.hashCode));

  // skip timestamp for now, as timestamps are not indexed properly it seems
  final indexedTestData = [
    (name: 'anInt', factory: intFactory),
    (name: 'string', factory: stringFactory),
    (name: 'objectId', factory: objectIdFactory),
    (name: 'uuid', factory: uuidFactory)
  ];

  for (final testCase in indexedTestData) {
    test('Indexed faster: ${testCase.name}', () {
      final config = Configuration.local([WithIndexes.schema, NoIndexes.schema]);
      final realm = getRealm(config);
      const max = 10000;
      final allIndexed = realm.all<WithIndexes>();
      final allNotIndexed = realm.all<NoIndexes>();
      expect(allIndexed.length, 0);
      expect(allNotIndexed.length, 0);

      final indexed = List.generate(
        max,
        (i) => WithIndexes(
          intFactory(i),
          boolFactory(i),
          stringFactory(i),
          timestampFactory(i),
          objectIdFactory(i),
          uuidFactory(i),
        ),
      );
      realm.write(() => realm.addAll(indexed));

      expect(allIndexed.length, max);

      final notIndexed = List.generate(
        max,
        (i) => NoIndexes(
          intFactory(i),
          boolFactory(i),
          stringFactory(i),
          timestampFactory(i),
          objectIdFactory(i),
          uuidFactory(i),
        ),
      );
      realm.write(() => realm.addAll(notIndexed));

      expect(allNotIndexed.length, max);

      // Inefficient, but fast enough for this test
      final halfMax = max ~/ 2;
      final searchOrder = (List.generate(halfMax, (i) => halfMax + i)..shuffle(Random(42))).map((i) => testCase.factory(i)).take(1000).toList();

      @pragma('vm:no-interrupts')
      Duration measureSpeed<T extends RealmObject>(RealmResults<T> results) {
        final queries = searchOrder.map((v) => results.query('${testCase.name} == \$0', [v])).toList(); // pre-calculate queries
        final found = <T?>[];

        final sw = Stopwatch()..start();
        for (final q in queries) {
          found.add(q.single); // evaluate query
        }
        final timing = sw.elapsed;

        // check that we found the right objects
        for (final f in found) {
          expect(f, isNotNull);
        }

        return timing;
      }

      final lookupCount = searchOrder.length;

      display(Type type, Duration duration) {
        print('$lookupCount lookups of ${'$type'.padRight(12)} on ${testCase.name.padRight(10)} : ${duration.inMicroseconds ~/ lookupCount} us/lookup');
      }

      final indexedTime = measureSpeed(allIndexed);
      final notIndexedTime = measureSpeed(allNotIndexed);
      try {
        expect(indexedTime, lessThan(notIndexedTime)); // indexed should be faster
      } catch (_) {
        display(WithIndexes, indexedTime); // only display if test fails
        display(NoIndexes, notIndexedTime);
        rethrow; // rethrow to fail test
      }
    });
  }

  final testCases = [
    FtsTestData('lord of the', <String>{lordOfTheFlies, lordOfTheRings, wheelOfTime, silmarillion}),
    FtsTestData('fantasy novel', <String>{lordOfTheRings, wheelOfTime}),
    FtsTestData('popular english', <String>{lordOfTheFlies, silmarillion}),
    FtsTestData('amazing awesome stuff', <String>{}),
    FtsTestData('fantasy -novel', <String>{silmarillion}),
  ];

  Realm setupFtsTest() {
    final config = Configuration.local([ObjectWithFTSIndex.schema]);
    final realm = getRealm(config);

    ObjectWithFTSIndex addObject(String title, String summary) {
      final value = realm.add(ObjectWithFTSIndex(title, summary));
      value.nullableSummary = summary;
      return value;
    }

    realm.write(() {
      final objectWithDefaults = addObject('N/A', '');
      objectWithDefaults.nullableSummary = null;

      addObject(animalFarm,
          'Animal Farm is a beast fable, in the form of a satirical allegorical novella, by George Orwell, first published in England on 17 August 1945. It tells the story of a group of farm animals who rebel against their human farmer, hoping to create a society where the animals can be equal, free, and happy. Ultimately, the rebellion is betrayed, and under the dictatorship of a pig named Napoleon, the farm ends up in a state as bad as it was before. According to Orwell, Animal Farm reflects events leading up to the Russian Revolution of 1917 and then on into the Stalinist era of the Soviet Union. Orwell, a democratic socialist, was a critic of Joseph Stalin and hostile to Moscow-directed Stalinism, an attitude that was critically shaped by his experiences during the Barcelona May Days conflicts between the POUM and Stalinist forces during the Spanish Civil War. In a letter to Yvonne Davet, Orwell described Animal Farm as a satirical tale against Stalin ("un conte satirique contre Staline"), and in his essay "Why I Write" (1946), wrote that Animal Farm was the first book in which he tried, with full consciousness of what he was doing, "to fuse political purpose and artistic purpose into one whole". The original title was Animal Farm: A Fairy Story, but US publishers dropped the subtitle when it was published in 1946, and only one of the translations during Orwell\'s lifetime, the Telugu version, kept it. Other titular variations include subtitles like "A Satire" and "A Contemporary Satire". Orwell suggested the title Union des républiques socialistes animales for the French translation, which abbreviates to URSA, the Latin word for "bear", a symbol of Russia. It also played on the French name of the Soviet Union, Union des républiques socialistes soviétiques. Orwell wrote the book between November 1943 and February 1944, when the United Kingdom was in its wartime alliance with the Soviet Union against Nazi Germany, and the British intelligentsia held Stalin in high esteem, a phenomenon Orwell hated. The manuscript was initially rejected by several British and American publishers, including one of Orwell\'s own, Victor Gollancz, which delayed its publication. It became a great commercial success when it did appear partly because international relations were transformed as the wartime alliance gave way to the Cold War. Time magazine chose the book as one of the 100 best English-language novels (1923 to 2005); it also featured at number 31 on the Modern Library List of Best 20th-Century Novels, and number 46 on the BBC\'s The Big Read poll. It won a Retrospective Hugo Award in 1996 and is included in the Great Books of the Western World selection.');
      addObject(lordOfTheRings,
          "The Lord of the Rings is an epic high-fantasy novel by English author and scholar J. R. R. Tolkien. Set in Middle-earth, the story began as a sequel to Tolkien's 1937 children's book The Hobbit, but eventually developed into a much larger work. Written in stages between 1937 and 1949, The Lord of the Rings is one of the best-selling books ever written, with over 150 million copies sold. The title refers to the story's main antagonist, the Dark Lord Sauron, who, in an earlier age, created the One Ring to rule the other Rings of Power given to Men, Dwarves, and Elves, in his campaign to conquer all of Middle-earth. From homely beginnings in the Shire, a hobbit land reminiscent of the English countryside, the story ranges across Middle-earth, following the quest to destroy the One Ring, seen mainly through the eyes of the hobbits Frodo, Sam, Merry and Pippin. Although often called a trilogy, the work was intended by Tolkien to be one volume of a two-volume set along with The Silmarillion. For economic reasons, The Lord of the Rings was published over the course of a year from 29 July 1954 to 20 October 1955 in three volumes titled The Fellowship of the Ring, The Two Towers, and The Return of the King. The work is divided internally into six books, two per volume, with several appendices of background material. Some later editions print the entire work in a single volume, following the author's original intent. Tolkien's work, after an initially mixed reception by the literary establishment, has been the subject of extensive analysis of its themes and origins. Influences on this earlier work, and on the story of The Lord of the Rings, include philology, mythology, Christianity, earlier fantasy works, and his own experiences in the First World War.");
      addObject(lordOfTheFlies,
          "Lord of the Flies is a 1954 novel by the Nobel Prize-winning British author William Golding. The plot concerns a group of British boys who are stranded on an uninhabited island and their disastrous attempts to govern themselves. Themes include the tension between groupthink and individuality, between rational and emotional reactions, and between morality and immorality. The novel, which was Golding's debut, was generally well received. It was named in the Modern Library 100 Best Novels, reaching number 41 on the editor's list, and 25 on the reader's list. In 2003, it was listed at number 70 on the BBC's The Big Read poll, and in 2005 Time magazine named it as one of the 100 best English-language novels published between 1923 and 2005, and included it in its list of the 100 Best Young-Adult Books of All Time. Popular reading in schools, especially in the English-speaking world, Lord of the Flies was ranked third in the nation's favourite books from school in a 2016 UK poll.");
      addObject(wheelOfTime,
          "The Wheel of Time is a series of high fantasy novels by American author Robert Jordan, with Brandon Sanderson as a co-author for the final three novels. Originally planned as a six-book series at its debut in 1990, The Wheel of Time came to span 14 volumes, in addition to a prequel novel and two companion books. Jordan died in 2007 while working on what was planned to be the final volume in the series. He prepared extensive notes which enabled fellow fantasy author Brandon Sanderson to complete the final book, which grew into three volumes: The Gathering Storm (2009), Towers of Midnight (2010), and A Memory of Light (2013). The series draws on numerous elements of both European and Asian mythology, most notably the cyclical nature of time found in Buddhism and Hinduism; the metaphysical concepts of balance, duality, and a respect for nature found in Taoism; the Abrahamic concepts of God and Satan; and Leo Tolstoy's War and Peace. The Wheel of Time is notable for its length, detailed imaginary world, and magic system, and its large cast of characters. The eighth through fourteenth books each reached number one on the New York Times Best Seller list. After its completion, the series was nominated for a Hugo Award. As of 2021, the series has sold over 90 million copies worldwide, making it one of the best-selling epic fantasy series since The Lord of the Rings. Its popularity has spawned a collectible card game, a video game, a roleplaying game, and a soundtrack album. A TV series adaptation produced by Sony Pictures and Amazon Studios premiered in 2021.The Wheel of Time is a series of high fantasy novels by American author Robert Jordan, with Brandon Sanderson as a co-author for the final three novels. Originally planned as a six-book series at its debut in 1990, The Wheel of Time came to span 14 volumes, in addition to a prequel novel and two companion books. Jordan died in 2007 while working on what was planned to be the final volume in the series. He prepared extensive notes which enabled fellow fantasy author Brandon Sanderson to complete the final book, which grew into three volumes: The Gathering Storm (2009), Towers of Midnight (2010), and A Memory of Light (2013). The series draws on numerous elements of both European and Asian mythology, most notably the cyclical nature of time found in Buddhism and Hinduism; the metaphysical concepts of balance, duality, and a respect for nature found in Taoism; the Abrahamic concepts of God and Satan; and Leo Tolstoy's War and Peace. The Wheel of Time is notable for its length, detailed imaginary world, and magic system, and its large cast of characters. The eighth through fourteenth books each reached number one on the New York Times Best Seller list. After its completion, the series was nominated for a Hugo Award. As of 2021, the series has sold over 90 million copies worldwide, making it one of the best-selling epic fantasy series since The Lord of the Rings. Its popularity has spawned a collectible card game, a video game, a roleplaying game, and a soundtrack album. A TV series adaptation produced by Sony Pictures and Amazon Studios premiered in 2021. ");
      addObject(silmarillion,
          'The Silmarillion (Quenya: [silmaˈrilliɔn]) is a collection of myths and stories in varying styles by the English writer J. R. R. Tolkien. It was edited and published posthumously by his son Christopher Tolkien in 1977, assisted by the fantasy author Guy Gavriel Kay. It tells of Eä, a fictional universe that includes the Blessed Realm of Valinor, the once-great region of Beleriand, the sunken island of Númenor, and the continent of Middle-earth, where Tolkien\'s most popular works—The Hobbit and The Lord of the Rings—are set. The Silmarillion has five parts. The first, Ainulindalë, tells in mythic style of the creation of Eä, the "world that is." The second part, Valaquenta, gives a description of the Valar and Maiar, supernatural powers of Eä. The next section, Quenta Silmarillion, which forms the bulk of the collection, chronicles the history of the events before and during the First Age, including the wars over three jewels, the Silmarils, that gave the book its title. The fourth part, Akallabêth, relates the history of the Downfall of Númenor and its people, which takes place in the Second Age. The final part, Of the Rings of Power and the Third Age, is a brief summary of the events of The Lord of the Rings and those that led to them. The book shows the influence of many sources, including the Finnish epic Kalevala, Greek mythology in the lost island of Atlantis (as Númenor) and the Olympian gods (in the shape of the Valar, though these also resemble the Norse Æsir).');
    });

    return realm;
  }

  for (final testCase in testCases) {
    test('FTS simple term: ${testCase.query}', () {
      final realm = setupFtsTest();

      final summaryMatches = realm.query<ObjectWithFTSIndex>('summary TEXT \$0', [testCase.query]).map((o) => o.title);
      expect(summaryMatches, testCase.expectedResults);

      final nullableSummaryMatches = realm.query<ObjectWithFTSIndex>('nullableSummary TEXT \$0', [testCase.query]).map((o) => o.title);
      expect(nullableSummaryMatches, testCase.expectedResults);
    });
  }

  test('FTS simple term on non-indexed property', () {
    final realm = setupFtsTest();

    expect(() => realm.query<ObjectWithFTSIndex>('title TEXT \$0', ["lord"]), throws<RealmException>('Column has no fulltext index'));
  });

  group('FTS with prefix search on embedded objects', () {
    late Realm realm;
    setUpAll(() {
      final config = Configuration.local([ParentWithFts.schema, EmbeddedWithFts.schema]);
      realm = Realm(config);

      realm.write(() {
        realm.addAll([
          ParentWithFts('Object 1', embedded: [
            EmbeddedWithFts('salt', 'salt'),
            EmbeddedWithFts('pepper', 'pepper'),
          ]),
          ParentWithFts('Object 2', embedded: [
            EmbeddedWithFts('basil', 'basil'),
            EmbeddedWithFts('oregano', 'oregano'),
          ])
        ]);
      });
    });

    for (final searchTerm in [
      'sal*',
      'Object 2*',
      'basil*',
      'Object*',
      'doesnotexist*',
    ]) {
      test('search term: $searchTerm', () {
        expect(realm.query<ParentWithFts>(r"name TEXT $0 OR embedded.nameSingular TEXT $0 OR embedded.namePlural TEXT $0", [searchTerm]), isNotNull);
      });
    }
  });
}
