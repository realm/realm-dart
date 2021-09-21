// @dart=2.10

// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Realm tests', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

     // This single tests runs all Realm tests and reports test run failure if any Realm test fails.
     test('run all', () async {
      String result = await driver.requestData('tests');
      if (result != null) {
        fail('Failed tests: $result');
      }
    });
  });
}