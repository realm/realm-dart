add_library(dart-dl OBJECT
    dart_api_dl.c
    dart_api_dl.h
    dart_api.h
    dart_native_api.h
    dart_version.h
    internal/dart_api_dl_impl.h
)

target_include_directories(dart-dl PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/internal
)
