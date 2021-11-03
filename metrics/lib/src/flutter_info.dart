import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'flutter_info.g.dart';

@JsonSerializable()
class FlutterInfo {
  final String frameworkVersion;
  final String channel;
  final String repositoryUrl;
  final String frameworkRevision;
  final String frameworkCommitDate;
  final String engineRevision;
  final String dartSdkVersion;
  final String flutterRoot;

  FlutterInfo(
      {required this.frameworkVersion,
      required this.channel,
      required this.repositoryUrl,
      required this.frameworkRevision,
      required this.frameworkCommitDate,
      required this.engineRevision,
      required this.dartSdkVersion,
      required this.flutterRoot});

  factory FlutterInfo.fromJson(Map<String, dynamic> json) =>
      _$FlutterInfoFromJson(json);

  static Future<FlutterInfo> get() async {
    final process = await Process.start('flutter', ['--version', '--machine']);
    final infoJson = await process.stdout.transform(utf8.decoder).join();
    return FlutterInfo.fromJson(json.decode(infoJson));
  }
}
