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

  baasTest('Realm.logger', (configuration) async {
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

    expectLogMessages(logMessages, expectedMinCountPerLevel: {
      RealmLogLevel.fatal: 0,
      RealmLogLevel.error: 0,
      RealmLogLevel.warn: 0,
    }, expectedMaxCountPerLevel: {
      RealmLogLevel.trace: 121,
      RealmLogLevel.debug: 98,
      RealmLogLevel.detail: 14,
      RealmLogLevel.info: 17,
    });
  });

  baasTest('Change Realm.logger level at runtime', (configuration) async {
    Map<String, int> logsCount = await Isolate.run(() async {
      Map<String, int> results = {};
      Realm.logger.level = RealmLogLevel.error;
      for (var i = 0; i < 2; i++) {
        String attemptNum = "Attempt $i";
        String functionName = generateRandomString(15);
        action() async => simulateError(configuration, functionName);
        final messages = await attachToLoggerBeforeAction(attemptNum, action);
        final matches = getErrorsCount(messages[attemptNum], functionName);
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
    int isolatesCount = 3;
    String functionName = generateRandomString(15);
    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      action() async => simulateError(configuration, functionName);
      // Root Isolate  with level Error
      final rootIsolate = attachToLoggerBeforeAction("Root", action, setNewLogger: true, logLevel: RealmLogLevel.error);

      // Isolate 1 with level Error
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await attachToLoggerBeforeAction("Isolate1", action, setNewLogger: true, logLevel: RealmLogLevel.error);
        sendPort.send(getErrorsCount(messages["Isolate1"], functionName));
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        final messages = await attachToLoggerBeforeAction("Isolate2", action, setNewLogger: true, logLevel: RealmLogLevel.error);
        sendPort.send(getErrorsCount(messages["Isolate2"], functionName));
      }, isolate2ReceivePort.sendPort);

      final rootMessages = await rootIsolate;
      final rootMatches = getErrorsCount(rootMessages["Root"], functionName);

      results.addEntries([MapEntry("Isolate1", await isolate1ReceivePort.first as int)]);
      results.addEntries([MapEntry("Isolate2", await isolate2ReceivePort.first as int)]);
      results.addEntries([MapEntry("Root", rootMatches)]);

      isolate1ReceivePort.close();
      isolate1.kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      isolate2.kill(priority: Isolate.immediate);

      final lastMessages = await attachToLoggerBeforeAction("After closing", action, setNewLogger: true, logLevel: RealmLogLevel.error);
      final lastMatches = getErrorsCount(lastMessages["After closing"], functionName);
      results.addEntries([MapEntry("After closing", lastMatches)]);
      return results;
    });
    expect(results["Isolate1"], isolatesCount, reason: "Isolate 1");
    expect(results["Isolate2"], isolatesCount, reason: "Isolate 2");
    expect(results["Root"], isolatesCount, reason: "Root isolate logs count");
    expect(results["After closing"], 1, reason: "Root isolate logs count after closing the other isolates");
  });

  baasTest('Logger set to Off for root isolate does not prevent the other isolates to receive logs', (configuration) async {
    String functionName = generateRandomString(15);
    Map<String, int> results = await Isolate.run(() async {
      Map<String, int> results = {};
      int entrypointLogCount = 0;
      action() async => simulateError(configuration, functionName);
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        entrypointLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        final messages = await attachToLoggerBeforeAction("Isolate 1", action, logLevel: RealmLogLevel.error);
        return getErrorsCount(messages["Isolate 1"], functionName);
      });
      results.addEntries([MapEntry("Isolate 1", log1Count)]);

      int log2Count = await Isolate.run(() async {
        final messages = await attachToLoggerBeforeAction("Isolate 2", action, logLevel: RealmLogLevel.error);
        return getErrorsCount(messages["Isolate 2"], functionName);
      });

      results.addEntries([MapEntry("Isolate 2", log2Count)]);
      results.addEntries([MapEntry("Root", entrypointLogCount)]);
      return results;
    });
    expect(results["Isolate 1"], 1);
    expect(results["Isolate 2"], 1);
    expect(results["Root"], 0);
  });

  test('Attach logger befor opening realm', () async {
    final path = generateRandomRealmPath();
    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "First isolate";
      final messages = await attachToLoggerBeforeAction(isolateName, action);
      final matches = messages[isolateName]?.where((element) => element.level == Level.INFO && element.message.contains("Open file: $path")).length;
      return matches ?? 0;
    });
    expect(count, 1);
  });

  test('Attach logger after opennig realm', () async {
    final path = generateRandomRealmPath();
    int count = await Isolate.run(() async {
      action() {
        var config = Configuration.local([Car.schema], path: path);
        final realm = getRealm(config);
        realm.close();
      }

      String isolateName = "First isolate";
      final messages = await attachToLoggerAfterAction(isolateName, action);
      final matches = messages[isolateName]?.where((element) => element.level == Level.INFO && element.message.contains("Open file: $path")).length;
      return matches ?? 0;
    });
    expect(count, 1);
  });
}

Future<Map<String, List<LogRecord>>> attachToLoggerBeforeAction(String isolateName, FutureOr<void> Function() action,
    {Level? logLevel, bool setNewLogger = false}) async {
  final completer = Completer<void>();
  List<LogRecord> events = [];
  Map<String, List<LogRecord>> messages = {isolateName: events};
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
  return messages;
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

int getErrorsCount(List<LogRecord>? logRecords, String functionName) {
  final matches = logRecords?.where((element) => element.level == RealmLogLevel.error && element.message.contains(functionName));
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
  Map<Level, int> expectedMinCountPerLevel = const {},
  Map<Level, int> expectedMaxCountPerLevel = const {},
}) {
  // Check count of various levels

  for (final e in expectedMaxCountPerLevel.entries) {
    final int count = actualMessages[e.key]?.length ?? 0;
    expect(count, lessThanOrEqualTo(e.value), reason: 'To many ${e.key} messages:\n  ${actualMessages[e.key]?.join("\n  ")}');
  }

  for (final e in expectedMinCountPerLevel.entries) {
    final count = actualMessages[e.key]?.length ?? 0;
    expect(count, greaterThanOrEqualTo(e.value), reason: 'To few ${e.key} messages:\n  ${actualMessages[e.key]?.join("\n  ")}');
  }
}
