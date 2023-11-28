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

const logLevels = [
  RealmLogLevel.all,
  RealmLogLevel.trace,
  RealmLogLevel.debug,
  RealmLogLevel.detail,
  RealmLogLevel.info,
  RealmLogLevel.fatal,
  RealmLogLevel.error,
  RealmLogLevel.warn
];

class LoggedMessage {
  final Level level;
  final String message;

  const LoggedMessage(this.level, this.message);

  factory LoggedMessage.empty() => const LoggedMessage(RealmLogLevel.off, "");

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoggedMessage) return false;
    return level == other.level && message == other.message;
  }

  @override
  String toString() => "level:$level message:$message";
}

void openARealm() {
  Configuration.defaultRealmName = generateRandomRealmPath();
  final config = Configuration.inMemory([Car.schema]);
  Realm(config).close();
  tryDeleteRealm(Configuration.defaultRealmName);
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  for (var level in logLevels) {
    test('Realm.logger supports log level $level', () async {
      LoggedMessage actual = await Isolate.run(() async {
        final completer = Completer<LoggedMessage>();

        Realm.logger.level = level;
        Realm.logger.onRecord.listen((event) {
          completer.complete(LoggedMessage(event.level, event.message));
        });

        RealmInternal.logMessageForTesting(level, "123");

        return await completer.future;
      });

      expect(actual, LoggedMessage(level, "123"));
    });
  }

  test('Realm.logger supports changing log level', () async {
    List<LoggedMessage> actual = await Isolate.run(() async {
      final result = <LoggedMessage>[];

      var completer = Completer<LoggedMessage>();
      Realm.logger.level = RealmLogLevel.trace;
      Realm.logger.onRecord.listen((event) {
        if (event.level != Realm.logger.level) {
          return;
        }

        completer.complete(LoggedMessage(event.level, event.message));
      });
      openARealm();
      result.add(await completer.future);

      Realm.logger.level = RealmLogLevel.debug;
      completer = Completer<LoggedMessage>();
      openARealm();
      result.add(await completer.future);

      Realm.logger.level = RealmLogLevel.trace;
      completer = Completer<LoggedMessage>();
      openARealm();
      result.add(await completer.future);

      //increase log verbosity
      Realm.logger.level = RealmLogLevel.debug;
      completer = Completer<LoggedMessage>();
      openARealm();
      result.add(await completer.future);

      return result;
    });

    expect(actual[0].level, RealmLogLevel.trace);
    expect(actual[1].level, RealmLogLevel.debug);
    expect(actual[2].level, RealmLogLevel.trace);
    expect(actual[3].level, RealmLogLevel.debug);
  });

  test('Realm.logger supports custom logger', () async {
    LoggedMessage actual = await Isolate.run(() async {
      final completer = Completer<LoggedMessage>();

      Realm.logger.onRecord.listen((event) {
        throw RealmError("Default logger should not log messages if custom logger is set");
      });

      Realm.logger = Logger.detached("custom logger")..level = RealmLogLevel.detail;

      Realm.logger.onRecord.listen((event) {
        completer.complete(LoggedMessage(event.level, event.message));
      });

      RealmInternal.logMessageForTesting(RealmLogLevel.detail, "123");

      return await completer.future;
    });

    expect(actual, LoggedMessage(RealmLogLevel.detail, "123"));
  });

  test('Realm.logger supports logging from multiple isolates', () async {
    List<LoggedMessage> actual = await Isolate.run(() async {
      var completer = Completer<void>();
      final result = <LoggedMessage>[];

      Realm.logger.level = RealmLogLevel.all;
      Realm.logger.onRecord.listen((event) {
        if (event.message == "stop") {
          return completer.complete();
        }

        result.add(LoggedMessage(event.level, event.message));
      });

      // run a second isolate to listen logging specific log level messages
      await Isolate.run(() async {
        var completer2 = Completer<void>();
        Realm.logger.level = RealmLogLevel.error;
        Realm.logger.onRecord.listen((event) {
          if ((event.level == RealmLogLevel.error && event.message != "2") || (event.level == RealmLogLevel.trace && event.message != "3")) {
            throw RealmError("Unexpected message ${LoggedMessage(event.level, event.message)}");
          }

          completer2.complete();
        });

        Future<void> logTestMessage(Level level, String message) async {
          completer2 = Completer<void>();
          RealmInternal.logMessageForTesting(level, message);
          if (Realm.logger.level == RealmLogLevel.off) {
            Future<void>.delayed(const Duration(milliseconds: 10)).then((value) {
              completer2.complete();
            }).ignore();
          }
          await completer2.future;
        }

        await logTestMessage(RealmLogLevel.error, "2");
        await logTestMessage(RealmLogLevel.error, "2");

        // turn off second isolate
        Realm.logger.level = RealmLogLevel.off;

        // log another message. second isoalte should not get it
        await logTestMessage(RealmLogLevel.error, "first only");

        // turn on second isolate
        Realm.logger.level = RealmLogLevel.trace;

        // log a another message
        await logTestMessage(RealmLogLevel.trace, "3");

        // stop all isolates signal
        await logTestMessage(RealmLogLevel.detail, "stop");

        return await completer2.future;
      });

      await completer.future;

      return result;
    });

    final expected = [
      const LoggedMessage(RealmLogLevel.error, "2"),
      const LoggedMessage(RealmLogLevel.error, "2"),
      const LoggedMessage(RealmLogLevel.error, "first only"),
      const LoggedMessage(RealmLogLevel.trace, "3")
    ];

    //first isolate should have collected all the messages
    expect(actual, containsAllInOrder(expected));
  });
}
