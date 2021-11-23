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

import 'native/realm_core.dart';
import 'realm_property.dart';

abstract class RealmAccessor {
  T get<T extends Object>(RealmObject object, String name);
  void set<T extends Object>(String name, T value);
}

class RealmValuesAccessor implements RealmAccessor {
  final Map<String, Object> _values = <String, Object>{};

  @override
  T get<T extends Object>(RealmObject object, String name) {
    return _values[name] as T;
  }

  @override
  void set<T extends Object>(String name, T value) {
    _values[name] = value;
  }

  void setAll(RealmAccessor accessor) {
    for (var entry in _values.entries) {
      accessor.set(entry.key, entry.value);
    }
  }
}

class RealmMetadata{
  final int classId;
  final Type classType;
  final Map<String, int> _propertyIds;


  RealmMetadata(this.classType, this.classId, this._propertyIds);

  int operator [](String propertyName) => _propertyIds[propertyName] ?? (throw RealmException("Property $propertyName does not exists on class $classId"));
}

class RealmCoreAccessor implements RealmAccessor {
  final RealmMetadata metadata;

  RealmCoreAccessor(this.metadata);

  @override
  T get<T extends Object>(RealmObject object, String name) {
    try {
      return realmCore.readProperty(object, metadata[name], RealmPropertyType.string) as T;
    } on RealmException catch (e) {
     throw RealmException("Error reading property ${metadata.classType.runtimeType}.$name ${e.message}");
    }
  }

  @override
  void set<T extends Object>(String name, T value) {
    // TODO: implement set
  }
}

/// A object in a realm. 
/// 
/// RealmObjects are generated from Realm data model classes
/// A data model class `_MyClass` will have a RealmObject with name `MyClass` generated 
/// which should be used insead of directly instantiating and working with RealmObject instances
class RealmObject {
  RealmObjectHandle? _handle;
  RealmAccessor _accessor = RealmValuesAccessor();

  static T get<T extends Object>(RealmObject realmObject, String name) {
    return  realmObject._accessor.get<T>(realmObject, name);
  }

  static void set<T extends Object>(RealmObject realmObject, String name, T value) {
    realmObject._accessor.set<T>(name, value);
  }

  // static void setDefaults<T extends RealmObject>(RealmObject realmObject, Map<String, Object> values) {
  //   RealmValuesAccessor.setDefaults<T>(realmObject, values);
  // }
}

//RealmObject package internal members
extension RealmObjectEx  on RealmObject {
  void manage(RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (_handle != null) {
      throw RealmException("Object is already managed");
    }

    _handle = handle;
    
    if (_accessor is RealmValuesAccessor) {
      (_accessor as RealmValuesAccessor).setAll(accessor);
    }

    _accessor = accessor;
  }

  RealmObjectHandle get handle => _handle!;
  RealmAccessor get accessor => _accessor;

  bool get isManaged => _accessor is RealmCoreAccessor;
}

/// An exception being thrown when a Realm operation or Realm object access fails
class RealmException implements Exception  {
  final String message;

  RealmException(this.message);

  @override
  String toString() {
    return "RealmException: $message";
  }
}



  // Map<String, Object>? _unmanagedProperties;

  // /**
  //  *  Default constructor. Enables the subclass to different constructors and work with RealmObject unmanaged instances
  //  */
  // RealmObject() {
  //   _unmanagedProperties = new Map<String, Object>();
  // }

  // /**
  //  *  Creates managed RealmObject. Called from generated code
  //  */
  // RealmObject.constructor() {}

  // Object get _realm native "RealmObject_get__realm";

  // Object _native_get(String name) native "RealmObject_get_property";
  // void _native_set(String name, Object value) native "RealmObject_set_property";

  // Object operator [](String name) {
  //   if (_unmanagedProperties != null) {
  //     return _unmanagedProperties![name]!;
  //   }

  //   Object result = _native_get(name);
  //   if (result is RealmList) {
  //     throw new Exception("Invalid RealmObject. RealmLists should be retrieved using super_get method");
  //   }

  //   return result;
  // }

  // void operator []=(String name, Object value) {
  //   if (_unmanagedProperties != null) {
  //     _unmanagedProperties![name] = value;
  //     return;
  //   }

  //   _native_set(name, value);
  // }

  // static dynamic getSchema(String typeName, Iterable<SchemaProperty> properties) {
  //   if (properties.length == 0) {
  //       throw new Exception("Class ${typeName} should have at least one field with RealmProperty annotation");
  //   }

  //   dynamic schema = DynamicObject();
  //   schema.name = typeName;
  //   schema.properties = new DynamicObject();

  //   for (var realmProperty in properties) {
  //     dynamic propertyValue = DynamicObject();
  //     propertyValue.type = realmProperty.type;
  //     propertyValue['default'] = realmProperty.defaultValue ?? null;
  //     propertyValue.optional = realmProperty.optional ?? null;
  //     propertyValue.mapTo = realmProperty.mapTo ?? null;
  //     schema.properties[realmProperty.propertyName] = propertyValue;
  //     if (realmProperty.primaryKey ?? false) {
  //       schema.primaryKey = realmProperty.propertyName;
  //     }
  //   }

  //   return schema;
  // }

  // Object isValid() native "RealmObject_isValid";
  
  // /// Adds a [RealmObjectListenerCallback] which will be called when RealmObject properties change.
  // Object addListener(RealmObjectListenerCallback callback) native "RealmObject_addListener";
  
  // /// Removes a [RealmObjectListenerCallback] that was previously added with [addListener]
  // /// 
  // /// The callback argument should be the same callback reference used in a previous call to [addListener]
  // /// ```dart
  // /// var callback = (object, changes) { ... }
  // /// myObject.addListener(callback);
  // /// myObject.removeListener(callback);
  // /// ```
  // Object removeListener(RealmObjectListenerCallback callback) native "RealmObject_removeListener";

  // /// Removes all [RealmObjectListenerCallback] that were previously added with [addListener] 
  // Object removeAllListeners() native "RealmObject_removeAllListeners";
// }

/// @nodoc
// extension Super on RealmObject {
//   ArrayList<T> super_get<T extends RealmObject>(String name) {
//     if (_unmanagedProperties != null) {
//       return _unmanagedProperties![name] as ArrayList<T>;
//     }

//     Object result = _native_get(name);
//     if (result is RealmList) {
//       return new ArrayList<T>.fromRealmList(result);
//     }

//     return result as ArrayList<T>;
//   }

//   void super_set<T extends RealmObject>(String name, Iterable<T> value) {
//     ArrayList<T> arrayList;
//     if (value is ArrayList<T>) {
//       arrayList = value;
//       return;
//     }

//     arrayList = new ArrayList(value);

//     if (_unmanagedProperties != null) {
//       _unmanagedProperties![name] = arrayList;
//       return;
//     }

//     throw new Exception("Setting ArrayList on manged object is not supported");
//   }
// }

