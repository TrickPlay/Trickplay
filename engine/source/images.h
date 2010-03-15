#ifndef _TRICKPLAY_IMAGES_H
#define _TRICKPLAY_IMAGES_H

#include "clutter/clutter.h"

namespace Images
{
    bool load_texture_from_data(ClutterTexture * texture,const void * data,size_t length);
    bool load_texture_from_file(ClutterTexture * texture,const char * file_name);
};

#endif // _TRICKPLAY_IMAGES_H
