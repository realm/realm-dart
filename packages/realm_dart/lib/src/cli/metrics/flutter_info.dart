// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import '../common/utils.dart';

part 'flutter_info.g.dart';

class VersionConverter extends JsonConverter<Version, String> {
  const VersionConverter();

  @override
  Version fromJson(String json) => Version.parse(json.takeUntil(' '));

  @override
  String toJson(Version object) => object.toString();
}

@JsonSerializable()
class FlutterInfo {
  @VersionConverter()
  final Version frameworkVersion;
  final String? channel;
  final String? repositoryUrl;
  final String? frameworkRevision;
  final String? frameworkCommitDate;
  final String? engineRevision;
  @VersionConverter()
  final Version dartSdkVersion;
  final String? flutterRoot;

  FlutterInfo(
      {required this.frameworkVersion,
      this.channel,
      this.repositoryUrl,
      this.frameworkRevision,
      this.frameworkCommitDate,
      this.engineRevision,
      required this.dartSdkVersion,
      this.flutterRoot});

  factory FlutterInfo.fromJson(Map<String, dynamic> json) => _$FlutterInfoFromJson(json);
}
