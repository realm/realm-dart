import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';

import 'version.dart';

part 'metrics.g.dart';

extension _IterableEx<T> on Iterable<T> {
  T? get firstOrNull => cast<T?>().firstWhere((element) => true, orElse: () => null);
}

Future<Metrics> generateMetrics() async {
  final nic = (await NetworkInterface.list()).firstOrNull;
  var distinctId = '${Platform.localHostname} ${Platform.localeName} ${Platform.numberOfProcessors}';
  distinctId = sha1.convert(utf8.encode(distinctId)).toString();
  return Metrics(
    event: 'run',
    properties: Properties(
      distinctId: distinctId,
      token: 'ce0fac19508f6c8f20066d345d360fd0',
      binding: 'dart',
      language: 'dart',
      framework: 'dart', // what about flutter?
      frameworkVersion: Platform.version,
      hostOSType: Platform.operatingSystem,
      hostOSVersion: Platform.operatingSystemVersion,
      realmVersion: packageVersion,
    ),
  );
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

@JsonSerializable(fieldRename: FieldRename.pascal, includeIfNull: false)
class Properties {
  @JsonKey(name: 'token') // not PascalCase
  final String token;
  @JsonKey(name: 'distinct_id') // snake-case
  final String distinctId;
  @JsonKey(name: 'Anonymized MAC Address')
  final String? anonymizedMacAddress;
  @JsonKey(name: 'Anonymized Bundle ID')
  final String? anonymizedBundleId;
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
  final String hostOSType;
  @JsonKey(name: 'Host OS Version')
  final String hostOSVersion;
  @JsonKey(name: 'Target OS Type')
  final String? targetOSType;
  @JsonKey(name: 'Target OS Version')
  final String? targetOSVersion;

  Properties({
    required this.distinctId,
    required this.token,
    required this.binding,
    required this.framework,
    required this.frameworkVersion,
    required this.hostOSType,
    required this.hostOSVersion,
    required this.language,
    required this.realmVersion,
    this.anonymizedBundleId,
    this.anonymizedMacAddress,
    this.syncEnabled,
    this.targetOSType,
    this.targetOSVersion,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}
