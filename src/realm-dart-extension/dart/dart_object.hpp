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

#pragma once

#include <cmath>

#include "dart_types.hpp"

namespace realm {
namespace js {

template<>
inline Dart::Value dartvm::Object::get_property(Dart::Env env, const Dart::Object& object, StringData key) {
	//usins Dart_GetField directly returns the getter property value
	//https://github.com/dart-lang/sdk/blob/14dfa1b9eed07524b44b841bf1fe46f38b4ad271/runtime/vm/dart_api_impl_test.cc#L4100

	const char* str = key.data();
	Dart::Value result = Dart_GetField(object, Dart_NewStringFromCString(str));
	if (Dart_IsError(result)) {
		const char* err = Dart_GetError(result);
		throw dartvm::Exception(env, err);
	}

	return result;


	/*try {
		return object.Get(key);
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/
}

inline Dart::Value get_dynamic_static_property(Dart::Env env, const Dart::Object& object, const dartvm::String& key) {
	if (!Dart_IsType(object)) {
		throw std::runtime_error("Invalid argument `object` is not a Dart `Type` object");
	}

	std::string str = key;
	Dart_Handle args[2] = { object, Dart_NewStringFromCString(str.c_str()) };
	
	//Dart: throw a c++ exception here instead of handleError to be catched and thrown as Dart Error where appropriate
	Dart::Value result = Dart_Invoke(dartvm::RealmTypeStaticPropertiesType, Dart_NewStringFromCString("getValue"), 2, args) || handleError; 
	return result;
}

template<>
inline Dart::Value dartvm::Object::get_property(Dart::Env env, const Dart::Object& object, const dartvm::String& key) {
	std::string str = key;

	if (Dart_IsType(object)) {
		Dart_Handle staticPropertyValue = get_dynamic_static_property(env, object, key);
		if (Dart_IsError(object)) {
			auto err = Dart_GetError(staticPropertyValue);
			throw std::runtime_error(err);
		}

		if (!Dart_IsNull(staticPropertyValue)) {
			return staticPropertyValue;
		}
	}

	Dart::Value result = Dart_GetField(object, Dart_NewStringFromCString(str.c_str()));
	if (Dart_IsError(result)) {
		auto err = Dart_GetError(result);
		return Dart_Null();
		
		//Dart: handle error correctly. Probably by Dart_PropagateError
		/*Dart_Handle HandleError(Dart_Handle handle) {
			if (Dart_IsError(handle)) {
				Dart_PropagateError(handle);
			}
			return handle;
		}*/

		/*const char* err = Dart_GetError(result);
		throw dartvm::Exception(env, err);*/
	}

	return result;


	/*try {
		return object.Get(key);
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/

}

template<>
inline Dart::Value dartvm::Object::get_property(Dart::Env env, const Dart::Object& object, uint32_t index) {
	//seems not used. probably used for array (Lists in Dart)
	if (!dartvm::Value::is_array(env, object)) {
		throw std::runtime_error("Invalid argument `object` is not an array");
	}

	auto result = Dart_ListGetAt(object, index) || handleError;
	return result;

	
	/*try {
		return object.Get(index);
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/
}

//This method will not handle creation of new properties as in JS. This is done when attributes are passed in
template<>
inline void dartvm::Object::set_property(Dart::Env env, const Dart::Object& object, const dartvm::String& key, const Dart::Value& value, PropertyAttributes attributes) {

	//Can't create nested types and don't need to support setting Type properties in dart as in
	//static Type myField
	if (Dart_IsType(value)) {
		/*throw std::runtime_error(util::format("Object does not have the required field: %1 and is not inheriting DynamicObjects", keyStr));*/
		return;
	}

	//Dart identifiers use lowercase first char.
	//Dart: maybe actually check if the object has the property name before setting it up. If the name is lowerCamelCase and the key argument is UppderCamelCase use the lowerCamelCase name to set the property
	std::string keyStr = key;
	util::to_lower(keyStr[0]);

