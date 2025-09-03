# CRUD - Create - Flutter SDK
Realm SDK uses a highly efficient storage engine
to persist objects. You can **create** objects,
**update** objects in the database, and eventually **delete**
objects from the database. Because these operations modify the
state of the database, we call them writes.

## Write Transactions
The SDK handles writes in terms of **transactions**. A
transaction is a list of read and write operations that
the SDK treats as a single indivisible operation. In other
words, a transaction is *all or nothing*: either all of the
operations in the transaction succeed or none of the
operations in the transaction take effect.

All writes must happen in a transaction.

The database allows only one open transaction at a time. The SDK
blocks other writes on other threads until the open
transaction is complete. Consequently, there is no race
condition when reading values from the database within a
transaction.

When you are done with your transaction, the SDK either
**commits** it or **cancels** it:

- When the SDK **commits** a transaction, it writes
all changes to disk.
- When the SDK **cancels** a write transaction or an operation in
the transaction causes an error, all changes are discarded
(or "rolled back").

### Write Operations
Once you've opened a database, you can create objects within it using a
[Realm.write()](https://pub.dev/documentation/realm/latest/realm/Realm/write.html) transaction block.

```dart
realm.write((){
  // ...write data to realm
});
```

You can also return values from the write transaction callback function.

```dart
final yoda = realm.write<Person>(() {
  return realm.add(Person(ObjectId(), 'Yoda'));
});
```

> **WARNING:**
> You can only write `RealmObjects` to a single realm file.
If you already wrote a `RealmObject` to one realm file,
the SDK throws a `RealmException` if you try to write it to another database.
>

### Background Writes
You can add, modify, or delete objects asynchronously using
[Realm.writeAsync()](https://pub.dev/documentation/realm/latest/realm/Realm/writeAsync.html).

When you use `Realm.writeAsync()` to perform write operations, waiting
to obtain the write lock and committing a transaction occur in the background.
Only the write itself occurs on the main process.

This can reduce time spent blocking the execution of the main process.

```dart
// Add Leia to the realm using `writeAsync`
Person leia = Person(ObjectId(), "Leia");
realm.writeAsync(() {
  realm.add<Person>(leia);
});
```

## Create Objects
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

### Create One Object
To add an object to the database, pass an instance of a Realm object class
to the database in a write transaction block with
[Realm.add()](https://pub.dev/documentation/realm/latest/realm/Realm/add.html).

```dart
realm.write(() {
  realm.add(Person(ObjectId(), 'Lando'));
});
```

### Create Multiple Objects
To add multiple objects to a database, pass a list of multiple objects
to [Realm.addAll()](https://pub.dev/documentation/realm/latest/realm/Realm/addAll.html) inside a write transaction block.

```dart
realm.write(() {
  realm.addAll([
    Person(ObjectId(), 'Figrin D\'an'),
    Person(ObjectId(), 'Greedo'),
    Person(ObjectId(), 'Toro')
  ]);
});
```
