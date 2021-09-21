// @dart=2.10

import 'package:flutter_driver/driver_extension.dart';
import 'package:tests/main.dart' as app;
import '../test/realm_test.dart' as tests;

void main() async {
  enableFlutterDriverExtension(handler: (command) async {
    if (command == 'tests') {
      return await tests.main();
    }
    else {
      throw Exception('Unknown command: $command');
    }
  });

  app.main();
}