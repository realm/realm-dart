// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Item extends RealmObject {
  Item._constructor() : super.constructor();
  Item() {}

  @RealmProperty(primaryKey: true)
  int get id => super['id'];
  set id(int value) => super['id'] = value;

  @RealmProperty()
  String get name => super['name'];
  set name(String value) => super['name'] = value;

  @RealmProperty(defaultValue: '42')
  int get price => super['price'];
  set price(int value) => super['price'] = value;

  static dynamic getSchema() {
    return RealmObject.getSchema('Item', [
      new SchemaProperty('id', type: 'int', primaryKey: true),
      new SchemaProperty('name', type: 'string'),
      new SchemaProperty('price', type: 'int', defaultValue: '42'),
    ]);
  }
}
