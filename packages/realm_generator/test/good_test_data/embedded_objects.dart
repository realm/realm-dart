import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Parent {
  late _Child1? child;

  late List<_Child1> children;
}

@RealmModel(ObjectType.embeddedObject)
class _Child1 {
  late String value;

  late _Child2? child;

  late List<_Child2> children;

  late _Parent? linkToParent;
}

@RealmModel(ObjectType.embeddedObject)
class _Child2 {
  late bool boolProp;
  late int intProp;
  late double doubleProp;
  late String stringProp;
  late DateTime dateProp;
  late ObjectId objectIdProp;
  late Uuid uuidProp;

  late bool? nullableBoolProp;
  late int? nullableIntProp;
  late double? nullableDoubleProp;
  late String? nullableStringProp;
  late DateTime? nullableDateProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
}
