cmake_minimum_required(VERSION 3.19)

if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.14" CACHE STRING "Minimum OS X deployment version")
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