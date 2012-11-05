#ifndef _TRICKPLAY_IMAGES_H
#define _TRICKPLAY_IMAGES_H

#include "clutter/clutter.h"
#include "cairo/cairo.h"

#include "trickplay/image.h"
#include "common.h"
#include "json.h"

//=============================================================================

class Image
{
public:

    static Image * make( const TPImage & image );

    static Image * make( cairo_surface_t * surface );

    static Image * decode( gpointer data, gsize size, bool read_tags , const gchar * content_type = NULL );

    static Image * decode( const gchar * filename , bool read_tags );

    static Image * screenshot( ClutterActor *stage );

    typedef void ( * DecodeAsyncCallback )( Image * image , gpointer user );

    static void decode_async( const gchar * filename , bool read_tags , DecodeAsyncCallback callback , gpointer user , GDestroyNotify destroy_notify );

    static void decode_async( GByteArray * bytes , bool read_tags , const gchar * content_type , DecodeAsyncCallback callback , gpointer user , GDestroyNotify destroy_notify );

    static void free_image_with_g_free( TPImage * image );

    ~Image();

    inline const guchar * pixels() const { return ( const guchar * ) image->pixels; }
    inline guint width() const { return image->width; }
    inline guint height() const { return image->height; }
    inline guint pitch() const { return image->pitch; }
    inline guint depth() const { return image->depth; }
    inline bool bgr() const { return image->bgr; }
    inline bool pm_alpha() const { return image->pm_alpha; }

    inline guint size() const { return image->height * image->pitch; }

    String checksum() const;

    cairo_surface_t * cairo_surface() const;

    bool write_to_png( const gchar * filename ) const;

    //.........................................................................

    bool is_packed() const;

    //.........................................................................
    // Returns a copy of this image where the pitch == width * depth

    Image * make_packed_copy() const;

    //.........................................................................
    // Makes a wholesale copy of the image

    Image * make_copy() const;

    //.........................................................................
    // For WebGL, flips the image vertically

    void flip_y();

    //.........................................................................
    // Premultiplies alpha

    void premultiply_alpha();

    static void premultiply_alpha( TPImage * image );

    const JSON::Object & get_tags() const;

    //.........................................................................

    static void destroy( void * image );

private:

    friend class Images;

    Image();

    Image( TPImage * );

    Image( const Image & );

    Image * convert_to_cairo_argb32() const;

    void load_tags( const gchar * filename );
    void load_tags( gpointer data , gsize size );

    TPImage * 		image;
    JSON::Object 	tags;
};

//=============================================================================

class Images
{
public:

    //.........................................................................

    static void set_external_decoder( TPContext * context , TPImageDecoder decoder, gpointer decoder_data );

    //.........................................................................
    // Decodes an image and gives it to the Clutter texture.

    static bool load_texture( ClutterTexture * texture, gpointer data, gsize size, const char * content_type = NULL );

    static bool load_texture( ClutterTexture * texture, const char * filename );

    //.........................................................................
    // Loads the the decoded image into a Clutter texture.

    static void load_texture( ClutterTexture * texture, const Image * image , guint x = 0 , guint y = 0 , guint w = 0 , guint h = 0 );

    //.........................................................................
    // Destroys the Images singleton and frees all the decoders.

    static void shutdown();

    //.........................................................................
    // ABC for image decoders.

    class Decoder
    {
    public:
    	virtual ~Decoder() {};
        virtual const char * name() = 0;
        virtual int decode( gpointer data, gsize size, TPImage * image ) = 0;
        virtual int decode( const char * filename, TPImage * image ) = 0;
    };

    //.........................................................................

    static void add_to_image_list( ClutterTexture * texture , bool cached = false );

    //.........................................................................
    // Prints out a list of all loaded Clutter textures along with their
    // dimension and size

    static void dump();

    //.........................................................................

    static bool cache_put( TPContext * context , const String & key , CoglHandle texture , const JSON::Object & tags );

    static CoglHandle cache_get( const String & key , JSON::Object & tags );

    static bool cache_has( const String & key );

    // Prints out the cache contents, when the cache is enabled

    static void dump_cache();

private:

    friend class Image;

    Images();

    ~Images();

    Images( const Images & );

    //.........................................................................
    // Loads the the decoded image into a Clutter texture.

    static void load_texture( ClutterTexture * texture, TPImage * image , guint x = 0 , guint y = 0 , guint w = 0 , guint h = 0 );

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

#ifndef GLIB_VERSION_2_32
    GStaticRecMutex mutex;
#else
    GRecMutex mutex;
#endif

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

    class Cache
    {
    public:

    	Cache( int limit );

    	virtual ~Cache();

    	bool put( const String & key , CoglHandle texture , const JSON::Object & tags );

    	CoglHandle get( const String & key , JSON::Object & tags );

    	bool has( const String & key );

    	void dump();

    private:

    	int			limit;
    	double		size;

    	//.....................................................................
    	// Entries we keep in the cache

