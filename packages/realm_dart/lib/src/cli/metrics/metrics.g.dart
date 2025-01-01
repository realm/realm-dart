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
      builderId: _digestFromJson(json['builder_id'] as String),
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
          $enumDecodeNullable(_$TargetOsTypeEnumMap, json['Target OS Type']),
      targetOsVersion: json['Target OS Version'] as String?,
      realmCoreVersion: json['Core Version'] as String?,
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'token': instance.token,
      'distinct_id': _digestToJson(instance.distinctId),
      'builder_id': _digestToJson(instance.builderId),
      if (const DigestConverter().toJson(instance.anonymizedMacAddress)
          case final value?)
        'Anonymized MAC Address': value,
      if (const DigestConverter().toJson(instance.anonymizedBundleId)
          case final value?)
        'Anonymized Bundle ID': value,
      'Binding': instance.binding,
      'Language': instance.language,
      'Framework': instance.framework,
      'Framework Version': instance.frameworkVersion,
      if (instance.syncEnabled case final value?) 'Sync Enabled': value,
      'Realm Version': instance.realmVersion,
      'Host OS Type': instance.hostOsType,
      'Host OS Version': instance.hostOsVersion,
      if (_$TargetOsTypeEnumMap[instance.targetOsType] case final value?)
        'Target OS Type': value,
      if (instance.targetOsVersion case final value?)
        'Target OS Version': value,
      if (instance.realmCoreVersion case final value?) 'Core Version': value,
    };

const _$TargetOsTypeEnumMap = {
  TargetOsType.android: 'android',
  TargetOsType.ios: 'ios',
  TargetOsType.linux: 'linux',
  TargetOsType.macos: 'macos',
  TargetOsType.windows: 'windows',
};
