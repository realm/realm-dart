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
  T get<T>(RealmObject object, String name);
  void set<T>(RealmObject object, String name, T value, [bool isDefault = false]);

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

  static Map<String, Object?> getDefaults(Type realmObjectType) {
    final type = realmObjectType;
    if (!_defaultValues.containsKey(type)) {
      throw Exception("Type $type not found.");
    }

    return _defaultValues[type]!;
  }
}

class RealmValuesAccessor implements RealmAccessor {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  T get<T>(RealmObject object, String name) {
    if (!_values.containsKey(name)) {
      return RealmAccessor.getDefaultValue(object.runtimeType, name) as T;
    }

    return _values[name] as T;
  }

  @override
  void set<T>(RealmObject object, String name, T value, [bool isDefault = false]) {
    _values[name] =  value;
  }

  void setAll(RealmObject object, RealmAccessor accessor) {
    final defaults = RealmAccessor.getDefaults(object.runtimeType);

    for (var item in defaults.entries) {
      if (!_values.containsKey(item.key)) {
        accessor.set(object, item.key, item.value, true);
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

  @override
  T get<T>(RealmObject object, String name) {
    try {
      return realmCore.getProperty(object, metadata[name]) as T;
    } on RealmException catch (e) {
      throw RealmException("Error getting property ${metadata.class_.type}.$name Error: ${e.message}");
    }
  }

  @override
  void set<T>(RealmObject object, String name, T value, [bool isDefault = false]) {
    try {
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
  static final Map<Type, RealmObject Function()> _factories = <Type, RealmObject Function()>{};

  static T get<T extends Object>(RealmObject object, String name) {
    return object._accessor.get<T>(object, name);
  }

  static void set<T extends Object>(RealmObject object, String name, T value) {
    object._accessor.set<T>(object, name, value);
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
  void manage(RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (_handle != null) {
      throw RealmException("Object is already managed");
    }

    _handle = handle;

    if (_accessor is RealmValuesAccessor) {
      (_accessor as RealmValuesAccessor).setAll(this, accessor);
    }

    _accessor = accessor;
  }

  static T create<T extends RealmObject>(RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (!RealmObject._factories.containsKey(T)) {
      throw Exception("Factory for object type $T not found.");
    }

    final object = RealmObject._factories[T]!() as T;
    object._handle = handle;
    object._accessor = accessor;
    return object;
  }

  RealmObjectHandle get handle => _handle!;
  RealmAccessor get accessor => _accessor;

  bool get isManaged => _accessor is RealmCoreAccessor;
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
