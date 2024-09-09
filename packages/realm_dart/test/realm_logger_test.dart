// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart' hide LogRecord;
import 'package:logging/logging.dart' as logging show LogRecord;
import 'package:realm_dart/src/logging.dart';
import 'package:realm_dart/src/handles/realm_core.dart';
import 'package:realm_dart/realm.dart';
import 'test.dart';

typedef DartLogRecord = logging.LogRecord;

final logToValues = LogLevel.values.where((l) => ![LogLevel.all, LogLevel.off].contains(l));

void main() {
  setupTests();

  group('All levels', () {
    for (var level in LogLevel.values) {
      test('Realm.logger supports log level $level', () {
        Realm.logger.setLogLevel(LogLevel.off);
        Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

        final tag = Uuid.v4();
        expectLater(
          Realm.logger.onRecord,
          emits((category: LogCategory.realm.sdk, level: level, message: '$level $tag')),
        );
        Realm.logger.log(level, '$level $tag');
      });
    }
  });

  group('Match levels', () {
    for (var level in LogLevel.values) {
      final expectedLevels = logToValues.where((l) => l.index >= level.index);
      test('$level matches $expectedLevels', () {
        Realm.logger.setLogLevel(LogLevel.off);
        Realm.logger.setLogLevel(level, category: LogCategory.realm.sdk);

        expectLater(Realm.logger.onRecord, emitsInOrder(expectedLevels.map((l) => isA<LogRecord>().having((r) => r.level, '$l', l))));
        for (var sendLevel in logToValues) {
          Realm.logger.log(sendLevel, '$sendLevel');
        }
      });
    }
  });

  group('LogCategory.contains', () {
    for (final outer in LogCategory.values) {
      for (final inner in LogCategory.values) {
        test('$outer contains $inner', () {
          expect(outer.contains(inner), inner.toString().startsWith(outer.toString()));
        });
      }
    }
  });

  test('Trace in subisolate seen in parent', () {
    Realm.logger.setLogLevel(LogLevel.off);
    Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

    expectLater(Realm.logger.onRecord, emits(isA<LogRecord>().having((r) => r.message, 'message', 'Hey')));
    Isolate.run(() {
      Realm.logger.log(LogLevel.trace, 'Hey');
    });
  });

  test('Trace in root isolate seen in subisolate', () async {
    Realm.logger.setLogLevel(LogLevel.off);
    Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

    final trace = Isolate.run(() async {
      return (await Realm.logger.onRecord.first).message;
    });
    await Future<void>.delayed(const Duration(milliseconds: 100)); // yield
    expectLater(trace, completion('Hey'));
    Realm.logger.log(LogLevel.trace, 'Hey');
  });

  test('RealmLogger hookup logging', () async {
    Realm.logger.setLogLevel(LogLevel.off);
    Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

    final logger = Logger.detached('Test');
    final sub = Realm.logger.onRecord.listen((r) => logger.log(r.level.level, r.message));
    logger.level = Level.ALL;

    expectLater(logger.onRecord, emits(isA<DartLogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')))
        .whenComplete(sub.cancel);

    Realm.logger.log(LogLevel.error, 'error');
  });

  test('RealmLogger hookup hierarchical logging', () async {
    Realm.logger.setLogLevel(LogLevel.off);
    Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

    final old = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;

    final sub = Realm.logger.onRecord.listen((r) => Logger(r.category.toString()).log(r.level.level, r.message));
    Logger.root.level = Level.ALL;

    expectLater(
        Logger('Realm').onRecord, emits(isA<DartLogRecord>().having((r) => r.level, 'level', Level.SEVERE).having((r) => r.message, 'message', 'error')));
    expectLater(
      Logger('Realm.SDK').onRecord,
      emits(isA<DartLogRecord>().having((r) => r.level, 'level', Level.SEVERE).having(
            (r) => r.message,
            'message',
            'error',
          )),
    ).whenComplete(() {
      sub.cancel();
      hierarchicalLoggingEnabled = old;
    });

    Realm.logger.log(LogLevel.error, 'error', category: LogCategory.realm.sdk);
  });

  group('Category mapping', () {
    // Filter out sync/app category names since this is a local-only build
    final nativeCategoryNames = realmCore.getAllCategoryNames().where((name) => !name.startsWith("Realm.Sync") && !name.contains("Realm.App")).toList();

    for (final name in nativeCategoryNames) {
      test('$name can parse', () {
        expect(() => LogCategory.fromString(name), returnsNormally);
        final category = LogCategory.fromString(name);
        expect(category, isA<LogCategory>().having((c) => c.toString(), 'toString()', name));
      });
    }

    for (final category in LogCategory.values) {
      test('$category known by native', () {
        expect(nativeCategoryNames, contains(category.toString()));
      });
    }
  });

  test('RealmLogger.onRecord is a broadcast stream', () {
    // see https://github.com/realm/realm-dart/pull/1574#issuecomment-2006769321
    expect(Realm.logger.onRecord.isBroadcast, isTrue);
    final sub = Realm.logger.onRecord.listen((_) {});
    expect(() => Realm.logger.onRecord.first, returnsNormally); // safe to listen twice on a broadcast stream
    sub.cancel();
  });

  test('Changing levels works', () {
    Realm.logger.setLogLevel(LogLevel.off);
    Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm.sdk);

    expectLater(
        Realm.logger.onRecord,
        emitsInOrder([
          isA<LogRecord>().having((r) => r.level, 'level', LogLevel.trace).having((r) => r.message, 'message', 'trace'),
          // note second trace is not seen
          isA<LogRecord>().having((r) => r.level, 'level', LogLevel.warn).having((r) => r.message, 'message', 'warn'),
        ]));

    Realm.logger.log(LogLevel.trace, 'trace');
    Realm.logger.setLogLevel(LogLevel.warn, category: LogCategory.realm.sdk);
    Realm.logger.log(LogLevel.trace, 'trace'); // <-- not seen
    Realm.logger.log(LogLevel.warn, 'warn');
  });
}
