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

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <exception>

#include "dart_api.h"
#include "dart_native_api.h"

#include "dart_init.hpp"

#ifdef FLUTTER
#include "realm_flutter.h"
#endif

Dart_NativeFunction ResolveName(Dart_Handle name, int argc,	bool* auto_setup_scope);
static Dart_PersistentHandle library;

DART_EXPORT Dart_Handle realm_dart_extension_Init(Dart_Handle realm_library) {
	if (Dart_IsError(realm_library)) {
		return realm_library;
	}


	////    print loaded libs
	//auto libs = Dart_GetLoadedLibraries();
	//intptr_t len;
	//Dart_ListLength(libs, &len);
	//for (size_t i = 0; i < len; i++)
	//{
	//	auto lib = Dart_ListGetAt(libs, i);
	//	auto name = Dart_LibraryResolvedUrl(lib);
	//	const char* nameStr;
	//	Dart_StringToCString(name, &nameStr);
	//	printf("%s \n", nameStr);
	//  //print on android
	//	//__android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary num:%d  name: %s", i, nameStr);
	//}

	
	try {
		realm::dartvm::dart_init(Dart_CurrentIsolate(), realm_library);

		library = Dart_NewPersistentHandle(realm_library);

		return Dart_Null();
	}
	catch (std::exception & e) {
		return Dart_NewCompilationError(e.what());
	}
}

Dart_Handle HandleError(Dart_Handle handle) {
	if (Dart_IsError(handle)) {
		Dart_PropagateError(handle);
	}
	return handle;
}