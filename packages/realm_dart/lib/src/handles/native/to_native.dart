import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:realm_common/realm_common.dart' hide Decimal128;

import '../../realm_object.dart';
import 'decimal128.dart';
import 'from_native.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

extension ListEx on List<int> {
  Pointer<Char> toCharPtr(Allocator allocator) {
    return toUint8Ptr(allocator).cast();
  }

  Pointer<Uint8> toUint8Ptr(Allocator allocator) {
    final nativeSize = length + 1;
    final result = allocator<Uint8>(nativeSize);
    final Uint8List native = result.asTypedList(nativeSize);
    native.setAll(0, this); // copy
    native.last = 0; // zero terminate
    return result.cast();
  }
}

extension StringEx on String {
  Pointer<Char> toCharPtr(Allocator allocator) {
    final units = utf8.encode(this);
    return units.toCharPtr(allocator).cast();
  }

  Pointer<realm_string_t> toRealmString(Allocator allocator) {
    final realmString = allocator<realm_string_t>();
    final units = utf8.encode(this);
    realmString.ref.data = units.toCharPtr(allocator).cast();
    realmString.ref.size = units.length;
    return realmString;
  }
}

extension NullableObjectEx on Object? {
  Pointer<realm_value_t> toNative(Allocator allocator) {
    final self = this;
    final realmValue = allocator<realm_value_t>();
    if (self is RealmValue && self.type.isCollection) {
      throw RealmError("Don't use toNative if the value may contain collections. $bugInTheSdkMessage");
    }
    _intoRealmValue(self, realmValue.ref, allocator);
    return realmValue;
  }
}

extension RealmValueTypeEx on RealmValueType {
  String toQueryArgString() {
    return switch (this) {
      RealmValueType.nullValue => 'null',
      RealmValueType.boolean => 'bool',
      RealmValueType.string => 'string',
      RealmValueType.int => 'int',
      RealmValueType.double => 'double',
      RealmValueType.object => 'link',
      RealmValueType.objectId => 'objectid',
      RealmValueType.dateTime => 'date',
      RealmValueType.decimal => 'decimal',
      RealmValueType.uuid => 'uuid',
      RealmValueType.binary => 'binary',
      RealmValueType.list => 'array',
      RealmValueType.map => 'object',
    };
  }
}

const int _microsecondsPerSecond = 1000 * 1000;
const int _nanosecondsPerMicrosecond = 1000;

void intoRealmQueryArg(Object? value, Pointer<realm_query_arg_t> realmQueryArg, Allocator allocator) {
  if (value is Iterable) {
    realmQueryArg.ref.nb_args = value.length;
    realmQueryArg.ref.is_list = true;
    realmQueryArg.ref.arg = allocator<realm_value>(value.length);
    int i = 0;
    for (var item in value) {
      _intoRealmValue(item, realmQueryArg.ref.arg[i], allocator);
      i++;
    }
  } else {
    realmQueryArg.ref.arg = allocator<realm_value_t>();
    realmQueryArg.ref.nb_args = 1;
    realmQueryArg.ref.is_list = false;
    _intoRealmValueHack(value, realmQueryArg.ref.arg.ref, allocator);
  }
}

void _intoRealmValueHack(Object? value, realm_value realmValue, Allocator allocator) {
  if (value is GeoShape) {
    _intoRealmValue(value.toString(), realmValue, allocator);
  } else if (value is RealmValueType) {
    _intoRealmValue(value.toQueryArgString(), realmValue, allocator);
  } else {
    _intoRealmValue(value, realmValue, allocator);
  }
}

void _intoRealmValue(Object? value, realm_value realmValue, Allocator allocator) {
  if (value == null) {
    realmValue.typeEnum = realm_value_type.RLM_TYPE_NULL;
  } else if (value is RealmObjectBase) {
    // when converting a RealmObjectBase to realm_value.link we assume the object is managed
    final link = value.handle.asLink;
    realmValue.values.link.target = link.targetKey;
    realmValue.values.link.target_table = link.classKey;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_LINK;
  } else if (value is int) {
    realmValue.values.integer = value;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_INT;
  } else if (value is bool) {
    realmValue.values.boolean = value;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_BOOL;
  } else if (value is String) {
    String string = value;
    final units = utf8.encode(string);
    final result = allocator<Uint8>(units.length);
    final Uint8List nativeString = result.asTypedList(units.length);
    nativeString.setAll(0, units);
    realmValue.values.string.data = result.cast();
    realmValue.values.string.size = units.length;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_STRING;
  } else if (value is double) {
    realmValue.values.dnum = value;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_DOUBLE;
  } else if (value is ObjectId) {
    final bytes = value.bytes;
    for (var i = 0; i < 12; i++) {
      realmValue.values.object_id.bytes[i] = bytes[i];
    }
    realmValue.typeEnum = realm_value_type.RLM_TYPE_OBJECT_ID;
  } else if (value is Uuid) {
    final bytes = value.bytes;
    for (var i = 0; i < 16; i++) {
      realmValue.values.uuid.bytes[i] = bytes[i];
    }
    realmValue.typeEnum = realm_value_type.RLM_TYPE_UUID;
  } else if (value is DateTime) {
    final microseconds = value.toUtc().microsecondsSinceEpoch;
    final seconds = microseconds ~/ _microsecondsPerSecond;
    int nanoseconds = _nanosecondsPerMicrosecond * (microseconds % _microsecondsPerSecond);
    if (microseconds < 0 && nanoseconds != 0) {
      nanoseconds = nanoseconds - _nanosecondsPerMicrosecond * _microsecondsPerSecond;
    }
    realmValue.values.timestamp.seconds = seconds;
    realmValue.values.timestamp.nanoseconds = nanoseconds;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_TIMESTAMP;
  } else if (value is Decimal128) {
    realmValue.values.decimal128 = value.value;
    realmValue.typeEnum = realm_value_type.RLM_TYPE_DECIMAL128;
  } else if (value is Uint8List) {
    realmValue.typeEnum = realm_value_type.RLM_TYPE_BINARY;
    realmValue.values.binary.size = value.length;
    realmValue.values.binary.data = allocator<Uint8>(value.length);
    realmValue.values.binary.data.asTypedList(value.length).setAll(0, value);
  } else if (value is RealmValue) {
    if (value is List<RealmValue>) {
      realmValue.typeEnum = realm_value_type.RLM_TYPE_LIST;
    } else if (value is Map<String, RealmValue>) {
      realmValue.typeEnum = realm_value_type.RLM_TYPE_DICTIONARY;
    } else {
      return _intoRealmValue(value.value, realmValue, allocator);
    }
  } else {
    throw RealmException("Property type ${value.runtimeType} not supported");
  }
}
