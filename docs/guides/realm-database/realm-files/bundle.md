# Bundle a Realm - Flutter SDK
You might want to seed your mobile app with some initial data that will be available
to users on the initial launch of the app. To do this, you can bundle an existing
realm file in your Flutter app.

> **TIP:**
> You can also add data to your realm the first time an application opens it
> using the initial data callback function.
>

## Bundle a Local Realm
### Create a Realm File for Bundling
Create a new project with the same Realm object schema as your production app.
Open an existing realm with the data you wish to bundle, or create a new one.

Get the path to the realm file with the [Realm.config.path](https://pub.dev/documentation/realm/latest/realm/Configuration/path.html)
property.

```dart
print("Bundling realm");
final config = Configuration.local([Car.schema], path: 'bundle.realm');
final realm = Realm(config);

realm.write(() {
  realm.add(Car(ObjectId(), "Audi", model: 'A8'));
  realm.add(Car(ObjectId(), "Mercedes", model: 'G Wagon'));
});
print("Bundled realm location: " + realm.config.path);
realm.close();
```

> **TIP:**
> You might want to use the Dart Standalone SDK to create the bundled realm for your Flutter application for the following reasons:
>
> - Creating a bundled realm does not require any Flutter UI elements.
> - Dart standalone projects require less boilerplate code than Flutter projects
>

### Bundle a Realm File in Your Production Application
Now that you have a copy of the realm with the "seed" data in it, you
need to bundle it with your production application.

Add the realm file to your application's [Flutter assets](https://docs.flutter.dev/development/ui/assets-and-images).
For example you could add the bundled realm in your project at the location
assets/bundled.realm.

Add a reference to the bundled realm to your `pubspec.yaml` file
to include it in your production application:

```yaml
flutter:
  assets:
  - realm/bundle.realm
```

### Open a Realm from a Bundled Realm File
Now that you have a copy of the realm included with your app, you need to
add code to use it.

Before you deploy your app with the bundled realm, you need to
extract the realm from the embedded resources, save it to the app's data
location, and then open this new realm in the app. The following code shows
how you can do this during start-up of the app.

Create a helper function `initBundledRealm` to check if the bundled realm
already exists within the app, and load it into the app if it does not exist yet.
Call `initBundledRealm` before calling loading the app's widgets with
[runApp()](https://api.flutter.dev/flutter/widgets/runApp.html).

```dart
// Also import Realm schema and Flutter widgets
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'dart:io';

Future<Realm> initBundledRealm(String assetKey) async {
  final config = Configuration.local([Car.schema]);
  final file = File(config.path);
  if (!await file.exists()) {
    final realmBytes = await rootBundle.load(assetKey);
    await file.writeAsBytes(
        realmBytes.buffer
            .asUint8List(realmBytes.offsetInBytes, realmBytes.lengthInBytes),
        mode: FileMode.write);
  }
  return Realm(config);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final realm = await initBundledRealm("assets/bundle.realm");
  runApp(const MyApp());
}
```
