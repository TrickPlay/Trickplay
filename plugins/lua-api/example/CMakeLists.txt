
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )

add_library( tp_lua_api-example SHARED main.c )

target_link_libraries( tp_lua_api-example tplua )

set_target_properties( tp_lua_api-example PROPERTIES PREFIX "" )
