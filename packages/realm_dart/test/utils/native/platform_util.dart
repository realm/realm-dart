// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:realm_dart/realm.dart';

import '../platform_util.dart' as intf;

class PlatformUtil implements intf.PlatformUtil {
  const PlatformUtil();

  @override
  String get systemTempPath => Directory.systemTemp.path;
  @override
  Future<String> createTempPath([String? prefix]) => Directory.systemTemp.createTemp(prefix).then((d) => d.path);
  @override
  String createTempPathSync([String? prefix]) => Directory.systemTemp.createTempSync(prefix).path;
  @override
  Future<int> sizeOnStorage(Configuration config) => File(config.path).stat().then((fs) => fs.size);

  @override
  void printPlatformInfo() {
    final os = Platform.operatingSystem;
    String? cpu;

    if (!isFlutterPlatform) {
      if (Platform.isWindows) {
        cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
      } else {
        final info = Process.runSync('uname', ['-m']);
        cpu = info.stdout.toString().replaceAll('\n', '');
      }
    }

    print('Current PID $pid; OS $os, CPU ${cpu ?? 'unknown'}');
  }

  @override
  Future<void> copy(String fromPath, String toPath) async {
    await File(fromPath).copy(toPath);
  }

  @override
  Future<Uint8List> readAsBytes(String path) => File(path).readAsBytes();

  @override
  Map<String, String> get environment => Platform.environment;

  @override
  int get maxInt => 0x7FFFFFFFFFFFFFFF;

  @override
  int get minInt => -0x8000000000000000;
}
