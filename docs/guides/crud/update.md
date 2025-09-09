# CRUD - Update - Flutter SDK
Updates to `RealmObjects` must occur within write transactions. For more
information about write transactions, see: Write Transactions.

The SDK supports update and upsert operations. An **upsert** operation either
inserts a new instance of an object or updates an existing object that meets
certain criteria. For more information, refer to the **Upsert Objects**
section on this page.

## Update Objects
The examples on this page use two object types, `Person` and `Team`.

```dart
@RealmModel()
class _Person {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late List<String> hobbies;
}

@RealmModel()
class _Team {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late List<_Person> crew;
  late RealmValue eventLog;
}
```

### Update Object Properties
To modify an object's properties, update the properties in a write transaction
block.

```dart
realm.write(() {
  spaceshipTeam.name = 'Galactic Republic Scout Team';
  spaceshipTeam.crew
      .addAll([Person(ObjectId(), 'Luke'), Person(ObjectId(), 'Leia')]);
});
```

### Upsert Objects
To upsert an object, call [Realm.add()](https://pub.dev/documentation/realm/latest/realm/Realm/add.html)
with the optional `update` flag set to `true` inside a transaction block.
The operation inserts a new object with the given primary key
if an object with that primary key does not exist. If there's already an object
with that primary key, the operation updates the existing object for that
primary key.

```dart
final id = ObjectId();
// Add Anakin Skywalker to the realm with primary key `id`
final anakin = Person(
  id,
  "Anakin Skywalker",
);
realm.write(() {
  realm.add<Person>(anakin);
});

// Overwrite the 'Anakin' Person object
// with a new 'Darth Vader' object
final darthVader = Person(id, 'Darth Vader');
realm.write(() {
  realm.add<Person>(darthVader, update: true);
});
```
