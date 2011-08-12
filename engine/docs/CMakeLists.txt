cmake_minimum_required( VERSION 2.6 )

if (NOT NATURAL_DOCS)
	find_program(
		NATURAL_DOCS

		NAMES naturaldocs NaturalDocs
	)
endif (NOT NATURAL_DOCS)

if (NATURAL_DOCS)

    add_custom_target(
		git-tag-menu-txt
		COMMENT "Inserting Git tag into docs"
		DEPENDS ${PROJECT_SOURCE_DIR}/engine/docs/rte/config/Menu.txt.src
		VERBATIM
		COMMAND sed -e "s!__REPLACE_ME_VERSION_TAG__!${GIT_VERSION}!"
			 ${PROJECT_SOURCE_DIR}/engine/docs/rte/config/Menu.txt.src
			 > ${PROJECT_SOURCE_DIR}/engine/docs/rte/config/Menu.txt
	)

	add_custom_target(
		rte-docs
		COMMENT "Generating RTE docs"
		VERBATIM
		COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/docs/rte
        COMMAND ${NATURAL_DOCS}
			-r
            -i ${PROJECT_SOURCE_DIR}/engine
			-img ${PROJECT_SOURCE_DIR}/engine/docs/rte/reference/images
            -xi ${PROJECT_SOURCE_DIR}/engine/docs/oem
            -xi ${PROJECT_SOURCE_DIR}/engine/3rd_party
            -xi ${PROJECT_SOURCE_DIR}/engine/lb
            -xi ${PROJECT_SOURCE_DIR}/engine/lua
            -xi ${PROJECT_SOURCE_DIR}/engine/public
            -xi ${PROJECT_SOURCE_DIR}/engine/source
            -o HTML ${PROJECT_BINARY_DIR}/docs/rte
            -p ${PROJECT_SOURCE_DIR}/engine/docs/rte/config
            -s Default Trickplay
	)
	add_dependencies(rte-docs git-tag-menu-txt)

	add_custom_target(
		oem-docs
		COMMENT "Generating OEM docs"
		VERBATIM
		COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/docs/oem
        COMMAND ${NATURAL_DOCS}
			-r
            -i ${PROJECT_SOURCE_DIR}/engine            
            -xi ${PROJECT_SOURCE_DIR}/engine/docs/rte
            -xi ${PROJECT_SOURCE_DIR}/engine/docs/devtools
            -xi ${PROJECT_SOURCE_DIR}/engine/bindings
            -xi ${PROJECT_SOURCE_DIR}/engine/3rd_party
            -xi ${PROJECT_SOURCE_DIR}/engine/lb
            -xi ${PROJECT_SOURCE_DIR}/engine/lua
            -xi ${PROJECT_SOURCE_DIR}/engine/source
            -o HTML ${PROJECT_BINARY_DIR}/docs/oem
            -p ${PROJECT_SOURCE_DIR}/engine/docs/oem/config
            -s Default Trickplay
	)

    add_custom_target(
        docs
        ALL
    )
	add_dependencies(
		docs
			rte-docs
			oem-docs
	)
    
endif(NATURAL_DOCS)
