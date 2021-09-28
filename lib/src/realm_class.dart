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

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/src/utf8.dart';

import 'results.dart';
import 'configuration.dart';
import 'realm_object.dart';
import 'collection.dart';
import 'dynamic_object.dart';
import "helpers.dart";
import 'realm_property.dart';
import 'realm_bindings_win.dart';

export 'collection.dart';
export 'list.dart';
export 'results.dart';
export 'realm_object.dart';
export "configuration.dart";
export 'realm_property.dart';
export 'dynamic_object.dart';
export 'helpers.dart';

NativeLibrary? RealmLib;
void setRealmLib(DynamicLibrary realmLibrary) {
  RealmLib = NativeLibrary(realmLibrary);
}

/// The callback type to use with `Realm.write`
typedef void VoidCallback();

/// The callback type to use with `Realm.addListener`
typedef void ListenerCallback(dynamic sender, String event);

void _inspect(dynamic arg1, dynamic arg2, dynamic arg3, dynamic arg4, dynamic arg5) {
   Object k;
}

/// An event type used when adding event listeners with `Realm.addListener`
enum Event {
  /// The callback will be called when objects in the `Realm` changed
  change,

  /// The callback will be called when the `Realm` schema changes
  schema
}

/// A Realm instance represents a Realm database.
class Realm extends DynamicObject {
  // Used from native code
  Realm._constructor();

  /// Opens a Realm using a [Configuration] object
  factory Realm(Configuration config) native "Realm_constructor";

  //native code expects first argument this instance. For static methods pass null
  
  /// Get the schemaVersion version of the Realm at [path].
  /// 
  /// For details about the schema version see [Configuration.schemaVersion]
  static double schemaVersion(String path) {
    return _schemaVersion(null, path);
  }
  static double _schemaVersion(Object? nullptr, String path) native "Realm_schemaVersion";

  /// Returns `true` if the Realm already exists on [path].
  static bool exists(String path) {
    return _exists(null, new Configuration()..path = path);
  }
  static bool _exists(Object? nullptr, Configuration config) native "Realm_exists";

  /// DO NOT USE.
  static bool clearTestState() {
    // TODO: fix clearTestState with FFI
    //return _clearTestState(null);
    return true;
  }
  //move this to the tests and make it an extensions method that calls clearTestState and passes the correct `this`
  static bool _clearTestState(Object nullptr) native "Realm_clearTestState";

  /// Delete the Realm file at [path]
  static void deleteFile(String path) {
    File realmFile = new File(path);
    if (!realmFile.existsSync()) {
      throw new RealmException("The realm file does not exists at path $path");
    }
    
    File realmLockFile = new File("$path.lock");
    if (!realmLockFile.existsSync()) {
      throw new RealmException("The path does not specify a Realm file: $path");
    }

    File realmNoteFile = new File("$path.note");
    Directory realmManagementDirectory = new Directory("$path.management");
        
    try {
      //delete these first since their existence is optional
      if (realmNoteFile.existsSync()) realmNoteFile.deleteSync();
      if (realmManagementDirectory.existsSync()) realmManagementDirectory.deleteSync(recursive: true);

      //try delete realmFile first
      realmFile.deleteSync();
      realmLockFile.deleteSync();
    }
    catch (e) {
      throw new RealmException("Could not delete the Realm at $path error: $e");
    }
  }

  /// Returns the Realm default path on the current platform.
  /// 
  /// For more details about the path to the Realm file see [Configuration.path]
  static String get defaultPath native "Realm_get_defaultPath";

  /// Create a new Realm object of type `T`
  ///
  /// Gets an object of type `T` and returns a Realm object of the same type `T`. 
  /// The temporary object used for the argument should be discarded.
  /// ```dart
  ///  Car car = new Car()..make = "Audi";
  ///  realm.write(() {
  ///    car = realm.create(car);
  ///    Car car2 = realm.create(new Car()..make == 'Audi');
  ///  });
  /// ```
  T create<T extends RealmObject>(T object) {
      String typeName = _getRealmObjectName<T>();
      return _create(typeName, object) as T;  
  }
  RealmObject _create(String? typeName, RealmObject object) native "Realm_create";

