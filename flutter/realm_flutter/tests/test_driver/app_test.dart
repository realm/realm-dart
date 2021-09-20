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

     test('Realm Flutter Tests', () async {
      String result = await driver.requestData('tests');
      if (result != null) {
        fail('Failed tests: $result');
      }
    });
  });
}