// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlutterInfo _$FlutterInfoFromJson(Map<String, dynamic> json) => FlutterInfo(
      frameworkVersion: const VersionConverter().fromJson(json['frameworkVersion'] as String),
      channel: json['channel'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      frameworkRevision: json['frameworkRevision'] as String?,
      frameworkCommitDate: json['frameworkCommitDate'] as String?,
      engineRevision: json['engineRevision'] as String?,
      dartSdkVersion: const VersionConverter().fromJson(json['dartSdkVersion'] as String),
      flutterRoot: json['flutterRoot'] as String?,
    );

Map<String, dynamic> _$FlutterInfoToJson(FlutterInfo instance) => <String, dynamic>{
      'frameworkVersion': const VersionConverter().toJson(instance.frameworkVersion),
      'channel': instance.channel,
      'repositoryUrl': instance.repositoryUrl,
      'frameworkRevision': instance.frameworkRevision,
      'frameworkCommitDate': instance.frameworkCommitDate,
      'engineRevision': instance.engineRevision,
      'dartSdkVersion': const VersionConverter().toJson(instance.dartSdkVersion),
      'flutterRoot': instance.flutterRoot,
    };
