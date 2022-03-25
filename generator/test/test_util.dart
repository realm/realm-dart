import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as _path;
import 'package:dart_style/dart_style.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:realm_generator/realm_generator.dart';

Function executeTest = test;

Map<String, String> getListOfTestFiles(String directory) {
  Map<String, String> result = {};
  var files = Directory(_path.join(Directory.current.path, directory)).listSync();
  for (var file in files) {
    if (_path.extension(file.path) == '.dart' && !file.path.endsWith('g.dart')) {
      var outputFileName = _path.setExtension(file.path, '.expected');
      if (!files.any((f) => f.path == outputFileName)) outputFileName = '';
      result.addAll({_path.basename(file.path): _path.basename(outputFileName)});
    }
  }
  return result;
}

Future<dynamic> generatorTestBuilder(String directoryName, String inputFileName, [String outputFileName = ""]) async {
  return testBuilder(generateRealmObjects(), await getInputFileAsset('$directoryName/$inputFileName'),
      outputs: outputFileName.isNotEmpty ? await getOutputFileAsset('$directoryName/$inputFileName', '$directoryName/$outputFileName') : null,
      reader: await PackageAssetReader.currentIsolate());
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

Future<String> readFileAsDartFormattedString(String path) async {
  var file = File(_path.join(Directory.current.path, path));
  String content = await file.readAsString(encoding: utf8);
  return _stringReplacements(content);
}

Future<String> readFileAsErrorFormattedString(String directoryName, String outputFilePath) async {
  var file = File(_path.join(Directory.current.path, '$directoryName/$outputFilePath'));
  String content = await file.readAsString(encoding: utf8);
  if (Platform.isWindows) {
    var macToWinSymbols = {'╷': ',', '━': '=', '╵': '\'', '│': '|', '─': '-', '┌': ',', '└': '\''};
    macToWinSymbols.forEach((key, value) {
      content = content.replaceAll(key, value);
    });
  }
  return LineSplitter.split(content).join('\n');
}

String _stringReplacements(String content) {
  final formatter = DartFormatter();
  var lines = LineSplitter.split(content);
  String formattedContent = lines.where((element) => !element.startsWith("part of")).join('\n');
  return formatter.format(formattedContent);
}

String getTestName(String file) {
  return _path.basename(file.replaceAll('_', ' '));
}
