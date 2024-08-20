// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:realm_common/realm_common.dart';
import 'package:type_plus/type_plus.dart';

import 'configuration.dart';
import 'handles/handle_base.dart';
import 'handles/notification_token_handle.dart';
import 'handles/object_changes_handle.dart';
import 'handles/object_handle.dart';
import 'list.dart';
import 'map.dart';
import 'realm_class.dart';
import 'results.dart';

typedef DartDynamic = dynamic;

abstract class RealmAccessor {
  Object? get<T extends Object?>(RealmObjectBase object, String name);
  void set(RealmObjectBase object, String name, Object? value, {bool isDefault = false, bool update = false});

  static final Map<Type, Map<String, Object?>> _defaultValues = <Type, Map<String, Object?>>{};

  static void setDefaults<T extends RealmObjectBase>(Map<String, Object?> values) {
    _defaultValues[T] = values;
  }

  static (bool valueExists, Object? value) getDefaultValue(Type realmObjectType, String name) {
    final type = realmObjectType;

    final values = _defaultValues[type];
    if (values != null && values.containsKey(name)) {
      return (true, values[name]);
    }

    return (false, null);
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
  Object? get<T extends Object?>(RealmObjectBase object, String name) {
    if (!_values.containsKey(name)) {
      final (valueExists, value) = RealmAccessor.getDefaultValue(object.runtimeType, name);
      if (!valueExists) {
        throw RealmError("Property '$name' does not exist on object of type '${object.runtimeType}'");
      }

      return value;
    }

    return _values[name];
  }

  @override
  void set(RealmObjectBase object, String name, Object? value, {bool isDefault = false, bool update = false}) {
    _values[name] = value;
  }

  void setAll(RealmObjectBase object, RealmAccessor accessor, bool update) {
    final defaults = RealmAccessor.getDefaults(object.runtimeType);

    if (defaults != null) {
      for (var item in defaults.entries) {
        //check if a default value has been overwritten
        if (!_values.containsKey(item.key)) {
          accessor.set(object, item.key, item.value, isDefault: true);
        }
      }
    }

    for (var entry in _values.entries) {
      accessor.set(object, entry.key, entry.value, update: update);
    }
  }
}

class RealmObjectMetadata {
  final int classKey;
  final SchemaObject schema;
  late final String? primaryKey = schema.firstWhereOrNull((element) => element.primaryKey)?.mapTo;

  final Map<String, RealmPropertyMetadata> _propertyKeys;

  String get _realmObjectTypeName => schema.isGenericRealmObject ? schema.name : schema.type.toString();

  RealmObjectMetadata(this.schema, this.classKey, this._propertyKeys);

  RealmPropertyMetadata operator [](String propertyName) {
    var meta = _propertyKeys[propertyName];
    if (meta == null) {
      // We couldn't find a property by the name supplied by the user - this may be because the _propertyKeys
      // map is keyed on the property names as they exist in the database while the user supplied the public
      // name (i.e. the name of the property in the model). Try and look up the property by the public name and
      // then try to re-fetch the property meta using the database name.
      final publicName = schema.firstWhereOrNull((e) => e.name == propertyName)?.mapTo;
      if (publicName != null && publicName != propertyName) {
        meta = _propertyKeys[publicName];
      }
    }

    return meta ?? (throw RealmException("Property $propertyName does not exist on class $_realmObjectTypeName"));
  }

  void operator []=(String propertyName, RealmPropertyMetadata value) {
    _propertyKeys[propertyName] = value;
  }

  String? getPropertyName(int propertyKey) {
    for (final entry in _propertyKeys.entries) {
      if (entry.value.key == propertyKey) {
        return entry.key;
      }
    }
    return null;
  }
}

/// @nodoc
class RealmPropertyMetadata {
  final int key;
  final RealmCollectionType collectionType;
  final RealmPropertyType propertyType;
  final bool isNullable;
  final String? objectType;
  final String? linkOriginProperty;
  final bool isPrimaryKey;
  const RealmPropertyMetadata(this.key, this.objectType, this.linkOriginProperty, this.propertyType, this.isNullable, this.isPrimaryKey,
      [this.collectionType = RealmCollectionType.none]);
}

class RealmCoreAccessor implements RealmAccessor {
  final RealmObjectMetadata metadata;
  final bool isInMigration;

