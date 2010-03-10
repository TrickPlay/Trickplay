
cmake_minimum_required( VERSION 2.6 )

project( TP )

#------------------------------------------------------------------------------

if(CMAKE_TOOLCHAIN_FILE)
   
else(CMAKE_TOOLCHAIN_FILE)

    set( CMAKE_FIND_ROOT_PATH /opt/local /usr/local /usr)

endif(CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------

include(util.cmake)

#------------------------------------------------------------------------------
# When building with a toolchain, it is implied that we will only build
# the engine library and not the executables

if (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )
    
else (CMAKE_TOOLCHAIN_FILE)

    add_subdirectory( engine )

    add_subdirectory( clients/desktop )

    #add_subdirectory( clients/lirc )

    add_subdirectory( clients/clutter-mediaplayer )
    
endif (CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------
# Docs, you have to tell us where the NaturalDocs script is, like this:
# cmake -DNATURAL_DOCS=/path/to/NaturalDocs

add_subdirectory( engine/docs )


