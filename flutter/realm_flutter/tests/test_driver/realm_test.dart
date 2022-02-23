import 'dart:async';

import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/state.dart' as test_api;

import '../test/configuration_test.dart' as configuration_test;
import '../test/realm_test.dart' as realm_tests;
import '../test/realm_object_test.dart' as realm_object_tests;
import '../test/list_test.dart' as list_tests;
import '../test/results_test.dart' as results_tests;

Future<String> main(List<String> args) async {
  final Completer<String> completer = Completer<String>();
  final List<String> failedTests = [];

  await configuration_test.main(args);
  await realm_tests.main(args);
  await realm_object_tests.main(args);
  await list_tests.main(args);
  await results_tests.main(args);

  tearDown(() {
    if (Invoker.current?.liveTest.state.result == test_api.Result.error || Invoker.current?.liveTest.state.result == test_api.Result.failure) {
      failedTests.add(Invoker.current!.liveTest.individualName);
    }
  });

  tearDownAll(() {
    if (failedTests.isNotEmpty) {
      completer.complete(failedTests.join('\n'));
    } else {
      completer.complete('');
    }
  });

  return completer.future;
}
