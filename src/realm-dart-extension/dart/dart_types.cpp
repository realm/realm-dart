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
#pragma clang diagnostic ignored "-Wdocumentation"

#include <cmath>
#include <functional>
#include <map>
#include <string>

#include "dart_api.h"
#include "dart_native_api.h"

#include "js_types.hpp"

#include "dart_types.hpp"

bool ___DartError::use_native_exceptions;

Dart_Handle operator ||(const Dart_Handle& dartResult, ___DartError error) {
	if (Dart_IsError(dartResult)) {
		auto err = Dart_GetError(dartResult);
		//Dart_PropagateError(dartResult);
		if (!___DartError::use_native_exceptions) {
			Dart_ThrowException(dartResult);
		}
		else {
			throw std::runtime_error(err);
		}
		
	}
	return dartResult;
}

namespace realm {
	namespace dartvm {
		namespace flutter {
			std::string FilesDir;
		}

		Dart_Handle DartCoreLibrary;
		Dart_Handle RealmLibrary;
		std::string RealmPackageName;
		Dart_Handle DartDateTimeType;
		
		Dart_Handle RealmCreateDateTimeFunc;
		Dart_Handle RealmDynamicObjectType;
		Dart_Handle RealmTypeStaticPropertiesType;
		Dart_Handle RealmHelpersType;
	}

	namespace util {
		void to_lower(char& c) {
			c = std::tolower(static_cast<unsigned char>(c));
		}

		void to_lowecase(std::string& string)
		{
			std::for_each(string.begin(), string.end(), to_lower);
		}
	}
}

namespace Dart {

	HandleScope::HandleScope() {
		Dart_EnterScope();
	}

	HandleScope::~HandleScope() {
		Dart_ExitScope();
	}

	Dart_Handle GetLibrary(const char* libName) {
		Dart_Handle libraryUrl = Dart_NewStringFromCString(libName) || handleError;
		Dart_Handle library = Dart_LookupLibrary(libraryUrl) || handleError;
		return library;
	}
}

