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

#include "dart_api.h"
#include "dart_native_api.h"

#include <cmath>
#include <functional>
#include <map>
#include <string>

#include "js_types.hpp"
#include "dart_types.hpp"

#define HANDLESCOPE(env) Dart::HandleScope handle_scope;

struct ___DartError {
	static bool use_native_exceptions;
};


#define handleError ___DartError()
extern Dart_Handle operator ||(const Dart_Handle& dartResult, ___DartError error);

namespace Dart {
#define CurrentEnv() nullptr

	using Env = Dart_Isolate;
	using GlobalContext = Dart_Isolate;
	using Value = Dart_Handle;
	using Object = Dart_Handle;
	using String = Dart_Handle;
	using Function = Dart_Handle;

	struct HandleScope {
		HandleScope();

		~HandleScope();

		HandleScope(const HandleScope& other) = delete;
		HandleScope(const HandleScope&& other) = delete;
		HandleScope& operator=(const HandleScope& other) = delete;
		HandleScope& operator=(const HandleScope&& other) = delete;

	};

	Dart_Handle GetLibrary(const char* libName);
}

namespace realm {
	namespace dartvm {
		namespace flutter {
			extern std::string FilesDir;
		}

		extern Dart_Handle DartCoreLibrary;
		extern Dart_Handle RealmLibrary;
		extern std::string RealmPackageName;
		extern Dart_Handle DartDateTimeType;
		extern Dart_Handle RealmDynamicObjectType;
		extern Dart_Handle RealmTypeStaticPropertiesType;
		extern Dart_Handle RealmHelpersType;

		struct Types {
			using Context = Dart::Env;
			using GlobalContext = Dart::Env;
			using Value = Dart::Value;
			using Object = Dart::Object;
			using String = Dart::String;
			using Function = Dart::Function;

			typedef void(*DartFunctionCallback)(Dart_NativeArguments arguments);

			//using ConstructorCallback = DartFunctionCallback;
			using FunctionCallback = DartFunctionCallback;
			using PropertyGetterCallback = DartFunctionCallback;
			using PropertySetterCallback = DartFunctionCallback;
			using IndexPropertyGetterCallback = DartFunctionCallback;
			using IndexPropertySetterCallback = DartFunctionCallback;

			using StringPropertyGetterCallback = DartFunctionCallback;
			using StringPropertySetterCallback = DartFunctionCallback;
			using StringPropertyEnumeratorCallback = DartFunctionCallback;
		};

		template<typename ClassType>
		class ObjectWrap;

		using String = js::String<Types>;
		using Context = js::Context<Types>;
		using Value = js::Value<Types>;
		using Function = js::Function<Types>;
		using Object = js::Object<Types>;
		using Exception = js::Exception<Types>;
		using ReturnValue = js::ReturnValue<Types>;

	} // dartvm

	namespace util {
		void to_lower(char& c);
		void to_lowecase(std::string& string);
	}

} // realm


