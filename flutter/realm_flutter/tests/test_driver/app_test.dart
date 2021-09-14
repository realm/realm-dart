// @dart=2.10

// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:realm/realm.dart';

void main() {
  group('Realm tests', () {
    FlutterDriver driver;

    // // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      initRealm();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver.close();
    });

     test('Realm version', () {
      expect(Realm.version, contains('11.'));
    });
  });
}