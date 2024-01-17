import 'dart:async';

import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/state.dart' as test_api;

import '../test/app_test.dart' as app_test;
import '../test/asymmetric_test.dart' as asymmetric_test;
import '../test/backlinks_test.dart' as backlinks_test;
import '../test/client_reset_test.dart' as client_reset_test;
import '../test/configuration_test.dart' as configuration_test;
import '../test/credentials_test.dart' as credentials_test;
import '../test/decimal128_test.dart' as decimal128_test;
import '../test/dynamic_realm_test.dart' as dynamic_realm_test;
import '../test/embedded_test.dart' as embedded_test;
import '../test/geospatial_test.dart' as geospatial_test;
import '../test/indexed_test.dart' as indexed_test;
import '../test/list_test.dart' as list_test;
import '../test/migration_test.dart' as migration_test;
import '../test/realm_object_test.dart' as realm_object_test;
import '../test/realm_set_test.dart' as realm_set_test;
import '../test/realm_test.dart' as realm_test;
import '../test/realm_value_test.dart' as realm_value_test;
import '../test/results_test.dart' as results_test;
import '../test/session_test.dart' as session_test;
import '../test/subscription_test.dart' as subscription_test;
import '../test/user_test.dart' as user_test;
import '../test/realm_logger_test.dart' as realm_logger_test;

Future<String> main() async {
  configuration_test.copyFile = _copyBundledFile;

  final Completer<String> completer = Completer<String>();

  try {
    final List<String> failedTests = [];

    app_test.main();
    asymmetric_test.main();
    backlinks_test.main();
    client_reset_test.main();
    configuration_test.main();
    credentials_test.main();
    decimal128_test.main();
    dynamic_realm_test.main();
    embedded_test.main();
    geospatial_test.main();
    indexed_test.main();
    list_test.main();
    migration_test.main();
    realm_logger_test.main();
    realm_object_test.main();
    realm_set_test.main();
    realm_test.main();
    realm_value_test.main();
    results_test.main();
    session_test.main();
    subscription_test.main();
    user_test.main();

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
  } catch (e) {
    completer.complete(e.toString());
  }

  return completer.future;
}
