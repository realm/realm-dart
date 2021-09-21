// @dart=2.10

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/state.dart' as test_api;

import '../../test/realm_test.dart' as realm_tests;

Future<String> main() {
  final Completer<String> completer = Completer<String>();

  final List<String> failedTests = [];

  realm_tests.main(['--testname', 'Realm version']);

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