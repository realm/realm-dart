Realm Dart library provides a set of classes for access to realm schema definition. These classes describe the type and properties of [RealmObjects](../realm/RealmObject-class.html) that will be persisted in the database. [RealmObjects](../realm/RealmObject-class.html) are generated from defined classes in the model using the [annotations](./Annotations-topic.html).

 If class `Car` is generated [RealmObject](../realm/RealmObject-class.html) from model class `_Car` with class level annotation [@RealmModel](../realm/RealmModel-class.html). Then this class has a static property schema that returns [SchemaObject](../realm/SchemaObject-class.html) describing realm object type and properties.

    ```dart
    SchemaObject schemaCar =  Car.schema;
    ```

To create instance of [RealmSchema](../realm/RealmSchema-class.html) pass a collection of schema objects [SchemaObject](../realm/SchemaObject-class.html) to the constructor of [Configuration](../realm/Configuration-class.html).

    ```dart
    var config = Configuration([Car.schema, Person.schema]);
    ```

Configured schema [RealmSchema](../realm/RealmSchema-class.html) is available through `schema` property of [Configuration](../realm/Configuration-class.html). Schema type and described properties of each model are available through iterating schemas in [RealmSchema](../realm/RealmSchema-class.html).
    ```dart
    RealmSchema schema = config.schema;
    ```

[Configuration](../realm/Configuration-class.html) instance with defined schema inside is useed for creating a new instance of [Realm](../realm/Realm-class.html) storage.

    ```dart
    var realm = Realm(config);
    ```

