# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "realm")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "realm_plugin")

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
#
# Any new source files that you add to the plugin should be added here.
add_library(${PLUGIN_NAME} SHARED
  "realm_plugin.cpp"
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(realm_bundled_libraries
  "${PROJECT_SOURCE_DIR}/binary/linux/librealm_dart.so"
  PARENT_SCOPE
)

# message ("CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")
# message ("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")
# message ("CMAKE_CURRENT_SOURCE_DIR is ${CMAKE_CURRENT_SOURCE_DIR}")

# This works cause realm plugin is always accessed through the .plugin_symlinks directory.
set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../ephemeral")
include(${EPHEMERAL_DIR}/generated_config.cmake)

# message ("FLUTTER_TOOL_ENVIRONMENT is ${FLUTTER_TOOL_ENVIRONMENT}")
# message ("FLUTTER_ROOT is ${FLUTTER_ROOT}")

execute_process(COMMAND "${FLUTTER_ROOT}/bin/flutter" "pub" "run" "realm" "install" "--target-os-type" "linux" "--package-name" "realm" #"--debug"
  OUTPUT_VARIABLE output
  RESULT_VARIABLE result
  COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "cmd output: ${output}")
message(STATUS "cmd result: ${result}")

# message("CMAKE_HOST_SYSTEM_VERSION ${CMAKE_HOST_SYSTEM_VERSION}")
execute_process(
  COMMAND "${FLUTTER_ROOT}/bin/flutter" "pub" "run" "realm" "metrics" "--verbose" "--flutter-root" "${FLUTTER_ROOT}/bin" "--target-os-type" "linux" "--target-os-version" "${CMAKE_HOST_SYSTEM_VERSION}" #"--pause-isolates-on-start" "--enable-vm-service"
  # COMMAND ${CMAKE_COMMAND} -E true
  OUTPUT_VARIABLE output
  RESULT_VARIABLE result
  # COMMAND_ERROR_IS_FATAL LAST
)
message(STATUS "cmd output: ${output}")
message(STATUS "cmd result: ${result}")
