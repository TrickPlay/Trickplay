
#------------------------------------------------------------------------------
# Lua has to be built as C++ in order to get exceptions. Since most distributions
# do not already do that, we include Lua directly into our engine.

set( LUA_VERSION 5.2.0 )

set( LUA_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/lua-${LUA_VERSION} )

add_definitions( -DLUA_USE_LINUX=1 )
if( NOT TP_PROFILING )
    add_definitions( -DLUA_USE_LONGJMP=1 )
endif( NOT TP_PROFILING )

include_directories( ${LUA_ROOT}/src )

set( LUA_SOURCE_FILES

    ${LUA_ROOT}/src/lapi.c
    ${LUA_ROOT}/src/lcode.c
    ${LUA_ROOT}/src/ldebug.c
    ${LUA_ROOT}/src/ldo.c
    ${LUA_ROOT}/src/ldump.c
    ${LUA_ROOT}/src/lfunc.c
    ${LUA_ROOT}/src/lgc.c
    ${LUA_ROOT}/src/llex.c
    ${LUA_ROOT}/src/lmem.c
    ${LUA_ROOT}/src/lobject.c
    ${LUA_ROOT}/src/lopcodes.c
    ${LUA_ROOT}/src/lparser.c
    ${LUA_ROOT}/src/lstate.c
    ${LUA_ROOT}/src/lstring.c
    ${LUA_ROOT}/src/ltable.c
    ${LUA_ROOT}/src/ltm.c
    ${LUA_ROOT}/src/lundump.c
    ${LUA_ROOT}/src/lvm.c
    ${LUA_ROOT}/src/lzio.c
    ${LUA_ROOT}/src/lauxlib.c
    ${LUA_ROOT}/src/lbaselib.c
    ${LUA_ROOT}/src/ldblib.c
    ${LUA_ROOT}/src/lmathlib.c
    ${LUA_ROOT}/src/loslib.c
    ${LUA_ROOT}/src/ltablib.c
    ${LUA_ROOT}/src/lstrlib.c
    ${LUA_ROOT}/src/loadlib.c
    ${LUA_ROOT}/src/liolib.c
    ${LUA_ROOT}/src/lbitlib.c
    ${LUA_ROOT}/src/lcorolib.c
    ${LUA_ROOT}/src/lctype.c
    ${LUA_ROOT}/src/ldblib.c
    ${LUA_ROOT}/src/ltablib.c

#    ${LUA_ROOT}/src/linit.c
)

include( CheckCXXCompilerFlag )
CHECK_CXX_COMPILER_FLAG("-x c++" LUA_BUILD_FORCE_CXX)
if(LUA_BUILD_FORCE_CXX)
    add_definitions("-x c++")
endif(LUA_BUILD_FORCE_CXX)


set_source_files_properties(

    ${LUA_SOURCE_FILES}

    PROPERTIES
        LANGUAGE CXX
)

add_library( tplua SHARED ${LUA_SOURCE_FILES} )

install(TARGETS tplua LIBRARY DESTINATION lib)

