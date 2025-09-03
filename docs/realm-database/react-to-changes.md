# React to Changes - Flutter SDK
All Flutter SDK objects are **live objects**, which means they
automatically update whenever they're modified. The SDK emits a
notification event whenever any property changes.

When a user adds a new item to a list, you may want to update the UI, show a
notification, or log a message. When someone updates that item, you may want to
change its visual state or fire off a network request. Finally, when someone
deletes the item, you probably want to remove it from the
UI. The SDK's notification system allows you to watch for and react to changes
in your data, independent of the writes that caused the changes.

You can subscribe to changes on the following events:

- Query on collection
- Realm object
- Collections in a Realm object
- User instance

## About the Examples on This Page
The examples in this page use two object types, `Character` and
`Fellowship`:

```dart
@RealmModel()
class _Character {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late String species;
  late int age;
}

@RealmModel()
class _Fellowship {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late List<_Character> members;
}
```

Additionally, the examples have this sample data:

```dart
final frodo = Character(ObjectId(), 'Frodo', 'Hobbit', 51);
final samwise = Character(ObjectId(), 'Samwise', 'Hobbit', 39);
final gollum = Character(ObjectId(), 'Gollum', 'Hobbit', 589);
final aragorn = Character(ObjectId(), 'Aragorn', 'Human', 87);
final legolas = Character(ObjectId(), 'Legolas', 'Elf', 2931);
final gimli = Character(ObjectId(), 'Gimli', 'Dwarf', 140);

final fellowshipOfTheRing = Fellowship(
    ObjectId(), 'Fellowship of the Ring',
    members: [frodo, samwise, aragorn, legolas, gimli]);

final config = Configuration.local([Fellowship.schema, Character.schema]);
final realm = Realm(config);

realm.write(() {
  realm.add(fellowshipOfTheRing);
  realm.add(gollum); // not in fellowship
});
```

