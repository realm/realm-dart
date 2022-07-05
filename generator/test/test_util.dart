import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:path/path.dart' as _path;
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';

Function executeTest = test;

Map<String, String> getListOfTestFiles(String directory) {
  Map<String, String> result = {};
  var files = Directory(_path.join(Directory.current.path, directory)).listSync();
  for (var file in files) {
    if (_path.extension(file.path) == '.dart' && !file.path.endsWith('g.dart')) {
      var expectedFileName = _path.setExtension(file.path, '.expected');
      if (!files.any((f) => f.path == expectedFileName)) expectedFileName = '';
      result.addAll({_path.basename(file.path): _path.basename(expectedFileName)});
    }
  }
  return result;
}

Future<dynamic> generatorTestBuilder(String directoryName, String inputFileName) async {
  final inputPath = _path.join(directoryName, inputFileName);
  final expectedPath = _path.setExtension(inputPath, '.expected');
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset(inputPath),
    outputs: await getExpectedFileAsset(inputPath, expectedPath),
    reader: await PackageAssetReader.currentIsolate(),
  );
}

Future<Map<String, Object>> getInputFileAsset(String inputFilePath) async {
  var key = 'pkg|$inputFilePath';
  String inputContent = await readFileAsDartFormattedString(inputFilePath);
  return {key: inputContent};
}

class GoldenFileMatcher extends Matcher {
  final File golden;
  final Matcher Function(File) matcherFactory;
  late final Matcher _matcher;

  GoldenFileMatcher(this.golden, this.matcherFactory);

  @override
  Description describe(Description description) {
    return _matcher.describe(description);
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) =>
      _matcher.describeMismatch(item, mismatchDescription, matchState, verbose);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    // create golden master, if missing
    if (!golden.existsSync()) {
      var bytes = <int>[];
      if (item is File) {
        bytes = item.readAsBytesSync();
      } else if (item is List<int>) {
        bytes = item;
      } else if (item is String) {
        bytes = utf8.encode(item);
      }
      golden.writeAsBytesSync(bytes, flush: true);
    }
    _matcher = matcherFactory(golden);
    return _matcher.matches(item, matchState);
  }
}

class MyersDiffMatcher extends Matcher {
  final String expected;

  MyersDiffMatcher(this.expected);

  @override
  Description describe(Description description) => description.add(expected);

  String _getText(dynamic item) {
    if (item is String) {
      return item;
    } else if (item is List<int>) {
      return utf8.decode(item);
    }
    return item.toString();
  }

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) => expected == _getText(item);

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final actual = _getText(item);
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(actual, expected);
    dmp.diffCleanupSemantic(diffs);
    ansiColorDisabled = false;
    final pen = AnsiPen();
    for (final d in diffs) {
      if (d.operation < 0) {
        pen.red(bg: true); // delete
      } else if (d.operation == 0) {
        pen.reset(); // no-edit
      } else if (d.operation > 0) {
        pen.green(bg: true); // insert
      }
      mismatchDescription = mismatchDescription.add(pen(d.text));
    }
    return mismatchDescription;
  }
}

/// A special equality matcher for strings.
class LinesEqualsMatcher extends Matcher {
  final String expected;

  LinesEqualsMatcher(this.expected);

  @override
  Description describe(Description description) => description.add(expected);

  @override
  // ignore: strict_raw_type
  bool matches(dynamic actual, Map matchState) {
    final actualValue = utf8.decode(actual as List<int>);

    final expectedLines = expected.split("\n");
    final actualLines = actualValue.split("\n");

    if (actualLines.length > expectedLines.length) {
      matchState["Error"] = "Different number of lines. \nExpected: ${expectedLines.length}\nActual: ${actualLines.length}";
      return false;
    }

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

    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    mismatchDescription.addDescriptionOf(item).replace(utf8.decode(item as List<int>));
    if (matchState["Error"] != null) {
      mismatchDescription.add(matchState["Error"] as String);
    }

    return mismatchDescription;
  }
}

Future<Map<String, Object>> getExpectedFileAsset(String inputFilePath, String expectedFilePath) async {
  var key = 'pkg|${_path.setExtension(inputFilePath, '.realm_objects.g.part')}';
  return {key: GoldenFileMatcher(File(expectedFilePath), (f) => MyersDiffMatcher(f.readAsStringSync()))};
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
