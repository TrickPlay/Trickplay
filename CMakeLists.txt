
cmake_minimum_required( VERSION 2.6 )

project( TP )

#------------------------------------------------------------------------------

if(CMAKE_TOOLCHAIN_FILE)

    set(PREFIX $ENV{PREFIX})

    if (PREFIX)
    
        set( CMAKE_INSTALL_PREFIX ${PREFIX} )
        
    endif(PREFIX)
    
    unset(PREFIX)
      
else(CMAKE_TOOLCHAIN_FILE)

    set( CMAKE_FIND_ROOT_PATH /opt/local /usr/local /usr)

endif(CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------
# For now, enable both

set( TP_CONTROLLER_DISCOVERY_MDNS 1 )
set( TP_CONTROLLER_DISCOVERY_UPNP 1 )

set( TP_UPNP_CLIENT 1 )

#------------------------------------------------------------------------------

include(util.cmake)

#------------------------------------------------------------------------------
# Read our version from trickplay.h

file(STRINGS engine/public/include/trickplay/trickplay.h TP_MAJOR_VERSION REGEX "^#define.*TP_MAJOR_VERSION.*")
file(STRINGS engine/public/include/trickplay/trickplay.h TP_MINOR_VERSION REGEX "^#define.*TP_MINOR_VERSION.*")
file(STRINGS engine/public/include/trickplay/trickplay.h TP_PATCH_VERSION REGEX "^#define.*TP_PATCH_VERSION.*")

string(REGEX REPLACE "^#define.*TP_MAJOR_VERSION[^0-9]*([0-9]+)[^0-9]*" "\\1" TP_MAJOR_VERSION "${TP_MAJOR_VERSION}")
string(REGEX REPLACE "^#define.*TP_MINOR_VERSION[^0-9]*([0-9]+)[^0-9]*" "\\1" TP_MINOR_VERSION "${TP_MINOR_VERSION}")
string(REGEX REPLACE "^#define.*TP_PATCH_VERSION[^0-9]*([0-9]+)[^0-9]*" "\\1" TP_PATCH_VERSION "${TP_PATCH_VERSION}")

set(TP_VERSION "${TP_MAJOR_VERSION}.${TP_MINOR_VERSION}.${TP_PATCH_VERSION}")

message( STATUS "TRICKPLAY VERSION IS ${TP_VERSION}" )

#------------------------------------------------------------------------------
# When building with a toolchain, it is implied that we will only build
# the engine library and not the executables

if (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )
    
else (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )

    add_subdirectory( clients/desktop )

    add_subdirectory( clients/clutter-mediaplayer )
    
    add_subdirectory( sdk )
    
endif (CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------
# Docs, you have to tell us where the NaturalDocs script is, like this:
# cmake -DNATURAL_DOCS=/path/to/NaturalDocs

add_subdirectory( engine/docs )



