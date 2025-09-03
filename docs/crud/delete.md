# CRUD - Delete - Flutter SDK
You can choose to delete a single object, multiple objects, or all objects
from the database. After you delete an object, you can no longer access or
modify it. If you try to use a deleted object, the SDK throws an error.

Deleting objects from the database does not delete the realm file or affect
the schema. It only deletes the object instance from the database. If you
want to delete the realm file itself, refer to Delete a Realm File - Flutter SDK.

## Delete Objects
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

### Delete a Single Object
Delete an object from the database by calling [Realm.delete()](https://pub.dev/documentation/realm/latest/realm/Realm/delete.html)
in a write transaction block.

```dart
realm.write(() {
  realm.delete(obiWan);
});
```

### Delete Multiple Objects
Delete multiple objects from the database by calling [Realm.deleteMany()](https://pub.dev/documentation/realm/latest/realm/Realm/deleteMany.html) in a write transaction block.

```dart
realm.write(() {
  realm.deleteMany([obiWan, quiGon]);
});
```

### Delete All Objects of a Type
Delete all objects of a type in the database with [Realm.deleteAll()](https://pub.dev/documentation/realm/latest/realm/Realm/deleteAll.html)
in a write transaction block.

```dart
realm.write(() {
  realm.deleteAll<Person>();
});
```
