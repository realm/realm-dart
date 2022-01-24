Realm API provides a set of classes that helps developers to work with Realm in an easy way. Once the data model is defined using the [annotations](Annotations-topic.html) and the realm models are generated using ```flutter run realm generate```, Realm API is able to create, delete, edit and search your model objecrs in Realm storage.


* Defining set of schemas to be stored and opening [Realm] instance. This code will create Realm file with given schema.
    ```dart
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);
    ```

* Creating object in memory
    ```dart
    final dog = Dog("Foxy")
        ..age = 1
        ..owner = Person("Daryl Stone");
    ```

* Adding new object to the Realm storage
    ```dart
    realm.write(() => realm.add(dog));
    ```

* Editing object in Realm storage
    ```dart
    realm.write(() => dog.age = 2);
    ```
* Reading objects from Realm
    ```dart
    // Find object by primary key.
    var foxy = realm.find<Dog>("Foxy");
    // Get all objects from specific type.
    var allDogs = realm.all<Dog>();
    //Search objects with query.
    var myDog = realm.all<Dog>().query(r'name=$0', [dog.name]);
    ```

* Deleting objects from Realm
    ```dart
    //Deleting one object
    realm.write(() => realm.delete(dog));
    //Deleting all objects
    realm.write(() => realm.deleteMany(realm.all<Dog>()));
    //Deleting many objects
    realm.write(() => realm.deleteMany([dog1, dog2, dog3]]));
    ```