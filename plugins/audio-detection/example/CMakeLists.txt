
include_directories( ${PROJECT_SOURCE_DIR}/engine/public/include )

add_library( tp_audio_detection-example SHARED main.c )

set_target_properties( tp_audio_detection-example PROPERTIES PREFIX "" )