  /// Gets all objects of type `T` 
  /// 
  /// Returns a [Results] object which can be indexed, filtered, sorted, queried etc
  ///
  /// ```dart
  /// var objects = realm.objects<Car>();
  /// Car firstCar = objects[0];
  /// int count = objects.length;
  /// var sortedObjects = objects.sort("make");
  /// ```
  Results<T> objects<T extends RealmObject>() {
    String typeName = _getRealmObjectName<T>();
    var results = _objects(typeName);  
    return new Results<T>(results);
  }
  RealmResults _objects(String typeName) native "Realm_objects";
  
  /// Synchronously call the provided callback inside a write transaction. 
  /// If an exception happens inside a transaction, you'll lose the changes in that transaction, 
  /// but the Realm itself won't be affected (or corrupted).
  /// 
  /// Nesting transactions (calling `write()` within `write()`) will throw an exception.
  void write(VoidCallback callback) native "Realm_write";

  String _getRealmObjectName<T>() {
    var schema = TypeStaticProperties.getValue(T, "schema");
    if (schema == null) {
      throw new Exception("Class ${T} was not registered in the schema for this Realm");
    }
    String name = schema.name;
    return name;
  }

  /// Add a [ListenerCallback] callback for the specified event [event].
  /// 
  /// The provided callback will be called when write transactions are committed.
  /// Creating a new write transactions within the callback will throw an exception 
  /// if there is a current transaction already open
  /// You can check if there is a current transaction with `realm.IsInTransaction`
  void addListener(Event event, ListenerCallback callback) {
    _addListener(event.toString().split(".")[1], callback);
  }
  void _addListener(String name, ListenerCallback callback) native 'Realm_addListener';

  /// Remove a [ListenerCallback] callback for the specified event [event].
  /// 
  /// The callback argument should be the same callback reference used in a previous call to [addListener]
  /// ```dart
  /// var callback = (realm, name) { ... }
  /// realm.addListener(Event.change, callback);
  /// realm.removeListener(Event.change, callback);
  /// ```
  void removeListener(Event event, ListenerCallback callback) {
    _removeListener(event.toString().split(".")[1], callback);
  }
  void _removeListener(String name, ListenerCallback callback) native 'Realm_removeListener';

  /// Closes this [Realm] so it may be re-opened with a newer schema version. 
  /// All objects and collections from this Realm are no longer valid after calling this method.
  /// This method will not throw an exception if called multiple times.
  close() native 'Realm_close';

  /// Returns `true` if this [Realm] is closed.
  bool get isClosed native 'Realm_get_isClosed';

  /// Returns `true` if this [Realm] has a transaction opened
  bool get isInTransaction native 'Realm_get_isInTransaction';
  
  /// Deletes a Realm object from the this [Realm].
  void delete(RealmObject object) native 'Realm_delete';

  /// Deletes a list of Realm object from the this [Realm].
  void deleteMany(List<RealmObject> objects) native 'Realm_delete';

  /// Deletes all Realm object from the this [Realm].
  void deleteAll() native 'Realm_deleteAll';

  /// Searches for a Realm object with the specified primary key of type `T`.
  T find<T extends RealmObject>(dynamic key) {
    String typeName = _getRealmObjectName<T>();
    return _objectForPrimaryKey(typeName, key) as T; 
  }
  RealmObject _objectForPrimaryKey(String name, dynamic key) native 'Realm_objectForPrimaryKey';

  static String get version => RealmLib!.realm_get_library_version().toDartString();
}

/// An exception being thrown when a Realm operation or Realm object access fails
class RealmException implements Exception  {
  final dynamic message;

  RealmException([this.message]);

  String toString() {
    Object message = this.message;
    if (message == null) return "RealmException:";
    return "RealmException: $message";
  }
}
