set(SOURCES
     realm_dart.cpp
)

set(HEADERS
    realm-core/src/realm.h
)

if(NOT CMAKE_SYSTEM_NAME STREQUAL iOS)
    add_library(realm_dart SHARED ${SOURCES} ${HEADERS})
    set_target_properties(realm_dart PROPERTIES POSITION_INDEPENDENT_CODE 1)
else() #iOS
    # building a static library for iOS
    add_library(realm_dart STATIC ${SOURCES} ${HEADERS})
    set(CMAKE_SYSTEM_NAME iOS)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

    set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)
    #set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Release] NO)

    # set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/vendor/realm-core/tools/cmake/macosx.toolchain.cmake")

    # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
endif()

# target_include_directories(realm_dart_extension PUBLIC ${DART_INCLUDE_DIR} ${HEADERS}, ${INCLUDE_DIRS})

# target_compile_definitions(realm_dart_extension PUBLIC -DDART_SHARED_LIB)

# if(CMAKE_SYSTEM_NAME MATCHES "^Windows")    
#     if (CMAKE_CONFIGURATION_TYPES MATCHES "Debug") 
#         set (BUILD_SUFFIX "-dbg") 
#     endif()

#     set (LINK_LIBS
#         "${PROJECT_SOURCE_DIR}/../dart-include/lib/windows-x64/dart.lib"
#         "${PROJECT_SOURCE_DIR}/../vendor-include/realm-win-x64/lib/object-store${BUILD_SUFFIX}.lib"
#         "${PROJECT_SOURCE_DIR}/../vendor-include/realm-win-x64/lib/realm${BUILD_SUFFIX}.lib"
#         "${PROJECT_SOURCE_DIR}/../vendor-include/realm-win-x64/lib/realm-parser${BUILD_SUFFIX}.lib"
#     )
# endif()

# if(APPLE)    
#     set (LINK_LIBS
#         "${PROJECT_SOURCE_DIR}/../vendor-include/macos/object-store.a"
#         "${PROJECT_SOURCE_DIR}/../vendor-include/macos/librealm-parser.a"
#         "${PROJECT_SOURCE_DIR}/../vendor-include/macos/librealm.a"
#     )
# endif()

# message("LINK_LIBS is ${LINK_LIBS}")

# target_link_libraries(realm_dart_extension ${LINK_LIBS})

# set_property(TARGET realm_dart_extension PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# if(CMAKE_SYSTEM_NAME MATCHES "^Windows")
#     #copy the dll to the lib directory
#     add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm_dart_extension.dll"  ${PROJECT_SOURCE_DIR}../../../lib/realm_dart_extension.dll)
#     if (CMAKE_CONFIGURATION_TYPES MATCHES "Debug") 
#         add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm_dart_extension.pdb"  ${PROJECT_SOURCE_DIR}../../../lib/realm_dart_extension.pdb)
#     endif()

#     #copy the dll to the root directory of realm-dart so VS Code dart test runner can run and debug the tests.
#     add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm_dart_extension.dll"  ${PROJECT_SOURCE_DIR}../../../realm_dart_extension.dll)

#     #copy the dll to the test directory of realm-dart so VS Code dart debug test runner can run and debug the tests. If the dll is not besides the tests then the library is not loaded correctly and the cached RealmLib types are not the same. Dart: investigate this
#     add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm_dart_extension.dll"  ${PROJECT_SOURCE_DIR}../../../test/realm_dart_extension.dll)


#     if (CMAKE_CONFIGURATION_TYPES MATCHES "Release") 
#         #copy the Release dll to the bin directory of realm-dart so it gets into the realm_dart package
#         add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm_dart_extension.dll"  ${PROJECT_SOURCE_DIR}../../../bin/realm_dart_extension.dll)
#     endif()
# endif()

# if(APPLE)
#     #copy the dylib to the bin directory of realm-dart so it gets into the realm_dart package
#     add_custom_command(TARGET realm_dart_extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/librealm_dart_extension.dylib"  ${PROJECT_SOURCE_DIR}../../../bin/librealm_dart_extension.dylib)
# endif()

option(REALM_BUILD_CORE_FROM_SOURCE "Build Realm Core from source" ON)
if(REALM_BUILD_CORE_FROM_SOURCE)
    set(REALM_BUILD_LIB_ONLY ON)
    set(REALM_ENABLE_SYNC OFF)

    if(ANDROID)
        message ("Realm Flutter Androd build enabled")
        set(REALM_ANDROID ON)
    endif()

    add_subdirectory(realm-core EXCLUDE_FROM_ALL)
endif()

target_compile_definitions(RealmFFIStatic PUBLIC -DRealm_EXPORTS)

target_link_libraries(realm_dart RealmFFIStatic)

set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary")
if(ANDROID)
    #core requires these options for the final *.so file. See more realm-core/CMakeLists.txt
    add_compile_options(-Wl,-gc-sections)

    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary/android/${ANDROID_ABI}")

    if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
        message("Stripping enabled for Release or MinSizeRel builds")
        add_custom_command(TARGET realm_dart
        POST_BUILD
        COMMAND ${CMAKE_STRIP} $<TARGET_FILE:realm_dart>)
    endif()
endif()


string(APPEND OUTPUT_DIR "${PROJECT_SOURCE_DIR}/binary")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    string(APPEND OUTPUT_DIR "/windows")
endif()

# using RUNTIME_OUTPUT_DIRECTORY_<CONFIG> to output the binaries in the target directory wihtout creating a sub directory
# for multi-configuration generators (VS, XCode)
# https://cmake.org/cmake/help/v2.8.8/cmake.html#prop_tgt:RUNTIME_OUTPUT_DIRECTORY
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}")
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}")
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${OUTPUT_DIR}")