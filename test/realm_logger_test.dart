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
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('Realm.logger expected messages for log levels', (configuration) async {
    Map<Level, List<String>> logMessages = await Isolate.run(() async {
      Realm.logger = Logger.detached(generateRandomString(10))..level = RealmLogLevel.all;

      configuration = AppConfiguration(
        configuration.appId,
        baseFilePath: configuration.baseFilePath,
        baseUrl: configuration.baseUrl,
      );

      clearCachedApps();
      final app = App(configuration);
      final realm = await getIntegrationRealm(app: app);

      final logMessages = _listenLogger(Realm.logger);

      await realm.syncSession.waitForDownload();
      return await logMessages;
    });

    _expectLogMessages(logMessages,
        notExpectedMessagesFromLevels: [RealmLogLevel.fatal, RealmLogLevel.error, RealmLogLevel.warn],
        expectedMessagesFromLevels: [RealmLogLevel.trace, RealmLogLevel.debug, RealmLogLevel.detail, RealmLogLevel.info]);
  });

  baasTest('Realm.logger level changed at runtime', (configuration) async {
    Map<String, int> logsCount = await Isolate.run(() async {
      Map<String, int> results = {};
      Realm.logger.level = RealmLogLevel.error;

      for (var i = 0; i < 2; i++) {
        String attemptNum = "Attempt $i";
        String generatedName = generateRandomString(15);
        action() async => _simulateError(configuration, generatedName);
        final messages = await _attachToLoggerBeforeAction(attemptNum, action);
        final matches = _matchedMessagesCount(messages[attemptNum], generatedName, RealmLogLevel.error);
        results.addEntries([MapEntry(attemptNum, matches)]);

        Realm.logger.level = RealmLogLevel.off;
      }
      return results;
    });

    expect(logsCount["Attempt 0"], 1);
    //After setting the log level to "Off" the logger won't receive the error
    expect(logsCount["Attempt 1"], 0);
  });

  baasTest('Realm.logger logs messages from all the isolates', (configuration) async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2", rootIsolateAfterKillIsolatesName = "AfterKillIsolates";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      action() async => _simulateError(configuration, generatedName);

      // Root Isolate  with level Error. Attach to a new logger.
      final rootIsolate = _attachToLoggerBeforeAction(rootIsolateName, action, setNewLogger: true, logLevel: RealmLogLevel.error);

      // Isolate 1 with level Error. Attach to the existing logger.
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await _attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCount(messages[isolate1Name], generatedName, RealmLogLevel.error);
        sendPort.send(matches);
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error. Attach to a new logger.
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await _attachToLoggerBeforeAction(isolate2Name, action, setNewLogger: true, logLevel: RealmLogLevel.error);
        final matches = _matchedMessagesCount(messages[isolate2Name], generatedName, RealmLogLevel.error);
        sendPort.send(matches);
      }, isolate2ReceivePort.sendPort);

      final rootMessages = await rootIsolate;
      final rootMatches = _matchedMessagesCount(rootMessages[rootIsolateName], generatedName, RealmLogLevel.error);
      results.addEntries([MapEntry(rootIsolateName, rootMatches)]);

      results.addEntries([MapEntry(isolate1Name, await isolate1ReceivePort.first as int)]);
      results.addEntries([MapEntry(isolate2Name, await isolate2ReceivePort.first as int)]);

      isolate1ReceivePort.close();
      isolate1.kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      isolate2.kill(priority: Isolate.immediate);

      // Root Isolate  with level Error. Attach to the new logger create at the begining.
      final lastMessages = await _attachToLoggerBeforeAction(rootIsolateAfterKillIsolatesName, action, logLevel: RealmLogLevel.error);
      final lastMatches = _matchedMessagesCount(lastMessages[rootIsolateAfterKillIsolatesName], generatedName, RealmLogLevel.error);
      results.addEntries([MapEntry(rootIsolateAfterKillIsolatesName, lastMatches)]);
      return results;
    });

    expect(results[isolate1Name], 3, reason: "Isolate 1");
    expect(results[isolate2Name], 3, reason: "Isolate 2");
    expect(results[rootIsolateName], 3, reason: "Root isolate logs count");
    expect(results[rootIsolateAfterKillIsolatesName], 1, reason: "Root isolate logs count after closing the other isolates");
  });

  baasTest('Realm.logger level set to Off in the root isolate does not prevent the other isolates to receive logs', (configuration) async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      int rootLogCount = 0;
      action() async => _simulateError(configuration, generatedName);
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        rootLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        final messages = await _attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        return _matchedMessagesCount(messages[isolate1Name], generatedName, RealmLogLevel.error);
      });
      results.addEntries([MapEntry(isolate1Name, log1Count)]);

      int log2Count = await Isolate.run(() async {
        final messages = await _attachToLoggerBeforeAction(isolate2Name, action, logLevel: RealmLogLevel.error);
        return _matchedMessagesCount(messages[isolate2Name], generatedName, RealmLogLevel.error);
      });

      results.addEntries([MapEntry(isolate2Name, log2Count)]);
      results.addEntries([MapEntry(rootIsolateName, rootLogCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[isolate2Name], 1);
    expect(results[rootIsolateName], 0);
  });

  test('Realm.logger - attached listener before an action', () async {
    final path = generateRandomRealmPath();

    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "Root isolate";
      final messages = await _attachToLoggerBeforeAction(isolateName, action);
      return _matchedMessagesCount(messages[isolateName], "Open file: $path", RealmLogLevel.info);
    });

    expect(count, 1);
  });

  test('Realm.logger - attached listener after an action', () async {
    final path = generateRandomRealmPath();
    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "Root isolate";
      final messages = await _attachToLoggerAfterAction(isolateName, action);
      return _matchedMessagesCount(messages[isolateName], "Open file: $path", RealmLogLevel.info);
    });
    expect(count, 1);
  });

  test('Realm.logger - attached listener in root isolate receives the logs from another isolate', () async {
    final path = generateRandomRealmPath();
    String rootIsolateName = "Root", isolate1Name = "Isolate1";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      List<LogRecord> rootEvents = [];
      Realm.logger.onRecord.listen((event) {
        rootEvents.add(event);
      });

      int isolate1LogsCount = await Isolate.run(() async {
        action() {
          var config = Configuration.local([Car.schema], path: path);
          final realm = Realm(config);
          realm.close();
        }

        final messages = await _attachToLoggerAfterAction(isolate1Name, action);
        return _matchedMessagesCount(messages[isolate1Name], "Open file: $path", RealmLogLevel.info);
      });
      results.addEntries([MapEntry(isolate1Name, isolate1LogsCount)]);
      int rootLogsCount = _matchedMessagesCount(rootEvents, "Open file: $path", RealmLogLevel.info);
      results.addEntries([MapEntry(rootIsolateName, rootLogsCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[rootIsolateName], 1);
  });
}

Future<Map<String, List<LogRecord>>> _attachToLoggerBeforeAction(String isolateName, FutureOr<void> Function() action,
    {Level? logLevel, bool setNewLogger = false}) async {
  final completer = Completer<void>();
  List<LogRecord> events = [];

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

  return {isolateName: events};
}

Future<Map<String, List<LogRecord>>> _attachToLoggerAfterAction(String isolateName, FutureOr<void> Function() action,
    {Level? logLevel, bool setNewLogger = false}) async {
  final completer = Completer<void>();
  List<LogRecord> events = [];
  Map<String, List<LogRecord>> messages = {isolateName: events};
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
  return messages;
}

Future<void> _simulateError(AppConfiguration configuration, String functionName) async {
  await Future<void>.delayed(Duration(milliseconds: 200));
  final app = App(configuration);
  final user = await app.logIn(Credentials.anonymous());

  try {
    await user.functions.call(functionName);
  } on AppException catch (appExc) {
    if (!appExc.message.contains("function not found")) {
      rethrow;
    }
  }
}

int _matchedMessagesCount(List<LogRecord>? logRecords, String functionName, Level level) {
  final matches = logRecords?.where((element) => element.level == level && element.message.contains(functionName));
  return matches?.length ?? 0;
}

Future<Map<Level, List<String>>> _listenLogger(Logger logger) async {
  // Prepare to capture trace
  final messages = <Level, List<String>>{};
  logger.onRecord.listen((r) {
    if (messages[r.level] == null) {
      messages[r.level] = [];
    }
    //print(r);
    messages[r.level]!.add(r.message);
  });

  // Trigger trace
  return messages;
}

void _expectLogMessages(
  Map<Level, List<String>> actualMessages, {
  List<Level> notExpectedMessagesFromLevels = const [],
  List<Level> expectedMessagesFromLevels = const [],
}) {
  // Check count of various levels

  for (final level in expectedMessagesFromLevels) {
    final int count = actualMessages[level]?.length ?? 0;
    expect(count, greaterThan(0), reason: 'There is no messages from $level');
  }

  for (final level in notExpectedMessagesFromLevels) {
    final count = actualMessages[level]?.length ?? 0;
    expect(count, 0, reason: 'Messages from level $level are not expected:\n  ${actualMessages[level]?.join("\n  ")}');
  }
}
