////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:collection';
//import 'dart:mirrors';
import 'dart:typed_data';

import 'realm_object.dart';
import 'realm_property.dart';
import 'dynamic_object.dart';
import 'helpers.dart';

/// A collection of Realm object types used for declaring the Realm schema
class SchemaObjects extends ListBase<Type> {
  List<Type> innerList = new List<Type>();

  //final realmObjectClassMirror = reflectClass(RealmObject);
  // /**
  //  * Generates Realm Object Schema of the following type
  //  * Car.schema = {
  //  *      name: 'Car',
  //  *      properties: {
  //  *          make: { type: 'string' },
  //  *          model: { type: 'string' },
  //  *          otherType: { type: 'string', mapTo: "type", optional: true},
  //  *          kilometers: { type: 'int', default: 0 },
  //  *      }
  //  *  };
  //  */
  // void _generateSchema(Type type) {
  //   ClassMirror classMirror = reflectClass(type);

  //   if (!classMirror.isSubclassOf(realmObjectClassMirror)) {
  //     throw new Exception("Invali schema type ${type}. Type should be subclass of RealmObject");
  //   }

  //   dynamic schema = DynamicObject();
  //   schema.name = type.toString();
  //   schema.properties = new DynamicObject();

  //   bool hasRealmProperty = false;
  //   for (var value in classMirror.declarations.values) {
  //     if (!value.metadata.isEmpty) {
  //       if (value.metadata.first.reflectee is RealmProperty) {
  //         hasRealmProperty = true;
  //         String propertyName = value.simpleName.name;
  //         dynamic realmProperty = value.metadata.first.reflectee;

  //         // if (realmProperty.type == null) {
  //         //   //Dart: this can use @required from meta package.
  //         //   throw new Exception("Field ${propertyName} of class ${T.toString()} has an invalid annotation. No `RealmProperty.type` specified.");
  //         // }

  //         //Generates: "propertyName: { type: '...', mapTo: "...", optional: bool}"
  //         dynamic propertyValue = DynamicObject();
  //         propertyValue.type = realmProperty.type;
  //         propertyValue['default'] = realmProperty.defaultValue ?? null;
  //         propertyValue.optional = realmProperty.optional ?? null;
  //         propertyValue.mapTo = realmProperty.mapTo ?? null;
  //         schema.properties[propertyName] = propertyValue;
  //         if (realmProperty.primaryKey ?? false) {
  //           schema.primaryKey = propertyName;
  //         }

  //         //print(propertyName + " type: " + realmProperty.type + " defaultValue:" + realmProperty.defaultValue.toString());
  //         //print(value.metadata.first.reflectee.description);
  //       }
  //     }
  //   }

  //   if (!hasRealmProperty) {
  //     throw new Exception("Class ${type.toString()} should have at least one field with RealmProperty annotation");
  //   }

  //   //set the static field on the T class.
  //   TypeStaticProperties.setValue(type, "schema", schema);
  // }

  /// Add a Realm object type to this schema instance
  add(Type type) {
    var schema = Helpers.invokeStatic(type, "getSchema");
    //set the static field on the T class.
    TypeStaticProperties.setValue(type, "schema", schema);

    //_generateSchema(type);
    innerList.add(type);
  }


  /**
   *  Define schema for a RealmObject type
   */
  // define<T>() {
  //   innerList.add(T);

  //   _generateSchema<T>();
  // }

  /// Add all Realm object types from an [Iterable<T>] to this schema instance
  /// 
  /// ```dart
  /// var config = new Configuration();
  /// config.schema.addAll([Car, Person]);
  /// ```
  addAll(Iterable<Type> types) {
    // addMany(schemaObjects);
    for (var type in types) {
      add(type);
    }

    //defineAll(types);
  }

  /**
   * Define schema for all RealmObject types
   */
  // defineAll(Iterable<T> types) {
  //   for (var type in types) {
  //     add(type);
  //   }
  // }

  /// Returns the number of Realm object types in the schema
  @override
  //int get length => innerList.length;
  int get length {
    return innerList.length;
  }

  /// Sets the number of Realm object types in the schema
  @override
  void set length(int length) {
    innerList.length = length;
  }

  /// Get the Type of a Realm object in the schema at the specified `index`
  @override
  Type operator [](int index) => innerList[index];

  /// Set the Type of a Realm object in the schema at the specified `index`
  @override
  void operator []=(int index, Type value) {
    innerList[index] = value;
  }
}

/// Configuration used to create a [Realm] instance
class Configuration {
  Configuration() {
    schema = new SchemaObjects();
  }

  /// The 512-bit (64-byte) encryption key used to encrypt and decrypt all data in the Realm.
  ByteData encryptionKey;

  //migrationCallback
  //use typedef to MigrationCallback from index.d.ts
  //Function migration;
  //callback
  //Function shouldCompactOnLaunch;

  ///The path to the file where the Realm database should be stored.
  ///
  /// If omitted the default Realm path for the platform will be used. 
  String path;

  /// An alternatiev location for the Realm FIFO files.
  /// 
  /// Opening a Realm creates a number of FIFO special files in order to 
  /// coordinate access to the Realm across threads and processes. 
  /// If the Realm file is stored in a location that does not allow the creation
  ///  of FIFO special files (e.g. FAT32 filesystems), then the Realm cannot be 
  /// opened. In that case Realm needs a different location to store these files 
  /// and this property defines that location. The FIFO special files are very 
  /// lightweight and the main Realm file will still be stored in the location 
  /// defined by the path property. This property is ignored if the directory 
  /// defined by path allow FIFO special files.
  String fifoFilesFallbackPath;

  /// Specifies if this Realm should be opened as read-only.
  bool readOnly;
  
  /// Specifies if this Realm should be opened in-memory. 
  /// 
  /// A [path] is still required (can be the default path) to identify the Realm 
  /// so other processes can open the same Realm. The file will also be used as 
  /// swap space if the Realm becomes bigger than what fits in memory, 
  /// but it is not persistent and will be removed when the last instance is closed.
  bool inMemory;
  
  // get List<Type> schema_objects;
  // set List<Type> schema_objects;

  /// The schema of the [Realm]. Use [SchemaObjects.add] to add objects to the schema
  SchemaObjects schema;

  /// The schema version used to open the [Realm]
  /// 
  /// If omitted the default value of `0` is used to open the [Realm]
  /// It is required to specify a schema version when initializing an existing 
  /// Realm with a schema that contains objects that differ from their previous 
  /// specification. If the schema was updated and the schemaVersion was not, 
  /// an [RealmException] will be thrown.
  double schemaVersion;

  /// Specifies if this Realm should be deleted if a migration is needed.
  bool deleteRealmIfMigrationNeeded;
  
  /// Disables the automatic upgrade of the Realm file
  ///
  /// If the Realm file format was created with an older version of Realm SDK 
  /// it will be automatically upgraded when opened. If needed set `disableFormatUpgrade` 
  /// to `true` to get an exception in such cases instead.
  bool disableFormatUpgrade;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isAccessor) {
      return super.noSuchMethod(invocation);
    }

    return null;
  }
}
