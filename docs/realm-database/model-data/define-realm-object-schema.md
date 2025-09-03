# Define a Realm Object Schema - Flutter SDK
> **IMPORTANT:**
> Flutter SDK version 2.0.0 introduces an update to the
> builder, which impacts how files generate. In v2.0.0 and later, all
> generated files use the `.realm.dart` naming convention instead of `.g.dart`.
>
> This is a breaking change for existing apps. For information on how to upgrade an existing app from an earlier SDK version to v2.0.0 or later,
> refer to Upgrade to Flutter SDK v2.0.0.
>

An **object schema** is a configuration object that defines the properties and
relationships of a Realm object. Realm client
applications define object schemas with the native class implementation in their
respective language using the Object Schema.

Object schemas specify constraints on object properties such as the data
type of each property and whether or not a property is required. Schemas can
also define relationships between object
types in a realm.

## Create Model
#### Import Realm
Import the Realm SDK package at the top of your file.

#### Flutter
```dart
import 'package:realm/realm.dart';
```

#### Dart
```dart
import 'package:realm_dart/realm.dart';
```

#### Create Generated File Part Directive
> Version changed: v2.0.0 Generated files are named  instead of
> `.g.dart`
>

Add a part directive to include the `RealmObject` file that you generate in step 4
in the same package as the file you're currently working on.

```dart
part 'schemas.realm.dart';
```

