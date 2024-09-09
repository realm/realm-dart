// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';

import '../../../realm_dart/test/test.dart' as test;

import '../../../realm_dart/test/backlinks_test.dart' as backlinks_test;
import '../../../realm_dart/test/configuration_test.dart' as configuration_test;
import '../../../realm_dart/test/decimal128_test.dart' as decimal128_test;
import '../../../realm_dart/test/dynamic_realm_test.dart' as dynamic_realm_test;
import '../../../realm_dart/test/embedded_test.dart' as embedded_test;
import '../../../realm_dart/test/geospatial_test.dart' as geospatial_test;
import '../../../realm_dart/test/indexed_test.dart' as indexed_test;
import '../../../realm_dart/test/list_test.dart' as list_test;
import '../../../realm_dart/test/migration_test.dart' as migration_test;
import '../../../realm_dart/test/realm_logger_test.dart' as realm_logger_test;
import '../../../realm_dart/test/realm_map_test.dart' as realm_map_test;
import '../../../realm_dart/test/realm_object_test.dart' as realm_object_test;
import '../../../realm_dart/test/realm_set_test.dart' as realm_set_test;
import '../../../realm_dart/test/realm_test.dart' as realm_test;
import '../../../realm_dart/test/realm_value_test.dart' as realm_value_test;
import '../../../realm_dart/test/results_test.dart' as results_test;
import '../../../realm_dart/test/serialization_test.dart' as serialization_test;

Future<void> _copyBundledFile(String fromPath, String toPath) async {
  final data = await rootBundle.load(fromPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(toPath).writeAsBytes(bytes);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // To support both dart test and flutter integration test we pass an alternative
  // copyFile function. Remember to add any needed files as assets in pubspec.yaml.
  test.copyFile = _copyBundledFile;

  group('backlinks_test.dart', backlinks_test.main);
  group('configuration_test.dart', configuration_test.main);
  group('decimal128_test.dart', decimal128_test.main);
  group('dynamic_realm_test.dart', dynamic_realm_test.main);
  group('embedded_test.dart', embedded_test.main);
  group('geospatial_test.dart', geospatial_test.main);
  group('indexed_test.dart', indexed_test.main);
  group('list_test.dart', list_test.main);
  group('migration_test.dart', migration_test.main);
  group('realm_logger_test.dart', realm_logger_test.main);
  group('realm_map_test.dart', realm_map_test.main);
  group('realm_object_test.dart', realm_object_test.main);
  group('realm_set_test.dart', realm_set_test.main);
  group('realm_test.dart', realm_test.main);
  group('realm_value_test.dart', realm_value_test.main);
  group('results_test.dart', results_test.main);
  group('serialization_test.dart', serialization_test.main);
}
