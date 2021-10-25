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
      hostOSType: json['Host OS Type'] as String,
      hostOSVersion: json['Host OS Version'] as String,
      language: json['Language'] as String,
      realmVersion: json['Realm Version'] as String,
      anonymizedBundleId: const DigestConverter()
          .fromJson(json['Anonymized Bundle ID'] as String?),
      anonymizedMacAddress: const DigestConverter()
          .fromJson(json['Anonymized MAC Address'] as String?),
      syncEnabled: json['Sync Enabled'] as String?,
      targetOSType: json['Target OS Type'] as String?,
      targetOSVersion: json['Target OS Version'] as String?,
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
  val['Host OS Type'] = instance.hostOSType;
  val['Host OS Version'] = instance.hostOSVersion;
  writeNotNull('Target OS Type', instance.targetOSType);
  writeNotNull('Target OS Version', instance.targetOSVersion);
  return val;
}
