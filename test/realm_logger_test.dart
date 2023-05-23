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
import 'package:realm_dart/src/native/realm_core.dart';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('Realm.logger expected messages from levels', (configuration) async {
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

      final logMessages = listenLogger(Realm.logger);

      await realm.syncSession.waitForDownload();
      return await logMessages;
    });

    expectLogMessages(logMessages,
        notExpectedMessagesFromLevels: [RealmLogLevel.fatal, RealmLogLevel.error, RealmLogLevel.warn],
        expectedMessagesFromLevels: [RealmLogLevel.trace, RealmLogLevel.debug, RealmLogLevel.detail, RealmLogLevel.info]);
  });

  baasTest('Change Realm.logger level at runtime', (configuration) async {
    Map<String, int> logsCount = await Isolate.run(() async {
      Map<String, int> results = {};
      Realm.logger.level = RealmLogLevel.error;

      for (var i = 0; i < 2; i++) {
        String attemptNum = "Attempt $i";
        String generatedName = generateRandomString(15);
        action() async => simulateError(configuration, generatedName);
        final messages = await attachToLoggerBeforeAction(attemptNum, action);
         final matches = matchedMessagesCount(messages[attemptNum], generatedName, RealmLogLevel.error);
        results.addEntries([MapEntry(attemptNum, matches)]);

        Realm.logger.level = RealmLogLevel.off;
      }
      return results;
    });

    expect(logsCount["Attempt 0"], 1);
    //After setting the log level to "Off" the logger won't receive the error
    expect(logsCount["Attempt 1"], 0);
  });

  baasTest('Realm loggers logs the same messages in all the isolates', (configuration) async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2", rootIsolateAfterKillIsolatesName = "AfterKillIsolates";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      action() async => simulateError(configuration, generatedName);

      // Root Isolate  with level Error. Attach to a new logger.
      final rootIsolate = attachToLoggerBeforeAction(rootIsolateName, action, setNewLogger: true, logLevel: RealmLogLevel.error);

      // Isolate 1 with level Error. Attach to the existing logger.
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        final matches = matchedMessagesCount(messages[isolate1Name], generatedName, RealmLogLevel.error);
        sendPort.send(matches);
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error. Attach to a new logger.
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await attachToLoggerBeforeAction(isolate2Name, action, setNewLogger: true, logLevel: RealmLogLevel.error);
        final matches = matchedMessagesCount(messages[isolate2Name], generatedName, RealmLogLevel.error);
        sendPort.send(matches);
      }, isolate2ReceivePort.sendPort);

      final rootMessages = await rootIsolate;
      final rootMatches = matchedMessagesCount(rootMessages[rootIsolateName], generatedName, RealmLogLevel.error);
      results.addEntries([MapEntry(rootIsolateName, rootMatches)]);

      results.addEntries([MapEntry(isolate1Name, await isolate1ReceivePort.first as int)]);
      results.addEntries([MapEntry(isolate2Name, await isolate2ReceivePort.first as int)]);

      isolate1ReceivePort.close();
      isolate1.kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      isolate2.kill(priority: Isolate.immediate);

      // Root Isolate  with level Error. Attach to the new logger create at the begining.
      final lastMessages = await attachToLoggerBeforeAction(rootIsolateAfterKillIsolatesName, action, logLevel: RealmLogLevel.error);
      final lastMatches = matchedMessagesCount(lastMessages[rootIsolateAfterKillIsolatesName], generatedName, RealmLogLevel.error);
      results.addEntries([MapEntry(rootIsolateAfterKillIsolatesName, lastMatches)]);
      return results;
    });

    expect(results[isolate1Name], 3, reason: "Isolate 1");
    expect(results[isolate2Name], 3, reason: "Isolate 2");
    expect(results[rootIsolateName], 3, reason: "Root isolate logs count");
    expect(results[rootIsolateAfterKillIsolatesName], 1, reason: "Root isolate logs count after closing the other isolates");
  });

  baasTest('Logger set to Off for root isolate does not prevent the other isolates to receive logs', (configuration) async {
    String generatedName = generateRandomString(15);
    String rootIsolateName = "Root", isolate1Name = "Isolate1", isolate2Name = "Isolate2";

    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      int rootLogCount = 0;
      action() async => simulateError(configuration, generatedName);
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        rootLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        final messages = await attachToLoggerBeforeAction(isolate1Name, action, logLevel: RealmLogLevel.error);
        return matchedMessagesCount(messages[isolate1Name], generatedName, RealmLogLevel.error);
      });
      results.addEntries([MapEntry(isolate1Name, log1Count)]);

      int log2Count = await Isolate.run(() async {
        final messages = await attachToLoggerBeforeAction(isolate2Name, action, logLevel: RealmLogLevel.error);
        return matchedMessagesCount(messages[isolate2Name], generatedName, RealmLogLevel.error);
      });

      results.addEntries([MapEntry(isolate2Name, log2Count)]);
      results.addEntries([MapEntry(rootIsolateName, rootLogCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[isolate2Name], 1);
    expect(results[rootIsolateName], 0);
  });

  test('Attach logger befor an action', () async {
    final path = generateRandomRealmPath();

    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "Root isolate";
      final messages = await attachToLoggerBeforeAction(isolateName, action);
      return matchedMessagesCount(messages[isolateName], "Open file: $path", RealmLogLevel.info);
    });

    expect(count, 1);
  });

  test('Attach logger after an action', () async {
    final path = generateRandomRealmPath();
    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "Root isolate";
      final messages = await attachToLoggerAfterAction(isolateName, action);
      return matchedMessagesCount(messages[isolateName], "Open file: $path", RealmLogLevel.info);
    });
    expect(count, 1);
  });

  
  test('Attached logger in root isolate receive the logs from the other isolate', () async {
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

        final messages = await attachToLoggerAfterAction(isolate1Name, action);
        return matchedMessagesCount(messages[isolate1Name], "Open file: $path", RealmLogLevel.info);
      });
      results.addEntries([MapEntry(isolate1Name, isolate1LogsCount)]);
      int rootLogsCount = matchedMessagesCount(rootEvents, "Open file: $path", RealmLogLevel.info);
      results.addEntries([MapEntry(rootIsolateName, rootLogsCount)]);
      return results;
    });

    expect(results[isolate1Name], 1);
    expect(results[rootIsolateName], 1);
  });
}

Future<Map<String, List<LogRecord>>> attachToLoggerBeforeAction(String isolateName, FutureOr<void> Function() action,
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

Future<Map<String, List<LogRecord>>> attachToLoggerAfterAction(String isolateName, FutureOr<void> Function() action,
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

Future<void> simulateError(AppConfiguration configuration, String functionName) async {
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

int matchedMessagesCount(List<LogRecord>? logRecords, String functionName, Level level) {
  final matches = logRecords?.where((element) => element.level == level && element.message.contains(functionName));
  return matches?.length ?? 0;
}

Future<Map<Level, List<String>>> listenLogger(Logger logger) async {
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

void expectLogMessages(
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
