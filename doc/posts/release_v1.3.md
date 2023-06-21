# New release!

Today we are happy to announce the release of version 1.3.0 of Realm for Flutter and Dart. Since the v1.0.0 back in February we have added support for:
* Consolidated logging,
* Decimal128,
* Full Text Search, and
* Uint8List (binary),

as well as numerous minor features, tweaks, fixes and performance improvements. You can check the [CHANGELOG](https://github.com/realm/realm-dart/blob/release/1.3.0/CHANGELOG.md) for the full details. 

As always, the doc teams has done a commendable job of [documenting](https://www.mongodb.com/docs/realm/sdk/flutter/) the features, but lets briefly visit some highlights

## Dart 3 here we come..

This marks the first release that will only work with Dart 3 and later. It has been great to see how fast the community has moved to 3.0, and today we follow along. We are exited about the future of Dart and we are looking forward to embrace the upcoming support for static meta-programming.

## Consolidated logging

With realm-core v13.7.0 the way tracing is done has changed. This surfaced an issue with cross-isolate tracing in Dart, which was addressed in v1.1.0.

If you have experienced odd behavior when listening for trace in multiple isolates, you will appreciate these changes. As an example you can try running this sample:
```dart
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:realm_dart/realm.dart';

Future<void> main(List<String> arguments) async {
  Realm.logger.level = Level.ALL;
  Realm.logger.onRecord.listen((record) {
    print('root isolate: $record');
  });

  final isolate = await Isolate.spawn((_) {
    Realm.logger.level = Level.ALL;
    Realm.logger.onRecord.listen((record) {
      print('sub isolate: $record');
    });
  }, null);

  Realm(Configuration.local([]));

  await Future.delayed(const Duration(seconds: 1));
  isolate.kill();

  Realm.shutdown();
}
```
Now the output is:
```shell
root isolate: [DETAIL] Realm: DB: 50530 Thread 0x16e2bf000: Open file: /Users/kasper/Projects/mongodb/experiments/logger_ex/default.realm
sub isolate: [DETAIL] Realm: DB: 50530 Thread 0x16e2bf000: Open file: /Users/kasper/Projects/mongodb/experiments/logger_ex/default.realm
sub isolate: [DETAIL] Realm: DB: 50530 Thread 0x16de03000: DB closed
root isolate: [DETAIL] Realm: DB: 50530 Thread 0x16de03000: DB closed
```
ie. each isolate will receive the log messages from core and handle it independently.

## Decimal128

Customers has been requesting support for IEEE 754-2008 Decimal128 for a while, and support was finally released with v1.1.0.

This allows you to store, fetch, query and do basic arithmetics with Decimal128

Here is a quick example:
```dart
import 'package:realm_dart/realm.dart';
import 'package:test/test.dart';

part 'dec128_ex.g.dart';

@RealmModel()
class _Stuff {
  late Decimal128 value;
}

void main(List<String> arguments) {
  // The maximum value of long double in 64 bit precision is 1.8 x 10^308,
  // so let us use a bigger number
  final big = Decimal128.parse('1e310');
  final two = Decimal128.fromInt(2);

  test('double cannot', () {
    expect(1e310, double.infinity); // double can't ..
    expect(big, isNot(Decimal128.infinity)); // .. but Decimal128 can
  });

  test('storage', () {
    final realm = Realm(Configuration.inMemory([Stuff.schema]));
    realm.write(() => realm.add(Stuff(big)));
    expect(realm.all<Stuff>().first.value, big);
  });

  test('basic arithmetic', () {
    expect(big + big, Decimal128.parse('2e310'));
    expect(big - big, Decimal128.zero);
    expect(big * two, Decimal128.parse('2e310'));
    expect(big / two, Decimal128.parse('5e309'));
    expect(big / Decimal128.zero, Decimal128.infinity);
  });
}
```

## Full Text Search

Realm-core has supported full text search (FTS) in some form since v13. This was exposed for Dart with v1.2.0. Here is an example of how you might use it:

```dart
import 'package:realm_dart/realm.dart';

part 'fts_ex.g.dart';

@RealmModel()
class _Book {
  @Indexed(RealmIndexType.fullText)
  late String title;
}

void main(List<String> arguments) {
  final realm = Realm(Configuration.inMemory([Book.schema]));

  realm.write(() => realm.addAll([
        Book('Animal Farm'),
        Book('The Lord of the Rings'),
        Book('Lord of the Flies'),
        Book('The Wheel of Time'),
        Book('The Silmarillion'),
      ]));

  realm.query<Book>('title TEXT \$0', ['the']).forEach((e) => print(e.title));
  print('---');
  realm.query<Book>('title TEXT \$0', ['of']).forEach((e) => print(e.title));
  print('---');
  realm.query<Book>('title TEXT \$0', ['farm']).forEach((e) => print(e.title));

  Realm.shutdown();
}
```
outputs:
```shell
The Lord of the Rings
Lord of the Flies
The Wheel of Time
The Silmarillion
---
The Lord of the Rings
Lord of the Flies
The Wheel of Time
---
Animal Farm
```

## Uint8List (binary)

Another datatype previously missing from the Flutter and Dart SDKs was raw binary. With version 1.3.0 you can now store `Uint8List`s in realms as well:

```dart
import 'dart:typed_data';

import 'package:realm_dart/realm.dart';

part 'bin_ex.g.dart';

@RealmModel()
class _Stuff {
  late Uint8List bytes;
}

void main(List<String> arguments) {
  final realm = Realm(Configuration.inMemory([Stuff.schema]));
  final stuff = Stuff(Uint8List.fromList([1, 2, 3]));
  realm.write(() => realm.add(stuff));
  realm.all<Stuff>().forEach((e) => print(e.bytes));
  Realm.shutdown();
}
```
outputs:
```shell
[1, 2, 3]
```

## Coming up ..

We are hard at work, adding support for EJson, Geo-spatial queries, aggregated queries, etc. so stay tuned until next time. Enjoy the summer (or winter) where ever you are.


