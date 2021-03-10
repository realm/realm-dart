cmake_minimum_required(VERSION 3.15)

project(realm-dart-extension-main)

message ("Realm Dart Extension")
message ("CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")
message ("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_CXX_EXTENSIONS off)

set(REALM_PLATFORM "Node")

set(_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING=1)

add_subdirectory(src/realm-dart-extension)
