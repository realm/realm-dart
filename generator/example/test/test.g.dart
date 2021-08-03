// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class MyClass123 extends RealmObject {
  MyClass123._constructor() : super.constructor();
  MyClass123() {}

  @RealmProperty(type: 'string')
  int get myField => super['myField'];
  set myField(int value) => super['myField'] = value;

  @override
  dynamic get _schema {
    return RealmObject.getSchema('MyClass123', [
      new SchemaProperty('myField', type: 'string'),
    ]);
  }
}
