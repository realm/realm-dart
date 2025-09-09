# Freeze Data - Flutter SDK
Freezing creates an immutable snapshot of data in a realm at the time of freezing.
Frozen objects are not live and do not automatically update.
You cannot write to frozen data.
Once data is frozen, it cannot be unfrozen.

You can freeze the following object types:

- Realm
- RealmResults
- RealmObject
- RealmList

## Freeze a Realm
Create a frozen snapshot of an entire realm with [Realm.freeze()](https://pub.dev/documentation/realm/latest/realm/Realm/freeze.html). Once you finish working with the frozen realm,
you must close it to prevent memory leaks.

```dart
final config = Configuration.local([Person.schema, Scooter.schema]);
final realm = Realm(config);
// Add scooter owned by Mace Windu
final maceWindu = Person(ObjectId(), "Mace", "Windu");
final purpleScooter =
    Scooter(ObjectId(), "Purple scooter", owner: maceWindu);
realm.write(() {
  realm.add(purpleScooter);
});

// Create frozen snapshot of realm
final frozenRealm = realm.freeze();

// Update data in the realm
final quiGonJinn = Person(ObjectId(), "Qui-Gon", "Jinn");
realm.write(() {
  purpleScooter.owner = quiGonJinn;
});

// Data changes not in the frozen snapshot
final purpleScooterFrozen =
    frozenRealm.query<Scooter>("name == \$0", ["Purple scooter"]).first;
print(purpleScooterFrozen.owner!.firstName); // prints 'Mace'

// You must also close the frozen realm before exiting the process
frozenRealm.close();
```

## Freeze RealmResults
Create a frozen snapshot of `RealmResults` with [RealmResults.freeze()](https://pub.dev/documentation/realm/latest/realm/RealmResults/freeze.html). Once you finish working with the frozen data,
you must close the realm associated with it to prevent memory leaks.

```dart
// Add data to the realm
final maceWindu = Person(ObjectId(), "Mace", "Windu");
final jocastaNu = Person(ObjectId(), "Jocasta", "Nu");
realm.write(() => realm.addAll([maceWindu, jocastaNu]));

// Get RealmResults and freeze data
final people = realm.all<Person>();
final frozenPeople = people.freeze();

// Update data in the non-frozen realm
final newLastName = "Foo";
realm.write(() {
  for (var person in people) {
    person.lastName = newLastName;
  }
});

// Data changes not in the frozen snapshot
final frozenFooPeople =
    frozenPeople.query("lastName == \$0", [newLastName]);
print(frozenFooPeople.length); // prints 0

// You must also close the frozen realm associated
// with the frozen RealmResults before exiting the process
frozenPeople.realm.close();
```

## Freeze a RealmObject
Create a frozen snapshot of a `RealmObject` with [RealmObject.freeze()](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase/freeze.html). Once you finish working with the frozen data,
you must close the realm associated with it to prevent memory leaks.

```dart
final person = realm.query<Person>(
    'firstName == \$0 AND lastName == \$1', ["Count", "Dooku"]).first;

// Freeze RealmObject
final frozenPerson = person.freeze();

// Change data in the unfrozen object.
realm.write(() {
  realm.delete(person);
});

// Frozen person snapshot still exists even though data deleted
// in the unfrozen realm
print(frozenPerson.isValid); // prints true
print(person.isValid); // prints false

// You must also close the frozen realm associated
// with the frozen RealmObject before exiting the process
frozenPerson.realm.close();
```

## Freeze a RealmList in a RealmObject
Create a frozen snapshot of `RealmList` in a `RealmObject`
with [RealmList.freeze()](https://pub.dev/documentation/realm/latest/realm/RealmList/freeze.html).
Once you finish working with the frozen data,
you must close the realm associated with it to prevent memory leaks.

```dart
final firstPerson =
    realm.query<Person>("firstName = \$0", ["Yoda"]).first;

// Freeze RealmList in a RealmObject
final firstPersonAttributesFrozen = firstPerson.attributes.freeze();

// Change data in the unfrozen realm
final newAttribute = "quick";
realm.write(() {
  // Append item to list
  firstPerson.attributes.add(newAttribute);
});

final index = firstPersonAttributesFrozen.indexOf(newAttribute);
print(index); // prints -1 because cannot find new attribute

// You must also close the frozen realm associated
// with the frozen RealmList before exiting the process
firstPersonAttributesFrozen.realm.close();
```

## Check if Data Is Frozen
Check if any of the freezable data types are frozen with the `isFrozen` property.
`isFrozen` returns `true` if an object is frozen and `false` if it is a live object.

```dart
// You can check if all freezable types are frozen
// with the `isFrozen` property.

final realm = Realm(config);
print(realm.isFrozen);

final people = realm.all<Person>();
print(people.isFrozen);

final firstPerson =
    realm.query<Person>("firstName = \$0", ["Yoda"]).first;
print(firstPerson.isFrozen);

final firstPersonAttributes = firstPerson.attributes;
print(firstPersonAttributes.isFrozen);
```
