#ifndef _TRICKPLAY_IMAGES_H
#define _TRICKPLAY_IMAGES_H

#include "clutter/clutter.h"
#include "cairo/cairo.h"
#include "trickplay/image.h"
#include "common.h"

//-----------------------------------------------------------------------------
// Set to 1 to enable caching of images

#define TP_IMAGE_CACHE_ENABLED                  0

#define TP_IMAGE_CACHE_DEFAULT_LIMIT_BYTES      ( 20 * 1024 * 1024 )

//=============================================================================

class Image
{
public:

    static Image * make( const TPImage & image );

    static Image * decode( gpointer data, gsize size, const gchar * content_type = NULL );

    static Image * decode( const gchar * filename );

    static Image * screenshot();


    ~Image();

    inline const guchar * pixels() const { return ( const guchar * ) image->pixels; }
    inline guint width() const { return image->width; }
    inline guint height() const { return image->height; }
    inline guint pitch() const { return image->pitch; }
    inline guint depth() const { return image->depth; }
    inline bool bgr() const { return image->bgr; }

    inline guint size() const { return image->height * image->pitch; }

    String checksum() const;

    cairo_surface_t * cairo_surface() const;

    bool write_to_png( const gchar * filename ) const;

private:

    friend class Images;

    Image();

    Image( TPImage * );

    Image( const Image & );

    Image * convert_to_cairo_argb32() const;

    TPImage * image;
};

//=============================================================================

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

    static void load_texture( ClutterTexture * texture, const Image * image );

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

    //.........................................................................
    // Prints out a list of all loaded Clutter textures along with their
    // dimension and size

    static void dump();

    //.........................................................................

    static void set_cache_limit( guint bytes );

    //.........................................................................
    // Prints out the cache contents, when the cache is enabled

    static void dump_cache();

private:

    friend class Image;

    Images();

    ~Images();

    Images( const Images & );

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

    GStaticRecMutex mutex;

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

#if TP_IMAGE_CACHE_ENABLED

    typedef std::pair< TPImage *, guint > CacheEntry;

    typedef std::map< String, CacheEntry > CacheMap;

    CacheMap         cache;

    typedef std::pair< String, CacheEntry > PruneEntry;

    typedef std::vector< PruneEntry > PruneVector;

    static bool prune_sort( const PruneEntry & a, const PruneEntry & b );

    void prune_cache();

    guint cache_limit;

    guint cache_size;

#endif

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

    static bool compare( std::pair< gpointer , ImageInfo > a, std::pair< gpointer , ImageInfo > b );

#endif

};

#endif // _TRICKPLAY_IMAGES_H
