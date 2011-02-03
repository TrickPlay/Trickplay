#ifndef _TRICKPLAY_IMAGE_H
#define _TRICKPLAY_IMAGE_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------------
    File: Image Decoding
*/

/*-----------------------------------------------------------------------------
    Function: TPImageFreePixels

    A function used to free an image's pixel data. If it is not set in the
    <TPImage> structure, then free will be used.

    Arguments:

        pixels - The pixel data of a TPImage structure.
*/

    typedef
    void
    (*TPImageFreePixels)(

        void * pixels);

/*-----------------------------------------------------------------------------
    Struct: TPImage

    Holds information about a decoded image.
*/
    typedef struct TPImage TPImage;

    struct TPImage
    {
        /*
            Field: pixels

            Pixels should be set to a contiguous memory block holding the
            decoded image data as either RGB or RGBA. If this data needs
            to be freed in a special manner, set the <free_pixels> field
            to point to a function that will free the data.
        */

        void *              pixels;

        /*
            Field: width

            The width of the image in pixels.
        */

        unsigned int        width;

        /*
            Field: height

            The height of the image in pixels.
        */

        unsigned int        height;

        /*
            Field: pitch

            The number of bytes occupied by each row of pixels. If there is no
            padding between rows, it should be the same as width * depth.
        */

        unsigned int        pitch;

        /*
            Field: depth

            The number of 8 bit components (bytes) per pixel. This should be
            3 for an RGB image or 4 for an RGBA image.
        */

        unsigned int        depth;

        /*
            Field: bgr

            If the components are arranged in BGR or BGRA order, set this
            to 1. This is not recommended.
        */

        unsigned int        bgr;

        /*
            Field: free_pixels

            Pointer to a function that will be used to free the pixels once
            TrickPlay is done with them. If this is NULL (the default), then
            free will be used.
        */

        TPImageFreePixels   free_pixels;
    };

/*-----------------------------------------------------------------------------
    Constants: Decoder Return Values

    TP_IMAGE_DECODE_OK          - The image was decoded successfully.
    TP_IMAGE_SUPPORTED_FORMAT   - The decoder detected and supports the image format.
    TP_IMAGE_UNSUPPORTED_FORMAT - The decoder does not support the image format.
    TP_IMAGE_DECODE_FAILED      - The decoder failed.
*/

#define TP_IMAGE_DECODE_OK               0
#define TP_IMAGE_SUPPORTED_FORMAT        0
#define TP_IMAGE_UNSUPPORTED_FORMAT      1
#define TP_IMAGE_DECODE_FAILED          -1

/*-----------------------------------------------------------------------------
    Function: TPImageDecoder

    Decodes an image from a memory buffer.

    When TrickPlay calls this function with the image set to NULL, the buffer
    does not contain the whole image, only the first few bytes. In this case,
    the decoder should try to identify the image format and decide whether
    it can handle it. If the format is recognized, the function should
    return <TP_IMAGE_SUPPORTED_FORMAT>. In this case, TrickPlay will call the
    function again with the entire image and a valid pointer for the image
    parameter.

    When the image parameter is not NULL, this function should attempt to
    decode the image data and fill in the image parameter. The decoded image
    should be allocated in a contiguous memory block. The depth should be
    either 3 for no alpha, or 4 if it includes alpha. Each component should
    be 8 bits and the components should be organized as either RGB or RGBA.
    If the pixel data needs to be freed in a special manner, you can set
    the <free_pixels> field of the image parameter to a function; otherwise
    TrickPlay will use the system's 'free' function.

    This function should be thread safe.

    Arguments:

        data -  A pointer to the compressed image data.

        size -  The number of bytes data points to.

        image - A pointer to a <TPImage> structure that the function should
                populate when it returns <TP_IMAGE_DECODE_OK>.

        user - An opaque pointer that was set when <tp_context_set_image_decoder>
               was called.

    Returns:

        TP_IMAGE_SUPPORTED_FORMAT - When the image parameter is NULL and the
                                    decoder detected and supports the image
                                    format.

        TP_IMAGE_UNSUPPORTED_FORMAT - When the decoder cannot handle this image.

        TP_IMAGE_DECODE_OK -        If the image was decoded.

        TP_IMAGE_DECODE_FAILED -    If there was a problem decoding the image. In
                                    this case, the image parameter should not be
                                    modified, as TrickPlay will ignore it.
*/

    typedef
    int
    (*TPImageDecoder)(

        void * data,
        unsigned long int size,
        TPImage * image,
        void * user);

/*-----------------------------------------------------------------------------
    Function: tp_context_set_image_decoder

    Specify the function used to decode images.

    Arguments:

        context - A valid TPContext.
        decoder - A pointer to a <TPImageDecoder> function.
        user - An opaque pointer that is passed to the decoder.
*/

    TP_API_EXPORT
    void
    tp_context_set_image_decoder(

        TPContext * context,
        TPImageDecoder decoder,
        void * user);

/*-----------------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif

#endif /* _TRICKPLAY_IMAGE_H */
