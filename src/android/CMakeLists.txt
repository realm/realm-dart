set(SOURCES
     platform.cpp
)

set(HEADERS
    platform.h
)

add_library(realm_flutter_android STATIC ${SOURCES} ${HEADERS})