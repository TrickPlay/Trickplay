
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/include /usr/include/libxml2 )
link_directories( ${CMAKE_CURRENT_SOURCE_DIR}/lib )

add_library( tp_audio_detection-audible_magic SHARED main.cpp )

target_link_libraries( tp_audio_detection-audible_magic mfcbroem sndfile iconv xml2 )

set_target_properties( tp_audio_detection-audible_magic PROPERTIES PREFIX "" )

#add_executable( test test.cpp )
#target_link_libraries( test xml2 )
