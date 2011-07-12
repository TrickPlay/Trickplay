
# To build the debian package, first run a regular build with documentation, then
# fakeroot make debian package
# Run lintian on the output package to make sure it is clean(ish)

if (UNIX AND NOT APPLE)
		
    if (NATURAL_DOCS)
    
    	# This is so we can put all the dependencies in a list.
    	# After this, we concatenate them.
    
    	set( DEPS 

            "gstreamer0.10-ffmpeg"
            "gstreamer0.10-plugins-bad"
            "gstreamer0.10-plugins-good"

            "libatk1.0-0"
            "libavahi-common3 (>= 0.6.25)"
            "libavahi-core6 (>= 0.6.25) | libavahi-core7"
            "libavahi-glib1(>= 0.6.25)"
            "libc-ares2"
            "libc6 (>= 2.7)"
            "libcairo2 (>= 1.4.10)"
            "libclutter-1.0-0 (>= 1.0.6)"
            "libclutter-gst-0.10-0 | libclutter-gst-1.0-0"
            "libcurl3 (>=7.19.0)"
            "libexpat1"
            "libfontconfig1"
            "libfreetype6"
            "libgif4"
            "libglib2.0-0 (>= 2.18.0)"
            "libgstreamer0.10-0"
            "libgstreamer-plugins-base0.10-0"
            "libjpeg62"
            "libjson-glib-1.0-0 (>= 0.5.0)"
            "libossp-uuid15 | libossp-uuid16"
            "libpango1.0-0 (>= 1.20.0)"
            "libpng12-0"
            "libreadline6"
            "libsndfile1"
            "libsoup2.4-1"
            "libsqlite3-0 (>= 3.6.0)"
            "libssl0.9.8"
            "libtiff4"
            "libtiffxx0c2"
            "libupnp3 (>= 1.6)"
            "liburiparser1"
            "libxml2"
		)
		
		set( FIRST 1 )
		
		foreach( D ${DEPS} )
		
			if ( FIRST )
			
				set( CPACK_DEBIAN_PACKAGE_DEPENDS "${D}" )
				unset( FIRST )
				
			else ( FIRST )
			
				set( CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS},${D}" )
			
			endif( FIRST )
		
		endforeach( D ) 

        string( TOLOWER "${CMAKE_BUILD_TYPE}" BUILD_TYPE )		
			
    
        # Get the architecture string from dpkg
        
	    execute_process(COMMAND dpkg --print-architecture OUTPUT_VARIABLE CPACK_DEBIAN_PACKAGE_ARCHITECTURE OUTPUT_STRIP_TRAILING_WHITESPACE)
		
        set(CPACK_GENERATOR DEB)
        
        set(CPACK_PACKAGE_NAME "trickplay-sdk")
        
        set(CPACK_PACKAGE_VERSION "${GIT_CURRENT_TAG}")
        
        set(CPACK_STRIP_FILES 1)
        
        set(CPACK_SYSTEM_NAME "Linux-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
        
        set(CPACK_PACKAGE_FILE_NAME "trickplay-sdk_${CPACK_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}_${BUILD_TYPE}")
        
        set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Pablo Pissanetzky <pablo@trickplay.com>")
        
        set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "TrickPlay SDK\n The TrickPlay SDK allows you to build and test TrickPlay apps.")
        
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

        # Resources
	
	install(DIRECTORY ${PROJECT_SOURCE_DIR}/resources DESTINATION share/trickplay/ )
	
	# Menu entry
	
	install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/trickplay.desktop DESTINATION share/applications/)
	
	# Icons
	
	install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/trickplay.png DESTINATION share/icons/hicolor/64x64/apps/)

        include(CPack)

    endif (NATURAL_DOCS)		
		

endif(UNIX AND NOT APPLE)


