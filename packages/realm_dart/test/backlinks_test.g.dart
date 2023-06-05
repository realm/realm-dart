// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlinks_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeSource(Source value) {
  return {
    'name': value.name.toEJson(),
    'oneTarget': value.oneTarget.toEJson(),
    'manyTargets': value.manyTargets.toEJson()
  };
}

Source decodeSource(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'oneTarget': EJsonValue oneTarget,
      'manyTargets': EJsonValue manyTargets
    } =>
      Source(
          name: name.to<String>(),
          oneTarget: oneTarget.to<Target?>(),
          manyTargets: manyTargets.to<Iterable<Target>>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension SourceEJsonEncoderExtension on Source {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeSource(this);
}

EJsonValue encodeTarget(Target value) {
  return {'name': value.name.toEJson()};
}

Target decodeTarget(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name} => Target(name: name.to<String>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TargetEJsonEncoderExtension on Target {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTarget(this);
}
