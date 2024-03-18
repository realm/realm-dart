// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:realm_dart/src/logging.dart';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';
import 'test.dart';

void main() {
  setupTests();

  group('All levels', () {
    Realm.logger.setLogLevel(RealmLogLevel.all);
    for (var level in RealmLogLevel.values) {
      test('Realm.logger supports log level $level', () {
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
      final expectedLevels = RealmLogLevel.logToValues.where((l) => l.index >= level.index);
      test('$level matches $expectedLevels', () {
        Realm.logger.setLogLevel(level);
        expectLater(Realm.logger.onRecord, emitsInOrder(expectedLevels.map((l) => isA<RealmLogRecord>().having((r) => r.level, '$l', l))));
        for (var sendLevel in RealmLogLevel.logToValues) {
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
    Realm.logger.setLogLevel(RealmLogLevel.all);
    expectLater(Realm.logger.onRecord, emits(isA<RealmLogRecord>().having((r) => r.message, 'message', 'Hey')));
    Isolate.run(() {
      Realm.logger.log(RealmLogLevel.trace, 'Hey');
    });
  });

  test('Trace in root isolate seen in subisolate', () async {
    Realm.logger.setLogLevel(RealmLogLevel.all);
    final trace = Isolate.run(() async {
      return (await Realm.logger.onRecord.first).message;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1)); // yield
    expectLater(trace, completion('Hey'));
    Realm.logger.log(RealmLogLevel.trace, 'Hey');
  });

  test('RealmLogger hookup logging', () async {
    final logger = Logger.detached('Test');
    Realm.logger.onRecord.forEach((r) => logger.log(r.level.level, r.message));
    logger.level = Level.ALL;
    Realm.logger.setLogLevel(RealmLogLevel.error);

    expectLater(logger.onRecord, emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')));

    Realm.logger.log(RealmLogLevel.error, 'error', category: RealmLogCategory.realm.sdk);
  });

  test('RealmLogger hookup hierarchical logging', () async {
    hierarchicalLoggingEnabled = true;
    Realm.logger.onRecord.forEach((r) => Logger(r.category.toString()).log(r.level.level, r.message));
    Logger.root.level = Level.ALL;
    Realm.logger.setLogLevel(RealmLogLevel.error);

    expectLater(Logger('Realm').onRecord, emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')));
    expectLater(
        Logger('Realm.SDK').onRecord, emits(isA<LogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')));

    Realm.logger.log(RealmLogLevel.error, 'error', category: RealmLogCategory.realm.sdk);
  });
}
