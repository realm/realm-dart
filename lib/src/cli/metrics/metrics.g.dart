// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metrics _$MetricsFromJson(Map<String, dynamic> json) => Metrics(
      event: json['event'] as String,
      properties:
          Properties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MetricsToJson(Metrics instance) => <String, dynamic>{
      'event': instance.event,
      'properties': instance.properties,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
      distinctId: _digestFromJson(json['distinct_id'] as String),
      token: json['token'] as String,
      binding: json['Binding'] as String,
      framework: json['Framework'] as String,
      frameworkVersion: json['Framework Version'] as String,
      hostOsType: json['Host OS Type'] as String,
      hostOsVersion: json['Host OS Version'] as String,
      language: json['Language'] as String,
      realmVersion: json['Realm Version'] as String,
      anonymizedBundleId: const DigestConverter()
          .fromJson(json['Anonymized Bundle ID'] as String?),
      anonymizedMacAddress: const DigestConverter()
          .fromJson(json['Anonymized MAC Address'] as String?),
      syncEnabled: json['Sync Enabled'] as String?,
      targetOsType:
          _$enumDecodeNullable(_$TargetOsTypeEnumMap, json['Target OS Type']),
      targetOsVersion: json['Target OS Version'] as String?,
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) {
  final val = <String, dynamic>{
    'token': instance.token,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('distinct_id', _digestToJson(instance.distinctId));
  writeNotNull('Anonymized MAC Address',
      const DigestConverter().toJson(instance.anonymizedMacAddress));
  writeNotNull('Anonymized Bundle ID',
      const DigestConverter().toJson(instance.anonymizedBundleId));
  val['Binding'] = instance.binding;
  val['Language'] = instance.language;
  val['Framework'] = instance.framework;
  val['Framework Version'] = instance.frameworkVersion;
  writeNotNull('Sync Enabled', instance.syncEnabled);
  val['Realm Version'] = instance.realmVersion;
  val['Host OS Type'] = instance.hostOsType;
  val['Host OS Version'] = instance.hostOsVersion;
  writeNotNull('Target OS Type', _$TargetOsTypeEnumMap[instance.targetOsType]);
  writeNotNull('Target OS Version', instance.targetOsVersion);
  return val;
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$TargetOsTypeEnumMap = {
  TargetOsType.android: 'android',
  TargetOsType.ios: 'ios',
  TargetOsType.linux: 'linux',
  TargetOsType.macos: 'macos',
  TargetOsType.windows: 'windows',
};
