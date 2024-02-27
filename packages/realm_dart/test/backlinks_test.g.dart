// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlinks_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeSource(Source value) {
  return {
    'name': value.name.toEJson(),
    'oneTarget': value.oneTarget.toEJson(),
    'dynamicTarget': value.dynamicTarget.toEJson(),
    'manyTargets': value.manyTargets.toEJson(),
    'dynamicManyTargets': value.dynamicManyTargets.toEJson()
  };
}

Source decodeSource(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'oneTarget': EJsonValue oneTarget,
      'dynamicTarget': EJsonValue dynamicTarget,
      'manyTargets': EJsonValue manyTargets,
      'dynamicManyTargets': EJsonValue dynamicManyTargets
    } =>
      Source(
          name: fromEJson(name),
          oneTarget: fromEJson(oneTarget),
          dynamicTarget: fromEJson(dynamicTarget),
          manyTargets: fromEJson(manyTargets),
          dynamicManyTargets: fromEJson(dynamicManyTargets)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension SourceEJsonEncoderExtension on Source {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeSource(this);
}

EJsonValue encodeTarget(Target value) {
  return {'name': value.name.toEJson(), 'source': value.source.toEJson()};
}

Target decodeTarget(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name, 'source': EJsonValue source} =>
      Target(name: fromEJson(name), source: fromEJson(source)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TargetEJsonEncoderExtension on Target {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTarget(this);
}
