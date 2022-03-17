import 'package:test/test.dart';
import 'test_util.dart';
void main() {

  final folderName = 'good_test_io';

  test('required argument with default value', () async {
    await ioTestBuilder(folderName, 'required_arg_with_default_value.dart', 'required_arg_with_default_value.expected');
  });

  test('required argument', () async {
    await ioTestBuilder(folderName, 'required_argument.dart', 'required_argument.expected');
  });

  test('list initialization', () async {
    await ioTestBuilder(folderName, 'list_initialization.dart', 'list_initialization.expected');
  });

  test('optional argument', () async {
    await ioTestBuilder(folderName, 'optional_argument.dart', 'optional_argument.expected');
  });

  test('user defined getter', () async {
    await ioTestBuilder(folderName, 'user_defined_getter.dart', 'user_defined_getter.expected');
  });
}
