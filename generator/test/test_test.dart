import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('test test', () {
    test('compiles', () async {
      await expectLater(compile(r'''
import 'package:realm_dart/realm.dart';

part 'myapp.g.dart';

@RealmModel
class _Car {
  @PrimaryKey
  late String licensePlate;
}
'''), completes);
    });

    test('does not compile', () async {
      await expectLater(compile(r'''
'''), throwsCompileError);
    });
  });
}
