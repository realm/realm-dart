# Data Types - Flutter SDK
The Flutter SDK supports Dart-language data types, a limited subset of
[BSON](https://bsonspec.org/) types, and [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).

## Dart Types
Realm supports the following Dart types:

- `int`
- `double`
- `bool`
- `String`
- `DateTime`

### DateTime
When you use `DateTime` with the Realm Flutter SDK, you can declare
it in the model as you would any other Dart type:

```dart
@RealmModel()
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;

  late String nickname;
  late DateTime dateLastServiced;
}
```

However, it is important to note that Realm stores `DateTime` in UTC.
When you use `DateTime`, you must create it in UTC or convert it
with `.toUtc()` before you store it. If your application requires it,
you can convert it back to local or the desired time zone when reading
from Realm.

```dart
// Create a Realm object with date in UTC, or convert with .toUtc() before storing
final subaruOutback = realm.write<Vehicle>(() {
  return realm.add(
      Vehicle(ObjectId(), 'Subie', DateTime.utc(2022, 9, 18, 12, 30, 0)));
});

final fordFusion =
    Vehicle(ObjectId(), 'Fuse', DateTime(2022, 9, 18, 8, 30, 0).toUtc());
realm.write(() {
  realm.add(fordFusion);
});

// When you query the object, the `DateTime` returned is UTC
final queriedSubaruOutback =
    realm.all<Vehicle>().query('nickname == "Subie"')[0];

// If your app needs it, convert it to Local() or the desired time zone
final localizedSubieDateLastServiced =
    queriedSubaruOutback.dateLastServiced.toLocal();
```

## Reference Realm Objects
You can also reference one or more Realm objects from another. Learn more in the
relationship properties documentation.

## Collections
A Realm collection contains zero or more instances of a
Realm supported data type.
In a Realm collection, all objects in a collection are of the same type.

You can filter and sort any collection using Realm's
query language. Collections are
live objects, so they always reflect the
current state of the realm instance. The contents of a collection update
when new elements are added to or deleted from the collection or from its Realm.

You can also listen for changes in the collection by subscribing
to change notifications.

Realm has the following types of collections:

- `RealmList`
- `RealmSet`
- `RealmResults`

### RealmList
Realm objects can contain lists of any supported data type.
Realm uses the [RealmList](https://pub.dev/documentation/realm/latest/realm/RealmList-class.html) data type
to store the data.

When you include `RealmObjects` as the items in a `RealmList`,  it represents a to-many
relationship.

Deleting an object from the database will remove it from any RealmLists
where it existed. Therefore, a `RealmList` of `RealmObject` types will never contain null values.
Also, a `RealmList` can contain multiple references to the same `RealmObject`.

A `RealmList` of primitive types can contain null values. If you do not
want to allow null values in a list, then either use non-nullable types in
the list declaration (for example, use `List<int>` instead of
`List<int?>`).

A `RealmList` is mutable and you can add and remove elements on a `RealmList`
within a write transaction.

#### Add a RealmList to a Schema
You can add a `RealmList` to your Realm Object schema by defining a property as type
`List<T>` where `T` can be any supported Realm data type
(except other collections), in your Realm Object model.

```dart
@RealmModel()
class _Player {
  @PrimaryKey()
  late ObjectId id;

  late String username;
  // `inventory` property of type RealmList<Item>
  // where Items are other RealmObjects
  late List<_Item> inventory;
  // `traits` property of type RealmList<String>
  // where traits are Dart Strings.
  late List<String> traits;
}

@RealmModel()
class _Item {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late String description;
}
```

#### Work with a RealmList
> Version changed: 2.0.0
> Get `RealmList` by property name with [dynamic.getList()](https://pub.dev/documentation/realm/latest/realm/DynamicRealmObject/getList.html)
>

The following example demonstrates some basic usage of `RealmList`.
For more information about all available methods, refer to the
[RealmList reference](https://pub.dev/documentation/realm/latest/realm/RealmList-class.html) documentation.

```dart
final artemis =
    realm.write(() => realm.add(Player(ObjectId(), 'Art3mis', inventory: [
          Item(ObjectId(), 'elvish sword', 'sword forged by elves'),
          Item(ObjectId(), 'body armor', 'protects player from damage'),
        ], traits: [
          'brave',
          'kind'
        ])));

// Get a RealmList by property name with dynamic.getList()
final inventory = artemis.dynamic.getList('inventory');

// Use RealmList methods to filter results
RealmList<String> traits = artemis.traits;
final brave = traits.firstWhere((element) => element == 'brave');

final elvishSword =
    artemis.inventory.where((item) => item.name == 'elvish sword').first;

// Query RealmList with Realm Query Language
final playersWithBodyArmor =
    realm.query<Player>("inventory.name == \$0", ['body armor']);
print("LEN ${playersWithBodyArmor.length}");
```

### RealmSet
Realm objects can contain sets of any supported data type except another collection.
Realm uses the [RealmSet](https://pub.dev/documentation/realm/latest/realm/RealmSet-class.html) data type
to store the data. In a `RealmSet` collection, all values are *unique*.
`RealmSet` extends the native Dart [Set](https://api.dart.dev/stable/dart-core/Set-class.html)
data type with additional Realm-specific properties and methods.

When you include `RealmObjects` as the items in a `RealmSet`,  it represents a to-many
relationship.

A `RealmSet` is mutable and you can add and remove elements in a `RealmSet`
within a write transaction.

#### Add a RealmSet to a Schema
You can add a `RealmSet` to your Realm Object schema by defining a property as type
`Set<T>` where `T` can be any supported Realm data type
except other collections, in your Realm Object model.

When defining a RealmSet in a schema:

- A set of primitive types can be defined as either nullable or non-nullable.
For example, both `Set<int>` and `Set<int?>` are valid in a Realm schema.
- A set of `RealmObject` and `RealmValue` types can only be non-nullable.
For example `Set<RealmValue>` is valid, but `Set<RealmValue?>` *is not* valid.
- You *cannot* define default values when defining a set in a schema.
For example, `Set mySet = {0,1,2}` *is not* valid.

```dart
@RealmModel()
class _RealmSetExample {
  late Set<String> primitiveSet;
  late Set<int?> nullablePrimitiveSet;
  late Set<_SomeRealmModel> realmObjectSet;
}

@RealmModel()
class _SomeRealmModel {
  late ObjectId id;
}
```

#### Work with a RealmSet
> Version changed: 2.0.0
> Get `RealmSet` by property name with [dynamic.getSet()](https://pub.dev/documentation/realm/latest/realm/DynamicRealmObject/getSet.html)
>

The following example demonstrates some basic usage of `RealmSet`.
For more information about all available methods, refer to the
[RealmSet reference](https://pub.dev/documentation/realm/latest/realm/RealmSet-class.html) documentation.

```dart
final realm = Realm(
    Configuration.local([RealmSetExample.schema, SomeRealmModel.schema]));

// Pass native Dart Sets to the object to create RealmSets
final setExample = RealmSetExample(
    primitiveSet: {'apple', 'pear'},
    nullablePrimitiveSet: {null, 2, 3},
    realmObjectSet: {SomeRealmModel(ObjectId())});
// Add RealmObject to database
realm.write(() => realm.add(setExample));

// Once you add the sets, they are of type RealmSet
RealmSet primitiveSet = setExample.primitiveSet;

// Modify RealmSets of RealmObjects in write transactions
realm.write(() {
  // Add element to a RealmSet with RealmSet.add()
  setExample.realmObjectSet.add(SomeRealmModel(ObjectId()));
  // Remove element from a RealmSet with RealmSet.remove()
  setExample.primitiveSet.remove('pear');
});

// Check if a RealmSet contains an element with RealmSet.contains()
if (setExample.primitiveSet.contains('apple')) {
  print('Set contains an apple');
}

// Get RealmSet by property name with dynamic.getSet()
final getSetResult = setExample.dynamic.getSet('primitiveSet');

// Check number of elements in a RealmSet with RealmSet.length
print(
    'Set now has ${getSetResult.length} elements'); // Prints 'Set now has 1 elements'

// Query RealmSets using Realm Query Language
final results =
    realm.query<RealmSetExample>('\$0 IN nullablePrimitiveSet', [null]);
```

### RealmMap
> Version added: 1.7.0

[RealmMap](https://pub.dev/documentation/realm/latest/realm/RealmMap-class.html) is a collection that
contains key-value pairs of `<String, T>`, where `T` is any data type
supported by the SDK. Map keys may not contain `.` or start with `$` unless
you use [percent-encoding](https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding).

A `RealmMap` is mutable and you can add and remove elements in a `RealmMap`
within a write transaction. You can listen for RealmMap entry changes using a
change listener.

#### Add a RealmMap to a Schema
You can add a `RealmMap` to your Realm Object schema by defining a property as
type `RealmMap<String, T>` where `T` can be any supported Realm data type (except other collections), in your Realm Object model.

```dart
@RealmModel()
class _MapExample {
  late Map<String, int> map;
  late Map<String, int?> nullableMap;
}
```

#### Work with a RealmMap
> Version changed: 2.0.0
> Get `RealmMap` by property name with [dynamic.getMap()](https://pub.dev/documentation/realm/latest/realm/DynamicRealmObject/getMap.html)
>

The following example demonstrates some basic usage of `RealmMap`.
For more information about all available methods, refer to the
[RealmMap reference](https://pub.dev/documentation/realm/latest/realm/RealmMap-class.html) documentation.

```dart
final realm = Realm(Configuration.local([MapExample.schema]));

// Pass native Dart Maps to the object to create RealmMaps
final mapExample = MapExample(
  map: {
    'first': 1,
    'second': 2,
    'third': 3,
  },
  nullableMap: {
    'first': null,
    'second': 2,
    'third': null,
  },
);
// Add RealmObject to the database
realm.write(() => realm.add(mapExample));

// Once you add maps, they are of type RealmMap
RealmMap map = mapExample.map;

// Modify RealmMaps in write transactions
realm.write(() {
  // Update value by key with .update() or [value] = newValue
  mapExample.nullableMap['second'] = null;
  mapExample.map.update('first', (value) => 5);
  mapExample.nullableMap.update('fourth', (v) => 4, ifAbsent: () => null);

  // Add a new map entry with .addEntries()
  const newMap = {'fourth': 4};
  mapExample.map.addEntries(newMap.entries);
});

// Check a RealmMap with .containsKey() or .containsValue()
if (mapExample.map.containsKey('first')) {
  print('Map contains key "first"');
} else if (mapExample.map.containsValue(null)) {
  print('Map contains null value');
} else {
  print('These aren\'t the maps you\'re looking for');
}

// Get a RealmMap by property name with dynamic.getMap()
final getPrimitiveMap = mapExample.dynamic.getMap('map');

// Check the number of elements in a RealmMap with RealmMap.length
print(
    'Map contains ${getPrimitiveMap.length} elements'); // Prints 'Map contains 4 elements'

// Query RealmMaps using Realm Query Language
final results = realm.query<MapExample>('map.first == \$0', [5]);
```

### RealmResults
A [RealmResults](https://pub.dev/documentation/realm/latest/realm/RealmResults-class.html)
collection represents the lazily-evaluated
results of a query operation. Unlike a `RealmList`, results are immutable: you
cannot add or remove elements on the results collection.
This is because the contents of a results collection are determined by a
query against the database.

[Realm.all()](https://pub.dev/documentation/realm/latest/realm/Realm/all.html) and [Realm.query()](https://pub.dev/documentation/realm/latest/realm/Realm/query.html) return `RealmResults`.
For more information on querying Realm, refer to Read Operations.

```dart
RealmResults<Player> players = realm.all<Player>();
RealmResults<Player> bravePlayers =
    realm.query<Player>('ANY traits == \$0', ['brave']);
```

#### Results are Lazily Evaluated
Realm only runs a query when you actually request the
results of that query, e.g. by accessing elements of the
results collection. This lazy evaluation enables you to
write elegant, highly performant code for handling large
data sets and complex queries.

### Collections are Live
Like live objects, Realm collections
are *usually* live:

- **Live results collections** always reflect the current results of the associated query.
- **Live lists** of `RealmObjects` always reflect the current state of the relationship on the realm instance.

There are two cases, however, when a collection is *not* live:

- The collection is unmanaged: a `RealmList` property of a Realm object
that has not been added to a realm yet or that has been copied from a
realm.
- The collection is frozen.

Combined with listening for changes on a collection,
live collections enable clean, reactive code.
For example, suppose your view displays the results of a query.
You can keep a reference to the results collection in your view class,
then read the results collection as needed without having to refresh it or
validate that it is up-to-date.

> **IMPORTANT:**
> Because results update themselves automatically, do not
> store the positional index of an object in the collection
> or the count of objects in a collection. The stored index
> or count value could be outdated by the time you use it.
>

## Additional Supported Data Types
### ObjectId
ObjectId is a 12-byte unique value which you can use as an
identifier for objects. ObjectId is indexable and can be used as a primary key.

To define a property as an ObjectId, set its type as `ObjectId` in
your object model.

```dart
@RealmModel()
class _ObjectIdPrimaryKey {
  @PrimaryKey()
  late ObjectId id;
}
```

Call `ObjectId()` to set any unique identifier properties of
your object. Alternatively, pass a string
to `ObjectId()` to set the unique identifier property to a specific value.

```dart
final id = ObjectId();
final object = ObjectIdPrimaryKey(id);
```

### UUID
UUID (Universal Unique Identifier) is a 16-byte [unique value](https://en.wikipedia.org/wiki/Universally_unique_identifier). You can use a UUID as an identifier for
objects. UUIDs are indexable and you can use them as primary keys.

> **NOTE:**
> In general, you can use `UUID` for any fields that function as a unique
> identifier.
>

To define a property as a UUID, set its type as `Uuid` in
your object model.

```dart
@RealmModel()
class _UuidPrimaryKey {
  @PrimaryKey()
  late Uuid id;
}
```

To set any unique identifier properties of
your object to a random value, call one of the `Uuid` methods to create a UUID,
such as `Uuid.v4()`.

```dart
final myId = Uuid.v4();
final object = UuidPrimaryKey(myId);
```

### Decimal128
Dart doesn't have a native decimal type. You can use
[Decimal128](https://pub.dev/documentation/realm/latest/realm/Decimal128-class.html),
which is a 128-bit implementation of [IEEE-754](https://en.wikipedia.org/wiki/IEEE_754).
When defining a decimal type, use the `Decimal128` BSON type.

When using `Decimal128`, be aware that the Dart `compareTo()` method
implements total ordering that mimics the Dart `double` type. This means the
following things are true when using `compareTo()`:

- All `NaN` values are considered equal and greater than any numeric value.
- `-Decimal128.zero` is less than `Decimal128.zero` (and the integer 0)
but greater than any non-zero negative value.
- Negative infinity is less than all other values and positive infinity is
greater than all non-NaN values.
- All other values are compared using their numeric value.

### RealmValue
> **IMPORTANT:**
> Flutter SDK version 2.0.0 updates `RealmValue` to allow a `List`
> or `Map` type of `RealmValue`, which enables more flexibility
> when modeling unstructured data. Refer to Model Unstructured Data
> for more information.
>
> This update also includes the following breaking changes, which may affect
your app when upgrading to v2.0.0 or later:
>
> - `RealmValue.type` is now an enum of `RealmValueType` instead of `Type`.
> - `RealmValue.uint8List` is renamed to `RealmValue.binary`.
>
> For more information on how to upgrade an existing app from an earlier
> version to v2.0.0 or later, refer to Upgrade to Flutter SDK v2.0.0.
>

The [RealmValue](https://pub.dev/documentation/realm_common/latest/realm_common/RealmValue-class.html)
data type is a mixed data type that can represent any other valid
data type except embedded objects. In Flutter SDK v2.0.0 and later, `RealmValue`
can represent a `List<RealmValue>` or `Map<String, RealmValue>`.

#### Define a RealmValue Property
To define a `RealmValue` property, set its type in your object model.
`RealmValue` is indexable, but cannot be a primary key. You can also define
properties as collections (lists, sets, or maps) of type `RealmValue`.

```dart
@RealmModel()
class _RealmValueExample {
  @Indexed()
  late RealmValue singleAnyValue;
  late List<RealmValue> listOfMixedAnyValues;
  late Set<RealmValue> setOfMixedAnyValues;
  late Map<String, RealmValue> mapOfMixedAnyValues;
}

```

> **NOTE:**
> When defining your Realm object schema, you cannot create a nullable `RealmValue`.
> However, if you want a `RealmValue` property to contain a null value,
> you can use the special `RealmValue.nullValue()` property.
>

#### Create a RealmValue
To add a `RealmValue` to a Realm object, call `RealmValue.from()` on the data or `RealmValue.nullValue()` to set a null value.

```dart
final realm = Realm(Configuration.local([RealmValueExample.schema]));

realm.write(() {
  // Use 'RealmValue.from()' to set values
  var anyValue = realm.add(RealmValueExample(
      // Add a single `RealmValue` value
      singleAnyValue: RealmValue.from(1),
      // Add a list of `RealmValue` values
      listOfMixedAnyValues: [Uuid.v4(), 'abc', 123].map(RealmValue.from),
      // Add a set of `RealmValue` values
      setOfMixedAnyValues: {
        RealmValue.from('abc'),
        RealmValue.from('def')
      },
      // Add a map of string keys and `RealmValue` values
      mapOfMixedAnyValues: {
        '1': RealmValue.from(123),
        '2': RealmValue.from('abc')
      }));

  // Use 'RealmValue.nullValue()' to set null values
  var anyValueNull = realm.add(RealmValueExample(
      singleAnyValue: RealmValue.nullValue(),
      listOfMixedAnyValues: [null, null].map(RealmValue.from),
      setOfMixedAnyValues: {RealmValue.nullValue()},
      mapOfMixedAnyValues: {'null': RealmValue.nullValue()}));
```

#### Access RealmValue Data Type
> Version changed: 2.0.0
> `RealmValueType` enum replaces `RealmValue.type`.
> `RealmValue.binary` replaces  `RealmValue.uint8List`.
>

To access the data stored in a `RealmValue`, you can use:

- `RealmValue.value`, which returns an `Object?`.
- `RealmValue.as<T>`, which fetches the data and casts it to a desired type.

```dart
for (var obj in data) {
  for (var mixedValue in obj.listOfMixedAnyValues) {
    // Use RealmValue.value to access the value
    final value = mixedValue.value;
    if (value is int) {
      sum = sum + value;
    } else if (value is String) {
      combinedStrings += value;
    }

    // Use RealmValue.as<T> to cast value to a specific type
    try {
      final intValue = mixedValue.as<int>();
      sum = sum + intValue;
    } catch (e) {
      log('Error casting value to int: $e');
    }
  }
}
```

You can check the type of data currently stored in a `RealmValue` property by
accessing the `type` property. Starting with Flutter SDK v2.0.0, this returns a
`RealmValueType` enum. In earlier SDK versions, the SDK returned a
`RealmValue.value.runtimeType`.

The following example uses `RealmValueType` to run calculations based on the
data type.

```dart
final data = realm.all<RealmValueExample>();
for (var obj in data) {
  final anyValue = obj.singleAnyValue;
  // Access the RealmValue.type property
  switch (anyValue.type) {
    // Work with the returned RealmValueType enums
    case RealmValueType.int:
      approximateAge = DateTime.now().year - anyValue.as<int>();
      break;
    case RealmValueType.dateTime:
      approximateAge =
          (DateTime.now().difference(anyValue.as<DateTime>()).inDays /
                  365)
              .floor();
      break;
    case RealmValueType.string:
      final birthday = DateTime.parse(anyValue.as<String>());
      approximateAge =
          (DateTime.now().difference(birthday).inDays / 365).floor();
      break;
    // Handle other possible types ...
    default:
      log('Unhandled type: ${anyValue.type}');
  }
}
```

#### Collections as Mixed
> Version changed: 2.0.0
> `RealmValue` properties can contain lists or maps of mixed data.
>

In version 2.0.0 and later, a mixed data type can hold collections (a list or
map, but *not* a set) of mixed elements. You can use mixed collections to
model unstructured or variable data. For more information, refer to
Model Unstructured Data.

- You can nest mixed collections up to 100 levels.
- You can query mixed collection properties and
register a listener for changes,
as you would a normal collection.
- You can find and update individual mixed collection elements
- You *cannot* store sets or embedded objects in mixed collections.

To use mixed collections, define the mixed type property in your data model.
Then, create the list or map collections using `RealmValue.from()`.

```dart
realm.write(() {
  realm.add(RealmValueCollectionExample(
      // Set the RealmValue as a map of mixed data
      singleAnyValue: RealmValue.from({
    'int': 1,
    // You can nest RealmValues in collections
    'listOfInt': [2, 3, 4],
    'mapOfStrings': {'1': 'first', '2': 'second'},
    // You can also nest collections within collections
    'mapOfMaps': [
      {
        'nestedMap_1': {'1': 1, '2': 2},
        'nestedMap_2': {'3': 3, '4': 4}
      }
    ],
    'listOfMaps': [
      {
        'nestedList_1': [1, 2, 3],
        'nestedList_2': [4, 5, 6]
      }
    ]
  })));
```

### Uint8List
[Uint8List](https://api.dart.dev/stable/3.0.5/dart-typed_data/Uint8List-class.html)
is a binary data type from [dart:typed_data](https://api.dart.dev/stable/3.0.5/dart-typed_data/dart-typed_data-library.html).
You can use this data type in object models and property values.

To define a property as `Uint8List`, you must first import `dart:typed_data`.
Then, set the object's type as `Uint8List` in your object model.

```dart
@RealmModel()
class _BinaryExample {
  late String name;
  late Uint8List requiredBinaryProperty;
  late Uint8List? nullableBinaryProperty;
}
```

To add `Uint8List` to a Realm object, call `Uint8List.fromList()` on the data.

```dart
final realm = Realm(Configuration.local([BinaryExample.schema]));

realm.write(() {
  realm.addAll([
    BinaryExample("Example binary object", Uint8List.fromList([1, 2]))
  ]);
});
```

## Embedded Objects
Realm treats each embedded object as nested data inside of a parent object.
An embedded object inherits the lifecycle of its parent object.
It cannot exist as an independent Realm object.
Embedded objects have the following properties:

- Embedded objects are deleted when their parent object is deleted
or their parent no longer references them.
- You cannot reassign an embedded object to a different parent object.
- you cannot link to an embedded object from multiple parent objects.
- You can only query an embedded object by accessing it through its parent object.

Declare an embedded objects by passing [ObjectType.embeddedObject](https://pub.dev/documentation/realm_common/latest/realm_common/ObjectType.html)
to the `@RealmModel()` annotation.
Embedded objects must be nullable when defining them in the parent object's
`RealmModel`. You must also include the embedded object's schema in the realm's
[Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html).

The following example shows how to model an embedded object in a Realm schema.
The `_Address` model is embedded within the `_Person` model.

```dart
// The generated `Address` class is an embedded object.
@RealmModel(ObjectType.embeddedObject)
class _Address {
  late String street;
  late String city;
  late String state;
  late String country;
}

@RealmModel()
class _Person {
  @PrimaryKey()
  late ObjectId id;

  late String name;

  // Embedded object in parent object schema
  late _Address? address; // Must be nullable
}
```

You can use the [parent](https://pub.dev/documentation/realm/latest/realm/EmbeddedObjectExtension/parent.html)
property to access the parent of the embedded object.

The following example shows the unique considerations when working with embedded objects.
The example uses the `Address` embedded object generated from the `_Address`
`RealmModel` in the above schema.

```dart
// Both parent and embedded objects in schema
final realm = Realm(Configuration.local([Person.schema, Address.schema]));

// Create an embedded object.
final joesHome = Address("500 Dean Street", "Brooklyn", "NY", "USA");
final joePrimaryKey = ObjectId();
final joe = Person(joePrimaryKey, "Joe", address: joesHome);
realm.write(() => realm.add(joe));

// Update an embedded object property.
realm.write(() {
  joe.address?.street = "800 Park Place";
});

// Query a collection of embedded objects.
// You must access the embedded object through the parent RealmObject type.
final peopleWithNewYorkHomes = realm.query<Person>("address.state = 'NY'");

// Overwrite an embedded object.
// Also deletes original embedded object from realm.
final joesNewHome = Address("12 Maple Way", "Toronto", "ON", "Canada");
realm.write(() {
  joe.address = joesNewHome;
});

// You can access the parent object from an embedded object.
final thePersonObject = joesNewHome.parent;

// Delete embedded object from parent object.
realm.write(() => realm.delete(joe.address!));

// Add address back for the following example.
final anotherNewHome = Address("202 Coconut Court", "Miami", "FL", "USA");
realm.write(() {
  joe.address = anotherNewHome;
});
// Deleting the parent object also deletes the embedded object.
realm.write(() => realm.delete(joe));
```

## Example
The following model includes some supported data types.

```dart
part 'car.realm.dart';

// The generated `Address` class is an embedded object.
@RealmModel(ObjectType.embeddedObject)
class _Address {
  late String street;
  late String city;
  late String state;
  late String country;
}

@RealmModel()
class _Person {
  @PrimaryKey()
  late ObjectId id;

  late String name;

  // Embedded object in parent object schema
  late _Address? address; // Must be nullable
}

@RealmModel()
class _Car {
  @PrimaryKey()
  late ObjectId id;

  String? licensePlate;
  bool isElectric = false;
  double milesDriven = 0;
  late List<String> attributes;
  late _Person? owner;
}
```
