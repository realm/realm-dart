import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as _path;
import 'package:dart_style/dart_style.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';

String _stringReplacements(String content) {
  final formatter = DartFormatter();
  var lines = LineSplitter.split(content);
  String formattedContent = lines.where((element) => !element.startsWith("part of")).join('\n');
  return formatter.format(formattedContent);
}

Future<String> readFileAsFormattedString(String path) async {
  var file = File(_path.join(Directory.current.path, path));
  return await file.readAsString(encoding: utf8).then((value) => _stringReplacements(value));
}

class _OutputFileWriter extends RecordingAssetWriter {
  final _assets = <AssetId, List<int>>{};

  @override
  Map<AssetId, List<int>> get assets => _assets;

  @override
  Future<void> writeAsBytes(AssetId id, List<int> bytes) {
    return Future<void>(() {
      String content = _stringReplacements(utf8.decode(bytes));
      _assets.addAll({id: utf8.encode(content)});
    });
  }

  @override
  Future<void> writeAsString(AssetId id, String contents, {Encoding encoding = utf8}) {
    return Future<void>(() {
      _assets.addAll({id: encoding.encode(_stringReplacements(contents))});
    });
  }
}

Future<Map<String, Object>> getInputFileAsset(String path) async {
  String input = await readFileAsFormattedString(path);
  return {'pkg|$path': input};
}

Future<Map<String, Object>> getOutputFileAsset(String path) async {
  String output = await readFileAsFormattedString(path);
  String fileNameWithoutExtensions = _path.basenameWithoutExtension(_path.basenameWithoutExtension(path));
  var generatedFile = '${_path.dirname(path)}/$fileNameWithoutExtensions.realm_objects.g.part';
  return {'pkg|$generatedFile': output};
}

Future<dynamic> ioTtestBuilder(String directoryName, String testFilesPreffix) async {
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset('test/$directoryName/$testFilesPreffix.dart'),
    outputs: await getOutputFileAsset('test/$directoryName/$testFilesPreffix.g.dart'),
    reader: await PackageAssetReader.currentIsolate(),
    writer: _OutputFileWriter(),
  );
}
