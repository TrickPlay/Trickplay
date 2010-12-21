cmake_minimum_required( VERSION 2.6 )

if (NATURAL_DOCS)

    execute_process(
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
	COMMAND git log -1 --pretty=format:%h
	OUTPUT_STRIP_TRAILING_WHITESPACE
	OUTPUT_VARIABLE GIT_CURRENT_REVISION
    )

    execute_process(
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
	COMMAND git tag --contains ${GIT_CURRENT_REVISION}
	OUTPUT_STRIP_TRAILING_WHITESPACE
	OUTPUT_VARIABLE GIT_CURRENT_TAG
    )

    add_custom_target(
        docs
        ALL
        COMMENT "Generating documentation"
	VERBATIM

	COMMAND sed -e "s/__REPLACE_ME_VERSION_TAG__/${GIT_CURRENT_TAG} (${GIT_CURRENT_REVISION})/"
			 ${PROJECT_SOURCE_DIR}/engine/docs/apps/nd/Menu.txt.src
			 > ${PROJECT_SOURCE_DIR}/engine/docs/apps/nd/Menu.txt

        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine
            -xi ${PROJECT_SOURCE_DIR}/engine/docs/oem
            -xi ${PROJECT_SOURCE_DIR}/engine/docs/editor
            -xi ${PROJECT_SOURCE_DIR}/engine/3rd_party
            -xi ${PROJECT_SOURCE_DIR}/engine/lb
            -xi ${PROJECT_SOURCE_DIR}/engine/lua
            -xi ${PROJECT_SOURCE_DIR}/engine/public
            -xi ${PROJECT_SOURCE_DIR}/engine/source
            -o HTML ${PROJECT_BINARY_DIR}/docs/apps
            -p ${PROJECT_SOURCE_DIR}/engine/docs/apps/nd
            -s Default Trickplay

        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine/public/include/trickplay
            -o HTML ${PROJECT_BINARY_DIR}/docs/oem
            -p ${PROJECT_SOURCE_DIR}/engine/docs/oem/nd
            -s Default Trickplay

        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine/docs/editor/text
            -o HTML ${PROJECT_BINARY_DIR}/docs/editor
            -p ${PROJECT_SOURCE_DIR}/engine/docs/editor/nd
            -s Default Trickplay
    )

    file(
        MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/apps
    )

    file(
        MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/oem
    )

    file(
        MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/editor
    )
    
endif(NATURAL_DOCS)
