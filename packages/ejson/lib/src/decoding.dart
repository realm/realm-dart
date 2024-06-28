// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';
import 'package:type_plus/type_plus.dart';

import 'types.dart';

/// Predefined decoders for common types
const _commonDecoders = {
  dynamic: _decodeAny,
  Null: _decodeNull,
  Object: _decodeAny,
  Iterable: _decodeArray,
  List: _decodeArray,
  bool: _decodeBool,
  DateTime: _decodeDate,
  Defined: _decodeDefined,
  BsonKey: _decodeKey,
  Map: _decodeDocument,
  double: _decodeDouble,
  num: _decodeNum,
  int: _decodeInt,
  ObjectId: _decodeObjectId,
  String: _decodeString,
  Symbol: _decodeSymbol,
  Uint8List: _decodeBinary,
  Uuid: _decodeUuid,
  DBRef: _decodeDBRef,
  Undefined: _decodeUndefined,
  UndefinedOr: _decodeUndefinedOr,
};

/// Custom decoders for specific types. Use `register` to add a custom decoder.
final customDecoders = <Type, Function>{};

final _decoders = () {
  // register extra common types on first access
  undefinedOr<T>(dynamic f) => f<UndefinedOr<T>>();
  TypePlus.addFactory(undefinedOr);
  TypePlus.addFactory(<T>(dynamic f) => f<Defined<T>>(), superTypes: [undefinedOr]);
  TypePlus.addFactory(<T>(dynamic f) => f<Undefined<T>>(), superTypes: [undefinedOr]);
  TypePlus.addFactory(<T>(dynamic f) => f<DBRef<T>>());
  TypePlus.add<BsonKey>();
  TypePlus.add<ObjectId>();
  TypePlus.add<Uint8List>();
  TypePlus.add<Uuid>();

  return CombinedMapView([customDecoders, _commonDecoders]);
}();

/// Converts [ejson] to type [T].
///
/// [defaultValue] is returned if set, and [ejson] is `null`.
///
/// Throws [InvalidEJson] if [ejson] is not valid for [T].
/// Throws [MissingDecoder] if no decoder is registered for [T].
T fromEJson<T>(EJsonValue ejson, {T? defaultValue}) {
  final type = T;
  final nullable = type.isNullable;
  if (!nullable && ejson == null && defaultValue != null) return defaultValue;
  final decoder = nullable ? _decodeNullable : _decoders[type.base];
  if (decoder == null) {
    throw MissingDecoder._(ejson, type);
  }
  final args = nullable ? [type.nonNull] : type.args;
  if (args.isEmpty) {
    return decoder(ejson) as T; // minor optimization
  }
  return decoder.callWith(typeArguments: args, parameters: [ejson]) as T;
}

/// Parses [source] to [EJsonValue] and convert to type [T].
///
/// Throws [InvalidEJson] if [source] is not valid for [T].
/// Throws [MissingDecoder] if no decoder is registered for [T].
T fromEJsonString<T>(String source) => fromEJson(jsonDecode(source));

// Important to return `T` as opposed to [Never] for type inference to work
/// @nodoc
T raiseInvalidEJson<T>(Object? value) => throw InvalidEJson._(value, T);

dynamic _decodeAny(EJsonValue ejson) {
  return switch (ejson) {
    null => null,
    bool b => b,
    double d => d, // relaxed mode
    int i => i, // relaxed mode
    String s => s,
    {'\$date': _} => _decodeDate(ejson),
    {'\$maxKey': _} => _decodeKey(ejson),
    {'\$minKey': _} => _decodeKey(ejson),
    {'\$numberDouble': _} => _decodeDouble(ejson),
    {'\$numberInt': _} => _decodeInt(ejson),
    {'\$numberLong': _} => _decodeInt(ejson),
    {'\$ref': _, '\$id': _} => _decodeDBRef<dynamic>(ejson),
    {'\$regex': _} => _decodeString(ejson),
    {'\$symbol': _} => _decodeSymbol(ejson),
    {'\$undefined': _} => _decodeUndefined<dynamic>(ejson),
    {'\$oid': _} => _decodeObjectId(ejson),
    {'\$binary': {'base64': _, 'subType': '04'}} => _decodeUuid(ejson),
    {'\$binary': _} => _decodeBinary(ejson),
    List<dynamic> _ => _decodeArray<dynamic>(ejson),
    Map<dynamic, dynamic> _ => _tryDecodeCustom(ejson) ?? _decodeDocument<String, dynamic>(ejson), // other maps goes last!!
    _ => raiseInvalidEJson<dynamic>(ejson),
  };
}

dynamic _tryDecodeCustom(EJsonValue ejson) {
  for (final decoder in customDecoders.values) {
    try {
      return decoder(ejson);
    } catch (_) {
      // ignore
    }
  }
  return null;
}

List<T> _decodeArray<T>(EJsonValue ejson) {
  return switch (ejson) {
    Iterable<dynamic> i => i.map((ejson) => fromEJson<T>(ejson)).toList(),
    _ => raiseInvalidEJson(ejson),
  };
}

bool _decodeBool(EJsonValue ejson) {
  return switch (ejson) {
    bool b => b,
    _ => raiseInvalidEJson(ejson),
  };
}

