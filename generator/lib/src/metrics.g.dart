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
      distinctId: json['distinct_id'] as String,
      token: json['token'] as String? ?? 'ce0fac19508f6c8f20066d345d360fd0',
      binding: json['Binding'] as String? ?? 'Dart / Flutter SDK',
      language: json['Language'] as String? ?? 'Dart',
      anonymizedMacAddress: json['Anonymized MAC Address'] as String? ?? '',
      anonymizedBundleId: json['Anonymized Bundle ID'] as String? ?? '',
      framework: json['Framework'] as String? ?? '',
      frameworkVersion: json['Framework Version'] as String? ?? '',
      syncEnabled: json['Sync Enabled'] as String? ?? '',
      realmVersion: json['Realm Version'] as String? ?? '',
      hostOSType: json['Host OS Type'] as String? ?? '',
      hostOSVersion: json['Host OS Version'] as String? ?? '',
      targetOSType: json['Target OS Type'] as String? ?? '',
      targetOSVersion: json['Target OS Version'] as String? ?? '',
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'token': instance.token,
      'distinct_id': instance.distinctId,
      'Anonymized MAC Address': instance.anonymizedMacAddress,
      'Anonymized Bundle ID': instance.anonymizedBundleId,
      'Binding': instance.binding,
      'Language': instance.language,
      'Framework': instance.framework,
      'Framework Version': instance.frameworkVersion,
      'Sync Enabled': instance.syncEnabled,
      'Realm Version': instance.realmVersion,
      'Host OS Type': instance.hostOSType,
      'Host OS Version': instance.hostOSVersion,
      'Target OS Type': instance.targetOSType,
      'Target OS Version': instance.targetOSVersion,
    };