	bool isInstance = false;
	if (attributes) {
		auto result = Dart_ObjectIsType(object, dartvm::RealmDynamicObjectType, &isInstance) || handleError;
		if (Dart_IsError(result)) {
			const char* err = Dart_GetError(result);
			throw dartvm::Exception(env, err);
		}

		if (!isInstance) {
			//using getField to check if the object has this field name defined. If there is an error it's considered the field does not exists.
			auto result = Dart_GetField(object, Dart_NewStringFromCString(keyStr.c_str()));
			if (Dart_IsError(result)) {
				throw std::runtime_error(util::format("Object does not have the required field: %1 and is not inheriting DynamicObjects", keyStr));
			}
		}
	}


	/*auto realmClass = Dart_GetClass(dartvm::RealmLibrary, Dart_NewStringFromCString("Realm"));
	if (Dart_IsError(realmClass)) {
		const char* err = Dart_GetError(realmClass);
		throw dartvm::Exception(env, err);
	}

	auto realmClass = Dart_GetClass(dartvm::RealmLibrary, Dart_NewStringFromCString("Realm"));
	if (Dart_IsError(realmClass)) {
		const char* err = Dart_GetError(realmClass);
		throw dartvm::Exception(env, err);
	}*/


	
	auto result = Dart_SetField(object, Dart_NewStringFromCString(keyStr.c_str()), value);
	if (Dart_IsError(result)) {
		const char* err = Dart_GetError(result);
		throw dartvm::Exception(env, err);
	}

	/*try {
		Dart::Object obj = object;
		if (attributes) {
			napi_property_attributes napi_attributes = napi_default | attributes;
			std::string name = key;
			auto propDescriptor = Dart::PropertyDescriptor::Value(name, value, napi_attributes);
			obj.DefineProperty(propDescriptor);
		}
		else {
			obj.Set(key, value);
		}
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/
}

template<>
inline void dartvm::Object::set_property(Dart::Env env, const Dart::Object& object, uint32_t index, const Dart::Value& value) {
	throw std::runtime_error("set property by index is not implemented");

	/*try {
		Dart::Object obj = object;
		obj.Set(index, value);
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/
}

template<>
inline std::vector<dartvm::String> dartvm::Object::get_property_names(Dart::Env env, const Dart::Object& object) {
	bool isInstance = false;
	Dart_ObjectIsType(object, dartvm::RealmDynamicObjectType, &isInstance);
	if (!isInstance) {
		//Dart_Handle args[5] = { object, dartvm::RealmDynamicObjectType, Dart_Null(), Dart_Null(), Dart_Null() };
		//Dart_Invoke(dartvm::RealmLibrary, Dart_NewStringFromCString("_inspect"), 5, args);
		throw std::runtime_error("get_property_names invoked on non dynamic object");
	}

	Dart_Handle propertyNames = Dart_GetField(object, Dart_NewStringFromCString("propertyNames")) || handleError;
	intptr_t length;
	Dart_ListLength(propertyNames, &length) || handleError;
	std::vector<dartvm::String> result;
	result.reserve(length);

	for (size_t i = 0; i < length; i++)
	{
		Dart_Handle property = Dart_ListGetAt(propertyNames, i) || handleError;
		const char* propertyName;
		Dart_StringToCString(property, &propertyName) || handleError;
		result.emplace_back(dartvm::String(propertyName));
	}

	return result;

	
	

	/*try {
		auto propertyNames = object.GetPropertyNames();

		uint32_t count = propertyNames.Length();
		std::vector<dartvm::String> names;
		names.reserve(count);

		for (uint32_t i = 0; i < count; i++) {
			names.push_back(dartvm::Value::to_string(env, propertyNames[i]));
		}

		return names;
	}
	catch (const Dart::Error& e) {
		throw dartvm::Exception(env, e.Message());
	}*/
}

