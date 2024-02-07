import 'package:realm_common/realm_common.dart';
import 'mapto.dart';

part 'another_mapto.realm.dart';

@RealmModel()
@MapTo('this is also mapped')
class _MappedToo {
  late $Original? singleLink;

  late List<$Original> listLink;
}
