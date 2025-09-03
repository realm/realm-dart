# Property Annotations - Flutter SDK
You can use annotations to add functionality to properties in your Realm object models.

## Required and Optional Properties
In Dart, value types are implicitly non-nullable, but can be made optional (nullable) by appending
[?](https://dart.dev/null-safety). Include `?` to make properties optional.

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String? maybeDescription; // optional value

  late double milesTraveled = 0;

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make;

  @MapTo('wheels')
  late int numberOfWheels;
}
```

## Default Field Values
You can use the built-in language features to assign a default value to a property.
Assign a default value in the property declaration.

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String? maybeDescription;

  late double milesTraveled = 0; // 0 is default value

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make;

  @MapTo('wheels')
  late int numberOfWheels;
}
```

## Primary Keys
The [PrimaryKey](https://pub.dev/documentation/realm_common/latest/realm_common/PrimaryKey-class.html)
annotation indicates a primary key property.
The primary key is a unique identifier for an object in a realm.
No other objects of the same type may share an object's primary key.

Important aspects of primary keys:

- You cannot change a primary key after adding an object to a realm.
- Only add a primary key to one property in a RealmModel.
- Only `String`, `int`, `ObjectId`, and `Uuid` types can be primary keys.
- Realm automatically indexes primary keys.
- Primary keys are nullable. `null` can only be the primary key of one object
in a collection.

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id; // Primary key

  late String? maybeDescription;

  late double milesTraveled = 0;

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make;

  @MapTo('wheels')
  late int numberOfWheels;
}
```

## Map a Property or Class to a Different Name
The [MapTo](https://pub.dev/documentation/realm_common/latest/realm_common/MapTo-class.html) annotation
indicates that a model or property should be persisted under a different name.
It's useful when opening a Realm across different bindings where code style
conventions can differ. For example:

- To make it easier to work across platforms where naming conventions
differ.
- To change a class or field name without forcing a migration.

#### Remap Class

```dart
@RealmModel()
@MapTo('naval_ship') // `naval_ship` is the remapped class name
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

  late String? maybeDescription;

  late double milesTraveled = 0;

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make;

  @MapTo('wheels') // 'wheels' is the remapped property name in the RealmObject
  late int numberOfWheels;
}
```

## Ignore Properties from Realm Schema
If you add the [Ignored](https://pub.dev/documentation/realm_common/latest/realm_common/Ignored-class.html)
annotation to a property in your `RealmModel`, the realm object generator doesn't include the property in the `RealmObject` schema
or persist it to Realm.

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String? maybeDescription;

  late double milesTraveled = 0;

  @Ignored()
  late String notInRealmModel;  // Ignored property

  @Indexed()
  late String make;

  @MapTo('wheels')
  late int numberOfWheels;
}
```

## Index Properties
Add the [Indexed](https://pub.dev/documentation/realm_common/latest/realm_common/Indexed-class.html)
annotation to create an index on the field. Indexes can greatly speed up some
queries at the cost of slightly slower write times and additional storage and
memory overhead. Realm stores indexes on disk, which makes your realm
files larger. Each index entry is a minimum of 12 bytes. Indexes can be nullable.

The following data types can be indexed:

- `bool`
- `int`
- `String`
- `ObjectId`
- `Uuid`
- `DateTime`
- `RealmValue`

```dart
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String? maybeDescription;

  late double milesTraveled = 0;

  @Ignored()
  late String notInRealmModel;

  @Indexed()
  late String make; // Indexed property

  @MapTo('wheels')
  late int numberOfWheels;
}
```

### Full-Text Search Indexes
In addition to standard indexes, Realm also supports Full-Text Search (FTS)
indexes on string properties. While you can query a string field with or without
a standard index, an FTS index enables searching for multiple words and phrases
and excluding others.

For more information on querying FTS indexes, see Filter with Full-Text Search.

To create an FTS index on a property, use the [@Indexed](https://pub.dev/documentation/realm_common/latest/realm_common/Indexed-class.html)
annotation and specify the [RealmIndexType](https://pub.dev/documentation/realm_common/latest/realm_common/RealmIndexType.html)
as `fullText`. This enables full-text queries on the property. In the
following example, we mark the pattern and material properties with the FTS annotation:

```dart
@RealmModel()
class _Rug {
    @PrimaryKey()
    late ObjectId id;

    @Indexed(RealmIndexType.fullText) // Indexed with FTS
    late String pattern;

    @Indexed(RealmIndexType.fullText) // Indexed with FTS
    late String material;

    late int softness;
}
```
