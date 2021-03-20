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

  @override
  //int get length => innerList.length;
  int get length {
    return innerList.length;
  }

  @override
  void set length(int length) {
    innerList.length = length;
  }

  @override
  Type operator [](int index) => innerList[index];

  @override
  void operator []=(int index, Type value) {
    innerList[index] = value;
  }
}

class Configuration {
  Configuration() {
    schema = new SchemaObjects();
  }

  ByteData encryptionKey;
  //migrationCallback
  //use typedef to MigrationCallback from index.d.ts
  Function migration;
  //callback
  Function shouldCompactOnLaunch;

  String path;
  String fifoFilesFallbackPath;
  bool readOnly;
  bool inMemory;
  // get List<Type> schema_objects;
  // set List<Type> schema_objects;

  SchemaObjects schema;
  double schemaVersion;
  bool deleteRealmIfMigrationNeeded;
  bool disableFormatUpgrade;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isAccessor) {
      return super.noSuchMethod(invocation);
    }

    return null;
  }
}
