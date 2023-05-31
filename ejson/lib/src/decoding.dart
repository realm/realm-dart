import 'package:collection/collection.dart';
import 'package:type_plus/type_plus.dart';

import 'types.dart';

const commonDecoders = {
  dynamic: _decodeAny,
  Null: _decodeNull,
  Object: _decodeAny,
  List: _decodeArray,
  bool: _decodeBool,
  DateTime: _decodeDate,
  Defined: _decodeDefined,
  Key: _decodeKey,
  Map: _decodeDocument,
  double: _decodeDouble,
  num: _decodeNum,
  int: _decodeInt,
  String: _decodeString,
  Symbol: _decodeSymbol,
  Undefined: _decodeUndefined,
  UndefinedOr: _decodeUndefinedOr,
};

var customDecoders = <Type, Function>{};

// if registerSerializableTypes not called
final decoders = () {
  // register extra common types on first access
  undefinedOr<T>(f) => f<UndefinedOr<T>>();
  TypePlus.addFactory(undefinedOr);
  TypePlus.addFactory(<T>(f) => f<Defined<T>>(), superTypes: [undefinedOr]);
  TypePlus.addFactory(<T>(f) => f<Undefined<T>>(), superTypes: [undefinedOr]);
  TypePlus.add<Key>();

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
    return decoder(ejson); // minor optimization
  }
  return decoder.callWith(typeArguments: args, parameters: [ejson]);
}

// Important to return `T` as opposed to [Never] for type inference to work
T raiseInvalidEJson<T>(Object? value) => throw InvalidEJson<T>(value);

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
    {'\$undefined': _} => _decodeUndefined(ejson),
    List _ => _decodeArray(ejson),
    Map _ => _tryDecodeCustom(ejson) ??
        _decodeDocument(ejson), // other maps goes last!!
    _ => raiseInvalidEJson(ejson),
  };
}

dynamic _tryDecodeCustom(json) {
  for (final decoder in customDecoders.values) {
    try {
      return decoder(json);
    } catch (_) {
      // ignore
    }
  }
  return null;
}

List<T> _decodeArray<T>(EJsonValue ejson) {
  return switch (ejson) {
    Iterable i => i.map((ejson) => fromEJson<T>(ejson)).toList(),
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
    {'\$date': {'\$numberLong': int i}} =>
      DateTime.fromMillisecondsSinceEpoch(i),
    _ => raiseInvalidEJson(ejson),
  };
}

Defined<T> _decodeDefined<T>(EJsonValue ejson) {
  if (ejson case {'\$undefined': 1}) raiseInvalidEJson(ejson);
  return Defined<T>(fromEJson<T>(ejson));
}

Map<K, V> _decodeDocument<K, V>(EJsonValue ejson) {
  return switch (ejson) {
    Map m => m.map((key, value) => MapEntry(key as K, fromEJson<V>(value))),
    _ => raiseInvalidEJson(ejson),
  };
}

double _decodeDouble(EJsonValue ejson) {
  return switch (ejson) {
    double d => d, // relaxed mode
    {'\$numberDouble': double d} => d,
    {'\$numberDouble': String s} => switch (s) {
        'NaN' => double.nan,
        'Infinity' => double.infinity,
        '-Infinity' => double.negativeInfinity,
        _ => raiseInvalidEJson(ejson),
      },
    _ => raiseInvalidEJson(ejson),
  };
}

int _decodeInt(EJsonValue ejson) {
  return switch (ejson) {
    int i => i, // relaxed mode
    {'\$numberInt': int i} => i,
    {'\$numberLong': int i} => i,
    _ => raiseInvalidEJson(ejson)
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

class InvalidEJson<T> implements Exception {
  final Object? value;

  InvalidEJson(this.value);

  @override
  String toString() => 'Invalid EJson for $T: $value';
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
