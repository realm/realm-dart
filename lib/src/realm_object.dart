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
import 'realm_class.dart';

abstract class RealmAccessor {
  Object? get<T extends Object>(RealmObject object, String name);
  void set(RealmObject object, String name, Object? value, [bool isDefault = false]);

  static final Map<Type, Map<String, Object?>> _defaultValues = <Type, Map<String, Object?>>{};

  static void setDefaults<T extends RealmObject>(Map<String, Object?> values) {
    _defaultValues[T] = values;
  }

  static Object? getDefaultValue(Type realmObjectType, String name) {
    final type = realmObjectType;
    if (!_defaultValues.containsKey(type)) {
      throw RealmException("Type $type not found.");
    }

    final values = _defaultValues[type]!;
    if (values.containsKey(name)) {
      return values[name];
    }

    return null;
  }

  static Map<String, Object?>? getDefaults(Type realmObjectType) {
    if (!_defaultValues.containsKey(realmObjectType)) {
      return null;
    }

    return _defaultValues[realmObjectType]!;
  }
}

class RealmValuesAccessor implements RealmAccessor {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Object? get<T extends Object>(RealmObject object, String name) {
    if (!_values.containsKey(name)) {
      return RealmAccessor.getDefaultValue(object.runtimeType, name);
    }

    return _values[name];
  }

  @override
  void set(RealmObject object, String name, Object? value, [bool isDefault = false]) {
    _values[name] =  value;
  }

  void setAll(RealmObject object, RealmAccessor accessor) {
    final defaults = RealmAccessor.getDefaults(object.runtimeType);

    if (defaults != null) {
      for (var item in defaults.entries) {
        //check if a default value has been overwritten
        if (!_values.containsKey(item.key)) {
          accessor.set(object, item.key, item.value, true);
        }
      }
    }

    for (var entry in _values.entries) {
      accessor.set(object, entry.key, entry.value);
    }
  }
}

class RealmMetadata {
  RealmClassMetadata class_;
  final Map<String, int> _propertyKeys;

  RealmMetadata(this.class_, this._propertyKeys);

  int operator [](String propertyName) =>
      _propertyKeys[propertyName] ?? (throw RealmException("Property $propertyName does not exists on class ${class_.type.runtimeType}"));
}

class RealmClassMetadata {
  final int key;
  final Type type;
  final String? primaryKey;

  RealmClassMetadata(this.type, int classKey, [this.primaryKey]) : key = classKey;
}

class RealmCoreAccessor implements RealmAccessor {
  final RealmMetadata metadata;

  RealmCoreAccessor(this.metadata);

  // bool _sameTypes<S, T>() {
  //   void func<X extends S>() {}
  //   // Spec says this is only true if S and T are "the same type".
  //   print(S);
  //   print(T);
  //   return func is void Function<X extends T>();
  // }

  @override
  Object? get<T extends Object>(RealmObject object, String name) {
    try {
      final value = realmCore.getProperty(object, metadata[name]);
      if (value is! RealmObjectHandle) {
        return value;
      }
     
      return object._realm!.createObject(T, value);
    } on RealmException catch (e) {
      throw RealmException("Error getting property ${metadata.class_.type}.$name Error: ${e.message}");
    }
  }

  @override
  void set(RealmObject object, String name, Object? value, [bool isDefault = false]) {
    try {
      if (value is RealmObject && !value.isManaged) {
        object._realm!.add(value);
      }

      realmCore.setProperty(object, metadata[name], value, isDefault);
    } on RealmException catch (e) {
      throw RealmException("Error setting property ${metadata.class_.type}.$name Error: ${e.message}");
    }
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
  Realm? _realm;
  static final Map<Type, RealmObject Function()> _factories = <Type, RealmObject Function()>{};

  static Object? get<T extends Object>(RealmObject object, String name) {
    return object._accessor.get<T>(object, name);
  }

  static void set<T extends Object>(RealmObject object, String name, T? value) {
    object._accessor.set(object, name, value);
  }

  static void registerFactory<T extends RealmObject>(T Function() factory) {
    if (_factories.containsKey(T)) {
      return;
    }

    _factories[T] = factory;
  }

  static bool setDefaults<T extends RealmObject>(Map<String, Object> values) {
    RealmAccessor.setDefaults<T>(values);
    return true;
  }
}

//RealmObject package internal members
extension RealmObjectInternal on RealmObject {
  void manage(Realm realm, RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (_handle != null) {
      throw RealmException("Object is already managed");
    }

    _handle = handle;
    _realm = realm;

    if (_accessor is RealmValuesAccessor) {
      (_accessor as RealmValuesAccessor).setAll(this, accessor);
    }

    _accessor = accessor;
  }

  static RealmObject create(Type type, Realm realm, RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (!RealmObject._factories.containsKey(type)) {
      throw Exception("Factory for object type $type not found.");
    }

    final object = RealmObject._factories[type]!();
    object._handle = handle;
    object._accessor = accessor;
    object._realm = realm;
    return object;
  }

  RealmObjectHandle get handle => _handle!;
  RealmAccessor get accessor => _accessor;
  Realm? get realm => _realm;

  bool get isManaged => _realm != null;
}

/// An exception being thrown when a Realm operation or Realm object access fails
class RealmException implements Exception {
  final String message;

  RealmException(this.message);

  @override
  String toString() {
    return "RealmException: $message";
  }
}
