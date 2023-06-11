cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "realm")

project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "realm_plugin")

#make cmake output visible in build log file
set(CMAKE_VERBOSE_MAKEFILE TRUE CACHE BOOL "" FORCE)

add_library(${PLUGIN_NAME} SHARED "realm_plugin.cpp")

# print cmake variables
#function(print_directory_variables dir)
#    # Dump variables:
#    get_property(_variableNames DIRECTORY ${dir} PROPERTY VARIABLES)
#    list (SORT _variableNames)
#    foreach (_variableName ${_variableNames})
#        get_directory_property(_variableValue DIRECTORY ${dir} DEFINITION ${_variableName})
#        message(STATUS "DIR ${dir}: ${_variableName}=${_variableValue}")
#    endforeach()
#endfunction(print_directory_variables)
#
#print_directory_variables(.)