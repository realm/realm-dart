import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'metrics.g.dart';

Future<Metrics> generateMetrics() async {
  String? distinctId = null; // TODO
  return Metrics(
    event: 'run',
    properties: Properties(distinctId: distinctId ?? 'UNKNOWN'),
  );
}

@JsonSerializable()
class Metrics {
  final String event;
  final Properties properties;

  Metrics({required this.event, required this.properties});

  Map<String, dynamic> toJson() => _$MetricsToJson(this);
  factory Metrics.fromJson(Map<String, dynamic> json) =>
      _$MetricsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Properties {
  @JsonKey(name: 'token') // not PascalCase
  final String token;
  @JsonKey(name: 'distinct_id') // snake-case
  final String distinctId;
  @JsonKey(name: 'Anonymized MAC Address')
  final String anonymizedMacAddress;
  @JsonKey(name: 'Anonymized Bundle ID')
  final String anonymizedBundleId;
  final String binding;
  final String language;
  final String framework;
  @JsonKey(name: 'Framework Version')
  final String frameworkVersion;
  @JsonKey(name: 'Sync Enabled')
  final String syncEnabled;
  @JsonKey(name: 'Realm Version')
  final String realmVersion;
  @JsonKey(name: 'Host OS Type')
  final String hostOSType;
  @JsonKey(name: 'Host OS Version')
  final String hostOSVersion;
  @JsonKey(name: 'Target OS Type')
  final String targetOSType;
  @JsonKey(name: 'Target OS Version')
  final String targetOSVersion;

  Properties({
    required this.distinctId,
    this.token = 'ce0fac19508f6c8f20066d345d360fd0',
    this.binding = 'Dart / Flutter SDK',
    this.language = 'Dart',
    this.anonymizedMacAddress = '',
    this.anonymizedBundleId = '',
    this.framework = '',
    this.frameworkVersion = '',
    this.syncEnabled = '',
    this.realmVersion = '',
    this.hostOSType = '',
    this.hostOSVersion = '',
    this.targetOSType = '',
    this.targetOSVersion = '',
  });

  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
}