  RealmCoreAccessor(this.metadata, this.isInMigration);

  @override
  Object? get<T extends Object?>(RealmObjectBase object, String name) {
    try {
      final propertyMeta = metadata[name];

      switch (propertyMeta.collectionType) {
        case RealmCollectionType.list:
          if (propertyMeta.propertyType == RealmPropertyType.linkingObjects) {
            final sourceMeta = object.realm.metadata.getByName(propertyMeta.objectType!);
            final sourceProperty = sourceMeta[propertyMeta.linkOriginProperty!];
            final handle = object.handle.getBacklinks(sourceMeta.classKey, sourceProperty.key);
            return RealmResultsInternal.create<T>(handle, object.realm, sourceMeta);
          }

          final handle = object.handle.getList(propertyMeta.key);
          final listMetadata = propertyMeta.objectType == null ? null : object.realm.metadata.getByName(propertyMeta.objectType!);

          if (propertyMeta.propertyType == RealmPropertyType.mixed) {
            return object.realm.createList<RealmValue>(handle, metadata);
          }

          // listMetadata is not null when we have list of RealmObjects. If the API was
          // called with a generic object arg - get<Object> we construct a list of
          // RealmObjects since we don't know the type of the object.
          if (listMetadata != null && _isTypeGenericObject<T>()) {
            switch (listMetadata.schema.baseType) {
              case ObjectType.realmObject:
                //ManagedRealmList<RealmObject>._(handle, object.realm, listMetadata);
                return object.realm.createList<RealmObject>(handle, listMetadata);
              case ObjectType.embeddedObject:
                return object.realm.createList<EmbeddedObject>(handle, listMetadata);
              default:
                throw RealmError('List of ${listMetadata.schema.baseType} is not supported yet');
            }
          }
          return object.realm.createList<T>(handle, listMetadata);
        case RealmCollectionType.set:
          final handle = object.handle.getSet(propertyMeta.key);
          final setMetadata = propertyMeta.objectType == null ? null : object.realm.metadata.getByName(propertyMeta.objectType!);
          if (setMetadata != null && _isTypeGenericObject<T>()) {
            switch (setMetadata.schema.baseType) {
              case ObjectType.realmObject:
                return object.realm.createSet<RealmObject>(handle, setMetadata);
              case ObjectType.embeddedObject:
                return object.realm.createSet<EmbeddedObject>(handle, setMetadata);
              default:
                throw RealmError('Set of ${setMetadata.schema.baseType} is not supported yet');
            }
          }

          return object.realm.createSet<T>(handle, setMetadata);
        case RealmCollectionType.map:
          final handle = object.handle.getMap(propertyMeta.key);
          final mapMetadata = propertyMeta.objectType == null ? null : object.realm.metadata.getByName(propertyMeta.objectType!);

          if (propertyMeta.propertyType == RealmPropertyType.mixed) {
            return object.realm.createMap<RealmValue>(handle, metadata);
          }

          // mapMetadata is not null when we have map of RealmObjects. If the API was
          // called with a generic object arg - get<Object> we construct a map of
          // RealmObjects since we don't know the type of the object.
          if (mapMetadata != null && _isTypeGenericObject<T>()) {
            switch (mapMetadata.schema.baseType) {
              case ObjectType.realmObject:
                return object.realm.createMap<RealmObject>(handle, mapMetadata);
              case ObjectType.embeddedObject:
                return object.realm.createMap<EmbeddedObject>(handle, mapMetadata);
              default:
                throw RealmError('Map of ${mapMetadata.schema.baseType} is not supported yet');
            }
          }
          return object.realm.createMap<T>(handle, mapMetadata);
        default:
          var value = object.handle.getValue(object.realm, propertyMeta.key);

          if (value is ObjectHandle) {
            final meta = object.realm.metadata;
            final typeName = propertyMeta.objectType;

            late Type type;
            late RealmObjectMetadata targetMetadata;

            if (propertyMeta.propertyType == RealmPropertyType.mixed) {
              (type, targetMetadata) = meta.getByClassKey(value.classKey);
            } else {
              // If we have an object but the user called the API without providing a generic
              // arg, we construct a RealmObject since we don't know the type of the object.
              type = _isTypeGenericObject<T>() ? RealmObjectBase : T;
              targetMetadata = typeName != null ? meta.getByName(typeName) : meta.getByType(type);
            }

            value = object.realm.createObject(type, value, targetMetadata);
          }

          if (T == RealmValue || (propertyMeta.propertyType == RealmPropertyType.mixed && _isTypeGenericObject<T>())) {
            value = RealmValue.from(value);
          }

          return value;
      }
    } on Exception catch (e) {
      throw RealmException("Error getting property ${metadata._realmObjectTypeName}.$name Error: $e");
    }
  }

