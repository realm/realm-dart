# Serialization - Flutter SDK
The Realm SDK for Flutter supports serialization and deserialization of
[Extended JSON (EJSON)](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/) to and from static Realm objects.

## Supported Data Types for Serialization
The Flutter SDK currently supports serialization of the following supported data types:

- All Dart-language data types
- All Realm-specific data types, except `Decimal128` and `RealmValue`

The following table illustrates how the SDK's Realm-specific data types serialize with output examples:

|Realm Type|Serializes To|
| --- | --- |
|DateTime|Date `DateTime birthDate = DateTime.utc(2024, 4, 10)` serializes to `birthDate: {$date: {$numberLong: 1712707200000}}`|
|RealmList|Array `List<String> listOfStrings = [food, water]` serializes to `listOfStrings: [food, water]`|
|RealmMap|Array `Map<String, int> mapOfMixedAnyValues = {'first': 123 , 'second': 567}` serializes to `mapOfValues: {first: {$numberInt: 123}, second: {$numberInt: 567}}`|
|RealmSet|Array `Set<int> setOfInts = {0, 1, 2, 3}` serializes to `setOfInts: [{$numberInt: 0}, {$numberInt: 1}, {$numberInt: 2}, {$numberInt: 3}]`|
|ObjectId|ObjectId `ObjectId id = ObjectId()` serializes to `{id: {$oid: 666a6fd54978af08e54a8d52}`|
|UUID|Binary `Uuid myId = Uuid.v4()` serializes to `myId: {$binary: {base64: 6TvsMWxDRWa1jSC6gxiM3A==, subType: 04}}`|
|Uint8List|Binary `Uint8List aBinaryProperty = Uint8List.fromList([1, 2])` serializes to `aBinaryProperty: {$binary: {base64: AQI=, subType: 00}}`|
|Object|Document `Address address = Address("500 Dean Street", "Brooklyn", "NY", "USA")` serializes to `address: {street: 500 Dean Street, city: Brooklyn, state: NY, country: USA}`|

For more information on the serialization of non-Realm specific types,
see [BSON Data Types and Associated Representations](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#bson-data-types-and-associated-representations).

> **NOTE:** Flutter SDK serialization does *NOT* currently support the following BSON types: `Code`,
> `CodeWScope`, `DBPointer`, `DBRef`, `Regular Expression`, or `Timestamp`.
>

## Serialize Realm Objects
The SDK's full-document encoder enables you to serialize and deserialize user-defined
classes.

To use the encoder, create your object model as you normally would using
the `@RealmModel()` annotation. The `RealmObject` class
model created by your `part` declaration provides the necessary methods
for serialization and deserialization.

The following `Pet` object model will be used in the examples on this page:

```dart
import 'package:realm_dart/realm.dart';

part 'pet.realm.dart';

@RealmModel()
class _Pet {
  late String type;
  late int numberOfLegs;
  late DateTime birthDate;

  late double? price;
}
```

### Serialize to EJSON
For objects based on `RealmObject` classes, you can serialize to EJSON using the
[toEjson()](https://pub.dev/documentation/realm/latest/realm/toEJson.html) method in the following two ways:

```dart
// Pass the object as a parameter to the method
EJsonValue serializeByParam = toEJson(spider);

// Call the method directly on the object
EJsonValue serializeWithCall = spider.toEJson();
```

```console
{
    type: Jumping Spider,
    numberOfLegs: {$numberInt: 8},
    birthDate: {$date: {$numberLong: 1712707200000}},
    price: null
}
```

### Deserialize from EJSON
Deserialize from EJSON using the [fromEjson()](https://pub.dev/documentation/realm/latest/realm/fromEJson.html)
method. The method takes EJSON for a specified object type as input and outputs
a deserialized instance of the specified object type.

The following example deserializes `serializeByParam` from the previous example:

```dart
// Pass the serialized object to the method
final deserializeFromEjsonWithExplicitType = fromEJson<Pet>(serializeByParam);

// The method can also infer the object type
Pet deserializeFromEjson = fromEJson(serializeByParam);
```

## Serialize Non-Realm Objects
For non-Realm classes, you can use the `@ejson` annotation on the class constructor
to generate a decoder and encoder:

```dart
class Person {
  final String name;
  final DateTime birthDate;

  final int? age;
  final double income;
  final Person? spouse;

  @ejson // annotate constructor to generate decoder and encoder
  Person(this.name, this.birthDate, this.income, {this.spouse, this.age});
}
```

## Register Custom Codecs
The SDK also supports custom EJSON codecs. To use them in your app, [register](https://pub.dev/documentation/realm/latest/realm/register.html)
the custom EJSON encoder and decoder for the specified type.