    	class Entry
    	{
    	public:

    		Entry( CoglHandle handle , const JSON::Object & tags );

    		virtual ~Entry();

    		void update_timestamp();

    		CoglHandle		handle;
    		double			timestamp;
    		double			size;
    		JSON::Object	tags;

    	private:

    		Entry() {};
    		Entry( const Entry & ) {};
    	};

    	typedef std::map< String , Entry * > Map;

    	Map			map;

    	//.....................................................................
    	// Pruning

    	typedef std::pair< String , Entry * > PruneEntry;

    	typedef std::vector< PruneEntry > PruneVector;

    	static bool prune_sort( const PruneEntry & a , const PruneEntry & b );

    	void prune();

    };

    Cache *			cache;

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
            bytes( image->width * image->height * image->depth )
        {}

        ImageInfo( ClutterTexture * texture )
        :
        	width( 0 ),
        	height( 0 ),
        	bytes( 0 )
        {
        	if ( texture )
        	{
        		gint w;
        		gint h;

        		clutter_texture_get_base_size( texture , & w , & h );

        		int bpp = 0;

        		switch( clutter_texture_get_pixel_format( texture ) )
        		{
        		case COGL_PIXEL_FORMAT_A_8:
        		case COGL_PIXEL_FORMAT_G_8:
        			bpp = 1;
        			break;

        		case COGL_PIXEL_FORMAT_RGB_565:
        		case COGL_PIXEL_FORMAT_RGBA_4444:
        		case COGL_PIXEL_FORMAT_RGBA_5551:
        		case COGL_PIXEL_FORMAT_RGBA_4444_PRE:
        		case COGL_PIXEL_FORMAT_RGBA_5551_PRE:
        			bpp = 2;
        			break;

        		case COGL_PIXEL_FORMAT_RGB_888:
        		case COGL_PIXEL_FORMAT_BGR_888:
        			bpp = 3;
        			break;

        		case COGL_PIXEL_FORMAT_RGBA_8888:
        		case COGL_PIXEL_FORMAT_BGRA_8888:
        		case COGL_PIXEL_FORMAT_ARGB_8888:
        		case COGL_PIXEL_FORMAT_ABGR_8888:
        		case COGL_PIXEL_FORMAT_RGBA_8888_PRE:
        		case COGL_PIXEL_FORMAT_BGRA_8888_PRE:
        		case COGL_PIXEL_FORMAT_ARGB_8888_PRE:
        		case COGL_PIXEL_FORMAT_ABGR_8888_PRE:
        			bpp = 4;
        			break;

        		case COGL_PIXEL_FORMAT_ANY: // not sure
        		case COGL_PIXEL_FORMAT_YUV: // not supported by cogl
        			bpp = 0;
        			break;

#ifdef CLUTTER_VERSION_1_10

                case COGL_PIXEL_FORMAT_RGBA_1010102:
                case COGL_PIXEL_FORMAT_BGRA_1010102:
                case COGL_PIXEL_FORMAT_ARGB_2101010:
                case COGL_PIXEL_FORMAT_ABGR_2101010:
                case COGL_PIXEL_FORMAT_RGBA_1010102_PRE:
                case COGL_PIXEL_FORMAT_BGRA_1010102_PRE:
                case COGL_PIXEL_FORMAT_ARGB_2101010_PRE:
                case COGL_PIXEL_FORMAT_ABGR_2101010_PRE:
                    bpp = 0;
                    break;
#endif

        		}

        		width = w;
        		height = h;
        		bytes = width * height * bpp;
        	}
        }

        guint width;
        guint height;
        guint bytes;
    };

    typedef std::map< gpointer, ImageInfo > ImageMap;

    static void add_to_image_list( ClutterTexture * texture , const ImageInfo & info );

    ImageMap        images;

    static bool compare( std::pair< gpointer , ImageInfo > a, std::pair< gpointer , ImageInfo > b );

#endif

};

//-----------------------------------------------------------------------------
// A structure we attach to ClutterTexture to keep track of extra stuff

class ImageExtra
{

public:

	static ImageExtra * get( gpointer texture )
	{
		ImageExtra * result = ( ImageExtra * ) g_object_get_data( G_OBJECT( texture ), "tp-image-extra" );

		if ( ! result )
		{
			result = new ImageExtra();

			g_object_set_data_full( G_OBJECT( texture ), "tp-image-extra", result, ( GDestroyNotify ) ImageExtra::destroy );
		}

		return result;
	}

	bool           constructing;
	bool           loaded;
	bool           async;
	bool           read_tags;
	JSON::Object   tags;

private:

    ImageExtra()
    :
        constructing( false ),
        loaded( false ),
        async( false ),
        read_tags( false )
    {
    }

    ~ImageExtra()
    {
    }

    ImageExtra( const ImageExtra & )
    {
    }

    static void destroy( ImageExtra * me )
    {
        delete me;
    }
};

#endif // _TRICKPLAY_IMAGES_H