  @override
  void set(RealmObjectBase object, String name, Object? value, {bool isDefault = false, bool update = false}) {
    final propertyMeta = metadata[name];
    try {
      if (value is RealmValue && value.type.isCollection) {
        object.handle.setCollection(object.realm, propertyMeta.key, value);
        return;
      }

      if (value is RealmList) {
        final handle = object.handle.getList(propertyMeta.key);
        if (update) {
          handle.clear();
        }

        for (var i = 0; i < value.length; i++) {
          RealmListInternal.setValue(handle, object.realm, i, value[i], update: update);
        }
        return;
      }

      //TODO: set from ManagedRealmList is not supported yet
      if (value is RealmSet) {
        final handle = object.handle.getSet(propertyMeta.key);
        if (update) {
          handle.clear();
        }

        // TODO: use realmSetAssign when available in C-API
        // https://github.com/realm/realm-core/issues/6209
        //realmCore.realmSetAssign(handle, value.toList());
        for (var element in value) {
          object.realm.addUnmanagedRealmObjectFromValue(element, update);

          final result = handle.insert(element);
          if (!result) {
            throw RealmException("Error while adding value $element in RealmSet");
          }
        }
        return;
      }

      if (value is RealmMap) {
        final handle = object.handle.getMap(propertyMeta.key);
        if (update) {
          handle.clear();
        }

        for (var kvp in value.entries) {
          RealmMapInternal.setValue(handle, object.realm, kvp.key, kvp.value, update: update);
        }
        return;
      }

      if (value is EmbeddedObject) {
        if (value.isManaged) {
          throw RealmError("Can't set an embedded object that is already managed");
        }

        final handle = object.handle.createEmbedded(propertyMeta.key);
        object.realm.manageEmbedded(handle, value, update: update);
        return;
      }

      object.realm.addUnmanagedRealmObjectFromValue(value, update);

      if (propertyMeta.isPrimaryKey && !isInMigration) {
        final currentValue = object.handle.getValue(object.realm, propertyMeta.key);
        if (currentValue != value) {
          throw RealmException("Primary key cannot be changed (original value: '$currentValue', supplied value: '$value')");
        }
      }

      object.handle.setValue(propertyMeta.key, value, isDefault);
    } on Exception catch (e) {
      throw RealmException("Error setting property ${metadata._realmObjectTypeName}.$name Error: $e");
    }
  }
}

mixin RealmEntity {
  Realm? _realm;

  /// The [Realm] instance this object belongs to.
  Realm get realm => _realm ?? (throw RealmStateError('$this not managed'));

  /// True if the object belongs to a [Realm].
  bool get isManaged => _realm != null;

  /// True if the entity belongs to a frozen [Realm].
  bool get isFrozen => _realm?.isFrozen == true;
}

extension RealmEntityInternal on RealmEntity {
  void setRealm(Realm value) => _realm = value;
}

/// An object that is persisted in `Realm`.
///
/// `RealmObjects` are generated from Realm data model classes marked with `@RealmModel` annotation and named with an underscore.
///
/// A data model class `_MyClass` will have a `RealmObject` generated with name `MyClass`.
///
/// [RealmObject] should not be used directly as it is part of the generated class hierarchy. ex: `MyClass extends _MyClass with RealmObject`.
/// {@category Realm}
mixin RealmObjectBase on RealmEntity implements RealmObjectBaseMarker {
  ObjectHandle? _handle;
  RealmAccessor _accessor = RealmValuesAccessor();
  static final Map<Type, RealmObjectBase Function()> _factories = <Type, RealmObjectBase Function()>{
    // Register default factories for `RealmObject` and `RealmObject?`. Whenever the user
    // asks for these types, we'll use the ConcreteRealmObject implementation.
    RealmObject: () => _ConcreteRealmObject(),
    _typeOf<RealmObject?>(): () => _ConcreteRealmObject(),
    EmbeddedObject: () => _ConcreteEmbeddedObject(),
    _typeOf<EmbeddedObject?>(): () => _ConcreteEmbeddedObject(),
  };

  /// @nodoc
  static Object? get<T extends Object?>(RealmObjectBase object, String name) {
    return object._accessor.get<T>(object, name);
  }

  /// @nodoc
  static void set<T>(RealmObjectBase object, String name, T value, {bool update = false}) {
    object._accessor.set(object, name, value, update: update);
  }

  /// @nodoc
  static SchemaObject? getSchema(RealmObjectBase object) {
    final accessor = object.accessor;
    if (accessor is RealmCoreAccessor) {
      return accessor.metadata.schema;
    }

    return null;
  }

  /// @nodoc
  static void registerFactory<T extends RealmObjectBase>(T Function() factory) {
    // Register type as both (T).hashCode.toString() and T.name
    TypePlus.add<T>();
    if (TypePlus.fromId(T.name) == UnresolvedType) {
      // Only register by name, if no other class with the same name is registered
      // Can happen, if the same class name is used in different libraries.
      TypePlus.add<T>(id: T.name);
    }

    // We register a factory for both the type itself, but also the nullable
    // version of the type.
    _factories.putIfAbsent(T, () => factory);
    _factories.putIfAbsent(_typeOf<T?>(), () => factory);
  }

  /// @nodoc
  static RealmObjectBase createObject(Type type, RealmObjectMetadata? metadata) {
    final factory = _factories[type];
    if (factory == null) {
      if (type == RealmObjectBase && metadata != null) {
        switch (metadata.schema.baseType) {
          case ObjectType.realmObject:
            return _ConcreteRealmObject();
          case ObjectType.embeddedObject:
            return _ConcreteEmbeddedObject();
          default:
            throw RealmException("ObjectType ${metadata.schema.baseType} not supported");
        }
      }

      throw RealmException("Factory for Realm object type $type not found");
    }

    return factory();
  }

  /// @nodoc
  static bool setDefaults<T extends RealmObjectBase>(Map<String, Object> values) {
    RealmAccessor.setDefaults<T>(values);
    return true;
  }

  /// @nodoc
  static T freezeObject<T extends RealmObjectBase>(T object) {
    if (!object.isManaged) {
      throw RealmStateError("Can't freeze unmanaged objects.");
    }

    if (!object.isValid) {
      throw RealmStateError("Can't freeze invalidated (deleted) objects.");
    }

    if (object.isFrozen) {
      return object;
    }

    final frozenRealm = object.realm.freeze();
    return frozenRealm.resolveObject(object)!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmObjectBase) return false;
    if (!isManaged || !other.isManaged) return false;

    return handle == other.handle;
  }

