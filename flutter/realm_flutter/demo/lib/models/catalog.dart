// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:realm_flutter/realm.dart';


//declare part file
part 'catalog.g.dart';


/// A proxy of the catalog of items the user can buy.
///
/// In a real app, this might be backed by a backend and cached on device.
/// In this sample app, the catalog is procedurally generated and infinite.
///
/// For simplicity, the catalog is expected to be immutable (no products are
/// expected to be added, removed or changed during the execution of the app).
class CatalogModel {
  Realm realm;
  
  CatalogModel() {
    var config = new Configuration();
    config.schema.add(Item);

    realm = new Realm(config);

      var objects = realm.objects<Item>();
      
      //if (objects.length == 0) {
        realm.write(() {
          realm.deleteAll();
          realm.create(Item()..id = 0..name = '123 Code-Smell'..price = 20);
          realm.create(Item()..id = 1..name = '456 Control-Flow'..price = 1);
          realm.create(Item()..id = 2..name = '789 Interpreter'..price = 2);
          realm.create(Item()..id = 3..name = 'Recursion'..price = 3);
          realm.create(Item()..id = 4..name = 'Sprint'..price = 4);
          realm.create(Item()..id = 5..name = 'Heisenbug'..price = 5);
          realm.create(Item()..id = 6..name = 'Spaghetti'..price = 6);
          realm.create(Item()..id = 7..name = 'Hydra-Code'..price = 7);
          realm.create(Item()..id = 8..name = 'Off-By-One'..price = 8);
          realm.create(Item()..id = 9..name = 'Scope'..price = 9);
          realm.create(Item()..id = 10..name = 'Callback'..price = 10);
          realm.create(Item()..id = 11..name = 'Closure'..price = 11);
          realm.create(Item()..id = 12..name = 'Automata'..price = 12);
          realm.create(Item()..id = 13..name = 'Bit-Shift'..price = 13);
          realm.create(Item()..id = 14..name = 'Currying'..price = 14);
        });
      //}
  }

  //creating this in a realm database
  // static List<String> itemNames = [
  //   'Code Smell',
  //   'Control Flow',
  //   'Interpreter',
  //   'Recursion',
  //   'Sprint',
  //   'Heisenbug',
  //   'Spaghetti',
  //   'Hydra Code',
  //   'Off-By-One',
  //   'Scope',
  //   'Callback',
  //   'Closure',
  //   'Automata',
  //   'Bit Shift',
  //   'Currying',
  // ];

  /// Get item by [id].
  ///
  /// In this sample, the catalog is infinite, looping over [itemNames].
  Item getById(int id) // => Item(id, itemNames[id % itemNames.length]);
  {
    //realm objects in the database are not infinte. calculate the real object id
    int objId = id % 14;
   
    var item = realm.find<Item>(objId);
    return item;
  }

  /// Get item by its position in the catalog.
  Item getByPosition(int position) {
    // In this simplified case, an item's position in the catalog
    // is also its id.
    return getById(position);
  }
}


//creating realm object schema
class _Item {
  @RealmProperty(primaryKey: true)
  int id;

  @RealmProperty()
  String name;

  @RealmProperty(defaultValue: '42')
  int price;
}

// @immutable
// class Item {
//   final int id;
//   final String name;
//   final Color color;
//   final int price = 42;

//   Item(this.id, this.name)
//       // To make the sample app look nicer, each item is given one of the
//       // Material Design primary colors.
//       : color = Colors.primaries[id % Colors.primaries.length];

//   @override
//   int get hashCode => id;

//   @override
//   bool operator ==(Object other) => other is Item && other.id == id;
// }
