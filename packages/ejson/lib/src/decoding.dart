////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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
library;

import 'dart:typed_data';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';
import 'package:type_plus/type_plus.dart';

import 'types.dart';

const commonDecoders = {
  dynamic: _decodeAny,
  Null: _decodeNull,
  Object: _decodeAny,
  Iterable: _decodeArray,
  List: _decodeArray,
  bool: _decodeBool,
  DateTime: _decodeDate,
  Defined: _decodeDefined,
  Key: _decodeKey,
  Map: _decodeDocument,
  double: _decodeDouble,
  num: _decodeNum,
  int: _decodeInt,
  ObjectId: _decodeObjectId,
  String: _decodeString,
  Symbol: _decodeSymbol,
  Uuid: _decodeUuid,
  Undefined: _decodeUndefined,
  UndefinedOr: _decodeUndefinedOr,
};

final customDecoders = <Type, Function>{};

final decoders = () {
  // register extra common types on first access
  undefinedOr<T>(dynamic f) => f<UndefinedOr<T>>();
  TypePlus.addFactory(undefinedOr);
  TypePlus.addFactory(<T>(dynamic f) => f<Defined<T>>(), superTypes: [undefinedOr]);
  TypePlus.addFactory(<T>(dynamic f) => f<Undefined<T>>(), superTypes: [undefinedOr]);
  TypePlus.add<Key>();
  TypePlus.add<ObjectId>();
  TypePlus.add<Uuid>();

  return CombinedMapView([customDecoders, commonDecoders]);
}();

T fromEJson<T>(EJsonValue ejson) {
  final type = T;
  final nullable = type.isNullable;
  final decoder = nullable ? _decodeNullable : decoders[type.base];
  if (decoder == null) {
    throw MissingDecoder(ejson, type);
  }
  final args = nullable ? [type.nonNull] : type.args;
  if (args.isEmpty) {
    return decoder(ejson) as T; // minor optimization
  }
  return decoder.callWith(typeArguments: args, parameters: [ejson]) as T;
}

// Important to return `T` as opposed to [Never] for type inference to work
T raiseInvalidEJson<T>(Object? value) => throw InvalidEJson(value, T);

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
    {'\$regex': _} => _decodeString(ejson),
    {'\$symbol': _} => _decodeSymbol(ejson),
    {'\$undefined': _} => _decodeUndefined<dynamic>(ejson),
    {'\$oid': _} => _decodeObjectId(ejson),
    {'\$binary': {'base64': _, 'subType': '04'}} => _decodeUuid(ejson),
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
    //{'\$numberDouble': double d} => d,
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

Key _decodeKey(EJsonValue ejson) {
  return switch (ejson) {
    {'\$minKey': 1} => Key.min,
    {'\$maxKey': 1} => Key.max,
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
  try {
    return Uuid.fromBytes(_decodeBinary(ejson, "04"));
  } on InvalidEJson {
    return raiseInvalidEJson(ejson); // get the type right
  }
}

ByteBuffer _decodeBinary(EJsonValue ejson, String subType) {
  return switch (ejson) {
    {'\$binary': {'base64': String s, 'subType': String t}} when t == subType => base64.decode(s).buffer,
    _ => raiseInvalidEJson(ejson),
  };
}

class InvalidEJson implements Exception {
  final Object? value;
  final Type type;

  InvalidEJson(this.value, this.type);

  @override
  String toString() => 'Invalid EJson for $type: $value';
}

class MissingDecoder implements Exception {
  final EJsonValue ejson;
  final Type type;

  MissingDecoder(this.ejson, this.type);

  @override
  String toString() => 'Missing decoder for $type';
}

extension EJsonValueDecoderExtension on EJsonValue {
  T to<T>() => fromEJson<T>(this);
}
