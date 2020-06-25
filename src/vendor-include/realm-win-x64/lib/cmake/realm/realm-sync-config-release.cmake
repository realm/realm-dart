#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Sync" for configuration "Release"
set_property(TARGET Sync APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Sync PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/realm-sync.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS Sync )
list(APPEND _IMPORT_CHECK_FILES_FOR_Sync "${_IMPORT_PREFIX}/lib/realm-sync.lib" )

# Import target "SyncServer" for configuration "Release"
set_property(TARGET SyncServer APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SyncServer PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/realm-server.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS SyncServer )
list(APPEND _IMPORT_CHECK_FILES_FOR_SyncServer "${_IMPORT_PREFIX}/lib/realm-server.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
