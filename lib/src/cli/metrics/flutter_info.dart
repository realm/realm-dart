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

  static Future<FlutterInfo?> get() async {
    try {
      final process = await Process.start(
        'flutter',
        ['--version', '--machine'],
      );
      final infoJson = await process.stdout.transform(utf8.decoder).join();
      return FlutterInfo.fromJson(
          json.decode(infoJson) as Map<String, dynamic>);
    } catch (_) {}
    return null;
  }
}
