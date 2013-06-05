#ifndef _TRICKPLAY_IMAGE_DECODERS_H
#define _TRICKPLAY_IMAGE_DECODERS_H

#include "images.h"

namespace ImageDecoders
{
Images::Decoder* make_png_decoder();

Images::Decoder* make_jpeg_decoder();

Images::Decoder* make_tiff_decoder();

Images::Decoder* make_gif_decoder();
};

#endif // _TRICKPLAY_IMAGE_DECODERS_H
