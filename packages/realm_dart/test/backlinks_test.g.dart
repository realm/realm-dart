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
          name: name.to<String>(),
          oneTarget: oneTarget.to<Target?>(),
          dynamicTarget: dynamicTarget.to<Target?>(),
          manyTargets: manyTargets.to<Iterable<Target>>(),
          dynamicManyTargets: dynamicManyTargets.to<Iterable<Target>>()),
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
      Target(name: name.to<String>(), source: source.to<Source?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TargetEJsonEncoderExtension on Target {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTarget(this);
}
