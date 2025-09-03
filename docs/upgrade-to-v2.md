# Upgrade to Flutter SDK v2.0.0
Realm SDK for Flutter version 2.0.0 introduces several breaking changes
that impact existing apps upgrading from an earlier version.

Notably, this version of the SDK:

- Changes the part builder and how the SDK generates files for
your data model classes. This change impacts all apps upgrading from an
earlier version of the SDK. Refer to the Builder Changes
section on this page for information and instructions.
- Removes or replaces several classes and members. These changes may or may not impact your
app. Refer to the Removed Classes and Members section
on this page for information and instructions for impacted apps.

## Builder Changes
> **IMPORTANT:**
> This change impacts all apps upgrading from an earlier version of the SDK.
>

Flutter SDK version 2.0.0 updates the SDK's `realm_generator` to use a
`PartBuilder` instead of a `SharedPartBuilder`.
This updated builder generates `RealmModel` data model files with a new
`.realm.dart` file extension:

|Version|File Extension|Example Part Directive|
| --- | --- | --- |
|SDK v2.0.0 and later|`.realm.dart`|`part 'car.realm.dart';`|
|SDK v1.9.0 and earlier|`.g.dart`|`part 'car.g.dart';`|

> **TIP:**
> The update from `SharedPartBuilder` to `PartBuilder` makes it easier
> to use multiple builders in your app. For example, combining `realm_dart`
> with a serialization package builder such as `dart_mappable` or
> `json_serializable`.
>

### What Do I Need to Do?
When you upgrade an existing app from an earlier version of the Flutter SDK to
version 2.0.0 or later, you *must* update any existing part declarations, then
regenerate the object models with the new `.realm.dart` file extension:

#### Update Your Existing Part Declarations
Update all of the `RealmObject` part declarations in your app to
use the new naming convention:

```dart
import 'package:realm_dart/realm.dart';

// Update existing declaration from .g.dart to .realm.dart
// part 'car.g.dart';
part 'car.realm.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late ObjectId id;

  late String make;
  late String? model;
  late int? miles;
}
```

#### Regenerate Your Object Models
### Flutter
After you update all of your declarations, regenerate your
object models with the new `.realm.dart` file extension.
You can safely delete any `.g.dart` files from your project.

```shell
dart run realm generate
```

#### Dart
After you update all of your declarations, regenerate your
object models with the new `.realm.dart` file extension.
You can safely delete any `.g.dart` files from your project.

```shell
dart run realm_dart generate
```

## Removed Classes and Members
Flutter SDK version 2.0.0 also removed or replaced several classes, members, and properties
from the SDK. These changes may or may not impact your app.

The following table outlines what was removed and why, as well as a recommended solution
when upgrading an app that used the removed class or member, if any:

|Removed Class or Member|Reason|Solution|
| --- | --- | --- |
|`Realm.logger.level`|Replaced by `Realm.logger.setLogLevel`.|Replace any instances. See also Logging - Flutter SDK.|
|`RealmProperty.indexed`|Replaced by `RealmProperty.indexType`.|Replace any instances.|
|`RealmValue.type`|Changed to an enum of `RealmValueType`.|Replace any instances. See also RealmValue Data Type.|
|`RealmValue.uint8List`|Renamed to `RealmValue.binary`.|Replace any instances. See also RealmValue Data Type.|
|`SchemaObject.properties`|`SchemaObject` changed to an iterable collection of `SchemaProperty`.|Replace any instances. See also the [SchemaObject](https://pub.dev/documentation/realm/latest/realm/SchemaObject-class.html) API reference.|
