import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Parent {
  @MapTo('single child')
  late _Child1? child;

  @MapTo('CHILDREN')
  late List<_Child1> children;
}

@RealmModel(ObjectType.embedded)
@MapTo('MySuperChild')
class _Child1 {
  @MapTo('_value')
  late String value;

  @MapTo('_parent')
  late _Parent? linkToParent;

  @Indexed()
  late String indexedString;

  @Ignored()
  late String ignoredString;
}
