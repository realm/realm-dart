# Quick Start - Flutter SDK
This page contains information to quickly get Realm integrated into your Flutter app.

Before you begin, ensure you have:

- Installed the Flutter SDK

## Define Your Object Model
Your application's **data model** defines the structure of data stored within Realm.
You can define your application's data model via Dart classes in your
application code with a Realm object schema.
You then have to generate the
[RealmObjectBase](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase-mixin.html)
class that's used within your application.

For more information, refer to Define a Realm Object Schema.

### Create Data Model
To define your application's data model, add a Realm model class
definition to your application code.

Some considerations when defining your Realm model class:

- Import package at the top of your class definition file.
- In your file, give your class a private name (starting with `_`),
such as a file `car.dart` with a class `_Car`.

  You generate the public `RealmObject` class using the command in the following
*Generate RealmObject Class* section. This command
outputs a public class, such as `Car`.
- Make sure to include the generated file name, such as `part car.realm.dart`,
before the code defining your model.
This is required to generate the `RealmObject` class.

#### Flutter
```dart
import 'package:realm/realm.dart';

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

#### Dart
```dart
import 'package:realm_dart/realm.dart';

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

### Generate RealmObject Class
Now generate a `RealmObject` class `Car` from the data model class `Car`:

#### Flutter
```shell
dart run realm generate
```

#### Dart
```shell
dart run realm_dart generate
```

Running this creates a `Car` class in a `car.realm.dart` file located in the directory
where you defined the model class in the previous Create Data Model section.
This `Car` class is public and part of the same library as the `_Car` data model class.

The generated `Car` class is what's used throughout your application.

If you'd like to watch your data model class to generate a new `Car` class whenever
there's a change to `_Car`, run:

#### Flutter
```shell
dart run realm generate --watch
```

#### Dart
```shell
dart run realm_dart generate --watch
```

## Open a Realm
Use the
[Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html)
class to control the specifics of the realm you would like to open, including schema.

Pass your configuration to the
[Realm constructor](https://pub.dev/documentation/realm/latest/realm/Realm-class.html)
to generate an instance of that realm:

```dart
final config = Configuration.local([Car.schema]);
final realm = Realm(config);
```

You can now use that realm instance to work with objects in the database.

For more information, refer to Configure and Open a Realm.

## Work with Realm Objects
Once you've opened a realm, you can create objects within it using a
[write transaction block](https://pub.dev/documentation/realm/latest/realm/Realm/write.html).

For more information, refer to Write Transactions.

### Create Objects
To create a new `Car`, instantiate an instance of the
`Car` class and add it to the realm in a write transaction block:

```dart
final car = Car(ObjectId(), 'Tesla', model: 'Model S', miles: 42);
realm.write(() {
  realm.add(car);
});
```

### Update Objects
To modify a car, update its properties in a write transaction block:

```dart
realm.write(() {
  car.miles = 99;
});
```

### Query for Objects
Retrieve a collection of all objects of a data model in the realm with the
[Realm.all()](https://pub.dev/documentation/realm/latest/realm/Realm/all.html)
method:

```dart
final cars = realm.all<Car>();
final myCar = cars[0];
print('My car is ${myCar.make} ${myCar.model}');
```

Filter a collection to retrieve a specific segment
of objects with the [Realm.query()](https://pub.dev/documentation/realm/latest/realm/Realm/query.html) method.
In the `query()` method's argument,
use Realm Query Language operators to perform filtering.

```dart
final cars = realm.query<Car>('make == "Tesla"');
```

### Delete Objects
Delete a car by calling the [Realm.delete()](https://pub.dev/documentation/realm/latest/realm/Realm/delete.html)
method in a write transaction block:

```dart
realm.write(() {
  realm.delete(car);
});
```

### React to Changes
Listen and respond to changes to a query, a single object, or a list within an object.
The change listener is a Stream that invokes a callback function with an containing
changes since last invocation as its argument.

To listen to a query, use [RealmResults.changes.listen()](https://pub.dev/documentation/realm/latest/realm/RealmResultsChanges-class.html).

```dart
// Listen for changes on whole collection
final characters = realm.all<Character>();
final subscription = characters.changes.listen((changes) {
  changes.inserted; // Indexes of inserted objects.
  changes.modified; // Indexes of modified objects.
  changes.deleted; // Indexes of deleted objects.
  changes.newModified; // Indexes of modified objects after accounting for deletions & insertions.
  changes.moved; // Indexes of moved objects.
  changes.results; // The full List of objects.
  changes.isCleared; // `true` after call to characters.clear(); otherwise, `false`.
});

// Listen for changes on RealmResults.
final hobbits = fellowshipOfTheRing.members.query('species == "Hobbit"');
final hobbitsSubscription = hobbits.changes.listen((changes) {
  // ... all the same data as above
});
```

You can pause and resume subscriptions as well.

```dart
subscription.pause();
// The changes.listen() method won't fire until subscription is resumed.
subscription.resume();
```

Once you've finished listening to changes, close the change listener to prevent memory leaks.

```dart
await subscription.cancel();
```

For more information, refer to React to Changes.

## Close a Realm
Once you've finished working with a realm, close it to prevent memory leaks.

```dart
realm.close();
```

## Further Examples and Next Steps
For examples of the Flutter SDK methods described above and more,
refer to the [Realm Dart Samples Github repo](https://github.com/realm/realm-dart-samples).
