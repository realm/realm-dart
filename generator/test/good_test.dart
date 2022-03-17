import 'package:build_test/build_test.dart';
import 'package:realm_generator/realm_generator.dart';
import 'package:test/test.dart';
import 'test_util.dart';
void main() {

  final folderName = 'good_test_io';

  test('required argument with default value', () async {
    await ioTestBuilder(folderName, 'required_arg_with_default_value.dart', 'required_arg_with_default_value.g.dart');
  });

  test('required argument', () async {
    await ioTestBuilder(folderName, 'required_argument.dart', 'required_argument.g.dart');
  });

  test('list initialization', () async {
    await ioTestBuilder(folderName, 'list_initialization.dart', 'list_initialization.g.dart');
  });

  test('optional argument', () async {
    await ioTestBuilder(folderName, 'optional_argument.dart', 'optional_argument.g.dart');
  });

  test('user defined getter', () async {
    await ioTestBuilder(folderName, 'user_defined_getter.dart', 'user_defined_getter.g.dart');
  });
}
