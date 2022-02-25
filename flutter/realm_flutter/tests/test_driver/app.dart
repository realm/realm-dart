import 'package:flutter_driver/driver_extension.dart';

import 'realm_test.dart' as tests;
import 'const.dart';

void main(List<String> args) async {
  enableFlutterDriverExtension(handler: (command) async {
    if (command!.startsWith(testCommand)) {

      //Using the environment since --dart-entrypoint-args= is not working in 
      //Flutter 2.5 with command 
      //flutter drive -t test_driver/app.dart --dart-entrypoint-args="--testname"
      var testName = const String.fromEnvironment(envTestName);
      if (testName.isEmpty && args.isNotEmpty) {
        print("Using testName: \"${args[0]}\" from args");
        testName = args[0];
      }

      List<String> testArgs = List<String>.empty();
      if (testName.isNotEmpty) {
        // Build correct test arguments using the dart test arg name '--name'
        testArgs = ['--name', testName];
      }

      //Invoke the actual Dart tests inside Flutter
      return await tests.main(testArgs);
    }
    else {
      throw Exception('Unknown command: $command');
    }
  });
}