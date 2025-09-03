# Test & Debug - Flutter SDK
This page covers some strategies for testing and debugging Flutter apps
using the Realm Flutter SDK. You likely will have to adapt the examples
on this page significantly to work with your app.

## Test
To run tests on the Flutter SDK using the
[flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
and [test](https://dart.dev/tools/dart-test), you must first run
the following command:

```shell
dart run realm install
```

This command installs native binaries needed to run tests for the
Flutter app.

> **NOTE:**
> *If you are developing with the Realm Flutter SDK on macOS*,
> network requests do not work by default due to built-in macOS security settings.
> To fix this, you must change the Flutter app's macOS network
> entitlements. To learn how to do this, refer to Use Realm with the
> macOS App Sandbox.
>
> *If you're using the Dart Standalone SDK, you do don't need to install
> any additional native binaries to run tests*. This is because as part
> of the installation to use the Dart Standalone SDK
> in an app, you already need to install the native binaries.
>

### Test Using an In-Memory Realm
An easy way to use and test Realm-backed applications is to test
using an in-memory realm. This helps avoid overriding application data or leaking state
between tests.
To create an in-memory realm for your tests, you can do the following:

1. Lazily instantiate the `Realm` with the `late` keyword at a higher scope than your tests
2. Open the realm with a Configuration.inMemory()
inside a [setUp function](https://api.flutter.dev/flutter/flutter_test/setUp.html).
3. Close the realm in a [tearDown function](https://api.flutter.dev/flutter/flutter_test/tearDown.html).

```dart
import 'package:realm/realm.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/schema.dart'; // Import schema used in test

void main() {
  late Realm realm;
  setUp(() {
    realm = Realm(Configuration.inMemory([Car.schema]));
  });
  tearDown(() {
    realm.close();
  });

  // ...rest of test code
}
```

### Test Using a Default Realm
Another way to use and test Realm-backed applications is to
use the default realm. To avoid overriding application data or leaking
state between tests, set the default realm to a new file for each test
using `Configuration.defaultRealmName`
inside of a [setUp function](https://api.flutter.dev/flutter/flutter_test/setUp.html).

```dart
import 'dart:math';
import 'package:realm/realm.dart';
import 'package:flutter_test/flutter_test.dart';

// Utility function to generate random realm name
String generateRandomRealmName(int len) {
  final r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final nameBase =
      List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  return '$nameBase.realm';
}

void main() {
  // Set default Realm name before each test
  setUp(() {
    Configuration.defaultRealmName = generateRandomRealmName(10);
  });

  // ...rest of test code
}
```

### Clean up Realm in Tests
To clean up your tests, you can lazily instantiate the realm with the
`late` keyword at a higher scope than your tests. Then run clean up
operations inside of a [tearDown function](https://api.flutter.dev/flutter/flutter_test/tearDown.html).
Inside of the `tearDown` callback function, close and delete the realm
instance.

```dart
import 'package:realm/realm.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/schema.dart'; // Import schema used in test

void main() {
  late Realm realm;

  // Close and delete the realm after each test
  tearDown(() {
    final path = realm.config.path;
    realm.close();
    Realm.deleteRealm(path);
  });

  test("Open a local realm", () {
    realm = Realm(Configuration.local([Car.schema]));
    expect(realm.isClosed, isFalse);
  });
}
```

## Debug
### Debug with Realm Studio
Realm Studio enables you to open and edit local realms.
It supports Mac, Windows and Linux.

### Debug with DevTools and Code Editors
To debug your app, You can use the Realm Flutter SDK with
[Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview).
