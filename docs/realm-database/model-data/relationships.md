# Relationships - Flutter SDK
You can reference other Realm models from your Realm model.
This lets you create the following types of relationships between Realm objects:

- To-One Relationship
- To-Many Relationship
- Inverse Relationship

You can also embed one Realm object directly within another to create a nested data structure.
Embedded objects are similar to relationships, but provide additional constraints.
For more information about these constraints and how to create embedded objects,
refer to the Embedded Objects data type documentation.

> **TIP:**
> In Flutter v1.9.0 and later, you can use the
> [getBacklinks()](https://pub.dev/documentation/realm/latest/realm/RealmObjectBase/getBacklinks.html) method to find objects that link to another object through a relationship.
> For more information, refer to Query Related Objects.
>

## To-One Relationship
A **to-one** relationship means that an object is related in a specific
way to no more than one other object.

To set up a to-one relationship, create a property in your model whose type
is another model. Multiple objects can reference the same object.

> **IMPORTANT:**
> When you declare a to-one relationship in your object model, it must
> be an optional property. If you try to make a to-one relationship
> required, Realm throws an exception at runtime.
>

```dart
@RealmModel()
class _Bike {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late _Person? owner;
}

@RealmModel()
class _Person {
  @PrimaryKey()
  late ObjectId id;

  late String firstName;
  late String lastName;
  late int? age;
}
```

## To-Many Relationship
A **to-many** relationship means that an object is related in a specific
way to multiple objects.

You can create a relationship between one object and any number of objects
using a property of type `List<T>` in your application, where T is a Realm model class.

```dart
@RealmModel()
class _Scooter {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late _Person? owner;
}

@RealmModel()
class _ScooterShop {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late List<_Scooter> scooters;
}
```

## Inverse Relationship
An **inverse relationship** links a Realm object back to any other realm objects
that refer to it in to-one or to-many relationships.

Inverse relationships have the following properties:

- You must explicitly define a property in the object's model as an inverse relationship.
The schema cannot infer the inverse relationship.
- Inverse relationships automatically update themselves with corresponding backlinks.
You can find the same set of Realm objects with a manual query,
but the inverse relationship field reduces boilerplate query code and capacity for error.
- You cannot manually set the value of an inverse relationship property.
Instead, Realm updates implicit relationships when you add or remove
an object in the relationship.
- Backlinks only work with Realm objects. Objects that haven't been added to a
realm yet do not have backlinks.

For example, the to-many relationship "a User has many Tasks" does not
automatically create the inverse relationship "a Task belongs to one User".
If you don't specify the inverse relationship in the Task object model, you need to
run a separate query to look up the user that is assigned to a given task.

Use the [Backlink](https://pub.dev/documentation/realm_common/latest/realm_common/Backlink-class.html)
property annotation to define an inverse relationship.
Pass a [Symbol](https://api.dart.dev/stable/2.18.4/dart-core/Symbol/Symbol.html)
of the field name of the to-one or to-many field for which you are creating the backlink
as an argument to `Backlink()`. Include an `Iterable` of the object model
you are backlinking to in the field below the annotation.

```dart
@RealmModel()
class _User {
  @PrimaryKey()
  late ObjectId id;

  late String username;
  // One-to-many relationship that the backlink is created for below.
  late List<_Task> tasks;
}

@RealmModel()
class _Task {
  @PrimaryKey()
  late ObjectId id;

  late String description;
  late bool isComplete;

  // Backlink field. Links back to the `tasks` property in the `_User` model.
  @Backlink(#tasks)
  late Iterable<_User> linkedUser;
}
```

