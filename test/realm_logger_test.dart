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
      RealmLogLevel.trace: 10,
      RealmLogLevel.debug: 20,
      RealmLogLevel.detail: 2,
      RealmLogLevel.info: 1,
    });
  });

  baasTest('Change Realm.logger level at runtime', (configuration) async {
    int count = await Isolate.run(() async {
      Realm.logger.level = RealmLogLevel.off;
      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      String username = "realm_tests_do_autoverify${generateRandomEmail()}";
      const String strongPassword = "SWV23R#@T#VFQDV";
      await authProvider.registerUser(username, strongPassword);
      final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
      await app.deleteUser(user);

      return await attachToLoggerAndThrows(configuration, logLevel: RealmLogLevel.error);
    });
    expect(count, 1); // Occurs only once because the log level has been switched from "Off" to "Error"
  });

  baasTest('Realm loggers logs the same messages in all the isolates', (configuration) async {
    int isolatesCount = 3;
    List<int> results = await Isolate.run(() async {
      List<int> results = [];

      // First Isolate  with level Error
      final mainIsolate = setNewLoggerAndThrows("First Isolate", configuration, RealmLogLevel.error);

      // Isolate 1 with level Error
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        int result = await setNewLoggerAndThrows("Isolate 1 ", configuration, RealmLogLevel.error);
        sendPort.send(result);
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        int result = await setNewLoggerAndThrows("Isolate 2", configuration, RealmLogLevel.error);
        sendPort.send(result);
      }, isolate2ReceivePort.sendPort);

      int log1 = await isolate1ReceivePort.first as int;
      int log2 = await isolate2ReceivePort.first as int;
      int logMain = await mainIsolate;

      isolate1ReceivePort.close();
      isolate1.kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      isolate2.kill(priority: Isolate.immediate);

      int logCountAfterClosingIsolates = await setNewLoggerAndThrows("After closing", configuration, RealmLogLevel.error);
      Realm.logger.level = RealmLogLevel.info;

      results.add(log1);
      results.add(log2);
      results.add(logMain);
      results.add(logCountAfterClosingIsolates);
      return results;
    });
    expect(results[0], isolatesCount, reason: "Isolate 1");
    expect(results[1], isolatesCount, reason: "Isolate 2");
    expect(results[2], isolatesCount, reason: "Main isolate logs count");
    expect(results[3], 1, reason: "First isolate logs count after closing the other isolates");
  });

  baasTest('Logger set to Off for one isolates does not prevents the other isolates to receive logs', (configuration) async {
    List<int> results = await Isolate.run(() async {
      List<int> results = [];
      int entrypointLogCount = 0;
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        entrypointLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        return await attachToLoggerAndThrows(configuration, logLevel: RealmLogLevel.error);
      });
      results.add(log1Count);

      int log2Count = await Isolate.run(() async {
        return await attachToLoggerAndThrows(configuration, logLevel: RealmLogLevel.error);
      });
      results.add(log2Count);
      results.add(entrypointLogCount);
      return results;
    });
    expect(results[0], 1);
    expect(results[1], 1);
    expect(results[2], 0);
  });

  // test('Log 2 info messages when open realm', () async {
  //   int count = await Isolate.run(() async {
  //     int count = 0;
  //     // final completer = Completer<int>();
  //     var config = Configuration.local([Car.schema]);
  //     Realm.logger.onRecord.listen((event) {
  //       count++;
  //       print(event);
  //       if (count == 2) {
  //         //  completer.complete(count);
  //       }
  //     });
  //     getRealm(config);

  //     //return await completer.future;
  //     return 0;
  //   });
  //   // expect(count, 1);
  // });
}

Future<int> setNewLoggerAndThrows(String isolateName, AppConfiguration appConfig, Level logLevel) async {
  final completer = Completer<int>();
  int count = 0;
  Realm.logger = Logger.detached(generateRandomString(10))
    ..level = logLevel
    ..onRecord.listen((event) {
      count++;
      print("$isolateName: $event");
    });
  try {
    await simulateError(appConfig);
    count = await completer.future.timeout(Duration(seconds: 2), onTimeout: () => throw Exception("Stop waiting for logs"));
  } catch (error) {
    completer.complete(count);
  }
  return count;
}

Future<int> attachToLoggerAndThrows(AppConfiguration appConfig, {Level? logLevel}) async {
  final completer = Completer<int>();
  int count = 0;
  if (logLevel != null) {
    Realm.logger.level = logLevel;
  }
  Realm.logger.onRecord.listen((event) {
    count++;
  });
  try {
    await simulateError(appConfig);
    count = await completer.future.timeout(Duration(seconds: 2), onTimeout: () => throw Exception("Stop waiting for logs"));
  } catch (error) {
    completer.complete(count);
  }
  return count;
}

Future<void> simulateError(AppConfiguration configuration) async {
  await Future<void>.delayed(Duration(milliseconds: 200));
  final app = App(configuration);
  final authProvider = EmailPasswordAuthProvider(app);
  try {
    await app.logIn(Credentials.emailPassword("notExisting", "password"));
  } on AppException catch (appExc) {
    if (!appExc.message.contains("invalid username/password")) {
      rethrow;
    }
  }
}

Future<Map<Level, List<String>>> listenLogger(Logger logger) async {
  // Prepare to capture trace
  final messages = <Level, List<String>>{};
  logger.onRecord.listen((r) {
    if (messages[r.level] == null) {
      messages[r.level] = [];
    }

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
