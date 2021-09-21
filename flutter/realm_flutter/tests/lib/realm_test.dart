// @dart=2.10

import 'dart:async';
import 'dart:io';

import 'package:realm/realm.dart';
import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/state.dart' as test_api;

Future<String> main() {
  final Completer<String> completer = Completer<String>();
  initRealm();

  final List<String> failedTests = [];

  group('RealmClass tests', () {
    test('Realm version', () {
      expect(Realm.version, contains('11.'));
    });
  });

  tearDown(() {
    if (Invoker.current.liveTest.state.result == test_api.Result.error || Invoker.current.liveTest.state.result == test_api.Result.failure) {
      failedTests.add(Invoker.current.liveTest.individualName);
    }
  });

  tearDownAll(() {
    if (failedTests.isNotEmpty) {
      completer.completeError(failedTests.join('\n'));
    }
    else {
      completer.complete(null);
    }
  });

  return completer.future;
}