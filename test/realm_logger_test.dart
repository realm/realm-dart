////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

// ignore_for_file: unused_local_variable, avoid_relative_lib_imports

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:test/test.dart' hide test, throws;
import '../lib/src/realm_class.dart' show RealmInternal;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Realm.logger expected messages for log levels', () async {
    String generatedMessage = generateRandomString(10);
    Map<Level, int> logMessages = await Isolate.run(() async {
      Realm.logger = Logger.detached(generateRandomString(5))..level = RealmLogLevel.all;
      final allMessages = await _attachToLoggerBeforeAction("root isolate", () => _simulateLogs(generatedMessage));
      return _matchedMessagesCountPerLevel(allMessages, generatedMessage);
    });
    _expectAllLevelLogs(logMessages);
  });

  test('Realm.logger expected messages after action completed', () async {
    String generatedMessage = generateRandomString(10);
    Map<Level, int> logMessages = await Isolate.run(() async {
      Realm.logger = Logger.detached(generateRandomString(5))..level = RealmLogLevel.all;
      final allMessages = await _attachToLoggerAfterAction("root isolate", () => _simulateLogs(generatedMessage));
      return _matchedMessagesCountPerLevel(allMessages, generatedMessage);
    });
    _expectAllLevelLogs(logMessages);
  });

  baasTest('Realm.logger level changed', (configuration) async {
    Map<String, Map<Level, int>> logMessages = await Isolate.run(() async {
      Map<String, Map<Level, int>> results = {};
      Realm.logger.level = RealmLogLevel.error;

      for (var i = 0; i < 2; i++) {
        String attemptNum = "Attempt $i";
        String generatedMessage = generateRandomString(15);
        final allMessages = await _attachToLoggerBeforeAction("root isolate", () => _simulateLogs(generatedMessage));
        final matchedMessages = _matchedMessagesCountPerLevel(allMessages, generatedMessage);
        results.addEntries([MapEntry(attemptNum, matchedMessages)]);
        Realm.logger.level = RealmLogLevel.off;
      }
      return results;
    });
    _expectErrorLogs(logMessages, "Attempt 0");

    //After setting the log level to "Off" the logger won't receive the error
    _expectNoLogs(logMessages, "Attempt 1");
  });

  test('Realm.logger logs messages from all the isolates', () async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2", rootIsolateAfterKillIsolatesName = "AfterKillIsolates";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      action() => _simulateLogs(generatedName);

      // Root Isolate  with level Error. Attach to a new logger.
      final rootIsolate = _attachToLoggerBeforeAction(rootIsolateName, action, setNewLogger: true, logLevel: RealmLogLevel.error);

      // Isolate 1 with level Error. Attach to the existing logger.
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = Isolate.spawn((SendPort sendPort) async {
        final messages = await _attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCountPerLevel(messages, generatedName);
        sendPort.send(matches[RealmLogLevel.error]!);
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error. Attach to a new logger.
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = Isolate.spawn((SendPort sendPort) async {
        final messages = await _attachToLoggerBeforeAction(isolate2Name, action, setNewLogger: true, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCountPerLevel(messages, generatedName);
        sendPort.send(matches[RealmLogLevel.error]!);
      }, isolate2ReceivePort.sendPort);

      final rootMessages = await rootIsolate;
      final rootMatches = _matchedMessagesCountPerLevel(rootMessages, generatedName);
      results.addEntries([MapEntry(rootIsolateName, rootMatches[RealmLogLevel.error]!)]);

      results.addEntries([MapEntry(isolate1Name, await isolate1ReceivePort.first as int)]);
      results.addEntries([MapEntry(isolate2Name, await isolate2ReceivePort.first as int)]);

      isolate1ReceivePort.close();
      (await isolate1).kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      (await isolate2).kill(priority: Isolate.immediate);

      // Root Isolate  with level Error. Attach to the new logger create at the begining.
      final lastMessages = await _attachToLoggerBeforeAction(rootIsolateAfterKillIsolatesName, action, logLevel: RealmLogLevel.error);
      final lastMatches = _matchedMessagesCountPerLevel(lastMessages, generatedName);
      results.addEntries([MapEntry(rootIsolateAfterKillIsolatesName, lastMatches[RealmLogLevel.error]!)]);
      return results;
    });

    expect(results[isolate1Name], 3, reason: "Isolate 1");
    expect(results[isolate2Name], 3, reason: "Isolate 2");
    expect(results[rootIsolateName], 3, reason: "Root isolate logs count");
    expect(results[rootIsolateAfterKillIsolatesName], 1, reason: "Root isolate logs count after closing the other isolates");
  });

  test('Realm.logger level set to Off in the root isolate does not prevent the other isolates to receive logs', () async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      int rootLogCount = 0;
      action() async => _simulateLogs(generatedName);
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        rootLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        final messages = await _attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCountPerLevel(messages, generatedName);
        return matches[RealmLogLevel.error]!;
      });
      results.addEntries([MapEntry(isolate1Name, log1Count)]);

      int log2Count = await Isolate.run(() async {
        final messages = await _attachToLoggerBeforeAction(isolate2Name, action, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCountPerLevel(messages, generatedName);
        return matches[RealmLogLevel.error]!;
      });

      results.addEntries([MapEntry(isolate2Name, log2Count)]);
      results.addEntries([MapEntry(rootIsolateName, rootLogCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[isolate2Name], 1);
    expect(results[rootIsolateName], 0);
  });

  test('Realm.logger - attached listener in root isolate receives the logs from another isolate', () async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      List<LogRecord> rootEvents = [];
      Realm.logger.onRecord.listen((event) {
        rootEvents.add(event);
      });

      int isolate1LogsCount = await Isolate.run(() async {
        action() async => _simulateLogs(generatedName);

        final messages = await _attachToLoggerBeforeAction(isolate1Name, action);
        final matches = _matchedMessagesCountPerLevel(messages, generatedName);
        return matches[RealmLogLevel.info]!;
      });

      results.addEntries([MapEntry(isolate1Name, isolate1LogsCount)]);
      final matches = _matchedMessagesCountPerLevel(rootEvents, generatedName);
      int rootLogsCount = matches[RealmLogLevel.info]!;
      results.addEntries([MapEntry(rootIsolateName, rootLogsCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[rootIsolateName], 1);
  });
}

Future<List<LogRecord>> _attachToLoggerBeforeAction(String isolateName, FutureOr<void> Function() action, {Level? logLevel, bool setNewLogger = false}) async {
  final completer = Completer<void>();
  List<LogRecord> events = [];
  await Future<void>.delayed(Duration(milliseconds: 200));
  if (setNewLogger) {
    Realm.logger = Logger.detached(generateRandomString(10))
      ..level = logLevel ?? RealmLogLevel.info
      ..onRecord.listen((event) {
        events.add(event);
      });
  } else {
    if (logLevel != null) {
      Realm.logger.level = logLevel;
    }
    Realm.logger.onRecord.listen((event) {
      events.add(event);
    });
  }

  try {
    await action();
    await completer.future.timeout(Duration(seconds: 2), onTimeout: () => throw Exception("Stop waiting for logs"));
  } catch (error) {
    completer.complete();
  }

  return events;
}

Future<List<LogRecord>> _attachToLoggerAfterAction(String isolateName, FutureOr<void> Function() action, {Level? logLevel, bool setNewLogger = false}) async {
  final completer = Completer<void>();
  await Future<void>.delayed(Duration(milliseconds: 200));
  List<LogRecord> events = [];
  try {
    await action();
    if (setNewLogger) {
      Realm.logger = Logger.detached(generateRandomString(10))
        ..level = logLevel ?? RealmLogLevel.info
        ..onRecord.listen((event) {
          events.add(event);
        });
    } else {
      if (logLevel != null) {
        Realm.logger.level = logLevel;
      }
      Realm.logger.onRecord.listen((event) {
        events.add(event);
      });
    }

    await completer.future.timeout(Duration(seconds: 2), onTimeout: () => throw Exception("Stop waiting for logs"));
  } catch (error) {
    completer.complete();
  }
  return events;
}

Future<void> _simulateLogs(String message) async {
  RealmInternal.log(RealmLogLevel.trace, message);
  RealmInternal.log(RealmLogLevel.debug, message);
  RealmInternal.log(RealmLogLevel.detail, message);
  RealmInternal.log(RealmLogLevel.info, message);
  RealmInternal.log(RealmLogLevel.fatal, message);
  RealmInternal.log(RealmLogLevel.error, message);
  RealmInternal.log(RealmLogLevel.warn, message);
}

Map<Level, int> _matchedMessagesCountPerLevel(List<LogRecord>? logRecords, String specificMessage) {
  Map<Level, int> matchedMessages = {};
  for (Level level in Level.LEVELS) {
    final matches = logRecords?.where((element) => element.level == level && element.message.contains(specificMessage));
    matchedMessages.addEntries([MapEntry(level, matches?.length ?? 0)]);
  }
  return matchedMessages;
}

void _expectLogMessages(
  Map<Level, int> actualMessages, {
  List<Level> notExpectedMessagesFromLevels = const [],
  List<Level> expectedMessagesFromLevels = const [],
}) {
  // Check count of various levels

  for (final level in expectedMessagesFromLevels) {
    final int count = actualMessages[level] ?? 0;
    expect(count, greaterThan(0), reason: 'There is no messages from $level');
  }

  for (final level in notExpectedMessagesFromLevels) {
    final count = actualMessages[level] ?? 0;
    expect(count, 0, reason: 'Messages from level $level are not expected:\n  found ${actualMessages[level] ?? 0}');
  }
}

void _expectErrorLogs(Map<String, Map<Level, int>> logMessages, String expectedName) {
  expect(logMessages[expectedName], isNotNull);
  _expectLogMessages(
    logMessages[expectedName]!,
    notExpectedMessagesFromLevels: [
      RealmLogLevel.all,
      RealmLogLevel.trace,
      RealmLogLevel.debug,
      RealmLogLevel.detail,
      RealmLogLevel.warn,
      RealmLogLevel.info,
      RealmLogLevel.off
    ],
    expectedMessagesFromLevels: [
      RealmLogLevel.error,
      RealmLogLevel.fatal,
    ],
  );
}

void _expectNoLogs(Map<String, Map<Level, int>> logMessages, String expectedName) {
  expect(logMessages[expectedName], isNotNull);
  _expectLogMessages(
    logMessages[expectedName]!,
    notExpectedMessagesFromLevels: [
      RealmLogLevel.all,
      RealmLogLevel.off,
      RealmLogLevel.trace,
      RealmLogLevel.debug,
      RealmLogLevel.detail,
      RealmLogLevel.info,
      RealmLogLevel.error,
      RealmLogLevel.warn,
      RealmLogLevel.fatal,
    ],
  );
}

void _expectAllLevelLogs(Map<Level, int> logMessages) {
  _expectLogMessages(logMessages, notExpectedMessagesFromLevels: [
    RealmLogLevel.all,
    RealmLogLevel.off
  ], expectedMessagesFromLevels: [
    RealmLogLevel.trace,
    RealmLogLevel.debug,
    RealmLogLevel.detail,
    RealmLogLevel.info,
    RealmLogLevel.fatal,
    RealmLogLevel.error,
    RealmLogLevel.warn,
  ]);
}
