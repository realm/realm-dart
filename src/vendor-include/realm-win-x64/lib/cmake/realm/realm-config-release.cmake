#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Realm::Core" for configuration "Release"
set_property(TARGET Realm::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Realm::Core PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/realm.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS Realm::Core )
list(APPEND _IMPORT_CHECK_FILES_FOR_Realm::Core "${_IMPORT_PREFIX}/lib/realm.lib" )

# Import target "Realm::QueryParser" for configuration "Release"
set_property(TARGET Realm::QueryParser APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Realm::QueryParser PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/realm-parser.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS Realm::QueryParser )
list(APPEND _IMPORT_CHECK_FILES_FOR_Realm::QueryParser "${_IMPORT_PREFIX}/lib/realm-parser.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
