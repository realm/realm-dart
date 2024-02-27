// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_value_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeTuckedIn(TuckedIn value) {
  return {'x': value.x.toEJson()};
}

TuckedIn decodeTuckedIn(EJsonValue ejson) {
  return switch (ejson) {
    {'x': EJsonValue x} => TuckedIn(x: fromEJson(x)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TuckedInEJsonEncoderExtension on TuckedIn {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTuckedIn(this);
}

EJsonValue encodeAnythingGoes(AnythingGoes value) {
  return {
    'oneAny': value.oneAny.toEJson(),
    'manyAny': value.manyAny.toEJson(),
    'setOfAny': value.setOfAny.toEJson(),
    'dictOfAny': value.dictOfAny.toEJson()
  };
}

AnythingGoes decodeAnythingGoes(EJsonValue ejson) {
  return switch (ejson) {
    {
      'oneAny': EJsonValue oneAny,
      'manyAny': EJsonValue manyAny,
      'setOfAny': EJsonValue setOfAny,
      'dictOfAny': EJsonValue dictOfAny
    } =>
      AnythingGoes(
          oneAny: fromEJson(oneAny),
          manyAny: fromEJson(manyAny),
          setOfAny: fromEJson(setOfAny),
          dictOfAny: fromEJson(dictOfAny)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension AnythingGoesEJsonEncoderExtension on AnythingGoes {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeAnythingGoes(this);
}

EJsonValue encodeStuff(Stuff value) {
  return {'i': value.i.toEJson()};
}

Stuff decodeStuff(EJsonValue ejson) {
  return switch (ejson) {
    {'i': EJsonValue i} => Stuff(i: fromEJson(i)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension StuffEJsonEncoderExtension on Stuff {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeStuff(this);
}
