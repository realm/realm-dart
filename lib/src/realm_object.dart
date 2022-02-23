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

import 'list.dart';
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
    _values[name] = value;
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
  final Map<String, RealmPropertyMetadata> _propertyKeys;

  RealmMetadata(this.class_, this._propertyKeys);

  RealmPropertyMetadata operator [](String propertyName) =>
      _propertyKeys[propertyName] ?? (throw RealmException("Property $propertyName does not exists on class ${class_.type.runtimeType}"));

  String? getPropertyName(int propertyKey) {
    for (final entry in _propertyKeys.entries) {
      if (entry.value.key == propertyKey) {
        return entry.key;
      }
    }
    return null;
  }
}

class RealmClassMetadata {
  final int key;
  final Type type;
  final String? primaryKey;

  RealmClassMetadata(this.type, int classKey, [this.primaryKey]) : key = classKey;
}

class RealmPropertyMetadata {
  final int key;
  final RealmCollectionType collectionType;
  const RealmPropertyMetadata(this.key, [this.collectionType = RealmCollectionType.none]);
}

class RealmCoreAccessor implements RealmAccessor {
  final RealmMetadata metadata;

  RealmCoreAccessor(this.metadata);

  @override
  Object? get<T extends Object>(RealmObject object, String name) {
    try {
      final propertyMeta = metadata[name];
      if (propertyMeta.collectionType == RealmCollectionType.list) {
        final handle = realmCore.getListProperty(object, propertyMeta.key);
        return object._realm!.createList<T>(handle);
      }

      Object? value = realmCore.getProperty(object, propertyMeta.key);

      if (value is RealmObjectHandle) {
        return object._realm!.createObject(T, value);
      }

      return value;
    } on Exception catch (e) {
      throw RealmException("Error getting property ${metadata.class_.type}.$name Error: $e");
    }
  }

  @override
  void set(RealmObject object, String name, Object? value, [bool isDefault = false]) {
    final propertyMeta = metadata[name];
    try {
      if (value is List) {
        if (value.isEmpty) {
          return;
        }

        //This assumes the target list property is empty. `value is List` should happen only when making a RealmObject managed
        final handle = realmCore.getListProperty(object, propertyMeta.key);
        for (var i = 0; i < value.length; i++) {
          RealmListInternal.setValue(handle, object._realm!, i, value[i]);
        }
        return;
      }

      //If value is RealmObject - manage it
      if (value is RealmObject && !value.isManaged) {
        object._realm!.add(value);
      }

      realmCore.setProperty(object, propertyMeta.key, value, isDefault);
    } on Exception catch (e) {
      throw RealmException("Error setting property ${metadata.class_.type}.$name Error: $e");
    }
  }
}

/// An object that is persisted in `Realm`.
///
/// `RealmObjects` are generated from Realm data model classes marked with `@RealmModel` annotation and named with an underscore.
///
/// A data model class `_MyClass` will have a `RealmObject` generated with name `MyClass`.
///
/// [RealmObject] should not be used directly as it is part of the generated class hierarchy. ex: `MyClass extends _MyClass with RealmObject`.
/// {@category Realm}
class RealmObject {
  RealmObjectHandle? _handle;
  RealmAccessor _accessor = RealmValuesAccessor();
  Realm? _realm;
  static final Map<Type, RealmObject Function()> _factories = <Type, RealmObject Function()>{};

  /// @nodoc
  static Object? get<T extends Object>(RealmObject object, String name) {
    return object._accessor.get<T>(object, name);
  }

  /// @nodoc
  static void set<T extends Object>(RealmObject object, String name, T? value) {
    object._accessor.set(object, name, value);
  }

  /// @nodoc
  static void registerFactory<T extends RealmObject>(T Function() factory) {
    if (_factories.containsKey(T)) {
      return;
    }

    _factories[T] = factory;
  }

  /// @nodoc
  static T create<T extends RealmObject>() {
    if (!_factories.containsKey(T)) {
      throw RealmException("Factory for Realm object type $T not found");
    }

    return _factories[T]!() as T;
  }

  /// @nodoc
  static bool setDefaults<T extends RealmObject>(Map<String, Object> values) {
    RealmAccessor.setDefaults<T>(values);
    return true;
  }

  /// `true` if this `RealmObject` is equal to another `RealmObject`.
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmObject) return false;
    if (!isManaged || !other.isManaged) return false;
    return realmCore.equals(this, other);
  }

  /// Gets a value indicating whether this object is managed and represents a row in the database.
  ///
  /// If a managed object has been removed from the [Realm], it is no longer valid and accessing properties on it
  /// will throw an exception.
  /// The Object is not valid if its [Realm] is closed or object is deleted.
  /// Unmanaged objects are always considered valid.
  bool get isValid => isManaged ? realmCore.objectIsValid(this) : true;

  /// Allows listening for property changes on this Realm object
  /// 
  /// Returns a [Stream] of [RealmObjectChanges<T>] that can be listened to.
  /// 
  /// If the object is not managed a [RealmStateError] is thrown.
  Stream get changes => throw RealmError("Invalid usage. Use the generated inheritors of RealmObject");

  /// @nodoc
  static Stream<RealmObjectChanges<T>> getChanges<T extends RealmObject>(T object) {
     if (!object.isManaged) {
      throw RealmStateError("Object is not managed");
    }

    final controller = RealmObjectNotificationsController<T>(object);
    return controller.createStream();
  }
}

/// @nodoc
//RealmObject package internal members
extension RealmObjectInternal on RealmObject {
  void manage(Realm realm, RealmObjectHandle handle, RealmCoreAccessor accessor) {
    if (_handle != null) {
      //most certainly a bug hence we throw an Error
      throw ArgumentError("Object is already managed");
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

/// An exception being thrown when a `Realm` operation or [RealmObject] access fails.
/// {@category Realm}
class RealmException implements Exception {
  final String message;

  RealmException(this.message);

  @override
  String toString() {
    return "RealmException: $message";
  }
}

/// Describes the changes in on a single RealmObject since the last time the notification callback was invoked.
class RealmObjectChanges<T extends RealmObject> {
  // ignore: unused_field
  final RealmObjectChangesHandle _handle;
  
  /// The realm object being monitored for changes.
  final T object;

  /// `True` if the object was deleted.
  bool get isDeleted => realmCore.getObjectChangesIsDeleted(_handle);

  /// The property names that have changed.
  List<String> get properties {
    final propertyKeys = realmCore.getObjectChangesProperties(_handle);
    return object._realm!.getPropertyNames(object.runtimeType, propertyKeys);
  }
  
  const RealmObjectChanges._(this._handle, this.object);
}

/// @nodoc
class RealmObjectNotificationsController<T extends RealmObject> extends NotificationsController {
  T realmObject;
  late final StreamController<RealmObjectChanges<T>> streamController;

  RealmObjectNotificationsController(this.realmObject);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeObjectNotifications(realmObject._handle!, this, realmObject._realm!.scheduler.handle);
  }

  Stream<RealmObjectChanges<T>> createStream() {
    streamController = StreamController<RealmObjectChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(Handle changesHandle) {
    if (changesHandle is! RealmObjectChangesHandle) {
      throw RealmError("Invalid changes handle. RealmObjectChangesHandle expected");
    }

    final changes = RealmObjectChanges<T>._(changesHandle, realmObject);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}
