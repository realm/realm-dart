cmake_minimum_required(VERSION 3.21)

if(CMAKE_SYSTEM_NAME STREQUAL Android)
    message("Realm Flutter Android build enabled")
    set(REALM_ANDROID ON)
    set(CMAKE_ANDROID_STL_TYPE c++_static)
    set(ANDROID_ALLOW_UNDEFINED_SYMBOLS ON)
endif()

project(realm-dart)

if("$ENV{REALM_USE_CCACHE}" STREQUAL "TRUE")
    message("REALM_USE_CCACHE is TRUE. Will try a build with ccache")
    include(src/realm.build.use.ccache.cmake)
endif()

message ("Realm Dart")
message ("CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")
message ("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_CXX_EXTENSIONS off)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

set(_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING=1)

add_subdirectory(src)