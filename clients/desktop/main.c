
#include <string.h>
#include <stdio.h>

#include "trickplay/trickplay.h"
#include "trickplay/image.h"

#define CUSTOM_IMAGE_DECODER 0

//-----------------------------------------------------------------------------

#if CUSTOM_IMAGE_DECODER

int my_image_decoder( void * buffer, unsigned long int size, TPImage * image, void * data )
{

    if ( ! image )
    {
        // Should look at size bytes in buffer and attempt to detect the image format.
        // If it is supported, return TP_IMAGE_SUPPORTED_FORMAT

        return TP_IMAGE_UNSUPPORTED_FORMAT;
    }

    // Should decode the image and return TP_IMAGE_DECODE_OK, TP_IMAGE_UNSUPPORTED_FORMAT
    // or TP_IMAGE_DECODE_FAILED

    return TP_IMAGE_DECODE_FAILED;
}

#endif

//-----------------------------------------------------------------------------

int main( int argc, char * argv[ ] )
{
    tp_init( &argc, &argv );

    TPContext * context = tp_context_new();

    if ( argc > 1 )
    {
        tp_context_set( context, "app.path", argv[ 1 ] );
    }

#if CUSTOM_IMAGE_DECODER

    tp_context_set_image_decoder( context, my_image_decoder, NULL );

#endif

    int result = tp_context_run( context );

    tp_context_free( context );

    return result;
}