DateTime _decodeDate(EJsonValue ejson) {
  return switch (ejson) {
    {'\$date': String s} => DateTime.parse(s), // relaxed mode
    {'\$date': {'\$numberLong': String i}} => DateTime.fromMillisecondsSinceEpoch(int.tryParse(i) ?? raiseInvalidEJson(ejson)),
    _ => raiseInvalidEJson(ejson),
  };
}

DBRef<KeyT> _decodeDBRef<KeyT>(EJsonValue ejson) {
  return switch (ejson) {
    {'\$ref': String collection, '\$id': EJsonValue id} => DBRef<KeyT>(collection, fromEJson<KeyT>(id)),
    _ => raiseInvalidEJson(ejson),
  };
}

Defined<T> _decodeDefined<T>(EJsonValue ejson) {
  if (ejson case {'\$undefined': 1}) return raiseInvalidEJson(ejson);
  return Defined<T>(fromEJson<T>(ejson));
}

Map<K, V> _decodeDocument<K, V>(EJsonValue ejson) {
  return switch (ejson) {
    Map<dynamic, dynamic> m => m.map((key, value) => MapEntry(key as K, fromEJson<V>(value))),
    _ => raiseInvalidEJson(ejson),
  };
}

double _decodeDouble(EJsonValue ejson) {
  return switch (ejson) {
    double d => d, // relaxed mode
    {'\$numberDouble': String s} => switch (s) {
        'NaN' => double.nan,
        'Infinity' => double.infinity,
        '-Infinity' => double.negativeInfinity,
        _ => double.tryParse(s) ?? raiseInvalidEJson(ejson),
      },
    _ => raiseInvalidEJson(ejson),
  };
}

int _decodeInt(EJsonValue ejson) {
  return switch (ejson) {
    int i => i, // relaxed mode
    {'\$numberInt': String i} => int.tryParse(i) ?? raiseInvalidEJson(ejson),
    {'\$numberLong': String i} => int.tryParse(i) ?? raiseInvalidEJson(ejson),
    _ => raiseInvalidEJson(ejson),
  };
}

BsonKey _decodeKey(EJsonValue ejson) {
  return switch (ejson) {
    {'\$minKey': 1} => BsonKey.min,
    {'\$maxKey': 1} => BsonKey.max,
    _ => raiseInvalidEJson(ejson),
  };
}

// ignore: prefer_void_to_null
Null _decodeNull(EJsonValue ejson) {
  return switch (ejson) {
    null => null,
    _ => raiseInvalidEJson(ejson),
  };
}

T? _decodeNullable<T>(EJsonValue ejson) {
  if (ejson == null) {
    return null;
  }
  return fromEJson<T>(ejson);
}

num _decodeNum(EJsonValue ejson) {
  return switch (ejson) {
    num n => n, // relaxed mode
    {'\$numberLong': _} => _decodeInt(ejson),
    {'\$numberInt': _} => _decodeInt(ejson),
    {'\$numberDouble': _} => _decodeDouble(ejson),
    _ => raiseInvalidEJson(ejson),
  };
}

ObjectId _decodeObjectId(EJsonValue ejson) {
  return switch (ejson) {
    {'\$oid': String s} => ObjectId.fromHexString(s),
    _ => raiseInvalidEJson(ejson),
  };
}

String _decodeString(EJsonValue ejson) {
  return switch (ejson) {
    String s => s,
    _ => raiseInvalidEJson(ejson),
  };
}

Symbol _decodeSymbol(EJsonValue ejson) {
  return switch (ejson) {
    {'\$symbol': String s} => Symbol(s),
    _ => raiseInvalidEJson(ejson),
  };
}

Undefined<T> _decodeUndefined<T>(EJsonValue ejson) {
  return switch (ejson) {
    {'\$undefined': 1} => Undefined<T>(),
    _ => raiseInvalidEJson(ejson),
  };
}

UndefinedOr<T> _decodeUndefinedOr<T>(EJsonValue ejson) {
  return switch (ejson) {
    {'\$undefined': 1} => Undefined<T>(),
    _ => _decodeDefined(ejson),
  };
}

Uuid _decodeUuid(EJsonValue ejson) {
  return switch (ejson) {
    {'\$binary': {'base64': String s, 'subType': '04'}} => Uuid.fromBytes(base64.decode(s)),
    _ => raiseInvalidEJson(ejson),
  };
}

Uint8List _decodeBinary(EJsonValue ejson) {
  return switch (ejson) {
    {'\$binary': {'base64': String s, 'subType': _}} => base64.decode(s),
    _ => raiseInvalidEJson(ejson),
  };
}

/// Thrown when a value cannot be decoded from [ejson].
class InvalidEJson implements Exception {
  final EJsonValue ejson;
  final Type type;

  InvalidEJson._(this.ejson, this.type);

  @override
  String toString() => 'Invalid EJson for $type: $ejson';
}

/// Thrown when no decoder is registered for a [type].
class MissingDecoder implements Exception {
  final EJsonValue ejson;
  final Type type;

  MissingDecoder._(this.ejson, this.type);

  @override
  String toString() => 'Missing decoder for $type';
}
