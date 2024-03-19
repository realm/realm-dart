// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:realm_dart/src/logging.dart';
import 'package:realm_dart/src/native/realm_core.dart';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';
import 'test.dart';

final logToValues = RealmLogLevel.values.where((l) => ![RealmLogLevel.all, RealmLogLevel.off].contains(l));

void main() {
  setupTests();

  group('All levels', () {
    for (var level in RealmLogLevel.values) {
      test('Realm.logger supports log level $level', () {
        Realm.logger.setLogLevel(RealmLogLevel.off);
        Realm.logger.setLogLevel(RealmLogLevel.all, category: RealmLogCategory.realm.sdk);

        final tag = Uuid.v4();
        expectLater(
          Realm.logger.onRecord,
          emits((category: RealmLogCategory.realm.sdk, level: level, message: '$level $tag')),
        );
        Realm.logger.log(level, '$level $tag');
      });
    }
  });

  group('Match levels', () {
    for (var level in RealmLogLevel.values) {
      final expectedLevels = logToValues.where((l) => l.index >= level.index);
      test('$level matches $expectedLevels', () {
        Realm.logger.setLogLevel(RealmLogLevel.off);
        Realm.logger.setLogLevel(level, category: RealmLogCategory.realm.sdk);

        expectLater(Realm.logger.onRecord, emitsInOrder(expectedLevels.map((l) => isA<RealmLogRecord>().having((r) => r.level, '$l', l))));
        for (var sendLevel in logToValues) {
          Realm.logger.log(sendLevel, '$sendLevel');
        }
      });
    }
  });

  group('RealmLogCategory.contains', () {
    for (final outer in RealmLogCategory.values) {
      for (final inner in RealmLogCategory.values) {
        test('$outer contains $inner', () {
          expect(outer.contains(inner), inner.toString().startsWith(outer.toString()));
        });
      }
    }
  });

  test('Trace in subisolate seen in parent', () {
    Realm.logger.setLogLevel(RealmLogLevel.off);
    Realm.logger.setLogLevel(RealmLogLevel.all, category: RealmLogCategory.realm.sdk);

    expectLater(Realm.logger.onRecord, emits(isA<RealmLogRecord>().having((r) => r.message, 'message', 'Hey')));
    Isolate.run(() {
      Realm.logger.log(RealmLogLevel.trace, 'Hey');
    });
  });

  test('Trace in root isolate seen in subisolate', () async {
    Realm.logger.setLogLevel(RealmLogLevel.off);
    Realm.logger.setLogLevel(RealmLogLevel.all, category: RealmLogCategory.realm.sdk);

    final trace = Isolate.run(() async {
      return (await Realm.logger.onRecord.first).message;
    });
    await Future<void>.delayed(const Duration(milliseconds: 100)); // yield
    expectLater(trace, completion('Hey'));
    Realm.logger.log(RealmLogLevel.trace, 'Hey');
  });

  test('RealmLogger hookup logging', () async {
    Realm.logger.setLogLevel(RealmLogLevel.off);
    Realm.logger.setLogLevel(RealmLogLevel.all, category: RealmLogCategory.realm.sdk);

    final logger = Logger.detached('Test');
    final sub = Realm.logger.onRecord.listen((r) => logger.log(r.level.level, r.message));
    logger.level = Level.ALL;

    expectLater(logger.onRecord, emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')))
        .whenComplete(sub.cancel);

    Realm.logger.log(RealmLogLevel.error, 'error');
  });

  test('RealmLogger hookup hierarchical logging', () async {
    Realm.logger.setLogLevel(RealmLogLevel.off);
    Realm.logger.setLogLevel(RealmLogLevel.all, category: RealmLogCategory.realm.sdk);

    final old = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;

    final sub = Realm.logger.onRecord.listen((r) => Logger(r.category.toString()).log(r.level.level, r.message));
    Logger.root.level = Level.ALL;

    expectLater(Logger('Realm').onRecord, emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')));
    expectLater(
      Logger('Realm.SDK').onRecord,
      emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having(
            (r) => r.message,
            'message',
            'error',
          )),
    ).whenComplete(() {
      sub.cancel();
      hierarchicalLoggingEnabled = old;
    });

    Realm.logger.log(RealmLogLevel.error, 'error', category: RealmLogCategory.realm.sdk);
  });

  group('Category mapping', () {
    final nativeCategoryNames= realmCore.getAllCategoryNames();
    for (final name in nativeCategoryNames) {
      test('$name can parse', () {
        expect(() => RealmLogCategory.fromString(name), returnsNormally);
        final category = RealmLogCategory.fromString(name);
        expect(category, isA<RealmLogCategory>().having((c) => c.toString(), 'toString()', name));
      });
    }

    for(final category in RealmLogCategory.values) {
      test('$category known by native', () {
        expect(nativeCategoryNames, contains(category.toString()));
      });
    }
  });
}
