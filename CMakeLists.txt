
cmake_minimum_required( VERSION 2.6 )

project( TP )

#------------------------------------------------------------------------------
# Places to search in order. When we have a toolchain, we will only specify
# its directory here.

set( CMAKE_FIND_ROOT_PATH /opt/local /usr/local /usr)

#------------------------------------------------------------------------------

include(util.cmake)


add_subdirectory( clients/desktop )

#add_subdirectory( clients/lirc )

#add_subdirectory( clients/clutter-mediaplayer )

add_subdirectory( engine )

add_subdirectory( engine/docs )