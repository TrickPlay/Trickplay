cmake_minimum_required( VERSION 2.6 )

#------------------------------------------------------------------------------
#building txmpp locally as it doesn't support either cmake or autoconf currently.

set( TXMPP_VERSION 0.0.2 )

set( TXMPP_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/txmpp-${TXMPP_VERSION} )

add_definitions( -DPOSIX -DFEATURE_ENABLE_SSL -DHAVE_OPENSSL_SSL_H -DSSL_USE_OPENSSL -DUSE_SSLSTREAM )

OPTION( POSIX "Enable POSIX" ON )
OPTION( FEATURE_ENABLE_SSL "Enable Feature SSL" ON )
OPTION( HAVE_OPENSSL_SSL_H "Have OPENSSL_SSL_H" ON )
OPTION( SSL_USE_OPENSSL "Enable Use SSL" ON )
OPTION( USE_SSLSTREAM "Enable USE SSLSTREAM" ON )

include(../../../util.cmake)

#------------------------------------------------------------------------------
# Include directories
#------------------------------------------------------------------------------

include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )


    pkg_check_modules(EXPAT                     expat)
    pkg_check_modules(OPENSSL       REQUIRED    openssl)

    if( NOT(EXPAT_FOUND) )
        # expat only doesn't exist on broken version of shitty Ubuntu
        TP_FIND_INCLUDE( expat.h TXMPP_INCLUDE_DIRS )
        list( APPEND TXMPP_LIBRARY_NAMES expat )
    endif( NOT(EXPAT_FOUND) )


    list(APPEND TXMPP_INCLUDE_DIRS
        ${OPENSSL_INCLUDE_DIRS}
        ${EXPAT_INCLUDE_DIRS}
    )

    list(APPEND TXMPP_LIBRARY_NAMES
        ${OPENSSL_LIBRARIES}
        ${EXPAT_LIBRARIES}
    )

ELSE ( PKG_CONFIG_FOUND )


#------------------------------------------------------------------------------
# Libraries
#------------------------------------------------------------------------------

    list(APPEND TXMPP_LIBRARY_NAMES

        ssl
        crypto
        expat
    )

ENDIF ( PKG_CONFIG_FOUND )

include( FindThreads )
list( APPEND TXMPP_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} )

