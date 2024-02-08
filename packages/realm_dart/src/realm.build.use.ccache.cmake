message("Searching for ccache")
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    message("ccache found: ${CCACHE_PROGRAM}")
    # Set up wrapper scripts
    set(C_LAUNCHER   "${CCACHE_PROGRAM}")
    set(CXX_LAUNCHER "${CCACHE_PROGRAM}")
    configure_file("${CMAKE_SOURCE_DIR}/scripts/launch-c.in" "${CMAKE_BINARY_DIR}/launch-c")
    configure_file("${CMAKE_SOURCE_DIR}/scripts/launch-cxx.in" "${CMAKE_BINARY_DIR}/launch-cxx")
    execute_process(COMMAND chmod a+rx
                    "${CMAKE_BINARY_DIR}/launch-c"
                    "${CMAKE_BINARY_DIR}/launch-cxx"
    )

    if(CMAKE_GENERATOR STREQUAL "Xcode")
        # Set Xcode project attributes to route compilation and linking
        # through our scripts
        set(CMAKE_XCODE_ATTRIBUTE_CC         "${CMAKE_BINARY_DIR}/launch-c")
        set(CMAKE_XCODE_ATTRIBUTE_CXX        "${CMAKE_BINARY_DIR}/launch-cxx")
        set(CMAKE_XCODE_ATTRIBUTE_LD         "${CMAKE_BINARY_DIR}/launch-c")
        set(CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${CMAKE_BINARY_DIR}/launch-cxx")
    else()
        # Support Unix Makefiles and Ninja
        set(CMAKE_C_COMPILER_LAUNCHER   "${CMAKE_BINARY_DIR}/launch-c")
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CMAKE_BINARY_DIR}/launch-cxx")
    endif()
else()
    message(WARNING "ccache was not found")
endif()
