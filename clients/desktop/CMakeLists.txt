
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )
add_executable( tp main.c )
target_link_libraries( tp tpcore )
