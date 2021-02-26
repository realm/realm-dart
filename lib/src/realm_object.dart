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

/**
 *  The file is intentionaly not follwoing the dart naming guidelines. The name is used from native code by convention
 */

import 'list.dart';
import 'realm_property.dart';

import 'dynamic_object.dart';

class RealmObject /*extends DynamicObject*/ {
  Map<String, Object> _unmanagedProperties;

  /**
   *  Default constructor. Enables the subclass to different ctors and work with RealmObject unmanaged instances
   */
  RealmObject() {
    _unmanagedProperties = new Map<String, Object>();
  }

  /**
   *  Creates managed RealmObject. Called from generated code
   */
  RealmObject.constructor() {}

  Object get _realm native "RealmObject_get__realm";

  Object _native_get(String name) native "RealmObject_get_property";
  void _native_set(String name, Object value) native "RealmObject_set_property";

  Object operator [](String name) {
    if (_unmanagedProperties != null) {
      return _unmanagedProperties[name];
    }

    Object result = _native_get(name);
    if (result is RealmList) {
      throw new Exception("Invalid RealmObject. RealmLists should be retrieved using super_get method");
    }

    return result;
  }

  void operator []=(String name, Object value) {
    if (_unmanagedProperties != null) {
      _unmanagedProperties[name] = value;
      return;
    }

    _native_set(name, value);
  }

  static dynamic getSchema(String typeName, Iterable<SchemaProperty> properties) {
    if (properties.length == 0) {
        throw new Exception("Class ${typeName} should have at least one field with RealmProperty annotation");
    }

    dynamic schema = DynamicObject();
    schema.name = typeName;
    schema.properties = new DynamicObject();

    for (var realmProperty in properties) {
      dynamic propertyValue = DynamicObject();
      propertyValue.type = realmProperty.type;
      propertyValue['default'] = realmProperty.defaultValue ?? null;
      propertyValue.optional = realmProperty.optional ?? null;
      propertyValue.mapTo = realmProperty.mapTo ?? null;
      schema.properties[realmProperty.propertyName] = propertyValue;
      if (realmProperty.primaryKey ?? false) {
        schema.primaryKey = realmProperty.propertyName;
      }
    }

    return schema;
  }

  Object isValid() native "RealmObject_isValid";
  Object objectSchema() native "RealmObject_objectSchema";
  Object linkingObjects() native "RealmObject_linkingObjects";
  Object linkingObjectsCount() native "RealmObject_linkingObjectsCount";
  Object _objectId() native "RealmObject__objectId";
  Object _isSameObject() native "RealmObject__isSameObject";
  Object _setLink() native "RealmObject__setLink";
  Object addListener() native "RealmObject_addListener";
  Object removeListener() native "RealmObject_removeListener";
  Object removeAllListeners() native "RealmObject_removeAllListeners";
}

extension Super on RealmObject {
  ArrayList<T> super_get<T extends RealmObject>(String name) {
    if (_unmanagedProperties != null) {
      return _unmanagedProperties[name];
    }

    Object result = _native_get(name);
    if (result is RealmList) {
      return new ArrayList<T>.fromRealmList(result);
    }

    return result as ArrayList<T>;
  }

  void super_set<T extends RealmObject>(String name, Iterable<T> value) {
    ArrayList<T> arrayList;
    if (value is ArrayList<T>) {
      arrayList = value;
      return;
    }

    arrayList = new ArrayList(value);

    if (_unmanagedProperties != null) {
      _unmanagedProperties[name] = arrayList;
      return;
    }

    throw new Exception("Setting ArrayList on manged object is not supported");
  }
}
