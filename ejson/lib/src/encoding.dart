import 'package:type_plus/type_plus.dart';

import 'types.dart';

// No custom encoders, if registerSerializableTypes not called
var customEncoders = <Type, Function>{};

var relaxed = false;

Type typeOfExpression<T>(T value) => T;

@pragma('vm:prefer-inline')
EJsonValue toEJson(Object? value) => _encodeAny(value);

EJsonValue _encodeAny(Object? value) {
  return switch (value) {
    null => null,
    bool b => _encodeBool(b),
    DateTime d => _encodeDate(d),
    Defined d => _encodeDefined(d),
    double d => _encodeDouble(d),
    int i => _encodeInt(i),
    Key k => _encodeKey(k),
    List l => _encodeArray(l),
    Map m => _encodeDocument(m),
    String s => _encodeString(s),
    Symbol s => _encodeSymbol(s),
    Undefined u => _encodeUndefined(u),
    _ => _encodeCustom(value),
  };
}

EJsonValue _encodeArray(Iterable items) =>
    items.map((e) => toEJson(e)).toList();

EJsonValue _encodeBool(bool value) => value;

EJsonValue _encodeCustom(Object value) {
  final encoder = customEncoders[value.runtimeType.base];
  if (encoder == null) {
    throw MissingEncoder(value);
  }
  return encoder(value);
}

EJsonValue _encodeDate(DateTime value) {
  return switch (relaxed) {
    true => {'\$date': value.toIso8601String()},
    false => {
        '\$date': {'\$numberLong': value.millisecondsSinceEpoch}
      },
  };
}

EJsonValue _encodeDefined(Defined defined) => toEJson(defined.value);

EJsonValue _encodeDocument(Map map) =>
    map.map((k, v) => MapEntry(k, toEJson(v)));

EJsonValue _encodeDouble(double value) {
  if (value.isNaN) {
    return {'\$numberDouble': 'NaN'};
  }
  return switch (value) {
    double.infinity => {'\$numberDouble': 'Infinity'},
    double.negativeInfinity => {'\$numberDouble': '-Infinity'},
    _ => switch (relaxed) {
        true => value,
        false => {'\$numberDouble': value},
      }
  };
}

EJsonValue _encodeInt(int value, {bool long = true}) {
  return switch (relaxed) {
    true => value,
    false => {'\$number${long ? 'Long' : 'Int'}': value},
  };
}

EJsonValue _encodeKey(Key key) => {'\$${key.name}Key': 1};

@pragma('vm:prefer-inline')
EJsonValue _encodeString(String value) => value;

EJsonValue _encodeSymbol(Symbol value) => {'\$symbol': value.name};

EJsonValue _encodeUndefined(Undefined undefined) => {'\$undefined': 1};

class MissingEncoder implements Exception {
  final Object value;

  MissingEncoder(this.value);

  @override
  String toString() => 'Missing encoder for type ${value.runtimeType} ($value)';
}

extension BoolEJsonEncoderExtension on bool {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeBool(this);
}

extension DateTimeEJsonEncoderExtension on DateTime {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDate(this);
}

extension DefinedEJsonEncoderExtension on Defined {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDefined(this);
}

extension DoubleEJsonEncoderExtension on double {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDouble(this);
}

extension IntEJsonEncoderExtension on int {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson({bool long = true}) => _encodeInt(this, long: long);
}

extension KeyEJsonEncoderExtension on Key {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeKey(this);
}

extension ListEJsonEncoderExtension on List<Object?> {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeArray(this);
}

extension MapEJsonEncoderExtension on Map<dynamic, dynamic> {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDocument(this);
}

extension NullableObjectEJsonEncoderExtension on Object? {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeAny(this);
}

extension StringEJsonEncoderExtension on String {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeString(this);
}

extension SymbolEJsonEncoderExtension on Symbol {
  String get name {
    final full = toString();
    return full.substring(8, full.length - 2);
  }

  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeSymbol(this);
}

extension UndefinedEJsonEncoderExtension on Undefined {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeUndefined(this);
}
