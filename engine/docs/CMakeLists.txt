cmake_minimum_required( VERSION 2.6 )

if (NATURAL_DOCS)

    add_custom_target(
        docs
        ALL
        COMMENT "Generating documentation"
        COMMAND ${NATURAL_DOCS}
            -r
            -i ${PROJECT_SOURCE_DIR}/engine/docs/text
            -i ${PROJECT_SOURCE_DIR}/engine/bindings
            -o HTML ${CMAKE_CURRENT_BINARY_DIR}/html
            -p ${PROJECT_SOURCE_DIR}/engine/docs/nd
    )

    file(
        MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html
    )
    
endif(NATURAL_DOCS)
