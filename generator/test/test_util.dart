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
      var expectedFileName = _path.setExtension(file.path, '.expected');
      if (!files.any((f) => f.path == expectedFileName)) {
        throw "Expected file not found. $expectedFileName";
      }
      result.addAll({_path.basename(file.path): _path.basename(expectedFileName)});
    }
  }
  return result;
}

Future<dynamic> generatorTestBuilder(String directoryName, String inputFileName, [String? expectedFileName]) async {
  return testBuilder(generateRealmObjects(), await getInputFileAsset('$directoryName/$inputFileName'),
      outputs: expectedFileName != null ? await getExpectedFileAsset('$directoryName/$inputFileName', '$directoryName/$expectedFileName') : null,
      reader: await PackageAssetReader.currentIsolate());
}

Future<Map<String, Object>> getInputFileAsset(String inputFilePath) async {
  var key = 'pkg|$inputFilePath';
  String inputContent = await readFileAsDartFormattedString(inputFilePath);
  return {key: inputContent};
}

/// A special equality matcher for strings.
class LinesEqualsMatcher extends Matcher {
  late final List<String> expectedLines;

  LinesEqualsMatcher(String expected) {
    expectedLines = expected.split("\n");
  }

  @override
  Description describe(Description description) => description.add("LinesEqualsMatcher");

  @override
  // ignore: strict_raw_type
  bool matches(dynamic actual, Map matchState) {
    final actualValue = utf8.decode(actual as List<int>);
    final actualLines = actualValue.split("\n");

    for (var i = 0; i < expectedLines.length - 1; i++) {
      if (i >= actualLines.length) {
        matchState["Error"] = "Difference at line ${i + 1}. \nExpected: ${expectedLines[i]}.\n  Actual: empty";
        return false;
      }

      if (expectedLines[i] != actualLines[i]) {
        matchState["Error"] = "Difference at line ${i + 1}. \nExpected: ${expectedLines[i]}.\n  Actual: ${actualLines[i]}";
        return false;
      }
    }

    if (actualLines.length > expectedLines.length) {
      matchState["Error"] = "Different number of lines. \nExpected: ${expectedLines.length}\nActual: ${actualLines.length}";
      return false;
    }

    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState["Error"] != null) {
      mismatchDescription.add(matchState["Error"] as String);
    }

    return mismatchDescription;
  }
}

Future<Map<String, Object>> getExpectedFileAsset(String inputFilePath, String expectedFilePath) async {
  var key = 'pkg|${_path.setExtension(inputFilePath, '.realm_objects.g.part')}';
  String expectedContent = await readFileAsDartFormattedString(expectedFilePath);

  return {key: LinesEqualsMatcher(expectedContent)};
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
  return _path.basename(file);
}
