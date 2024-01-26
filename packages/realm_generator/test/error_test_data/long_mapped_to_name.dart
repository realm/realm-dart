import 'package:realm_common/realm_common.dart';

//part 'long_mapped_to_name.g.dart';

@RealmModel()
@MapTo('ThisIsAVeryLongClassNameSoLongInFactThatItRunsOverThe57CharacterLimit')
class _Foo {
  late int id;
}
