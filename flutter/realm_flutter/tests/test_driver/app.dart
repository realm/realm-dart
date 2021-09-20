// @dart=2.10


import 'dart:async';

import 'package:flutter_driver/driver_extension.dart';
import 'package:test/expect.dart';
import 'package:tests/main.dart' as app;
import 'package:tests/realm_test.dart' as tests;

void main() {
  enableFlutterDriverExtension(handler: (command) async {
    if (command == 'tests') {
      return await tests.main();
    }
    else {
      fail('Unknown command: $command');
    }
  });

  app.main();
}