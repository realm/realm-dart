// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class ObjectIdPrimaryKey extends _ObjectIdPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<ObjectIdPrimaryKey>
    implements RealmObject<ObjectIdPrimaryKey> {
  ObjectIdPrimaryKey(
    ObjectId id,
  ) {
    _idProperty.setValue(this, id);
  }

  ObjectIdPrimaryKey._();

  static const _idProperty = ValueProperty<ObjectId>(
    'id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<ObjectIdPrimaryKey>(
    ObjectIdPrimaryKey._,
    'ObjectIdPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableObjectIdPrimaryKey extends _NullableObjectIdPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<NullableObjectIdPrimaryKey>
    implements RealmObject<NullableObjectIdPrimaryKey> {
  NullableObjectIdPrimaryKey(
    ObjectId? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableObjectIdPrimaryKey._();

  static const _idProperty = ValueProperty<ObjectId?>(
    'id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId? get id => _idProperty.getValue(this);
  @override
  set id(ObjectId? value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<NullableObjectIdPrimaryKey>(
    NullableObjectIdPrimaryKey._,
    'NullableObjectIdPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class IntPrimaryKey extends _IntPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<IntPrimaryKey>
    implements RealmObject<IntPrimaryKey> {
  IntPrimaryKey(
    int id,
  ) {
    _idProperty.setValue(this, id);
  }

  IntPrimaryKey._();

  static const _idProperty = ValueProperty<int>(
    'id',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int get id => _idProperty.getValue(this);
  @override
  set id(int value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<IntPrimaryKey>(
    IntPrimaryKey._,
    'IntPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableIntPrimaryKey extends _NullableIntPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<NullableIntPrimaryKey>
    implements RealmObject<NullableIntPrimaryKey> {
  NullableIntPrimaryKey(
    int? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableIntPrimaryKey._();

  static const _idProperty = ValueProperty<int?>(
    'id',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int? get id => _idProperty.getValue(this);
  @override
  set id(int? value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<NullableIntPrimaryKey>(
    NullableIntPrimaryKey._,
    'NullableIntPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class StringPrimaryKey extends _StringPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<StringPrimaryKey>
    implements RealmObject<StringPrimaryKey> {
  StringPrimaryKey(
    String id,
  ) {
    _idProperty.setValue(this, id);
  }

  StringPrimaryKey._();

  static const _idProperty = ValueProperty<String>(
    'id',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get id => _idProperty.getValue(this);
  @override
  set id(String value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<StringPrimaryKey>(
    StringPrimaryKey._,
    'StringPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableStringPrimaryKey extends _NullableStringPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<NullableStringPrimaryKey>
    implements RealmObject<NullableStringPrimaryKey> {
  NullableStringPrimaryKey(
    String? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableStringPrimaryKey._();

  static const _idProperty = ValueProperty<String?>(
    'id',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String? get id => _idProperty.getValue(this);
  @override
  set id(String? value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<NullableStringPrimaryKey>(
    NullableStringPrimaryKey._,
    'NullableStringPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class UuidPrimaryKey extends _UuidPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<UuidPrimaryKey>
    implements RealmObject<UuidPrimaryKey> {
  UuidPrimaryKey(
    Uuid id,
  ) {
    _idProperty.setValue(this, id);
  }

  UuidPrimaryKey._();

  static const _idProperty = ValueProperty<Uuid>(
    'id',
    RealmPropertyType.uuid,
    primaryKey: true,
  );
  @override
  Uuid get id => _idProperty.getValue(this);
  @override
  set id(Uuid value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<UuidPrimaryKey>(
    UuidPrimaryKey._,
    'UuidPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableUuidPrimaryKey extends _NullableUuidPrimaryKey
    with RealmEntityMixin, RealmObjectMixin<NullableUuidPrimaryKey>
    implements RealmObject<NullableUuidPrimaryKey> {
  NullableUuidPrimaryKey(
    Uuid? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableUuidPrimaryKey._();

  static const _idProperty = ValueProperty<Uuid?>(
    'id',
    RealmPropertyType.uuid,
    primaryKey: true,
  );
  @override
  Uuid? get id => _idProperty.getValue(this);
  @override
  set id(Uuid? value) => _idProperty.setValue(this, value);

  static const schema = SchemaObject<NullableUuidPrimaryKey>(
    NullableUuidPrimaryKey._,
    'NullableUuidPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RemappedFromAnotherFile extends _RemappedFromAnotherFile
    with RealmEntityMixin, RealmObjectMixin<RemappedFromAnotherFile>
    implements RealmObject<RemappedFromAnotherFile> {
  RemappedFromAnotherFile({
    RemappedClass? linkToAnotherClass,
  }) {
    _linkToAnotherClassProperty.setValue(this, linkToAnotherClass);
  }

  RemappedFromAnotherFile._();

  static const _linkToAnotherClassProperty =
      ObjectProperty<RemappedClass>('property with spaces', 'myRemappedClass');
  @override
  RemappedClass? get linkToAnotherClass =>
      _linkToAnotherClassProperty.getValue(this);
  @override
  set linkToAnotherClass(covariant RemappedClass? value) =>
      _linkToAnotherClassProperty.setValue(this, value);

  static const schema = SchemaObject<RemappedFromAnotherFile>(
    RemappedFromAnotherFile._,
    'class with spaces',
    {
      'property with spaces': _linkToAnotherClassProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class BoolValue extends _BoolValue
    with RealmEntityMixin, RealmObjectMixin<BoolValue>
    implements RealmObject<BoolValue> {
  BoolValue(
    int key,
    bool value,
  ) {
    _keyProperty.setValue(this, key);
    _valueProperty.setValue(this, value);
  }

  BoolValue._();

  static const _keyProperty = ValueProperty<int>(
    'key',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int get key => _keyProperty.getValue(this);
  @override
  set key(int value) => _keyProperty.setValue(this, value);

  static const _valueProperty = ValueProperty<bool>(
    'value',
    RealmPropertyType.bool,
  );
  @override
  bool get value => _valueProperty.getValue(this);
  @override
  set value(bool value) => _valueProperty.setValue(this, value);

  static const schema = SchemaObject<BoolValue>(
    BoolValue._,
    'BoolValue',
    {
      'key': _keyProperty,
      'value': _valueProperty,
    },
    _keyProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}