template<>
inline Dart::Value dartvm::Object::get_prototype(Dart::Env env, const Dart::Object& object) {
	throw std::runtime_error("dartvm::Object::get_prototype not supported");
	/*napi_value result;
	napi_status status = napi_get_prototype(env, object, &result);
	if (status != napi_ok) {
		throw dartvm::Exception(env, "Failed to get object's prototype");
	}
	return Dart::Object(env, result);*/
}

template<>
inline void dartvm::Object::set_prototype(Dart::Env env, const Dart::Object& object, const Dart::Value& prototype) {
	throw std::runtime_error("dartvm::Object::set_prototype not supported");

	/*auto setPrototypeOfFunc = env.Global().Get("Object").As<Dart::Object>().Get("setPrototypeOf").As<Dart::Function>();
	if (setPrototypeOfFunc.IsEmpty() || setPrototypeOfFunc.IsUndefined()) {
		throw std::runtime_error("no 'setPrototypeOf'");
	}

	setPrototypeOfFunc.Call({ object, prototype });*/
}

template<>
inline Dart::Object dartvm::Object::create_empty(Dart::Env env) {
	Dart_Handle object = Dart_New(dartvm::RealmDynamicObjectType, Dart_Null(), 0, nullptr) || handleError;
	return object;
}

template<>
inline Dart::Object dartvm::Object::create_array(Dart::Env env, uint32_t length, const Dart::Value values[]) {
	Dart::Value array = Dart_NewList(length) || handleError;
	for (uint32_t i = 0; i < length; i++) {
		Dart::Value result = Dart_ListSetAt(array, i, values[i]) || handleError;
		if (Dart_IsError(result)) {
			const char* err = Dart_GetError(result);
			throw dartvm::Exception(env, err);
		}
	}
	return array;

	/*Dart::Array array = Dart::Array::New(env, length);
    for (uint32_t i = 0; i < length; i++) {
        set_property(env, array, i, values[i]);
    }
    return array;*/
}

template<>
inline Dart::Object dartvm::Object::create_date(Dart::Env env, double time) {
	Dart_Handle dateTimeArgs[1] = { Dart_NewInteger(std::round(time)) };
	return Dart_Invoke(dartvm::RealmHelpersType, Dart_NewStringFromCString("createDateTime"), 1, dateTimeArgs) || handleError;

}

template<>
template<typename ClassType>
inline Dart::Object dartvm::Object::create_instance(Dart::Env env, typename ClassType::Internal* internal) {
	return dartvm::ObjectWrap<ClassType>::create_instance(env, internal);
}

template<>
template<typename ClassType>
inline Dart::Object dartvm::Object::create_instance_by_schema(Dart::Env env, Dart::Function& constructor, const realm::ObjectSchema& schema, typename ClassType::Internal* internal) {
	return dartvm::ObjectWrap<ClassType>::create_instance(env, internal, constructor);
}

template<typename ClassType>
inline void on_context_destroy(Dart::Env env, std::string realmPath) {
	dartvm::ObjectWrap<ClassType>::on_context_destroy(env, realmPath);
}

template<>
template<typename ClassType>
inline bool dartvm::Object::is_instance(Dart::Env env, const Dart::Object& object) {
    return dartvm::ObjectWrap<ClassType>::is_instance(env, object);
}

template<>
template<typename ClassType>
inline typename ClassType::Internal* dartvm::Object::get_internal(Dart::Env env, const Dart::Object& object) {
	return dartvm::ObjectWrap<ClassType>::get_internal(env, object);
}

template<>
template<typename ClassType>
inline void dartvm::Object::set_internal(Dart::Env env, const Dart::Object& object, typename ClassType::Internal* internal) {
	return dartvm::ObjectWrap<ClassType>::set_internal(env, object, internal);
}

template<>
inline void dartvm::Object::set_global(Dart::Env env, const dartvm::String &key, const Dart::Value &value) {
	//set global is not needed in Realm Dart
}

template<>
inline Dart::Value dartvm::Object::get_global(Dart::Env env, const dartvm::String &key) {
	//set global is not needed in Realm Dart
	throw std::runtime_error("Not supported");
}

} // js
} // realm

