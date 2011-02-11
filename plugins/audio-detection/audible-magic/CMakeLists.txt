
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/include )
link_directories( ${CMAKE_CURRENT_SOURCE_DIR}/lib )

add_library( tp_audio_detection-audible_magic SHARED main.cpp )

set( AM_3RD_PARTY_LIBS avcodec avformat avutil )

target_link_libraries( tp_audio_detection-audible_magic mfcbroem sndfile ${AM_3RD_PARTY_LIBS} )

set_target_properties( tp_audio_detection-audible_magic PROPERTIES PREFIX "" )

