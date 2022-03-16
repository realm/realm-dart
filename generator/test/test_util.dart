import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as _path;
import 'package:dart_style/dart_style.dart';
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
  String content = await file.readAsString(encoding: utf8);
  return _stringReplacements(content);
}

Future<String> readFileAsErrorFormattedString(String directoryName, String logFileName) async {
  var file = File(_path.join(Directory.current.path, 'test/$directoryName/$logFileName'));
  String content = await file.readAsString(encoding: utf8);
  if (Platform.isWindows) {
    var macToWinSymbols = {'╷': ',', '━': '=', '╵': '\'', '│': '|', '─': '-', '┌': ',', '└': '\''};
    macToWinSymbols.forEach((key, value) {
      content = content.replaceAll(key, value);
    });
  }
  return LineSplitter.split(content).join('\n');
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
  return testBuilder(generateRealmObjects(), await getInputFileAsset('test/$directoryName/$inputFileName'),
      outputs: outputFileName.isEmpty ? null : await getOutputFileAsset('test/$directoryName/$inputFileName', 'test/$directoryName/$outputFileName'),
      reader: await PackageAssetReader.currentIsolate());
}

Future<dynamic> ioTestErrorBuilder(String directoryName, String inputFileName) async {
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset('test/$directoryName/$inputFileName'),
    reader: await PackageAssetReader.currentIsolate(),
  );
}
