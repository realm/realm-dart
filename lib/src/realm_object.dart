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
  void set<T>(RealmObject object, String name, T value);
}

class RealmValuesAccessor implements RealmAccessor {
  final Map<String, Object?> _values = <String, Object>{};

  @override
  T get<T>(RealmObject object, String name) {
    return _values[name] as T;
  }

  @override
  void set<T>(RealmObject object, String name, T value) {
    _values[name] = value;
  }

  void setAll(RealmObject object, RealmAccessor accessor) {
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
      throw RealmException("Error reading property ${metadata.class_.type}.$name Error: ${e.message}");
    }
  }

  @override
  void set<T>(RealmObject object, String name, T value) {
    try {
      realmCore.setProperty(object, metadata[name], value);
    } on RealmException catch (e) {
      throw RealmException("Error writting property ${metadata.class_.type}.$name Error: ${e.message}");
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

  static T create<T extends RealmObject>() {
    if (!_factories.containsKey(T)) {
      throw RealmException("Factory for Realm object type $T not found");
    }

    return _factories[T]!() as T;
  }

  // static void setDefaults<T extends RealmObject>(RealmObject realmObject, Map<String, Object> values) {
  //   RealmValuesAccessor.setDefaults<T>(realmObject, values);
  // }
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