  late final int _managedHashCode = handle.hashCode;

  @override
  int get hashCode {
    if (!isManaged) {
      return super.hashCode;
    }

    return _managedHashCode;
  }

  /// Gets a value indicating whether this object is managed and represents a row in the database.
  ///
  /// If a managed object has been removed from the [Realm], it is no longer valid and accessing properties on it
  /// will throw an exception.
  /// The Object is not valid if its [Realm] is closed or object is deleted.
  /// Unmanaged objects are always considered valid.
  bool get isValid => isManaged ? handle.isValid : true;

  /// Allows listening for property changes on this Realm object.
  ///
  /// Returns a [Stream] of [RealmObjectChanges<T>] that can be listened to.
  ///
  /// If the object is not managed a [RealmStateError] is thrown.
  Stream<RealmObjectChanges<RealmObjectBase>> get changes => throw RealmError("Invalid usage. Use the generated inheritors of RealmObject");

  /// Allows listening for property changes on this Realm object using the specified list of key paths.
  /// The key paths indicates which changes in properties should raise a notification.
  ///
  /// Returns a [Stream] of [RealmObjectChanges<T>] that can be listened to.
  ///
  /// If the object is not managed a [RealmStateError] is thrown.
  ///
  /// Example
  /// ``` dart
  /// @RealmModel()
  /// class _Person {
  ///   late String name;
  ///   late int age;
  ///   late List<_Person> friends;
  /// }
  ///
  /// // ....
  ///
  /// // Only changes to person.age and person.friends will raise a notification
  /// person.changesFor(["age", "friends"]).listen( .... )
  /// ```
  Stream<RealmObjectChanges<RealmObjectBase>> changesFor([List<String>? keyPaths]) =>
      throw RealmError("Invalid usage. Use the generated inheritors of RealmObject");

