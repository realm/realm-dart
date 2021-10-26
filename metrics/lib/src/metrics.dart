import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metrics/src/target_os_type.dart';

import 'version.dart';

part 'metrics.g.dart';

extension _IterableEx<T> on Iterable<T> {
  T? get firstOrNull =>
      cast<T?>().firstWhere((element) => true, orElse: () => null);
}

Future<Metrics> generateMetrics({
  required Digest distinctId,
  TargetOsType? targetOsType,
  String? targetOsVersion,
  Digest? anonymizedMacAddress,
  Digest? anonymizedBundleId,
}) async {
  return Metrics(
    event: 'run',
    properties: Properties(
      distinctId: distinctId,
      token: 'ce0fac19508f6c8f20066d345d360fd0',
      binding: 'dart',
      language: 'dart',
      framework: 'dart', // what about flutter?
      frameworkVersion: Platform.version,
      hostOsType: Platform.operatingSystem,
      hostOsVersion: Platform.operatingSystemVersion,
      realmVersion: packageVersion,
      targetOsType: targetOsType,
      targetOsVersion: targetOsVersion,
      anonymizedMacAddress: anonymizedMacAddress ?? distinctId, // fallback
      anonymizedBundleId: anonymizedBundleId,
    ),
  );
}

// While we wait for: https://github.com/google/json_serializable.dart/issues/822
Digest _digestFromJson(String json) => Digest(base64Decode(json));
String _digestToJson(Digest object) => base64Encode(object.bytes);

class DigestConverter extends JsonConverter<Digest?, String?> {
  const DigestConverter();

  @override
  Digest? fromJson(String? json) => json != null ? _digestFromJson(json) : null;

  @override
  String? toJson(Digest? object) =>
      object != null ? _digestToJson(object) : null;
}

@JsonSerializable()
class Metrics {
  final String event;
  final Properties properties;

  Metrics({required this.event, required this.properties});

  factory Metrics.fromJson(Map<String, dynamic> json) =>
      _$MetricsFromJson(json);
  Map<String, dynamic> toJson() => _$MetricsToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.pascal, // ex: hostOSType becomes HostOSType
  includeIfNull: false,
)
class Properties {
  @JsonKey(name: 'token') // not PascalCase
  final String token;

  @JsonKey(
    name: 'distinct_id', // snake-case
    fromJson: _digestFromJson,
    toJson: _digestToJson,
  )
  final Digest distinctId;

  @JsonKey(name: 'Anonymized MAC Address')
  @DigestConverter()
  final Digest? anonymizedMacAddress;

  @JsonKey(name: 'Anonymized Bundle ID')
  @DigestConverter()
  final Digest? anonymizedBundleId;

  final String binding;
  final String language;
  final String framework;

  @JsonKey(name: 'Framework Version')
  final String frameworkVersion;

  @JsonKey(name: 'Sync Enabled')
  final String? syncEnabled;

  @JsonKey(name: 'Realm Version')
  final String realmVersion;

  @JsonKey(name: 'Host OS Type')
  final String hostOsType;

  @JsonKey(name: 'Host OS Version')
  final String hostOsVersion;

  @JsonKey(name: 'Target OS Type')
  final TargetOsType? targetOsType;

  @JsonKey(name: 'Target OS Version')
  final String? targetOsVersion;

  Properties({
    required this.distinctId,
    required this.token,
    required this.binding,
    required this.framework,
    required this.frameworkVersion,
    required this.hostOsType,
    required this.hostOsVersion,
    required this.language,
    required this.realmVersion,
    this.anonymizedBundleId,
    this.anonymizedMacAddress,
    this.syncEnabled,
    this.targetOsType,
    this.targetOsVersion,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}
