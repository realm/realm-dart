import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Foo {
  @Indexed(RealmIndexType.none)
  late int value;
}