set( TXMPP_SOURCE_FILES

    ${TXMPP_ROOT}/src/asynchttprequest.cc
    ${TXMPP_ROOT}/src/asyncpacketsocket.cc
    ${TXMPP_ROOT}/src/asynctcpsocket.cc
    ${TXMPP_ROOT}/src/asyncudpsocket.cc
    ${TXMPP_ROOT}/src/autodetectproxy.cc
    ${TXMPP_ROOT}/src/base64.cc
    ${TXMPP_ROOT}/src/bytebuffer.cc
    ${TXMPP_ROOT}/src/checks.cc
    ${TXMPP_ROOT}/src/common.cc
    ${TXMPP_ROOT}/src/constants.cc
    ${TXMPP_ROOT}/src/diskcache.cc
    ${TXMPP_ROOT}/src/event.cc
    ${TXMPP_ROOT}/src/fileutils.cc
    ${TXMPP_ROOT}/src/firewallsocketserver.cc
    ${TXMPP_ROOT}/src/flags.cc
    ${TXMPP_ROOT}/src/helpers.cc
    ${TXMPP_ROOT}/src/httpbase.cc
    ${TXMPP_ROOT}/src/httpclient.cc
    ${TXMPP_ROOT}/src/httpcommon.cc
    ${TXMPP_ROOT}/src/httprequest.cc
    ${TXMPP_ROOT}/src/jid.cc
    ${TXMPP_ROOT}/src/logging.cc
    ${TXMPP_ROOT}/src/md5c.c
    ${TXMPP_ROOT}/src/messagehandler.cc
    ${TXMPP_ROOT}/src/messagequeue.cc
    ${TXMPP_ROOT}/src/nethelpers.cc
    ${TXMPP_ROOT}/src/network.cc
    ${TXMPP_ROOT}/src/openssladapter.cc
    ${TXMPP_ROOT}/src/opensslidentity.cc
    ${TXMPP_ROOT}/src/opensslstreamadapter.cc
    ${TXMPP_ROOT}/src/pathutils.cc
    ${TXMPP_ROOT}/src/physicalsocketserver.cc
    ${TXMPP_ROOT}/src/prexmppauthimpl.cc
    ${TXMPP_ROOT}/src/proxydetect.cc
    ${TXMPP_ROOT}/src/proxyinfo.cc
    ${TXMPP_ROOT}/src/qname.cc
    ${TXMPP_ROOT}/src/ratelimitmanager.cc
    ${TXMPP_ROOT}/src/saslmechanism.cc
    ${TXMPP_ROOT}/src/signalthread.cc
    ${TXMPP_ROOT}/src/socketadapters.cc
    ${TXMPP_ROOT}/src/socketaddress.cc
    ${TXMPP_ROOT}/src/socketpool.cc
    ${TXMPP_ROOT}/src/ssladapter.cc
    ${TXMPP_ROOT}/src/sslidentity.cc
    ${TXMPP_ROOT}/src/sslsocketfactory.cc
    ${TXMPP_ROOT}/src/sslstreamadapter.cc
    ${TXMPP_ROOT}/src/stream.cc
    ${TXMPP_ROOT}/src/stringdigest.cc
    ${TXMPP_ROOT}/src/stringencode.cc
    ${TXMPP_ROOT}/src/stringutils.cc
    ${TXMPP_ROOT}/src/task.cc
    ${TXMPP_ROOT}/src/taskparent.cc
    ${TXMPP_ROOT}/src/taskrunner.cc
    ${TXMPP_ROOT}/src/thread.cc
    ${TXMPP_ROOT}/src/time.cc
    ${TXMPP_ROOT}/src/urlencode.cc
    ${TXMPP_ROOT}/src/xmlbuilder.cc
    ${TXMPP_ROOT}/src/xmlconstants.cc
    ${TXMPP_ROOT}/src/xmlelement.cc
    ${TXMPP_ROOT}/src/xmlnsstack.cc
    ${TXMPP_ROOT}/src/xmlparser.cc
    ${TXMPP_ROOT}/src/xmlprinter.cc
    ${TXMPP_ROOT}/src/xmppasyncsocketimpl.cc
    ${TXMPP_ROOT}/src/xmppclient.cc
    ${TXMPP_ROOT}/src/xmppengineimpl.cc
    ${TXMPP_ROOT}/src/xmppengineimpl_iq.cc
    ${TXMPP_ROOT}/src/xmpplogintask.cc
    ${TXMPP_ROOT}/src/xmppstanzaparser.cc
    ${TXMPP_ROOT}/src/xmpptask.cc
    ${TXMPP_ROOT}/src/unixfilesystem.cc
)

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

    list(APPEND      TXMPP_SOURCE_FILES

        ${TXMPP_ROOT}/src/macconversion.cc
        ${TXMPP_ROOT}/src/macutils.cc
    )

    OPTION( OSX "Enable OSX" ON )

else(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

    list(APPEND      TXMPP_SOURCE_FILES

        ${TXMPP_ROOT}/src/linux.cc
    )

    OPTION( LINUX "Enable LINUX" ON )

endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")


configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/include/txmpp/config.h )


include_directories( ${CMAKE_CURRENT_BINARY_DIR}/include/txmpp ${TXMPP_INCLUDE_DIRS} )


foreach( LIB ${TXMPP_LIBRARY_NAMES} )
    TP_FIND_LIBRARY( ${LIB} TXMPP_LIBRARIES )
endforeach( LIB )


if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

FIND_LIBRARY (CORESERVICES_LIBRARY CoreServices)
MARK_AS_ADVANCED (CORESERVICES_LIBRARY)
FIND_LIBRARY (CARBON_LIBRARY Carbon)
MARK_AS_ADVANCED (CARBON_LIBRARY)
FIND_LIBRARY (SECURITY_LIBRARY Security)
MARK_AS_ADVANCED (SECURITY_LIBRARY)
FIND_LIBRARY (SYSTEM_CONFIGURATION_LIBRARY SystemConfiguration)
MARK_AS_ADVANCED (SYSTEM_CONFIGURATION_LIBRARY)

list( APPEND

    TXMPP_LIBRARIES

    ${CORESERVICES_LIBRARY}
    ${CARBON_LIBRARY}
    ${SECURITY_LIBRARY}
    ${SYSTEM_CONFIGURATION_LIBRARY}
    objc
)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

set_source_files_properties(

    ${TXMPP_SOURCE_FILES}

    PROPERTIES
    LANGUAGE CXX
)

add_library( tptxmpp SHARED ${TXMPP_SOURCE_FILES} )

target_link_libraries(

    tptxmpp

    ${TXMPP_LIBRARIES}
)

install(TARGETS tptxmpp LIBRARY DESTINATION lib)

