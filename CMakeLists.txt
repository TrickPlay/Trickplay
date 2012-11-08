
cmake_minimum_required( VERSION 2.6 )

project( TP )

#------------------------------------------------------------------------------

if(CMAKE_TOOLCHAIN_FILE)

else(CMAKE_TOOLCHAIN_FILE)

    set( CMAKE_FIND_ROOT_PATH /opt/local /usr/local /usr)

endif(CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------
# For now, enable both

set( TP_CONTROLLER_DISCOVERY_MDNS 1 )
set( TP_CONTROLLER_DISCOVERY_UPNP 1 )

set( TP_UPNP_CLIENT 1 )

if(NOT( ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" ))
    set( TP_WITH_WEBGL 1 )
endif(NOT( ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" ))

#------------------------------------------------------------------------------
# enable TP_WITH_GAMESERVICE by default

if (NOT TP_WITH_GAMESERVICE)
    set( TP_WITH_GAMESERVICE 1 )
endif(NOT TP_WITH_GAMESERVICE)

#------------------------------------------------------------------------------

include(util.cmake)

execute_process(
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMAND git log -1 --pretty=format:%h
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_CURRENT_REVISION
)

execute_process(
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMAND git describe --tags --dirty
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_CURRENT_TAG
)

if(NOT GIT_CURRENT_TAG)
    SET(GIT_CURRENT_TAG "no tag")
endif (NOT GIT_CURRENT_TAG)

string(REPLACE "\n" ", " GIT_CURRENT_TAG ${GIT_CURRENT_TAG})
string(REPLACE "#"  "~"  GIT_CURRENT_TAG ${GIT_CURRENT_TAG})

set(GIT_VERSION "${GIT_CURRENT_TAG}")

message( STATUS "TRICKPLAY VERSION IS ${GIT_VERSION}" )

#------------------------------------------------------------------------------
# all warnings
#------------------------------------------------------------------------------

set(CMAKE_CXX_FLAGS "-Wall")

#------------------------------------------------------------------------------
# aggressive optimization
#------------------------------------------------------------------------------

include( CheckCXXCompilerFlag )
CHECK_CXX_COMPILER_FLAG("-O3" OPT3)
if(${OPT3})
    set(CMAKE_CXX_FLAGS_RELEASE "-O3")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3")
endif(${OPT4})

#------------------------------------------------------------------------------
# When building with a toolchain, it is implied that we will only build
# the engine library and not the executables

if (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )

    add_subdirectory( pdk )

else (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )

    add_subdirectory( clients/desktop )

    add_subdirectory( clients/clutter-mediaplayer )

#    add_subdirectory( clients/jpeg-utils-test )

    add_subdirectory( sdk )

endif (CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------
# Docs, you have to tell us where the NaturalDocs script is, like this:
# cmake -DNATURAL_DOCS=/path/to/NaturalDocs

add_subdirectory( engine/docs EXCLUDE_FROM_ALL )

add_subdirectory ( apps EXCLUDE_FROM_ALL )

add_subdirectory( plugins )


