////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

// @dart=2.10

import 'helpers.dart';

/// @nodoc
class TypeStaticProperties {
  static final _staticProperties = new Map<Type, Map<String, dynamic>>();

  static dynamic getValue(Type type, String name) {
    Map<String, dynamic> properties = _staticProperties[type];
    if (properties == null) {
      return null;
    }

    return properties[name];
  }

  static setValue(Type type, String name, dynamic value) {
    Map<String, dynamic> properties = _staticProperties[type];
    if (properties == null) {
      properties = new Map<String, dynamic>();
      _staticProperties[type] = properties;
    }

    properties[name] = value;
  }
}

/// An object that supports dynamicly created properties at runtime
class DynamicObject {
  DynamicObject();

  final _properties = new Map<String, Object>();

  dynamic operator [](String name) {
    return _properties[name];
  }

  void operator []=(String name, dynamic value) {
    _properties[name] = value;
  }

  List<String> get propertyNames {
    var result = new List<String>();
    result.addAll(_properties.keys);
    return result;
  }

  @override
  noSuchMethod(Invocation invocation) {
    if (!invocation.isAccessor) {
      return super.noSuchMethod(invocation);
    }

    //final realName = invocation.memberName.toString();
    String name = invocation.memberName.name;
    name = name.endsWith('=') ? name.substring(0, name.length - 1) : name;
    if (invocation.isSetter) {
      //final name = realName.substring(8, realName.length - 3);
      dynamic value = invocation.positionalArguments.first;
      _properties[name] = value;
    } else {
      return _properties[name];
    }
  }
}

// class SchemaDynamicObject {
//   SchemaDynamicObject(Map<String, dynamic> map) {}

//   dynamic operator [](String name) {
//     return this[name];
//   }

//   void operator []=(String name, dynamic value) {
//     this[name] = value;
//   }

//   final _properties = new Map<String, Object>();

//   @override
//   noSuchMethod(Invocation invocation) {
//     print("dynamic object noSuchMethod invoked");
//     if (invocation.isAccessor) {
//       final realName = invocation.memberName.toString();
//       if (invocation.isSetter) {
//         final name = realName.substring(8, realName.length - 3);
//         _properties[name] = invocation.positionalArguments.first;
//         return;
//       } else {
//         return _properties[realName];
//       }
//     }

//     return super.noSuchMethod(invocation);
//   }
// }
