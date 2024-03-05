// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';
import 'package:type_plus/type_plus.dart';

import 'types.dart';

/// Custom encoders for specific types. Use `register` to add a custom encoder.
var customEncoders = <Type, Function>{};

/// Whether to use relaxed encoding or not, default is false
var relaxed = false;

@pragma('vm:prefer-inline')

/// Converts [value] to EJson
///
/// Throws [MissingEncoder] if no encoder is registered for [value]'s type.
EJsonValue toEJson(Object? value) => _encodeAny(value);

/// Converts [value] to EJson string
///
/// Throws [MissingEncoder] if no encoder is registered for [value]'s type.
String toEJsonString(Object? value) => jsonEncode(toEJson(value));

EJsonValue _encodeAny(Object? value) {
  return switch (value) {
    null => null,
    bool b => _encodeBool(b),
    DateTime d => _encodeDate(d),
    Defined<dynamic> d => _encodeDefined(d),
    double d => _encodeDouble(d),
    int i => _encodeInt(i),
    Key k => _encodeKey(k),
    Uint8List b => _encodeBinary(b, subtype: '00'),
    Iterable<dynamic> l => _encodeArray(l),
    Map<dynamic, dynamic> m => _encodeDocument(m),
    ObjectId o => _encodeObjectId(o),
    String s => _encodeString(s),
    Symbol s => _encodeSymbol(s),
    Undefined<dynamic> u => _encodeUndefined(u),
    Uuid u => _encodeUuid(u),
    _ => _encodeCustom(value),
  };
}

EJsonValue _encodeArray(Iterable<dynamic> items) => items.map((e) => toEJson(e)).toList();

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
        '\$date': {'\$numberLong': value.millisecondsSinceEpoch.toString()},
      },
  };
}

EJsonValue _encodeDefined(Defined<dynamic> defined) => toEJson(defined.value);

EJsonValue _encodeDocument(Map<dynamic, dynamic> map) => map.map((k, v) => MapEntry(k, toEJson(v)));

EJsonValue _encodeDouble(double value) {
  if (value.isNaN) {
    return {'\$numberDouble': 'NaN'};
  }
  return switch (value) {
    double.infinity => {'\$numberDouble': 'Infinity'},
    double.negativeInfinity => {'\$numberDouble': '-Infinity'},
    _ => switch (relaxed) {
        true => value,
        false => {'\$numberDouble': '$value'},
      }
  };
}

enum IntFormat { int32, int64 }

EJsonValue _encodeInt(int value, {IntFormat? forcedFormat}) {
  switch (relaxed) {
    case true:
      return value;
    case false:
      bool fitsInInt32 = value >= -0x80000000 && value < 0x80000000;
      final format = forcedFormat ?? (fitsInInt32 ? IntFormat.int32 : IntFormat.int64);
      if (!fitsInInt32 && format == IntFormat.int32) {
        throw ArgumentError.value(value, 'value', 'Value does not fit in int32');
      }
      return switch (format) {
        IntFormat.int32 => {'\$numberInt': '$value'},
        IntFormat.int64 => {'\$numberLong': '$value'},
      };
  }
}

EJsonValue _encodeKey(Key key) => {'\$${key.name}Key': 1};

@pragma('vm:prefer-inline')
EJsonValue _encodeString(String value) => value;

EJsonValue _encodeSymbol(Symbol value) => {'\$symbol': value.name};

EJsonValue _encodeUndefined(Undefined<dynamic> undefined) => {'\$undefined': 1};

EJsonValue _encodeUuid(Uuid uuid) => _encodeBinary(uuid.bytes.asUint8List(), subtype: '04');

EJsonValue _encodeBinary(Uint8List buffer, {required String subtype}) => {
      '\$binary': {
        'base64': base64.encode(buffer),
        'subType': subtype,
      },
    };

EJsonValue _encodeObjectId(ObjectId objectId) => {'\$oid': objectId.hexString};

/// Exception thrown when no encoder is registered for the type of a [value].
class MissingEncoder implements Exception {
  final Object value;

  MissingEncoder(this.value);

  @override
  String toString() => 'Missing encoder for type ${value.runtimeType} ($value)';
}

extension BoolEJsonEncoderExtension on bool {
  /// Converts this [bool] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeBool(this);
}

extension DateTimeEJsonEncoderExtension on DateTime {
  /// Converts this [DateTime] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDate(this);
}

extension DefinedEJsonEncoderExtension on Defined<dynamic> {
  /// Converts this [Defined] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDefined(this);
}

extension DoubleEJsonEncoderExtension on double {
  /// Converts this [double] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDouble(this);
}

extension IntEJsonEncoderExtension on int {
  /// Converts this [int] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson({IntFormat? forcedFormat}) => _encodeInt(this, forcedFormat: forcedFormat);
}

extension KeyEJsonEncoderExtension on Key {
  /// Converts this [Key] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeKey(this);
}

extension ListEJsonEncoderExtension on List<Object?> {
  /// Converts this [List] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeArray(this);
}

extension MapEJsonEncoderExtension on Map<dynamic, dynamic> {
  /// Converts this [Map] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeDocument(this);
}

extension NullEJsonEncoderExtension on Null {
  /// Converts this [Null] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => null;
}

extension NullableObjectEJsonEncoderExtension on Object? {
  /// Converts this [Object] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeAny(this);
}

extension ObjectIdEJsonEncoderExtension on ObjectId {
  /// Converts this [ObjectId] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeObjectId(this);
}

extension StringEJsonEncoderExtension on String {
  /// Converts this [String] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeString(this);
}

extension SymbolEJsonEncoderExtension on Symbol {
  /// Extract the name of this [Symbol]
  String get name {
    final full = toString();
    // remove leading 'Symbol("' and trailing '")'
    return full.substring(8, full.length - 2);
  }

  /// Converts this [Symbol] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeSymbol(this);
}

extension Uint8ListEJsonEncoderExtension on Uint8List {
  /// Converts this [Uint8List] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeBinary(this, subtype: '00');
}

extension UndefinedEJsonEncoderExtension on Undefined<dynamic> {
  /// Converts this [Undefined] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeUndefined(this);
}

extension UuidEJsonEncoderExtension on Uuid {
  /// Converts this [Uuid] to EJson
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeUuid(this);
}
