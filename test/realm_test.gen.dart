// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'realm_test.dart';


// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
  static bool? _defaultsSet;

  Car([String make = 'Tesla']) {
      _defaultsSet ??= RealmObject.setDefaults<Car>({"make": "Tesla"});
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, "make") as String;
  @override
  set make(String value) => RealmObject.set<String>(this, "make", value);

  static SchemaObject get schema { 
    RealmObject.registerFactory<Car>(() => Car._());
    return SchemaObject(Car)..properties = [SchemaProperty("make", RealmPropertyType.string, primaryKey: true)];
  }
}

class Person extends _Person with RealmObject {
  // static bool? _defaultsSet;
  //Type Person has no defaults  
  Person() {
    //_defaultsSet ??= RealmObject.setDefaults<Person>({});
  }

  @override
  String get name => RealmObject.get<String>(this, "name") as String;
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  static SchemaObject get schema {
    RealmObject.registerFactory<Person>(() => Person());
    return SchemaObject(Person)..properties = [SchemaProperty("name", RealmPropertyType.string)];
  }
}

class Dog extends _Dog with RealmObject {
  Dog();

  @override
  String get name => RealmObject.get<String>(this, "name") as String;
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  @override
  int? get age => RealmObject.get<int>(this, "age") as int?;
  @override
  set age(int? value) => RealmObject.set<int>(this, "age", value);

  @override
  Person? get owner => RealmObject.get<Person>(this, "owner") as Person?;
  @override
  set owner(covariant Person? value) => RealmObject.set<Person>(this, "owner", value);

  static SchemaObject get schema {
    RealmObject.registerFactory<Dog>(() => Dog());
    return SchemaObject(Dog)..properties = [
      SchemaProperty("name", RealmPropertyType.string), 
      SchemaProperty("age", RealmPropertyType.int, nullable: true),
      SchemaProperty("owner", RealmPropertyType.object, nullable: true, optional: true, linkTarget: 'Person')
    ];
  }
}

class Team extends _Team with RealmObject {
  Team();

  @override
  String get name => RealmObject.get<String>(this, "name") as String;
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  @override
  List<Person> get players => RealmObject.get<List<Person>>(this, "players") as List<Person>;
  @override
  set players(covariant List<Person> value) => RealmObject.set<List<Person>>(this, "players", value);

  static SchemaObject get schema {
    RealmObject.registerFactory<Team>(()=> Team());
    return SchemaObject(Team)..properties = [
      SchemaProperty("name", RealmPropertyType.string), 
      SchemaProperty("players", RealmPropertyType.object, collectionType: RealmCollectionType.list),
    ];
  }
}