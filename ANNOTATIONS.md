Realm annotations are used to define Realm data model classes and their properties.
For each class marked as `@RealmModel` a schema model is generated. Generated model is defined with [SchemaObject](../realm/SchemaObject-class.html) and it is able to be added to [RealmModel](../realm/RealmModel-class.html), which defines the schema of realm database.
Possible annotations for the properties are `@PrimaryKey`, `@MapTo`, `@Indexed`, `@Ignored`.

Defining a sample data model class `_Car`:
```dart
@RealmModel()
class _Car {
  @PrimaryKey()
  late final String plateNumber;

  late String make;

  @Ignored()
  late String description;
}
```
These annotaions help model generator to prepare classes for the schema. See in "Quick start" - [Define Your Object Model](https://docs-mongodbcom-staging.corp.mongodb.com/realm/docsworker-xlarge/flutter_alpha/sdk/flutter/quick-start/#define-your-object-model)