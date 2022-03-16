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

Future<String> readFileAsDartFormattedString(String path) async {
  var file = File(_path.join(Directory.current.path, path));
  return await file.readAsString(encoding: utf8).then((value) => _stringReplacements(value));
}

Future<String> readFileAsString(String path) async {
  var file = File(_path.join(Directory.current.path, path));
  return await file.readAsString(encoding: utf8).then((value) => LineSplitter.split(value).join('\n'));
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

Future<Map<String, Object>> getInputFileAsset(String inputFilePath) async {
  var key = 'pkg|$inputFilePath';
  String inputContent = await readFileAsDartFormattedString(inputFilePath);
  return {key: inputContent};
}

Future<Map<String, Object>> getOutputFileAsset(String inputFilePath, String outputFilePath) async {
  var key = 'pkg|${_path.setExtension(inputFilePath, '.realm_objects.g.part')}';
  String outputContent = await readFileAsDartFormattedString(outputFilePath);
  return {key: outputContent};
}

Future<dynamic> ioTestBuilder(String directoryName, String inputFileName, [String outputFileName = ""]) async {
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset('test/$directoryName/$inputFileName'),
    outputs: outputFileName.isEmpty ? null : await getOutputFileAsset('test/$directoryName/$inputFileName', 'test/$directoryName/$outputFileName'),
    reader: await PackageAssetReader.currentIsolate(),
    writer: _OutputFileWriter(),
  );
}

Future<dynamic> ioTestErrorBuilder(String directoryName, String inputFileName) async {
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset('test/$directoryName/$inputFileName'),
    reader: await PackageAssetReader.currentIsolate(),
  );
}
