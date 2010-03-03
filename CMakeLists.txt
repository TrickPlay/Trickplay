
cmake_minimum_required( VERSION 2.6 )

project( TP )

#------------------------------------------------------------------------------

if(CMAKE_TOOLCHAIN_FILE)
   
else(CMAKE_TOOLCHAIN_FILE)

    set( CMAKE_FIND_ROOT_PATH /opt/local /usr/local /usr)

endif(CMAKE_TOOLCHAIN_FILE)

#------------------------------------------------------------------------------

include(util.cmake)


add_subdirectory( clients/desktop )

#add_subdirectory( clients/lirc )

#add_subdirectory( clients/clutter-mediaplayer )

add_subdirectory( engine )

add_subdirectory( engine/docs )