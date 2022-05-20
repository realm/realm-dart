import 'dart:io';

// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'const.dart';

void main(List<String> args) {
  print("Current PID $pid");

  group('Realm tests', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver!.close();
    });

    // This single tests runs all Realm tests and reports test run failure if any Realm test fails. Contains all failed tests names.
    test('run all', () async {
      String testCommandWithArgs = testCommand;
      testCommandWithArgs += getArgFromEnvVariable("BAAS_URL");
      testCommandWithArgs += getArgFromEnvVariable("BAAS_CLUSTER");
      testCommandWithArgs += getArgFromEnvVariable("BAAS_API_KEY");
      testCommandWithArgs += getArgFromEnvVariable("BAAS_PRIVATE_API_KEY");
      testCommandWithArgs += getArgFromEnvVariable("BAAS_PROJECT_ID");

      String result = await driver!.requestData(testCommandWithArgs, timeout: const Duration(minutes: 30));
      if (result.isNotEmpty) {
        fail("Failed tests: \n $result");
      }
    }, timeout: const Timeout(Duration(minutes: 30)));
  });
}

String getArgFromEnvVariable(String argName) {
  return " --$argName ${Platform.environment[argName]}";
}
