
include_directories(
    ${PROJECT_SOURCE_DIR}/engine/public/include    
    /usr/lib/glib-2.0/include
    /usr/include/glib-2.0
    )

add_definitions(
    -DG_LOG_DOMAIN="tp-lirc"
    )
    
add_executable(
    tp-lirc
    main.c
)

target_link_libraries(
    tp-lirc

    gio-2.0
    glib-2.0
    lirc_client
    tpcore
    )
    
set_target_properties(
    tp-lirc
    PROPERTIES OUTPUT_NAME tp
)