  /// @nodoc
  static Stream<RealmObjectChanges<T>> getChanges<T extends RealmObjectBase>(T object) {
    return getChangesFor<T>(object, null);
  }

  /// @nodoc
  static Stream<RealmObjectChanges<T>> getChangesFor<T extends RealmObjectBase>(T object, [List<String>? keyPaths]) {
    if (!object.isManaged) {
      throw RealmStateError("Object is not managed");
    }

    if (object.isFrozen) {
      throw RealmStateError('Object is frozen and cannot emit changes.');
    }

    final controller = RealmObjectNotificationsController<T>(object, keyPaths, (object.accessor as RealmCoreAccessor).metadata.classKey);
    return controller.createStream();
  }

  // invocation.memberName in noSuchMethod is a Symbol, which hides its _name field. The idiomatic
  // way to obtain it is via Mirrors, which is not available in Flutter. Symbol.toString returns
  // Symbol("name"), so we use a simple regex to extract the symbol name. This is a bit fragile, but
  // is the approach used by the Flutter team as well: https://github.com/dart-lang/sdk/issues/28372.
  // If it turns out not to be reliable, we can instead construct symbols from the property names in
  // the Accessor metadata and compare symbols directly.
  static final RegExp _symbolRegex = RegExp('Symbol\\("(?<symbolName>.*?)=?"\\)');

  @override
  DartDynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final name = _symbolRegex.firstMatch(invocation.memberName.toString())?.namedGroup("symbolName");
      if (name == null) {
        throw RealmError("Could not find symbol name for ${invocation.memberName}");
      }

