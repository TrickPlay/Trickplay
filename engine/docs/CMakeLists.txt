cmake_minimum_required( VERSION 2.6 )

if (NATURAL_DOCS)

    add_custom_target(
        docs
        ALL
        COMMENT "Generating documentation"
        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine/docs/apps/text
            -i ${PROJECT_SOURCE_DIR}/engine/bindings
            -o HTML ${PROJECT_BINARY_DIR}/docs/apps
            -p ${PROJECT_SOURCE_DIR}/engine/docs/apps/nd
            -s Default Trickplay

        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine/public/include/trickplay
            -o HTML ${PROJECT_BINARY_DIR}/docs/oem
            -p ${PROJECT_SOURCE_DIR}/engine/docs/oem/nd
            -s Default Trickplay
    )

    file(
        MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/apps
    )

    file(
        MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/oem
    )
    
endif(NATURAL_DOCS)
