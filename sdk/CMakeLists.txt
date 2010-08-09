
# To build the debian package, first run a regular build with documentation, then
# fakeroot make debian package
# Run lintian on the output package to make sure it is clean(ish)

if (UNIX AND NOT APPLE)
		
    if (NATURAL_DOCS)
    
        # Get the architecture string from dpkg
        
	    execute_process(COMMAND dpkg --print-architecture OUTPUT_VARIABLE CPACK_DEBIAN_PACKAGE_ARCHITECTURE OUTPUT_STRIP_TRAILING_WHITESPACE)
		
        set(CPACK_GENERATOR DEB)
        
        set(CPACK_PACKAGE_NAME "trickplay-sdk")
        
        set(CPACK_PACKAGE_VERSION "${TP_VERSION}")
        
        set(CPACK_STRIP_FILES 1)
        
        set(CPACK_SYSTEM_NAME "Linux-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
        
        set(CPACK_PACKAGE_FILE_NAME "trickplay-sdk_${CPACK_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
        
        set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Pablo Pissanetzky <pablo@trickplay.com>")
        
        set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "TrickPlay SDK\n The TrickPlay SDK allows you to build and test TrickPlay apps.")
        
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.7),libcairo2 (>= 1.4.10),libgl1-mesa-glx | libgl1,libglib2.0-0 (>= 2.18.0),libgtk2.0-0 (>= 2.8.0),libpango1.0-0 (>= 1.20.0),libx11-6,libxcomposite1 (>= 1:0.3-1),libxdamage1 (>= 1:1.1),libxext6,libxfixes3 (>= 1:4.0.1),libcurl3 (>=7.19.0),libavahi-common3 (>= 0.6.25),libavahi-core6 (>= 0.6.25),libavahi-glib1(>= 0.6.25),libclutter-1.0-0 (>= 1.0.6),libtokyocabinet8,libexpat1,libsqlite3-0 (>= 3.6.0),libclutter-gst-0.10-0,libtiff4,libjson-glib-1.0-0 (>= 0.5.0),libjpeg62,libtiffxx0c2,libgif4,libossp-uuid15,libupnp4")

        # Custom target that:
        # 1. Generates the man file
        # 2. Puts the current version into the changelog
        
        add_custom_target(
            debian

            COMMENT "Generating Debian package files..."
            COMMAND pod2man -c "TrickPlay SDK" -r "TrickPlay ${CPACK_PACKAGE_VERSION}" ${CMAKE_CURRENT_SOURCE_DIR}/trickplay.1.pod | gzip --best > trickplay.1.gz
            COMMAND sed s/%TRICKPLAY_VERSION%/${CPACK_PACKAGE_VERSION}/ ${CMAKE_CURRENT_SOURCE_DIR}/changelog | gzip --best > changelog.gz
            )
            
        set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "trickplay.1.gz;changelog.gz") 

        # Documentation
        
        install(DIRECTORY ${PROJECT_BINARY_DIR}/docs/apps/ DESTINATION share/doc/trickplay-sdk/html)
        
        # Copyright
        
        install(FILES copyright DESTINATION share/doc/trickplay-sdk)
        
        # Man

        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/trickplay.1.gz DESTINATION share/man/man1/)
        
        # Changelog
        
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/changelog.gz DESTINATION share/doc/trickplay-sdk)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/changelog.gz DESTINATION share/doc/trickplay-sdk RENAME changelog.Debian.gz)


        include(CPack)

    endif (NATURAL_DOCS)		
		

endif(UNIX AND NOT APPLE)


