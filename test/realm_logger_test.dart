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
import '../lib/src/realm_class.dart' show RealmInternal;
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args, logOnlyOnError: false);

  baasTest('Realm.logger', (configuration) async {
    Logger defaultLogger = RealmInternal.defaultLogger;
    try {
      Realm.logger = Logger.detached(generateRandomString(10))..level = RealmLogLevel.all;
      configuration = AppConfiguration(
        configuration.appId,
        baseFilePath: configuration.baseFilePath,
        baseUrl: configuration.baseUrl,
      );

      await testLogger(
        configuration,
        Realm.logger,
        maxExpectedCounts: {
          // No problems expected!
          RealmLogLevel.fatal: 0,
          RealmLogLevel.error: 0,
          RealmLogLevel.warn: 0,
        },
        minExpectedCounts: {
          // these are set low (roughly half of what was seen when test was created),
          // so that changes to core are less likely to break the test
          RealmLogLevel.trace: 10,
          RealmLogLevel.debug: 20,
          RealmLogLevel.detail: 2,
          RealmLogLevel.info: 1,
        },
      );
    } finally {
      Realm.logger = defaultLogger;
    }
  });

  baasTest('Change Realm.logger level at runtime', (configuration) async {
    Logger defaultLogger = RealmInternal.defaultLogger;
    try {
      int count = 0;
      final completer = Completer<void>();
      try {
        Realm.logger = Logger.detached(generateRandomString(10))
          ..level = RealmLogLevel.off
          ..onRecord.listen((event) {
            count++;
            expect(event.level, RealmLogLevel.error);
            completer.complete();
          });

        final app = App(configuration);
        final authProvider = EmailPasswordAuthProvider(app);
        String username = "realm_tests_do_autoverify${generateRandomEmail()}";
        const String strongPassword = "SWV23R#@T#VFQDV";
        await authProvider.registerUser(username, strongPassword);
        final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
        await app.deleteUser(user);

        Realm.logger.level = RealmLogLevel.error;

        await expectLater(() => app.logIn(Credentials.emailPassword(username, strongPassword)), throws<AppException>("invalid username/password"));
        await waitFutureWithTimeout(completer.future, timeoutError: "The error was not logged.");
        expect(count, 1); // Occurs only once because the log level has been switched from "Off" to "Error"
      } catch (error) {
        completer.completeError(error);
      }
    } finally {
      Realm.logger = defaultLogger;
    }
  });

  baasTest('Realm loggers log messages in all the isolates', (configuration) async {
    Logger defaultLogger = RealmInternal.defaultLogger;
    try {
      int isolatesCount = 3;

      // Isolate Main  with level Error
      final mainIsolate = predefineNewLoggerAndThrows("Main isolate", configuration, RealmLogLevel.error);

      // Isolate 1 with level Error
      ReceivePort isolate1ReceivePort = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        int result = await predefineNewLoggerAndThrows("Isolate 1", configuration, RealmLogLevel.error);
        sendPort.send(result);
      }, isolate1ReceivePort.sendPort);

      // Isolate 2 with level Error
      ReceivePort isolate2ReceivePort = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        int result = await predefineNewLoggerAndThrows("Isolate 2", configuration, RealmLogLevel.error);
        sendPort.send(result);
      }, isolate2ReceivePort.sendPort);

      int log1 = await isolate1ReceivePort.first as int;
      int log2 = await isolate2ReceivePort.first as int;
      int logMain = await mainIsolate;

      isolate1ReceivePort.close();
      isolate1.kill(priority: Isolate.immediate);
      isolate2ReceivePort.close();
      isolate2.kill(priority: Isolate.immediate);

      int logCountAfterClosingIsolates = await predefineNewLoggerAndThrows("Main isolate", configuration, RealmLogLevel.error);
      Realm.logger.level = RealmLogLevel.info;

      expect(log1, isolatesCount, reason: "Isolate 1");
      expect(log2, isolatesCount, reason: "Isolate 2");
      expect(logMain, isolatesCount, reason: "Main isolate logs count");
      expect(logCountAfterClosingIsolates, 1, reason: "Main isolate logs count after closing isolates");
    } finally {
      Realm.logger = defaultLogger;
    }
  });

  baasTest('Logger set to Off for first isolates', (configuration) async {
    Logger defaultLogger = RealmInternal.defaultLogger;
    try {
      int entrypointLogCount = 0;
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        entrypointLogCount++;
      });

      int log1Count = await Isolate.run(() async {
        return await attachToLoggerAndThrows("Isolate 1", configuration, logLevel: RealmLogLevel.error);
      });
      expect(log1Count, 1);

      int log2Count = await Isolate.run(() async {
        return await attachToLoggerAndThrows("Isolate 2", configuration, logLevel: RealmLogLevel.error);
      });
      expect(log2Count, 1);
      expect(entrypointLogCount, 0);
    } finally {
      Realm.logger = defaultLogger;
    }
  });

  test('Log messages', () async {
    RealmInternal.defaultLogger.onRecord.listen((event) {
      print(event);
    });
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    //expect(result, 2);
  }, skip: "not finished");
}

Future<int> predefineNewLoggerAndThrows(String isolateName, AppConfiguration appConfig, Level logLevel) async {
  final completer = Completer<int>();
  int count = 0;
  Realm.logger = Logger.detached(generateRandomString(10))
    ..level = logLevel
    ..onRecord.listen((event) {
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

Future<int> attachToLoggerAndThrows(String isolateName, AppConfiguration appConfig, {Level? logLevel}) async {
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

Future<void> testLogger(
  AppConfiguration configuration,
  Logger logger, {
  Map<Level, int> minExpectedCounts = const {},
  Map<Level, int> maxExpectedCounts = const {},
}) async {
  // To see the trace, add this:
  /*
  logger.onRecord.listen((event) {
    print('${event.sequenceNumber} ${event.level} ${event.message}');
  });
  */

  // Setup
  clearCachedApps();
  final app = App(configuration);
  final realm = await getIntegrationRealm(app: app);

  // Prepare to capture trace
  final messages = <Level, List<String>>{};
  logger.onRecord.listen((r) {
    if (messages[r.level] == null) {
      messages[r.level] = [];
    }

    messages[r.level]!.add(r.message);
  });

  // Trigger trace
  await realm.syncSession.waitForDownload();

  // Check count of various levels
  for (final e in maxExpectedCounts.entries) {
    final count = messages[e.key]?.length ?? 0;
    expect(count, lessThanOrEqualTo(e.value), reason: 'To many ${e.key} messages:\n  ${messages[e.key]?.join("\n  ")}');
  }
  for (final e in minExpectedCounts.entries) {
    final count = messages[e.key]?.length ?? 0;
    expect(count, greaterThanOrEqualTo(e.value), reason: 'To few ${e.key} messages:\n  ${messages[e.key]?.join("\n  ")}');
  }
}
