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

import 'results.dart';
import 'configuration.dart';
import 'realm_object.dart';
import 'collection.dart';
// if (dart.library.io) 'src/hw_io.dart'

// import 'platform_detect.dart';

// import 'dart-ext:realm_dart_extension';

//import 'dummy.dart'  
// import 'platform_detect.dart'
//   if (dart.library.io) 'platform_desktop';

// import 'platform_detect.dart'  
//   if (dart.library.io) 'dart-ext:realm_dart_extension';


import 'dynamic_object.dart';
import "helpers.dart";
import 'realm_property.dart';

export 'collection.dart';
export 'list.dart';
export 'results.dart';
export 'realm_object.dart';
export "configuration.dart";
export 'realm_property.dart';
export 'dynamic_object.dart';
export 'helpers.dart';

typedef void VoidCallback();
typedef void ListenerCallback(dynamic sender, String event);

void _inspect(dynamic arg1, dynamic arg2, dynamic arg3, dynamic arg4, dynamic arg5) {
   Object k;
}

class Realm extends DynamicObject {
  /**
   * Used from native code
   */
  Realm._constructor();

  factory Realm(Configuration config) native "Realm_constructor";

  static double schemaVersion(String path, dynamic encryptionKey) native "Realm_schemaVersion";
  static bool exists(String path) native "Realm_exists";

  //move this to the tests and make it an extensions method that calls clearTestState and passes the correct `this`
  static bool clearTestState() native "Realm_clearTestState";
  static bool deleteFile(Configuration config) native "Realm_deleteFile";

  static String get defaultPath native "Realm_defaultPath";

  RealmObject _create(String typeName, RealmObject object) native "Realm_create";

  T create<T extends RealmObject>(T object) {
      String typeName = _getRealmObjectName<T>();
      return _create(typeName, object);  
  }

  RealmResults _objects(String typeName) native "Realm_objects";

  Results<T> objects<T extends RealmObject>() {
    String typeName = _getRealmObjectName<T>();
    var results = _objects(typeName);  
    return new Results<T>(results);
  }
  
  void write(VoidCallback callback) native "Realm_write";

  String _getRealmObjectName<T>() {
    var schema = TypeStaticProperties.getValue(T, "schema");
    if (schema == null) {
      throw new Exception("Class ${T} was not registered in the schema for this Realm");
    }
    String name = schema.name;
    return name;
  }

  addListener(String name, ListenerCallback) native 'Realm_addListener';

  close() native 'Realm_close';
  bool get isClosed native 'Realm_get_isClosed';

  void delete(RealmObject object) native 'Realm_delete';
  void deleteMany(List<RealmObject> objects) native 'Realm_delete';
  void deleteAll() native 'Realm_deleteAll';


  RealmObject _objectForPrimaryKey(String name, dynamic key) native 'Realm_objectForPrimaryKey';

  T find<T extends RealmObject>(dynamic key) {
    String typeName = _getRealmObjectName<T>();
    return _objectForPrimaryKey(typeName, key) as T; 
  }

  //  String _realmObjectName(Type type) {
  //   var schema = TypeStaticProperties.getValue(type, "schema");
  //   if (schema == null) {
  //     throw new Exception("Class ${type}} was not registered in the schema for this Realm");
  //   }
  //   String name = schema.name;
  //   return name;
  // }
  

  
  //compat
  // static Type collection;
  // static Type list;
  // static Type results;
  // static Type object;
}