      return get(this, name);
    }

    if (invocation.isSetter) {
      final name = _symbolRegex.firstMatch(invocation.memberName.toString())?.namedGroup("symbolName");
      if (name == null) {
        throw RealmError("Could not find symbol name for ${invocation.memberName}");
      }

      return set(this, name, invocation.positionalArguments.single);
    }

    return super.noSuchMethod(invocation);
  }

  /// An object exposing dynamic API for this [RealmObject] instance.
  late final DynamicRealmObject dynamic = DynamicRealmObject._(this);

  /// Creates a frozen snapshot of this [RealmObject].
  RealmObjectBase freeze() => freezeObject(this);

  /// Returns all the objects of type [T] that link to this object via [propertyName].
  /// Example:
  /// ```dart
  /// @RealmModel()
  /// class School {
  ///   late String name;
  /// }
  ///
  /// @RealmModel()
  /// class Student {
  ///   School? school;
  /// }
  ///
  /// // Find all students in a school
  /// final school = realm.all<School>().first;
  /// final allStudents = school.getBacklinks<Student>('school');
  /// ```
  RealmResults<T> getBacklinks<T>(String propertyName) {
    if (!isManaged) {
      throw RealmStateError("Can't look up backlinks of unmanaged objects.");
    }

    final sourceMeta = realm.metadata.getByType(T);
    final sourceProperty = sourceMeta[propertyName];

    if (sourceProperty.objectType == null) {
      throw RealmError("Property $T.$propertyName is not a link property - it is a property of type ${sourceProperty.propertyType}");
    }

    if (sourceProperty.objectType != realm.metadata.getByType(runtimeType).schema.name) {
      throw RealmError(
          "Property $T.$propertyName is a link property that links to ${sourceProperty.objectType} which is different from the type of the current object, which is $runtimeType.");
    }
    final handle = this.handle.getBacklinks(sourceMeta.classKey, sourceProperty.key);
    return RealmResultsInternal.create<T>(handle, realm, sourceMeta);
  }

  /// Returns the schema for this object.
  SchemaObject get objectSchema;
}

/// @nodoc
mixin RealmObject on RealmObjectBase implements RealmObjectMarker {
  @override
  Stream<RealmObjectChanges<RealmObject>> get changes => throw RealmError("Invalid usage. Use the generated inheritors of RealmObject");
}

/// @nodoc
mixin EmbeddedObject on RealmObjectBase implements EmbeddedObjectMarker {
  @override
  Stream<RealmObjectChanges<EmbeddedObject>> get changes => throw RealmError("Invalid usage. Use the generated inheritors of EmbeddedObject");
}

extension EmbeddedObjectExtension on EmbeddedObject {
  /// Retrieve the [parent] object of this embedded object.
  RealmObjectBase? get parent {
    if (!isManaged) {
      return null;
    }

    final (parentHandle, classKey) = handle.parent;
    final (type, metadata) = realm.metadata.getByClassKey(classKey);
    return realm.createObject(type, parentHandle, metadata);
  }
}

/// @nodoc
//RealmObject package internal members
extension RealmObjectInternal on RealmObjectBase {
  void manage(Realm realm, ObjectHandle handle, RealmCoreAccessor accessor, bool update) {
    if (_handle != null) {
      // most certainly a bug hence we throw an Error
      throw ArgumentError("Object is already managed");
    }

    _handle = handle;
    _realm = realm;

    if (_accessor is RealmValuesAccessor) {
      (_accessor as RealmValuesAccessor).setAll(this, accessor, update);
    }

    _accessor = accessor;
  }

  static RealmObjectBase create(Type type, Realm realm, ObjectHandle handle, RealmCoreAccessor accessor) {
    final object = RealmObjectBase.createObject(type, accessor.metadata);
    object._handle = handle;
    object._accessor = accessor;
    object._realm = realm;
    return object;
  }

  ObjectHandle get handle {
    if (_handle?.released == true) {
      throw RealmClosedError('Cannot access an object that belongs to a closed Realm');
    }

    return _handle!;
  }

  RealmAccessor get accessor => _accessor;
}

/// An exception being thrown when a `Realm` operation or [RealmObject] access fails.
/// {@category Realm}
class RealmException implements Exception {
  final String message;

  /// A link to the documentation that explains how to resolve the error.
  final String? helpLink;

  RealmException(this.message, {this.helpLink});

  @override
  String toString() {
    return "RealmException: $message";
  }
}

/// An exception thrown when a Realm is opened with a different schema and a migration is required.
/// See [LocalConfiguration.migrationCallback] for more details.
class MigrationRequiredException extends RealmException {
  MigrationRequiredException(super.message)
      : super(helpLink: "https://www.mongodb.com/docs/realm/sdk/flutter/realm-database/model-data/update-realm-object-schema/#manually-migrate-schema");

  @override
  String toString() {
    return "Migration required: $message. See $helpLink for more details.";
  }
}

