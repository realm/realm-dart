// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlutterInfo _$FlutterInfoFromJson(Map<String, dynamic> json) => FlutterInfo(
      frameworkVersion: json['frameworkVersion'] as String,
      channel: json['channel'] as String,
      repositoryUrl: json['repositoryUrl'] as String,
      frameworkRevision: json['frameworkRevision'] as String,
      frameworkCommitDate: json['frameworkCommitDate'] as String,
      engineRevision: json['engineRevision'] as String,
      dartSdkVersion: json['dartSdkVersion'] as String,
      flutterRoot: json['flutterRoot'] as String,
    );

Map<String, dynamic> _$FlutterInfoToJson(FlutterInfo instance) =>
    <String, dynamic>{
      'frameworkVersion': instance.frameworkVersion,
      'channel': instance.channel,
      'repositoryUrl': instance.repositoryUrl,
      'frameworkRevision': instance.frameworkRevision,
      'frameworkCommitDate': instance.frameworkCommitDate,
      'engineRevision': instance.engineRevision,
      'dartSdkVersion': instance.dartSdkVersion,
      'flutterRoot': instance.flutterRoot,
    };