## Register a Listener
### Register a Query Change Listener
You can register a notification handler on any query within a Realm.
The handler receives a [RealmResultsChanges](https://pub.dev/documentation/realm/latest/realm/RealmResultsChanges-class.html) object,
which includes description of changes since the last notification.
`RealmResultsChanges` contains the following properties:

|Property|Type|Description|
| --- | --- | --- |
|`inserted`|*List<int>*|Indexes in the new collection which were added in this version.|
|`modified`|*List<int>*|Indexes of the objects in the new collection which were modified in this version.|
|`deleted`|*List<int>*|Indexes in the previous version of the collection which have been removed from this one.|
|`newModified`|*List<int>*|Indexes of modified objects after deletions and insertions are accounted for.|
|`moved`|*List<int>*|Indexes of the objects in the collection which moved.|
|`results`|*RealmResults<T as RealmObject>*|Results collection being monitored for changes.|
|`isCleared`|*bool*|Returns `true` if the results collection is empty in the notification callback.|

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

### Register a RealmObject Change Listener
You can register a notification handler on a specific object within a realm.
Realm notifies your handler when any of the object's properties change.
The handler receives a [RealmObjectChanges](https://pub.dev/documentation/realm/latest/realm/RealmObjectChanges-class.html) object,
which includes description of changes since the last notification.
`RealmObjectChanges` contains the following properties:

|Property|Type|Description|
| --- | --- | --- |
|`isDeleted`|*bool*|`true` if the object was deleted.|
|`object`|*RealmObject*|Realm object being monitored for changes.|
|`properties`|*List<String>*|Names of the Realm object's properties that have changed.|

```dart
final frodoSubscription = frodo.changes.listen((changes) {
  changes.isDeleted; // If the object has been deleted.
  changes.object; // The RealmObject being listened to, `frodo`.
  changes.properties; // The changed properties.
});
```

### Register Collection Change Listeners
> Version changed: 1.7.0
> Added support for `RealmMap` change listeners.
>
>
> Version changed: 2.0.0
> Added `isCollectionDeleted` property to collection listeners.
>
You can register a notification handler on a collection of any of the
supported data types within another `RealmObject`.
Realm notifies your handler when any of the items in the collection change.
The handler receives one of the following objects that include a description of
changes since the last notification:

- [RealmListChanges](https://pub.dev/documentation/realm/latest/realm/RealmListChanges-class.html) object
for `RealmList`
- [RealmSetChanges](https://pub.dev/documentation/realm/latest/realm/RealmSetChanges-class.html) object
for `RealmSet`
- [RealmMapChanges](https://pub.dev/documentation/realm/latest/realm/RealmMapChanges-class.html) object for
`RealmMap`

#### List

`RealmListChanges` contains the following properties:

|Property|Type|Description|
| --- | --- | --- |
|`inserted`|*List<int>*|Indexes of items in the list that were added in this version.|
|`modified`|*List<int>*|Indexes of items in the previous version of the list that were modified in this version.|
|`deleted`|*List<int>*|Indexes of items in the previous version of the list that were removed from this version.|
|`newModified`|*List<int>*|Indexes of modified items after deletions and insertions are accounted for.|
|`moved`|*List<int>*|Indexes of the items in the list that moved in this version.|
|`list`|*RealmList<T>*|`RealmList` being monitored for changes.|
|`isCleared`|*boolean*|`true` when the list has been cleared by calling its [RealmList.clear()](https://pub.dev/documentation/realm/latest/realm/RealmList-class.html) method.|
|`isCollectionDeleted`|*boolean*|`true` when the parent object containing the list has been deleted.|

#### Set

`RealmSetChanges` contains the following properties:

|Property|Type|Description|
| --- | --- | --- |
|`inserted`|*List<int>*|Indexes of items in the set that were added in this version.|
|`modified`|*List<int>*|Indexes of the items in the previous version of the set that were modified in this version.|
|`deleted`|*List<int>*|Indexes of items in the previous version of the set that were removed from this version.|
|`newModified`|*List<int>*|Indexes of modified items after deletions and insertions are accounted for.|
|`moved`|*List<int>*|Indexes of the items in the set that moved in this version.|
|`set`|*RealmSet<T>*|`RealmSet` being monitored for changes.|
|`isCleared`|*boolean*|`true` when the set has been cleared by calling its [RealmSet.clear()](https://pub.dev/documentation/realm/latest/realm/RealmSet-class.html) method.|
|`isCollectionDeleted`|*boolean*|`true` when the parent object containing the set has been deleted.|

#### Map

`RealmMapChanges` contains the following properties:

|Property|Type|Description|
| --- | --- | --- |
|`inserted`|*List<String>*|Keys of the map that were added in this version.|
|`modified`|*List<String>*|Keys of the previous version of the map whose corresponding values were modified in this version.|
|`deleted`|*List<String>*|Keys of the previous version of the map that were removed from this version.|
|`map`|*RealmMap<T>*|`RealmMap` being monitored for changes.|
|`isCleared`|*boolean*|`true` when the map has been cleared by calling its [RealmMap.clear()](https://pub.dev/documentation/realm/latest/realm/RealmMap-class.html) method.|
|`isCollectionDeleted`|*boolean*|`true` when the parent object containing the map has been deleted.|

```dart
final fellowshipSubscription =
    fellowshipOfTheRing.members.changes.listen((changes) {
  changes.inserted; // Indexes of inserted objects.
  changes.modified; // Indexes of modified objects.
  changes.deleted; // Indexes of deleted objects.
  changes.newModified; // Indexes of modified objects after accounting for deletions & insertions.
  changes.moved; // Indexes of moved objects.
  changes.list; // The full RealmList of objects.
  changes.isCleared; // `true` after call to fellowshipOfTheRing.members.clear(); otherwise, `false`.
  changes.isCollectionDeleted; // `true` if the collection is deleted; otherwise, `false`.
});
```

## Pause and Resume a Change Listener
Pause your subscription if you temporarily don't want to receive notifications.
You can later resume listening.

```dart
subscription.pause();
// The changes.listen() method won't fire until subscription is resumed.
subscription.resume();
```

## Unsubscribe a Change Listener
Unsubscribe from your change listener when you no longer want to receive
notifications on updates to the data it's watching.

```dart
await subscription.cancel();
```

## Change Notification Limits
Changes in nested documents deeper than four levels down do not trigger
change notifications.

If you have a data structure where you need to listen for changes five
levels down or deeper, workarounds include:

- Refactor the schema to reduce nesting.
- Add something like "push-to-refresh" to enable users to manually refresh data.
