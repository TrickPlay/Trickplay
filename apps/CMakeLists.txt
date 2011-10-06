cmake_minimum_required( VERSION 2.6 )

add_custom_target( apps )

file(GLOB app_list RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*/app")

foreach(the_app ${app_list})

    # Read the version and revision from the app file
    file( STRINGS ${the_app} the_id      REGEX "^[ \\t]*id[ \\t]*=" )
    file( STRINGS ${the_app} the_version REGEX "^[ \\t]*version[ \\t]*=" )
    file( STRINGS ${the_app} the_release REGEX "^[ \\t]*release[ \\t]*=" )

    string( REGEX REPLACE "^[ \\t]*id[ \\t]*=[ \\t]*['\"]?([^'\"]*)[\"']?,$" "\\1" the_id ${the_id} )
    string( REGEX REPLACE "^[ \\t]*version[ \\t]*=[ \\t]*['\"]?([^'\"]*)[\"']?,$" "\\1" the_version ${the_version} )
    string( REGEX REPLACE "^[ \\t]*release[ \\t]*=[ \\t]*['\"]?([^'\"]*)[\"']?,$" "\\1" the_release ${the_release} )

    set( the_zipfile ${the_id}-${the_version}-${the_release}.zip )
    string( REPLACE //app "" the_directory ${the_app} )

    message("Building " ${the_zipfile} " from " ${the_directory})

    add_custom_target(${the_zipfile}
                        COMMAND zip -9vr "${CMAKE_CURRENT_BINARY_DIR}/${the_zipfile}" ${the_directory}
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    )

    add_dependencies( apps ${the_zipfile} )
endforeach(the_app IN LISTS app_list)