/// An exception throws during execution of a user callback - e.g. during migration or initial data population.
/// {@category Realm}
class UserCallbackException extends RealmException {
  /// The error that was thrown while executing the callback.
  final Object userException;

  UserCallbackException(this.userException)
      : super('An exception occurred while executing a user-provided callback. See userException for more details: $userException');
}

/// Describes the changes in on a single RealmObject since the last time the notification callback was invoked.
class RealmObjectChanges<T extends RealmObjectBase> {
  // ignore: unused_field
  final ObjectChangesHandle _handle;

  /// The realm object being monitored for changes.
  final T object;

  /// `True` if the object was deleted.
  bool get isDeleted => _handle.isDeleted;

  /// The property names that have changed.
  List<String> get properties {
    final propertyKeys = _handle.properties;
    return object.realm
        .getPropertyNames(object, propertyKeys)
        .map((e) => object.objectSchema.firstWhere((element) => element.mapTo == e || element.name == e).name)
        .toList();
  }

  const RealmObjectChanges._(this._handle, this.object);
}

/// @nodoc
extension RealmObjectChangesInternal<T extends RealmObject> on RealmObjectChanges<T> {}

/// @nodoc
class RealmObjectNotificationsController<T extends RealmObjectBase> extends NotificationsController {
  T realmObject;
  late final StreamController<RealmObjectChanges<T>> streamController;
  List<String>? keyPaths;
  int? classKey;

  RealmObjectNotificationsController(this.realmObject, List<String>? keyPaths, int? classKey) {
    if (keyPaths != null) {
      this.keyPaths = keyPaths;
      this.classKey = classKey;

      // throw early if the key paths are invalid
      realmObject.realm.handle.verifyKeyPath(keyPaths, classKey);
    }
  }

  @override
  NotificationTokenHandle subscribe() {
    return realmObject.handle.subscribeForNotifications(this, keyPaths, classKey);
  }

  Stream<RealmObjectChanges<T>> createStream() {
    streamController = StreamController<RealmObjectChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! ObjectChangesHandle) {
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

/// @nodoc
class _ConcreteRealmObject with RealmEntity, RealmObjectBase, RealmObject {
  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this)!; // _ConcreteRealmObject should only ever be created for managed objects

  @override
  Stream<RealmObjectChanges<RealmObject>> get changes => RealmObjectBase.getChanges<RealmObject>(this);
}

/// @nodoc
class _ConcreteEmbeddedObject with RealmEntity, RealmObjectBase, EmbeddedObject {
  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this)!; // _ConcreteEmbeddedObject should only ever be created for managed objects

  @override
  Stream<RealmObjectChanges<EmbeddedObject>> get changes => RealmObjectBase.getChanges<EmbeddedObject>(this);
}

// This is necessary whenever we need to pass T? as the type.
Type _typeOf<T>() => T;

bool _isTypeGenericObject<T>() => T == Object || T == _typeOf<Object?>();

/// Exposes a set of dynamic methods on the RealmObject type. These allow you to
/// access properties by name rather than via the strongly typed API.
///
/// {@category Realm}
class DynamicRealmObject {
  final RealmObjectBase _obj;

  DynamicRealmObject._(this._obj);

  /// Gets a property by its name. If a generic type is specified, the property
  /// type will be validated against the type. Otherwise the result will be wrapped
  /// in [Object].
  T get<T extends Object?>(String name) {
    _validatePropertyType<T>(name, RealmCollectionType.none);
    return RealmObjectBase.get<T>(_obj, name) as T;
  }

  /// Sets a property by its name. The supplied [value] must be assignable
  /// to the property type, otherwise an exception will be thrown.
  void set<T extends Object?>(String name, T value) {
    _validatePropertyType<T>(name, RealmCollectionType.none, relaxedNullability: true);
    RealmObjectBase.set(_obj, name, value);
  }

