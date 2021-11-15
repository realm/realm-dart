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
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'options.dart';
import 'utils.dart';

part 'flutter_info.g.dart';

FutureOr<T?> safe<T>(FutureOr<T> Function() f, {Function(Object e, StackTrace s)? onError}) async {
  try {
    return await f();
  } catch (e, s) {
    if (onError != null) {
      onError(e, s);
    }
    return null;
  }
}

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

  static Future<FlutterInfo?> get(Options options) async {
    final pubspecPath = options.pubspecPath;
    final pubspec = Pubspec.parse(await File(pubspecPath).readAsString());

    const flutter = 'flutter';
    final flutterDep = pubspec.dependencies.values.whereType<SdkDependency>().where((dep) => dep.sdk == flutter).firstOrNull;
    if (flutterDep == null) {
      return null; // no flutter dependency, so not a flutter project
    }

    // Read constraints, if any
    var flutterVersionConstraints = flutterDep.version.intersect(pubspec.environment?[flutter] ?? VersionConstraint.any);

    // Try to read actual version from version file in .dart_tools
    final version = await safe(() async {
      return Version.parse(await File(path.join(path.dirname(pubspecPath), '.dart_tool/version')).readAsString());
    });

    // Try to get full info by calling flutter executable
    final info = await safe(() async {
      final flutterRoot = options.flutterRoot;
      final flutterPath = flutterRoot == null ? flutter : path.join(flutterRoot, 'bin', flutter);
      final process = await Process.start(
        flutterPath,
        ['--version', '--machine'],
      );
      final infoJson = await process.stdout.transform(utf8.decoder).join();
      return FlutterInfo.fromJson(json.decode(infoJson) as Map<String, dynamic>);
    });

    // Sanity check info
    if (info != null && (version?.allows(info.frameworkVersion) ?? true) && flutterVersionConstraints.allows(info.frameworkVersion)) {
      return info; // the returned info match both the projects constraints and the flutter version used on last build
    }

    // Fallback to the version used on last build
    return FlutterInfo(
      frameworkVersion: version ?? Version.none,
      dartSdkVersion: Version.parse(Platform.version.toString().takeUntil(' ')),
    );
  }
}
