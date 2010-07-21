
list( APPEND 3RD_PARTY_SOURCE_FILES

    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils/unzip.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/kiss_fft/kiss_fft.c
    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/kiss_fft/kiss_fftr.c

)

# This should be taken out for windows

add_definitions( -DZIP_STD=1 )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils ) 
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/kiss_fft ) 
