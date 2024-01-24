import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';

import '../../../../test/app_test.dart' as app_test;
import '../../../../test/asymmetric_test.dart' as asymmetric_test;
import '../../../../test/backlinks_test.dart' as backlinks_test;
import '../../../../test/client_reset_test.dart' as client_reset_test;
import '../../../../test/configuration_test.dart' as configuration_test;
import '../../../../test/credentials_test.dart' as credentials_test;
import '../../../../test/decimal128_test.dart' as decimal128_test;
import '../../../../test/dynamic_realm_test.dart' as dynamic_realm_test;
import '../../../../test/embedded_test.dart' as embedded_test;
import '../../../../test/geospatial_test.dart' as geospatial_test;
import '../../../../test/indexed_test.dart' as indexed_test;
import '../../../../test/list_test.dart' as list_test;
import '../../../../test/manual_test.dart' as manual_test;
import '../../../../test/migration_test.dart' as migration_test;
import '../../../../test/realm_logger_test.dart' as realm_logger_test;
import '../../../../test/realm_map_test.dart' as realm_map_test;
import '../../../../test/realm_object_test.dart' as realm_object_test;
import '../../../../test/realm_set_test.dart' as realm_set_test;
import '../../../../test/realm_test.dart' as realm_test;
import '../../../../test/realm_value_test.dart' as realm_value_test;
import '../../../../test/results_test.dart' as results_test;
import '../../../../test/session_test.dart' as session_test;
import '../../../../test/subscription_test.dart' as subscription_test;
import '../../../../test/user_test.dart' as user_test;

Future<void> _copyBundledFile(String fromPath, String toPath) async {
  final data = await rootBundle.load(fromPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(toPath).writeAsBytes(bytes);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // To support both dart test and flutter integration test we pass an alternative
  // copyFile function. Remember to add any needed files as assets in pubspec.yaml.
  configuration_test.copyFile = _copyBundledFile;

  group('app_test.dart', app_test.main);
  group('asymmetric_test.dart', asymmetric_test.main);
  group('backlinks_test.dart', backlinks_test.main);
  group('client_reset_test.dart', client_reset_test.main);
  group('configuration_test.dart', configuration_test.main);
  group('credentials_test.dart', credentials_test.main);
  group('decimal128_test.dart', decimal128_test.main);
  group('dynamic_realm_test.dart', dynamic_realm_test.main);
  group('embedded_test.dart', embedded_test.main);
  group('geospatial_test.dart', geospatial_test.main);
  group('indexed_test.dart', indexed_test.main);
  group('list_test.dart', list_test.main);
  group('manual_test.dart', manual_test.main);
  group('migration_test.dart', migration_test.main);
  group('realm_logger_test.dart', realm_logger_test.main);
  // Something sinister is going on with the realm_map_test on Android,
  // when run as integration test. It works fine when run as a unit test.
  if (!Platform.isAndroid) group('realm_map_test.dart', realm_map_test.main);
  group('realm_object_test.dart', realm_object_test.main);
  group('realm_set_test.dart', realm_set_test.main);
  group('realm_test.dart', realm_test.main);
  group('realm_value_test.dart', realm_value_test.main);
  group('results_test.dart', results_test.main);
  group('session_test.dart', session_test.main);
  group('subscription_test.dart', subscription_test.main);
  group('user_test.dart', user_test.main);
}
