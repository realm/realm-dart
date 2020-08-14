
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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