  /// Gets a list by the property name. If a generic type is specified, the property
  /// type will be validated against the type. Otherwise, a `List<Object>` will be
  /// returned.
  RealmList<T> getList<T extends Object?>(String name) {
    _validatePropertyType<T>(name, RealmCollectionType.list);
    return RealmObjectBase.get<T>(_obj, name) as RealmList<T>;
  }

  /// Gets a set by the property name. If a generic type is specified, the property
  /// type will be validated against the type. Otherwise, a `RealmSet<Object?>` will be
  /// returned.
  RealmSet<T> getSet<T extends Object?>(String name) {
    _validatePropertyType<T>(name, RealmCollectionType.set);
    return RealmObjectBase.get<T>(_obj, name) as RealmSet<T>;
  }

  /// Gets a map by the property name. If a generic type is specified, the property
  /// type will be validated against the type. Otherwise, a `RealmMap<Object?>` will be
  /// returned.
  RealmMap<T> getMap<T extends Object?>(String name) {
    _validatePropertyType<T>(name, RealmCollectionType.map);
    return RealmObjectBase.get<T>(_obj, name) as RealmMap<T>;
  }

  RealmPropertyMetadata? _validatePropertyType<T extends Object?>(String name, RealmCollectionType expectedCollectionType, {bool relaxedNullability = false}) {
    final accessor = _obj.accessor;
    if (accessor is RealmCoreAccessor) {
      final prop = accessor.metadata._propertyKeys[name];
      if (prop == null) {
        throw RealmException("Property '$name' does not exist on class '${accessor.metadata.schema.name}'");
      }

      if (prop.collectionType != expectedCollectionType) {
        throw RealmException(
            "Property '$name' on class '${accessor.metadata.schema.name}' is '${prop.collectionType}' but the method used to access it expected '$expectedCollectionType'.");
      }

      // If the user passed in a type argument, we should validate its nullability; if they invoked
      // the method without a type arg, we don't
      if (T != _typeOf<RealmValue>() && T != _typeOf<Object?>() && prop.isNullable != null is T) {
        if (relaxedNullability && prop.isNullable) {
          // We're relaxing nullability requirements when setting a property - in that case, we accept
          // a non-null generic type argument, even if the property is nullable to allow users to invoke
          // .set without a generic argument (i.e. have the compiler infer the generic based on the value
          // argument).
        } else {
          throw RealmException(
              "Property '$name' on class '${accessor.metadata.schema.name}' is ${prop.isNullable ? 'nullable' : 'required'} but the generic argument supplied is $T.");
        }
      }

      final targetType = _getPropertyType<T>();
      if (targetType != null && targetType != prop.propertyType) {
        throw RealmException(
            "Property '$name' on class '${accessor.metadata.schema.name}' is not the correct type. Expected '$targetType', got '${prop.propertyType}'.");
      }

      return prop;
    }

    return null;
  }

  static final _propertyTypeMap = <Type, RealmPropertyType>{
    int: RealmPropertyType.int,
    _typeOf<int?>(): RealmPropertyType.int,
    double: RealmPropertyType.double,
    _typeOf<double?>(): RealmPropertyType.double,
    String: RealmPropertyType.string,
    _typeOf<String?>(): RealmPropertyType.string,
    bool: RealmPropertyType.bool,
    _typeOf<bool?>(): RealmPropertyType.bool,
    DateTime: RealmPropertyType.timestamp,
    _typeOf<DateTime?>(): RealmPropertyType.timestamp,
    ObjectId: RealmPropertyType.objectid,
    _typeOf<ObjectId?>(): RealmPropertyType.objectid,
    Uuid: RealmPropertyType.uuid,
    _typeOf<Uuid?>(): RealmPropertyType.uuid,
    RealmObject: RealmPropertyType.object,
    _typeOf<RealmObject?>(): RealmPropertyType.object,
    EmbeddedObject: RealmPropertyType.object,
    _typeOf<EmbeddedObject?>(): RealmPropertyType.object,
  };

  RealmPropertyType? _getPropertyType<T extends Object?>() => _propertyTypeMap[T];
}
