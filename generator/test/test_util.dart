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

Future<dynamic> generatorTestBuilder(String directoryName, String inputFileName, {bool expectError = false}) async {
  final inputPath = _path.join(directoryName, inputFileName);
  final expectedPath = _path.setExtension(inputPath, '.expected');
  return testBuilder(
    generateRealmObjects(),
    await getInputFileAsset(inputPath),
    outputs: expectError ? null : await getExpectedFileAsset(inputPath, expectedPath),
    reader: await PackageAssetReader.currentIsolate(),
  );
}

Future<Map<String, Object>> getInputFileAsset(String inputFilePath) async {
  var key = 'pkg|$inputFilePath';
  String inputContent = await File(inputFilePath).readFileAsDartCode();
  return {key: inputContent};
}

class GoldenFileMatcher extends Matcher {
  final File golden;
  final Matcher matcher;

  GoldenFileMatcher(this.golden, this.matcher);

  @override
  Description describe(Description description) {
    return matcher.describe(description);
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) =>
      matcher.describeMismatch(item, mismatchDescription, matchState, verbose);

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
    return matcher.matches(item, matchState);
  }
}

Matcher myersDiff(String expected) => MyersDiffMatcher(expected);

class MyersDiffMatcher extends Matcher {
  final String _expected;

  MyersDiffMatcher(dynamic expected) : _expected = _getText(expected);

  @override
  Description describe(Description description) => description.add(_expected);

  static String _getText(dynamic item) {
    if (item is String) {
      return item;
    } else if (item is List<int>) {
      return utf8.decode(item);
    }
    return item.toString();
  }

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) => _expected == _getText(item);

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final actual = _getText(item);
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(actual, _expected);
    dmp.diffCleanupSemantic(diffs);
    ansiColorDisabled = false;
    final pen = AnsiPen();
    for (final d in diffs) {
      if (d.operation < 0) {
        pen.red(bg: true); // delete
      } else if (d.operation > 0) {
        pen.green(bg: true); // insert
      }
      mismatchDescription = mismatchDescription.add(pen(d.text));
      pen.reset();
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
  return {
    key: myersDiff(await File(expectedFilePath).readFileAsDartCode()),
  };
}

extension FileEx on File {
  Future<String> readFileAsErrorFormattedString() async {
    var content = await readAsString(encoding: utf8);
    if (Platform.isWindows) {
      var macToWinSymbols = {'╷': ',', '━': '=', '╵': '\'', '│': '|', '─': '-', '┌': ',', '└': '\''};
      macToWinSymbols.forEach((key, value) {
        content = content.replaceAll(key, value);
      });
    }
    return LineSplitter.split(content).join('\n');
  }

  Future<String> readFileAsDartCode() async {
    final content = await readAsString(encoding: utf8);
    final formatter = DartFormatter(lineEnding: '\n');
    return formatter.format(content);
  }
}

String getTestName(String file) {
  return _path.basename(file.replaceAll('_', ' '));
}
