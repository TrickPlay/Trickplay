#ifndef _TRICKPLAY_IMAGES_H
#define _TRICKPLAY_IMAGES_H

#include "clutter/clutter.h"
#include "trickplay/image.h"
#include "common.h"

class Images
{
public:

    //.........................................................................

    static void set_external_decoder( TPImageDecoder decoder, gpointer decoder_data );

    //.........................................................................
    // Decodes an image and gives it to the Clutter texture.

    static bool load_texture( ClutterTexture * texture, gpointer data, gsize size, const char * content_type = NULL );
    static bool load_texture( ClutterTexture * texture, const char * filename );

    //.........................................................................
    // Loads the the decoded image into a Clutter texture.

    static void load_texture( ClutterTexture * texture, TPImage * image );

    //.........................................................................
    // Decode an image and return the resulting TPImage, which must be freed
    // with destroy_image. The pixels of a TPImage cannot be stolen - because
    // there may be a custom function required to free them.

    static TPImage * decode_image( gpointer data, gsize size, const char * content_type = NULL );
    static TPImage * decode_image( const char * filename );

    //.........................................................................
    // Destroys a TPImage and frees its pixels.

    static void destroy_image( TPImage * image );

    //.........................................................................
    // Destroys the Images singleton and frees all the decoders.

    static void shutdown();

    //.........................................................................
    // ABC for image decoders.

    class Decoder
    {
    public:
        virtual const char * name() = 0;
        virtual int decode( gpointer data, gsize size, TPImage * image ) = 0;
        virtual int decode( const char * filename, TPImage * image ) = 0;
    };

    static void dump();

private:

    Images();

    ~Images();

    Images( const Images & );

    //.........................................................................
    // Gets the singleton or deletes it

    static Images * get( bool destroy = false );

    //.........................................................................
    // List of decoders

    typedef std::list< Decoder * > DecoderList;

    //.........................................................................
    // Returns a list of decoders in priority order. The hint can be a file
    // name or a mime type - this function only uses the last 4 characters
    // of it.

    static DecoderList get_decoders( const char * hint = NULL );

    //.........................................................................
    // List of our standard decoders

    DecoderList     decoders;

    //.........................................................................
    // Map of "hints" to specific decoders.

    typedef std::map< String, Decoder * > HintMap;

    HintMap         hints;

    //.........................................................................
    // The external decoder, if any

    Decoder *       external_decoder;

    //.........................................................................

#ifndef TP_PRODUCTION

    // Stuff to keep track of images and display a list

    static void texture_destroyed_notify( gpointer data, GObject * instance );

    struct ImageInfo
    {
        ImageInfo()
        :
            width( 0 ),
            height( 0 ),
            bytes( 0 )
        {}

        ImageInfo( TPImage * image )
        :
            width( image->width ),
            height( image->height ),
            bytes( image->pitch * image->height )
        {}

        guint width;
        guint height;
        guint bytes;
    };

    typedef std::map< gpointer, ImageInfo > ImageMap;

    ImageMap        images;

#endif

};

#endif // _TRICKPLAY_IMAGES_H
