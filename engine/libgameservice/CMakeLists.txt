
include(../../util.cmake)

include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )


    pkg_check_modules(EXPAT                     expat)

    if( NOT(EXPAT_FOUND) )
        # expat only doesn't exist on broken version of shitty Ubuntu
        TP_FIND_INCLUDE( expat.h EXPAT_INCLUDE_DIRS )
    endif( NOT(EXPAT_FOUND) )
ENDIF( PKG_CONFIG_FOUND )


include_directories(
    AFTER
    ${CMAKE_BINARY_DIR}/engine/3rd_party/txmpp/include/txmpp
    ${ENGINE_SRC}/3rd_party/txmpp/txmpp-0.0.2/src
    ${EXPAT_INCLUDE_DIRS}

)

add_library( gameservice SHARED
    xmppengineimpl_register.cc
    xmppengineimpl_register_iq.cc
    xmppregistertask.cc
    xmppregisterclient.cc
    xmppconnecttask.cc
    receivetask.cc
    registeraccounttask.cc

#   json_parser.c
    xmppmugconstants.cc
    libgameservice.cc
    status.cc
    game.cc
    presenceouttask.cc
    presencepushtask.cc
    receivetask.cc
    xmpppump.cc
    xmpptasks.cc
    gameserviceclient.cc
)

target_link_libraries (
    gameservice
    tptxmpp
)

install(TARGETS gameservice LIBRARY DESTINATION lib)
