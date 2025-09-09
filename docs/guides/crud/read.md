# CRUD - Read - Flutter SDK
> **NOTE:** See the [Realm Query Language (RQL)](/docs/realm-query-language.md) page for information on
> finding objects using RQL.

You can read back the data that you have stored
in the database by finding, filtering, and sorting objects.

A read from the database generally consists of the following steps:

- Get all objects of a certain type from the database.
- Optionally, filter the results.

Query operations return a
[results collection](https://pub.dev/documentation/realm/latest/realm/RealmResults-class.html). These
collections are live, meaning they always contain the latest results of the
associated query.

## Read Characteristics
Design your app's data access patterns around these three key
read characteristics to read data as efficiently as possible.

### Results Are Not Copies
Results to a query are not copies of your data. Modifying
the results of a query modifies the data on disk
directly. This memory mapping also means that results are
**live**: that is, they always reflect the current state on
disk.

### Results Are Lazy
The SDK only runs a query when you actually request the
results of that query. This lazy evaluation enables you to write
highly performant code for handling large data sets and complex
queries. You can chain several filter operations without requiring
extra work to process the intermediate state.

### References Are Retained
One benefit of the SDK's object model is that
the SDK automatically retains all of an object's
relationships as direct
references. This enables you to traverse your graph of relationships
directly through the results of a query.

A **direct reference**, or pointer, allows you to access a
related object's properties directly through the reference.

Other databases typically copy objects from database storage
into application memory when you need to work with them
directly. Because application objects contain direct
references, you are left with a choice: copy the object
referred to by each direct reference out of the database in
case it's needed, or just copy the foreign key for each
object and query for the object with that key if it's
accessed. If you choose to copy referenced objects into
application memory, you can use up a lot of resources for
objects that are never accessed, but if you choose to only
copy the foreign key, referenced object lookups can cause
your application to slow down.

The SDK bypasses all of this using zero-copy
live objects. The SDK's object accessors point
directly into database storage using memory mapping, so there is no
distinction between the objects in the database and the results
of your query in application memory. Because of this, you can traverse
direct references across an entire database from any query result.

### Limiting Query Results
As a result of lazy evaluation, you do not need any special mechanism to
limit query results with the SDK. For example, if your query
matches thousands of objects, but you only want to load the first ten,
simply access only the first ten elements of the results collection.

### Pagination
Thanks to lazy evaluation, the common task of pagination becomes quite
simple. For example, suppose you have a results collection associated
with a query that matches thousands of objects in your database. You
display one hundred objects per page. To advance to any page, simply
access the elements of the results collection starting at the index that
corresponds to the target page.

## Read Objects
Unless noted otherwise, the examples on this page use two object types, `Person` and `Team`.

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

### Find Object by Primary Key
Find an object by its primary key with [Realm.find()](https://pub.dev/documentation/realm/latest/realm/Realm/find.html).

```dart
final luke = realm.find<Person>(lukePrimaryKey);
```

### Query All Objects
Retrieve a collection of all objects of a data model in the database with the
[Realm.all()](https://pub.dev/documentation/realm/latest/realm/Realm/all.html) method.

```dart
final people = realm.all<Person>();
```

### Query Related Objects
> Version added: 1.8.0

If your data model includes objects that reference other objects, you can
query the relationship
using the [getBacklinks()](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase/getBacklinks.html) method.

This method returns a [results collection](https://pub.dev/documentation/realm/latest/realm/RealmResults-class.html)
of all objects that link to the given object through a to-one, to-many, or inverse
relationship. The following examples use the models defined on the
Relationships page.

- **To-one relationship:** In this example, we have a `Bike` object model
with a to-one relationship with a `Person` object.

  We use the `getBacklinks()` method to find any `Bike` objects that link
  to the specified person through the `owner` property:
  ```dart
  // Persons have a to-one relationship with Bikes
  final person = realm.query<Person>("firstName == 'Anakin'").first;

  // Find all Bikes owned by a Person named 'Anakin'
  final allBikes = person.getBacklinks<Bike>('owner');
  ```
- **To-many relationship:** In this example, we have a `Scooter` object model
with a to-many relationship with a `ScooterShop` object.

  We use the `getBacklinks()` method to find any `ScooterShops` objects
that link to the specified scooter through the `scooters` list
property:
  ```dart
  // Scooters have a to-many relationship with ScooterShops
  final scooters = realm.query<Scooter>("name == 'Scooterbug'").first;

  // Find all ScooterShops with a Scooter named 'Scooterbug'
  final shops = scooters.getBacklinks<ScooterShop>('scooters');
  ```
- **Inverse relationship:** In this example, we have a `Task` object model
with an inverse relationship with a `User` object.

  We use the `getBacklinks()` method to find any `User` objects that link
  to the specified tasks through the `tasks` backlinks property:

  ```dart
  // Tasks have an inverse relationship to Users
  final inCompleteTasks = realm.query<Task>("isComplete == false");

  // Find all Users who have an incomplete Task
  for (final task in inCompleteTasks) {
    final ownersWithIncompleteTasks = task.getBacklinks<User>('tasks');
    for (final user in ownersWithIncompleteTasks) {
      print("User ${user.username} has incomplete tasks.");
    }
  }
  ```

### Query Lists
You can query any list of [RealmObjects](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase-mixin.html)
or primitives.

```dart
final config = Configuration.local([Person.schema, Team.schema]);
final realm = Realm(config);
final heroes = Team(ObjectId(), 'Millenium Falcon Crew', crew: [
  Person(ObjectId(), 'Luke'),
  Person(ObjectId(), 'Leia'),
  Person(ObjectId(), 'Han'),
  Person(ObjectId(), 'Chewbacca')
]);
realm.write(() => realm.add(heroes));

final lukeAndLeia = heroes.crew.query('name BEGINSWITH \$0', ['L']);
```

### Query Nested Collections of Mixed Data
> Version added: 2.0.0

In Flutter SDK v2.0.0 and later, `RealmValue`
properties can contain collections (a list or map) of mixed data. These
collections can be nested within collections and can contain other
collections of mixed data.

You can query these using the same syntax as you would for a
normal list or dictionary collection. Refer to the  documentation for more
information on supported operators and list comparisons.

For nested collections, you can also use:

- Bracket notation, which provides the following collection query operators: `[FIRST]` and `[LAST]`: match the first or last elements within the collection.`[<int>]`: match the element at the specific index.`[*]`: match any element within the collection (this operator assumes a
collection type at that path).`[SIZE]`: match the collection length.
- The `@type` operator, which supports the following values:

  - `array` and `list`: match a list collection.
  - `dictionary` and `object`: match a map collection.
  - `collection`: match a list or a map collection.

```dart
realm.write(() {
  realm.addAll([
    (Team(ObjectId(), 'Janitorial Staff',
        eventLog: RealmValue.from({
          '1': {
            'date': DateTime.utc(5622, 8, 18, 12, 30, 0),
            'type': ['work_order', 'maintenance'],
            'summary': 'leaking pipes in control room',
            'priority': 'high',
          },
          '2': {
            'date': DateTime.utc(5622, 9, 18, 12, 30, 0),
            'type': ['maintenance'],
            'summary': 'trash compactor jammed',
            'priority': 'low',
            'comment': 'this is the second time this week'
          }
        }))),
    (Team(ObjectId(), 'IT',
        eventLog: RealmValue.from({
          '1': {
            'date': DateTime.utc(5622, 9, 20, 12, 30, 0),
            'type': ['hardware', 'repair'],
            'summary': 'lightsaber damage to server room',
            'priority': 'high',
          }
        })))
  ]);

  final teams = realm.all<Team>();
  // Use bracket notation to query collection values at the specified path
  final teamsWithHighPriorityEvents =
      // Check any element at that path with [*]
      teams.query("eventLog[*].priority == 'high'");
  print(teamsWithHighPriorityEvents.length); // prints `2`

  final teamsWithMaintenanceEvents =
      // Check for the first element at that path with [FIRST]
      teams.query("eventLog[*].type[FIRST] == 'maintenance'");
  print(teamsWithMaintenanceEvents.length); // prints `1`

  final teamsWithMultipleEvents =
      // Check for collection at that path with matching elements
      // Note that the order must match unless you use ANY or ALL
      teams.query("eventLog[*].type[*] == {'maintenance', 'work_order'}");
  print(
      teamsWithMultipleEvents.length); // prints `0` because order matters

  final teamsWithEventsAsLists =
      // Check the collection type with @type
      teams.query("eventLog[*].type.@type == 'list'");
  print(teamsWithEventsAsLists.length); // prints `2`
});
```

### Convert Lists or Sets to Results
You can convert a `RealmList` or `RealmSet` to an instance of `RealmResults`
using their respective methods:

- [RealmList.asResults()](https://pub.dev/documentation/realm/latest/realm/RealmList/asResults.html)
- [RealmSet.asResults()](https://pub.dev/documentation/realm/latest/realm/RealmSet/asResults.html)

These methods support lists and sets of `RealmObjects` as well as primitive
values.

```dart
final config = Configuration.local([Person.schema, Team.schema]);
final realm = Realm(config);
final heroes = Team(ObjectId(), 'Millenium Falcon Crew', crew: [
  Person(ObjectId(), 'Luke', hobbies: [
    'Going to Tashi Station',
    'Fixing the Moisture Vaporators'
  ]),
  Person(ObjectId(), 'Leia', hobbies: [
    'Going on diplomatic missions',
    'Rescuing short stormtroopers'
  ]),
  Person(ObjectId(), 'Han',
      hobbies: ['Shooting first', 'Making fast Kessel Runs']),
  Person(ObjectId(), 'Chewbacca', hobbies: [
    'Fixing the Millenium Falcon',
    'Tearing the arms off of droids'
  ])
]);
realm.write(() => realm.add(heroes));

// Converts the Team object's 'crew' List into a RealmResults<Person>.
final heroesCrewAsResults = heroes.crew.asResults();

final luke = heroesCrewAsResults.query("name == 'Luke'").first;
// Converts Luke's 'hobbies' list into a RealmResults<String>
final lukeHobbiesAsResults = luke.hobbies.asResults();
```

### Filter Results
Filter a `RealmList` to retrieve a specific segment
of objects with the [Realm.query()](https://pub.dev/documentation/realm/latest/realm/Realm/query.html) method.
In the `query()` method's argument, use Realm Query Language to perform filtering.
Realm Query Language is a string-based query language that you can use to retrieve
objects from the database.

```dart
final team =
    realm.query<Team>('name == \$0', ['Millennium Falcon Crew']).first;
final humanCrewMembers = team.crew.query('name != \$0', ['Chewbacca']);
```

You can use iterable arguments in your filter. For example:

```dart
final listOfNames = ['Luke', 'Leia'];
final matchingRealmObjects =
    realm.query<Person>('name IN \$0', [listOfNames]);
```

#### Filter Inverse Relationships
You can also filter by inverse relationships using the
`@links.<Type>.<Property>` syntax. For example, a filter can match
a `Task` object based on properties of the `User`
object that references it:

```dart
// Filter Tasks through the User's backlink property
// using `@links.<ObjectType>.<PropertyName>` syntax
final jarjarsIncompleteTasks = realm.query<Task>(
    "ALL @links.User.tasks.username == 'jarjar_binks' AND isComplete == false");

final tasksForHan =
    realm.query<Task>("ALL @links.User.tasks.username == 'han'");
```

For more information on constructing queries, refer to the
Realm Query Language reference documentation.

### Filter with Full-Text Search
You can use Realm Query Language (RQL) to query on properties that have a
Full-Text Search Index (FTS) annotation.
To query these properties, use the `TEXT` predicate in your query.

Exclude results for a word by placing the `-` character in front of the word.
For example, a search for `-sheep wool` would include all search results for
`wool` excluding those with `sheep`.

In Flutter SDK version 1.6.0 and later, you can specify prefixes by placing
the `*` character at the end of a word. For example, `wo*` would include
all search results for `wool` and `woven`. The Flutter SDK does *not*
currently support suffix searches.

In the following example, we query on the `Rug.pattern` and `Rug.material`
fields:

```dart
// Find rugs with a chevron pattern
final chevronRugs = realm.query<Rug>("pattern TEXT \$0", ["chevron"]);

// Find rugs with a wool material but not sheep wool
final notSheepWoolRugs = realm.query<Rug>("material TEXT \$0", [" -sheep wool"]);

// Find rugs with a material starting with "co-"
final coRugs = realm.query<Rug>("material TEXT \$0", ["co*"]);
```

#### Full-Text Search Tokenizer Details
Full-Text Search (FTS) indexes support:

- Boolean match word searches, not searches for relevance.
- Tokens are diacritics- and case-insensitive.
- Tokens can only consist of characters from ASCII and the Latin-1 supplement (western languages).
- All other characters are considered whitespace. Words split by a hyphen (-) like full-text are split into two tokens.

For more information on features of the FTS index, see the API reference for
[RealmIndexType](https://pub.dev/documentation/realm_common/latest/realm_common/RealmIndexType.html).

### Sort Results
Sort query results using the Realm Query Language SORT() operator in the `query()` method's argument.

Note that you can't use parameterized queries
in RQL SORT() clauses. Instead, use strings or string interpolation.

```dart
realm.write(() {
  realm.addAll([
    Person(ObjectId(), 'Luke'),
    Person(ObjectId(), 'Leia'),
    Person(ObjectId(), 'Han'),
    Person(ObjectId(), 'Chewbacca')
  ]);
});

final alphabetizedPeople =
    realm.query<Person>('TRUEPREDICATE SORT(name ASC)');
for (var person in alphabetizedPeople) {
  print(person.name);
}
// prints 'Chewbacca', 'Han', 'Leia', 'Luke'
```

### Limit Results
Limit query results using the Realm Query Language `LIMIT()` operator in the `query()` method's argument.

Note that you can't use parameterized queries
in RQL `LIMIT()` clauses. Instead, use strings or string interpolation.

```dart
realm.write(() {
  realm.addAll([
    Person(ObjectId(), 'Luke'),
    Person(ObjectId(), 'Luke'),
    Person(ObjectId(), 'Luke'),
    Person(ObjectId(), 'Luke')
  ]);
});

final limitedPeopleResults =
    realm.query<Person>('name == \$0 LIMIT(2)', ['Luke']);

// prints `2`
print(limitedPeopleResults.length);
```