#### Create RealmModel
Create the model for your Realm schema.
You must include the annotation [RealmModel](https://pub.dev/documentation/realm_common/latest/realm_common/RealmModel-class.html)
at the top of the class definition.

You'll use the `RealmModel` to generate the public `RealmObject`
used throughout the application in step 4.

You can make the model private or public. We recommend making
the all models private and defining them in a single file.
Prepend the class name with an underscore (`_`) to make it private.

If you need to define your schema across multiple files,
you can make the RealmModel public. Prepend the name with a dollar sign (`$`)
to make the model public. You must do this to generate the `RealmObject`
from the `RealmModel`, as described in step 4.

Add fields to the `RealmModel`.
You can add all supported data types.
Include additional behavior using property annotations.

```dart
@RealmModel()
class _Car {
  @PrimaryKey()
  late ObjectId id;

  late String make;
  late String? model;
  late int? miles;
}
```

> **NOTE:**
> Class names are limited to a maximum of 57 UTF-8 characters.
>

#### Generate RealmObject
> Version changed: v2.0.0Generated files are named  instead of
> `.g.dart`
>

Generate the `RealmObject`, which you'll use in your application:

#### Flutter
```shell
dart run realm generate
```

#### Dart
```shell
dart run realm_dart generate
```

This command generates the file in the same directory as your model file.
It has the name you specified in the part directive of step 2.

> Tip:
> Track the generated file in your version control system, such as git.
>

> Example:
> ```
> .
> ├── schemas.dart
> ├── schemas.realm.dart // newly generated file
> ├── myapp.dart
> └── ...rest of application
> ```
>

#### Use RealmObject in Application
Use the `RealmObject` that you generated in the previous step in your application.
Since you included the generated file as part of the same package
where you defined the `RealmModel` in step 2, access the `RealmObject`
by importing the file with the `RealmModel`.

```dart
import './schemas.dart';

final hondaCivic = Car(ObjectId(), 'Honda', model: 'Civic', miles: 99);

```

## Supported Data Types
Realm schemas support many Dart-language data types, in addition to some Realm-specific types.
For a comprehensive reference of all supported data types, refer to Data Types.

## Property Annotations
Use annotations to add functionality to properties in your Realm object models.
You can use annotations for things like marking a property as nullable,
setting a primary key, ignoring a property, and more.
To learn more about the available property annotations,
refer to Property Annotations.

## Define Relationship Properties
You can define relationships between Realm objects in your schema.
The Realm Flutter SDK supports to-one relationships, to-many relationships,
inverse relationships, and embedding objects within other objects.
To learn more about how to define relationships in your Realm object schema,
refer to Relationships.

## Map a Model or Class to a Different Name
You can use the [MapTo](https://pub.dev/documentation/realm_common/latest/realm_common/MapTo-class.html)
annotation to map a Realm object model or property to a different stored
name in Realm. This can be useful in the following scenarios. For example:

- To make it easier to work across platforms where naming conventions
differ.
- To change a class or field name without forcing a migration.
- To support multiple model classes with the same name in different packages.
- To use a class name that is longer than the 57-character limit enforced
by Realm.

#### Remap Class

```dart
@RealmModel()
@MapTo('naval_ship')
class _Boat {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late int? maxKnots;
  late int? nauticalMiles;
}

```

#### Remap Property

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String? maybeDescription; // optional value

  late double milesTravelled = 0; // 0 is default value

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make;

  @MapTo('wheels') // 'wheels' is property name in the RealmObject
  late int numberOfWheels;
}

```

## Model Unstructured Data
> Version added: 2.0.0

Starting in Flutter SDK version 2.0.0, you can store
collections of mixed data
within a  `RealmValue` property. You can use this feature to model complex
data structures, such as JSON, without having to define a
strict data model.

**Unstructured data** is data that doesn't easily conform to an expected
schema, making it difficult or impractical to model to individual
data classes. For example, your app might have highly variable data or dynamic
data whose structure is unknown at runtime.

Storing collections in a mixed property offers flexibility without sacrificing
functionality. And
you can work with them the same way you would a non-mixed
collection:

- You can nest mixed collections up to 100 levels.
- You can query on and react to changes
on mixed collections.
- You can find and update individual mixed collection elements.

However, storing data in mixed collections is less performant than using a structured
schema or serializing JSON blobs into a single string property.

To model unstructured data in your app, define the appropriate properties in
your schema as RealmValue types. You can then set
these `RealmValue` properties as a RealmList or a
RealmMap collection of `RealmValue` elements.
Note that `RealmValue` *cannot* represent a `RealmSet` or an embedded object.

For example, you might use a `RealmValue` that contains a map of mixed
data when modeling a variable event log object:

```dart
// Define class with a `RealmValue` property
@RealmModel()
class _EventLog {
  @PrimaryKey()
  late ObjectId id;

  late String eventType;
  late DateTime timestamp;
  late String userId;
  late RealmValue details;
}

```

```dart
realm.write(() {
  // Add `eventLog` property data as a map of mixed data, which
  // also includes nested lists of mixed data
  realm.add(EventLog(ObjectId(), 'purchase', DateTime.now(), 'user123',
      details: RealmValue.from({
        'ipAddress': '192.168.1.1',
        'items': [
          {'id': 1, 'name': 'Laptop', 'price': 1200.00},
          {'id': 2, 'name': 'Mouse', 'price': 49.99}
        ],
        'total': 1249.99
      })));

  final eventLog = realm.all<EventLog>().first;
  final items = eventLog.details.asMap();
  print('''
      Event Type: ${eventLog.eventType}
      Timestamp: ${eventLog.timestamp}
      User ID: ${eventLog.userId}
      Details:
        Item:
  ''');
  for (var item in items.entries) {
    print('${item.key}: ${item.value}');
  }

```

```shell
Event Type: purchase
Timestamp: 2024-03-18 13:50:58.402979Z
User ID: user123
Details:
Item:
   ipAddress: RealmValue(192.168.1.1)
   items: RealmValue([RealmValue({id: RealmValue(1), name: RealmValue(Laptop), price: RealmValue(1200.0)}), RealmValue({id: RealmValue(2), name: RealmValue(Mouse), price: RealmValue(49.99)})])
   total: RealmValue(1249.99)
```

> Tip:
> - Use a map of mixed data types when the type is unknown but each value will have a unique identifier.
> - Use a list of mixed data types when the type is unknown but the order of objects is meaningful.
>

## Generate the RealmObject
> Version changed: v2.0.0Generated files are named  instead of
> `.g.dart`
>

Once you've completed your Realm model, you must generate the
[RealmObject](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase-mixin.html) class to use
it in your application.

Run the following command to generate `RealmObjects`:

#### Flutter

```
dart run realm generate
```

#### Dart

```
dart run realm_dart generate
```

Running this creates a public class in a new file in the directory
where you defined the `RealmModel` class per the Create Model section.

The generated file has the same base name as the file with your `RealmModel`,
ending with `.realm.dart`. For example if the file with your `RealmModel`
is named `schemas.dart`, the generated file will be `schemas.realm.dart`.

> **NOTE:**
> Remember to include the generated file in a part directive in
your `RealmModel` definition file.
>
> ```dart
> // ...import packages
>
> part 'schemas.realm.dart';
>
> @RealmModel()
> // ...model definition
> ```
>

If you'd like to watch your data models to generate `RealmObjects` whenever there's a change,
include the `--watch` flag in your command.

#### Flutter

```
dart run realm generate --watch
```

#### Dart

```
dart run realm_dart generate --watch
```

To clean the generator caches, include the `--clean` flag in your command.
Cleaning the generator cache can be useful when debugging.

#### Flutter

```
dart run realm generate --clean
```

#### Dart

```
dart run realm_dart generate --clean
```
