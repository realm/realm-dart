# Update a Realm Object Schema - Flutter SDK
You can change the schema of a Realm object after you first create it.
Depending on the type of changes you make to the schema, the changes can be either
automatically applied or require a manual update to the new schema.
Manual schema updates are called **migrations** in Realm.

You can automatically update a Realm object schema when you add or delete a property
from a Realm object model. For more information, refer to the
Automatically Update Schema section.

You must perform a manual migration for all other schema changes.
For more information, refer to the Manually Migrate Schema section.

> Tip:
> When developing or debugging your application, you may prefer to
> delete the realm instead of migrating it. Use the
> [LocalConfiguration.shouldDeleteIfMigrationNeeded](https://pub.dev/documentation/realm/latest/realm/LocalConfiguration/shouldDeleteIfMigrationNeeded.html)
> property to delete the database automatically when a schema mismatch
> requires a migration.
>


## Schema Version
A **schema version** identifies the state of a realm schema at some point in time. Realm tracks the
schema version of each realm and uses it to map the objects in each
realm to the correct schema.

Schema versions are ascending integers that you can optionally include
in the realm configuration when you open a realm. If a client
application does not specify a version number when it opens a realm then
the realm defaults to version `0`.

Manual migrations must update a realm to a higher schema version.
Realm throws an error if a client application opens a realm with a
schema version that is lower than the realm's current version or if
the specified schema version is the same as the realm's current
version but includes different object schemas.

## Automatically Update Schema
Realm can automatically migrate added and deleted properties.
You must update the schema version when you make these changes.

### Add a Property
To add a property to a schema:

1. Add the new property to the object's `RealmModel` class.
2. Regenerate the RealmObject.
3. Set a schema version to the realm's
[Configuration object](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html).

> **EXAMPLE:**
> A realm using schema version `1` has a `Person` object type with a
> `firstName`, and `lastName` property. The developer decides to add an
> `age` property to the `_Person` RealmModel class.
>
> To change the realm to conform to the updated `Person` schema, the
> developer sets the realm's schema version to `2`.
>
> ```dart
> @RealmModel()
> class _Person {
>   late String firstName;
>   late String lastName;
>   late int age;
> }
> ```
>
> ```dart
> final config = Configuration.local([Person.schema], schemaVersion: 2);
> final realm = Realm(config);
> ```
>

### Delete a Property
To delete a property from a schema:

1. Remove the property from the object's `RealmModel` class.
2. Regenerate the RealmObject.
3. In the realm's configuration, include the regenerated `RealmObject.schema`
and increment the `schemaVersion`.

Deleting a property does not impact existing objects.

> **EXAMPLE:**
> A realm using schema version `1` has a `Person` object type with a
> `weight` property. The developer decides to remove the property from
> the schema.
>
> To migrate the realm to conform to the updated `Person` schema, the
> developer sets the realm's schema version to `2`.
>
> ```dart
> final config = Configuration.local([Person.schema], schemaVersion: 2);
> final realm = Realm(config);
> ```
>

## Manually Migrate Schema
For more complex schema updates, Realm requires you to manually migrate
old instances of a given object to the new schema.

When you open the realm with the updated schema, you must do the following
in the realm's `Configuration`:

- Increment the `schemaVersion` property.
- Define the migration logic in a [migrationCallback](https://pub.dev/documentation/realm/latest/realm/MigrationCallback.html)
property of a realm's [Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html).
The migration callback has the following parameters: `migration`: A [Migration](https://pub.dev/documentation/realm/latest/realm/Migration-class.html)
instance with access to the current realm, the realm that you're migrating to,
and methods to help with the migration operation.`oldSchemaVersion`: The number of the previous schema version of the realm
on the device.

The following sections explain how to perform various migration operations.

### Delete an Object Type
To delete all objects of a type from your realm, pass a string representation
of the object schema's name to [Migration.deleteType()](https://pub.dev/documentation/realm/latest/realm/Migration/deleteType.html).

This is useful if the previous version of a schema has a Realm object type,
but the new version of the schema does not.

```dart
final configWithoutPerson = Configuration.local([Car.schema],
    schemaVersion: 2,
    migrationCallback: ((migration, oldSchemaVersion) {
  // Between v1 and v2 we removed the Person type
  migration.deleteType('Person');
}));
final realmWithoutPerson = Realm(configWithoutPerson);
```

### Rename a Property
Rename a schema property with [Migration.renameProperty()](https://pub.dev/documentation/realm/latest/realm/Migration/renameProperty.html).

```dart
final configWithRenamedAge =
    Configuration.local([Person.schema, Car.schema],
        schemaVersion: 2,
        migrationCallback: ((migration, oldSchemaVersion) {
  // Between v1 and v2 we renamed the Person 'age' property to 'yearsSinceBirth'
  migration.renameProperty('Person', 'age', 'yearsSinceBirth');
}));
final realmWithRenamedAge = Realm(configWithRenamedAge);
```

### Other Migration Tasks
To perform other realm schema migrations, use the following properties of
the `Migration` object in your migration callback function:

- [Migration.oldRealm](https://pub.dev/documentation/realm/latest/realm/Migration/oldRealm.html): The realm
as it existed just before the migration with the previous schema version.
You must use the `oldRealm`'s dynamic API to access its objects because you
cannot use standard type-based queries. The dynamic API lets you find Realm objects
by a string representation of their class name.
- [Migration.newRealm](https://pub.dev/documentation/realm/latest/realm/Migration/newRealm.html):
The realm as it exists after the migration. By the end of the migration callback,
you must migrate all data affected by the schema update from `oldRealm` into `newRealm`.
Any data affected by the schema update that is not migrated will be lost.

To find instances of an object in an old realm in the new realm,
use [Migration.findInNewRealm()](https://pub.dev/documentation/realm/latest/realm/Migration/findInNewRealm.html).
To access the properties of objects from the old schema,
use the [RealmObjectBase.dynamic](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase/dynamic.html) API.

```dart
final configWithChanges = Configuration.local([Person.schema, Car.schema],
    schemaVersion: 2,
    migrationCallback: ((migration, oldSchemaVersion) {
  // Dynamic query for all Persons in previous schema
  final oldPeople = migration.oldRealm.all('Person');
  for (final oldPerson in oldPeople) {
    // Find Person instance in the updated realm
    final newPerson = migration.findInNewRealm<Person>(oldPerson);
    if (newPerson == null) {
      // That person must have been deleted, so nothing to do.
      continue;
    }
    // Use dynamic API to get properties from old schema and use in the
    // new schema
    newPerson.fullName = "${oldPerson.dynamic.get<String>("firstName")} ${oldPerson.dynamic.get<String>("lastName")}";
    // convert `id` from ObjectId to String
    final oldId = oldPerson.dynamic.get<ObjectId>("id");
    newPerson.id = oldId.toString();
  }
}));
final realmWithChanges = Realm(configWithChanges);
```
