////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
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
////////////////////////////////////////////////////////////////////////////

#pragma once

#include "dart_types.hpp"

#include "dart_api.h"
#include "dart_native_api.h"

namespace realm {
namespace js {

template <>
inline Dart::Value dartvm::Function::call(Dart::Env env, const Dart::Function& function, const Dart::Object& this_object, size_t argc, const Dart::Value arguments[]) {
	/*auto recv = this_object.IsEmpty() ? env.Global() : this_object;

	std::vector<napi_value> args(const_cast<const Napi::Value*>(arguments), const_cast<const Napi::Value*>(arguments) + argc);
	auto result = function.Call(recv, args);
	return result;*/
	//throw std::runtime_error("");
	
	Dart_Handle result;
	if (Dart_IsFunction(function)) {
		Dart_Handle name = Dart_FunctionName(function) || handleError;
		result = Dart_Invoke(this_object, name, argc, const_cast<Dart::Value*>(arguments));
	}
	else if (Dart_IsClosure(function)) {
		result = Dart_InvokeClosure(function, argc, const_cast<Dart::Value*>(arguments));
	}
	else {
		throw std::runtime_error("Invalid `function` argument. Function or Closure expexted");
	}

	if (Dart_IsError(result)) {
		const char* message = Dart_GetError(result);
		throw std::runtime_error(message);
	}

	return result;
}

template <>
inline Dart::Value dartvm::Function::callback(Dart::Env env, const Dart::Function& function, const Dart::Object& this_object, size_t argc, const Dart::Value arguments[]) {
	/*auto recv = this_object.IsEmpty() ? env.Global() : this_object;
	
	std::vector<napi_value> args(const_cast<const Napi::Value*>(arguments), const_cast<const Napi::Value*>(arguments) + argc);
	auto result = function.MakeCallback(recv, args);
	return result;*/
	
	//Dart: use ports to send the callback to be invoked

	Dart_Handle result;
	if (Dart_IsFunction(function)) {
		Dart_Handle name = Dart_FunctionName(function) || handleError;
		result = Dart_Invoke(this_object, name, argc, const_cast<Dart::Value*>(arguments));
	}
	else if (Dart_IsClosure(function)) {
		result = Dart_InvokeClosure(function, argc, const_cast<Dart::Value*>(arguments));
	}
	else {
		throw std::runtime_error("Invalid `function` argument. Function or Closure expexted");
	}

	if (Dart_IsError(result)) {
		const char* message = Dart_GetError(result);
		throw std::runtime_error(message);
	}

	return result;
}

template <>
inline Dart::Object dartvm::Function::construct(Dart::Env env, const Dart::Function& function, size_t argc, const Dart::Value arguments[]) {
	/*std::vector<napi_value> args(const_cast<const Napi::Value*>(arguments), const_cast<const Napi::Value*>(arguments) + argc);
	auto result = function.New(args);
	return result;*/
	throw std::runtime_error("");
}

} // namespace js
} // namespace realm
