import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Foo {
  @Backlink(#bad)
  late Iterable<int> bad;
}
