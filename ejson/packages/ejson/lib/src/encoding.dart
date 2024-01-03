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

import 'dart:convert';
import 'dart:typed_data';

import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';
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
    ObjectId o => _encodeObjectId(o),
    String s => _encodeString(s),
    Symbol s => _encodeSymbol(s),
    Undefined u => _encodeUndefined(u),
    Uuid u => _encodeUuid(u),
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

EJsonValue _encodeUuid(Uuid uuid) => _encodeBinary(uuid.bytes, "04");

EJsonValue _encodeBinary(ByteBuffer buffer, String subtype) => {
      '\$binary': {
        'base64': base64.encode(buffer.asUint8List()),
        'subType': subtype
      },
    };

EJsonValue _encodeObjectId(ObjectId objectId) => {'\$oid': objectId.hexString};

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

extension ObjectIdEJsonEncoderExtension on ObjectId {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeObjectId(this);
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

extension UuidEJsonEncoderExtension on Uuid {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeUuid(this);
}
