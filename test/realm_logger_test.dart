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
  await setupTests(args, loggerTest: true);
  baasTest('Realm loggers log messages in all the isolates', (appConfiguration) async {
    int isolatesCount = 3;
    ReceivePort isolate1ReceivePort = ReceivePort();
    ReceivePort isolate2ReceivePort = ReceivePort();

    // Isolate Main  with level Error
    final mainIsolate = predefineNewLoggerAndThrows("Main isolate", appConfiguration, RealmLogLevel.error);

    // Isolate 1 with level Error
    final isolate1 = await Isolate.spawn((SendPort sendPort) async {
      int result = await predefineNewLoggerAndThrows("Isolate 1", appConfiguration, RealmLogLevel.error);
      sendPort.send(result);
    }, isolate1ReceivePort.sendPort);

    // Isolate 2 with level Error
    final isolate2 = await Isolate.spawn((SendPort sendPort) async {
      int result = await predefineNewLoggerAndThrows("Isolate 2", appConfiguration, RealmLogLevel.error);
      sendPort.send(result);
    }, isolate2ReceivePort.sendPort);

    int log1 = await isolate1ReceivePort.first as int;
    int log2 = await isolate2ReceivePort.first as int;
    int logMain = await mainIsolate;

    isolate1ReceivePort.close();
    isolate1.kill(priority: Isolate.immediate);
    isolate2ReceivePort.close();
    isolate2.kill(priority: Isolate.immediate);
    int logCountAfterClosingIsolates = await predefineNewLoggerAndThrows("Main isolate", appConfiguration, RealmLogLevel.error);
    Realm.logger.level = RealmLogLevel.info;

    expect(log1, isolatesCount, reason: "Isolate 1");
    expect(log2, isolatesCount, reason: "Isolate 2");
    expect(logMain, isolatesCount, reason: "Main isolate logs count");
    expect(logCountAfterClosingIsolates, 1, reason: "Main isolate logs count after closing isolates");
  });

  baasTest('Logger set to Off for main isolates', (configuration) async {
    try {
      int mainIsolateCount = 0;
      Realm.logger.level = RealmLogLevel.off;
      Realm.logger.onRecord.listen((event) {
        mainIsolateCount++;
      });
      ReceivePort irp1 = ReceivePort();
      final isolate1 = await Isolate.spawn((SendPort sendPort) async {
        int result = await attachToLoggerAndThrows("Isolate 1", configuration, logLevel: RealmLogLevel.error);
        sendPort.send(result);
      }, irp1.sendPort);

      expect(await irp1.first as int, 1);

      ReceivePort irp2 = ReceivePort();
      final isolate2 = await Isolate.spawn((SendPort sendPort) async {
        int result = await attachToLoggerAndThrows("Isolate 2", configuration, logLevel: RealmLogLevel.error);
        sendPort.send(result);
      }, irp2.sendPort);

      expect(await irp2.first as int, 1);
      expect(mainIsolateCount, 0);
    } finally {
      Realm.logger.level = RealmLogLevel.info;
    }
  });
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
