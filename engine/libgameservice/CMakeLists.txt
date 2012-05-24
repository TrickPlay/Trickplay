
include(../../util.cmake)

set ( SYSTEM_INCLUDE_DIRS )

TP_FIND_INCLUDE( time.h   SYSTEM_INCLUDE_DIRS )

message( "system_include_dirs = ${SYSTEM_INCLUDE_DIRS}" )

include_directories( 

	${SYSTEM_INCLUDE_DIRS}
	${CMAKE_BINARY_DIR}/engine/3rd_party/txmpp/include/txmpp
	${ENGINE_SRC}/3rd_party/txmpp/txmpp-0.0.2/src 

)

add_library( gameservice SHARED 
	status.cc
        game.cc
        gameserviceclient.cc
        libgameservice.cc
        presenceouttask.cc
        presencepushtask.cc
        receivetask.cc
        xmppmugconstants.cc
        xmpppump.cc
        xmpptasks.cc
	json_parser.c
)

target_link_libraries (
	gameservice
	tptxmpp
)
         
install(TARGETS gameservice LIBRARY DESTINATION lib)
