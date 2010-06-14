
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )
add_executable( tp main.c )
target_link_libraries( tp tpcore )
set_target_properties( tp 
    PROPERTIES LINKER_LANGUAGE CXX 
    OUTPUT_NAME trickplay)

