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

#include "dart_types.hpp"

namespace realm {
namespace js {

template<>
inline bool dartvm::Value::is_array(Dart::Env env, const Dart::Value& value) {
	return Dart_IsList(value);
}

template<>
inline bool dartvm::Value::is_array_buffer(Dart::Env env, const Dart::Value& value) {
	//return value.IsArrayBuffer();
	return Dart_IsTypedData(value) || Dart_IsByteBuffer(value);
}

template<>
inline bool dartvm::Value::is_array_buffer_view(Dart::Env env, const Dart::Value& value) {
	//there is such thing as TypedDataView https://github.com/dart-lang/sdk/blob/14dfa1b9eed07524b44b841bf1fe46f38b4ad271/runtime/vm/dart_api_impl_test.cc#L1994

	//return value.IsTypedArray() || value.IsDataView();
	return Dart_IsTypedData(value) || Dart_IsByteBuffer(value);
}

template<>
inline bool dartvm::Value::is_date(Dart::Env env, const Dart::Value& value) {
	bool result;
	Dart_ObjectIsType(value, dartvm::DartDateTimeType, &result) || handleError;
	return result;

	//return value.IsObject() && value.As<Dart::Object>().InstanceOf(env.Global().Get("Date").As<Dart::Function>());
	
	//check if value is instance of DateTime
}

template<>
inline bool dartvm::Value::is_boolean(Dart::Env env, const Dart::Value& value) {
    //return value.IsBoolean();

	return Dart_IsBoolean(value);
}

template<>
inline bool dartvm::Value::is_constructor(Dart::Env env, const Dart::Value& value) {
	//return value.IsFunction();
	
	//use Dart_ObjectIsType to check if value is instanceof Object
	//throw std::runtime_error("");

	//used only to check if either ctor or POJO object was used for the schema.
	//dart will allow only objects so returning false here.
	return Dart_IsType(value);
}

template<>
inline bool dartvm::Value::is_function(Dart::Env env, const Dart::Value& value) {
	//return value.IsFunction();

	//this is used in js_sync and js_adapter only
	bool result = Dart_IsFunction(value) || Dart_IsClosure(value);
	return result;
}

template<>
inline bool dartvm::Value::is_null(Dart::Env env, const Dart::Value& value) {
	return Dart_IsNull(value);
}

template<>
inline bool dartvm::Value::is_number(Dart::Env env, const Dart::Value& value) {
	return Dart_IsNumber(value) || Dart_IsDouble(value) || Dart_IsInteger(value);
}

template<>
inline bool dartvm::Value::is_object(Dart::Env env, const Dart::Value& value) {
	//return value.IsObject();
	//Dart: should Dart_IsInstance be used here as well ?
	return !Dart_IsNumber(value) &&
		!Dart_IsBoolean(value) &&
		!Dart_IsString(value) &&
		!Dart_IsInteger(value) &&
		!Dart_IsDouble(value);
}

template<>
inline bool dartvm::Value::is_string(Dart::Env env, const Dart::Value& value) {
	//return value.IsString();

	return Dart_IsString(value);
}

template<>
inline bool dartvm::Value::is_undefined(Dart::Env env, const Dart::Value& value) {
	//return value.IsUndefined();

	return Dart_IsNull(value);
}

template<>
inline bool dartvm::Value::is_binary(Dart::Env env, const Dart::Value& value) {
	return Value::is_array_buffer(env, value) || Value::is_array_buffer_view(env, value);
}

template<>
inline bool dartvm::Value::is_valid(const Dart::Value& value) {
	//return !value.IsEmpty();

	return value != nullptr;
}

template<>
inline Dart::Value dartvm::Value::from_boolean(Dart::Env env, bool boolean) {
	//return Dart::Boolean::New(env, boolean);
	return Dart_NewBoolean(boolean);
}


template<>
inline Dart::Value dartvm::Value::from_null(Dart::Env env) {
	//return Dart::Value(env, env.Null());

	return Dart_Null();
}

template<>
inline Dart::Value dartvm::Value::from_number(Dart::Env env, int64_t number) {
	//return Dart::Number::New(env, number);

	return Dart_NewInteger(number);
}

template<>
inline Dart::Value dartvm::Value::from_number(Dart::Env env, double number) {
	//return Dart::Number::New(env, number);

	return Dart_NewDouble(number);
}

template<>
inline Dart::Value dartvm::Value::from_nonnull_string(Dart::Env env, const dartvm::String& string) {
	//return Dart::String::New(env, string);
	std::string str = string;
	return Dart_NewStringFromCString(str.c_str());
}

template<>
inline Dart::Value dartvm::Value::from_nonnull_binary(Dart::Env env, BinaryData data) {
	/*Dart::EscapableHandleScope scope(env);

	Dart::ArrayBuffer buffer = Dart::ArrayBuffer::New(env, data.size());

	if (data.size()) {
		memcpy(buffer.Data(), data.data(), data.size());
	}

	return scope.Escape(buffer);*/

	throw std::runtime_error("");
}

template<>
inline Dart::Value dartvm::Value::from_undefined(Dart::Env env) {
	//return Dart::Value(env, env.Undefined());

	return Dart_Null();
}

template<>
inline bool dartvm::Value::to_boolean(Dart::Env env, const Dart::Value& value) {
	//return value.ToBoolean();

	bool result;
	Dart_BooleanValue(value, &result);
	return result;
}

template<>
inline dartvm::String dartvm::Value::to_string(Dart::Env env, const Dart::Value& value) {
	//return value.ToString();

	const char* str;
	Dart_StringToCString(value, &str);
	return dartvm::String(str);
}

template<>
inline double dartvm::Value::to_number(Dart::Env env, const Dart::Value& value) {
	/*double number = value.ToNumber();
	if (std::isnan(number)) {
		throw std::invalid_argument(util::format("Value '%1' not convertible to a number.", (std::string)to_string(env, value)));
	}
	
	return number;*/
	if (Dart_IsInteger(value)) {
		int64_t result;
		Dart_IntegerToInt64(value, &result) || handleError;
		return result;
	}

	if (Dart_IsDouble(value)) {
		double result;
		Dart_DoubleValue(value, &result) || handleError;
		return result;
	}

	throw std::runtime_error("Invalid argument `value`. A number expected");
}

template<>
inline OwnedBinaryData dartvm::Value::to_binary(Dart::Env env, const Dart::Value value) {
	//// Make a non-null OwnedBinaryData, even when `data` is nullptr.
	//auto make_owned_binary_data = [](const char* data, size_t length) {
	//	REALM_ASSERT(data || length == 0);
	//	char placeholder;
	//	return OwnedBinaryData(data ? data : &placeholder, length);
	//};

	//if (Value::is_array_buffer(env, value)) {
	//	auto arrayBuffer = value.As<Dart::ArrayBuffer>();
	//	return make_owned_binary_data(static_cast<char*>(arrayBuffer.Data()), arrayBuffer.ByteLength());
	//}
	//else if (Value::is_array_buffer_view(env, value)) {
	//	int64_t byteLength = value.As<Dart::Object>().Get("byteLength").As<Dart::Number>();
	//	int64_t byteOffset = value.As<Dart::Object>().Get("byteOffset").As<Dart::Number>();
	//	Dart::ArrayBuffer arrayBuffer = value.As<Dart::Object>().Get("buffer").As<Dart::ArrayBuffer>();
	//	return make_owned_binary_data(static_cast<char*>(arrayBuffer.Data()) + byteOffset, byteLength);
	//}
	//else {
	//	throw std::runtime_error("Can only convert Buffer, ArrayBuffer, and ArrayBufferView objects to binary");
	//}

	throw std::runtime_error("");
}

template<>
inline Dart::Object dartvm::Value::to_object(Dart::Env env, const Dart::Value& value) {
	//return value.ToObject();
	
	//used in NativeAccessor print.

	if (Value::is_object(env, value)) {
		return value;
	}
	
	return Dart_ToString(value);
}

template<>
inline Dart::Object dartvm::Value::to_array(Dart::Env env, const Dart::Value& value) {
	//return to_object(env, value);

	if (Value::is_array(env, value)) {
		return value;
	}

	throw std::runtime_error("value is not an array");
}

template<>
inline Dart::Function dartvm::Value::to_function(Dart::Env env, const Dart::Value& value) {
	//return value.IsFunction() ? value.As<Dart::Function>() : Dart::Function();
	
	if (Value::is_function(env, value)) {
		return value;
	}

	throw std::runtime_error("value is not an function");
}

template<>
inline Dart::Function dartvm::Value::to_constructor(Dart::Env env, const Dart::Value& value) {
	//return to_function(env, value);

	//Realm Dart does not support using constructors for the schema
	if (Value::is_constructor(env, value)) {
		return value;
	}

	throw std::runtime_error("Invalid argument `value` is not a constructor");
}

template<>
inline Dart::Object dartvm::Value::to_date(Dart::Env env, const Dart::Value& value) {
	/*if (value.IsString()) {
		Dart::Function date_constructor = to_constructor(env, env.Global().Get("Date"));
		std::array<Dart::Value, 1 > args{ {value} };
		return dartvm::Function::construct(env, date_constructor, args.size(), args.data());
	}

	return to_object(env, value);*/


	//create new DateTime object and return it

	throw std::runtime_error("not implemented");
}

template<>
inline const char* dartvm::Value::typeof(Dart::Env env, const Dart::Value& value) {
	if (Value::is_null(env, value)) { return "null"; }
	if (Value::is_number(env, value)) { return "number"; }
	if (Value::is_string(env, value)) { return "string"; }
	if (Value::is_boolean(env, value)) { return "boolean"; }
	if (Value::is_object(env, value)) { return "object"; }
	return "unknown";
}

} // js
} // realm
