# Model Data - Flutter SDK
Realm applications model data as objects composed of
field-value pairs that each contain one or more supported data types.

## Realm Objects
Realm objects are regular Dart classes that you can interact with like any other
Dart class in your application. The Flutter SDK memory maps Realm objects directly
to Realm. You can work with Realm objects as you would any other Dart object instance.

Every Realm object conforms to a specific **object type**, which is a class
that defines the properties and relationships for objects of that type.
The SDK guarantees that all objects in a realm conform to the schema for their object type
and validates objects whenever they are created, modified, or deleted.

To learn more about defining Realm objects, refer to
Define a Realm Object Schema.

## Realm Object Properties
When you define your Realm object model, you specify a set of of properties
to include in the schema. You can define properties with the following characteristics:

- Its data type
- If it is optional or required
- If it is a primary key
- If it is indexed
- If the property defines a relationship to another Realm object type

To learn more about property options when defining Realm objects,
refer to the following documentation:

- Data Types
- Relationships
- Property Annotations

## Updating a Realm Object Schema
You can update your Realm schema over time as your application changes.
The steps to update the schema and your data vary depending on the type of schema change.
To learn more about the ways to update your schema,
refer to Update a Realm Object Schema.
