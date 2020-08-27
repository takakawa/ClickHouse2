set (SENTRY_LIBRARY "sentry")
set (SENTRY_INCLUDE_DIR "${ClickHouse_SOURCE_DIR}/contrib/sentry-native/include")
if (NOT EXISTS "${SENTRY_INCLUDE_DIR}/sentry.h")
    message (WARNING "submodule contrib/sentry-native is missing. to fix try run: \n git submodule update --init --recursive")
    if (USE_SENTRY)
         message (${RECONFIGURE_MESSAGE_LEVEL} "Can't find internal sentry library")
    endif()
    return()
endif ()

if (NOT OS_FREEBSD AND NOT SPLIT_SHARED_LIBRARIES AND NOT_UNBUNDLED AND NOT (OS_DARWIN AND COMPILER_CLANG))
    option (USE_SENTRY "Use Sentry" ${ENABLE_LIBRARIES})
    set (SENTRY_TRANSPORT "curl" CACHE STRING "")
    set (SENTRY_BACKEND "none" CACHE STRING "")
    set (SENTRY_EXPORT_SYMBOLS OFF CACHE BOOL "")
    set (SENTRY_LINK_PTHREAD OFF CACHE BOOL "")
    set (SENTRY_PIC OFF CACHE BOOL "")
    set (BUILD_SHARED_LIBS OFF)
    message (STATUS "Using sentry=${USE_SENTRY}: ${SENTRY_LIBRARY}")

    include_directories("${SENTRY_INCLUDE_DIR}")
elseif (USE_SENTRY)
    message (${RECONFIGURE_MESSAGE_LEVEL} "Sentry is not supported in current configuration")
endif ()
