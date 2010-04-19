#ifndef _TRICKPLAY_IMAGES_H
#define _TRICKPLAY_IMAGES_H

#include "clutter/clutter.h"

namespace Images
{
    bool load_texture_from_data( ClutterTexture * texture, const void * data, size_t length );
    bool load_texture_from_file( ClutterTexture * texture, const char * file_name );

    // Takes the data passed in and decodes it to an image. Results must be
    // freed with g_free.

    unsigned char * decode_image( const void * data, size_t length, int & width, int & height, int & pitch, int & depth, int & bgr );
};

#endif // _TRICKPLAY_IMAGES_H
