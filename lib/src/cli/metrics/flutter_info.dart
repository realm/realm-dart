////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'utils.dart';

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
