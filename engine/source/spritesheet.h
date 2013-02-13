#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include "tp-clutter.h"
#include <stdlib.h>
#include "common.h"
#include "app_resource.h"
#include "util.h"
#include "pushtexture.h"

#ifdef CLUTTER_VERSION_1_10
#define TP_COGL_TEXTURE(t) (COGL_TEXTURE(t))
#define TP_CoglTexture CoglTexture *
#else
#define TP_COGL_TEXTURE(t) (t)
#define TP_CoglTexture CoglHandle
#endif

class SpriteSheet : public RefCounted
{
public:
    
    // A source image owned by the spritesheet, which sprites will refer into to get their textures
    
    class Source : public PushTexture
    {
        public:
            Source( SpriteSheet * s ) : sheet( s ), source_uri( NULL ) { g_assert(s); };
            ~Source() { if (source_uri) g_free(source_uri); }
            
            void set_source( const char * uri );
            void set_source( Image * image );
            
            // Guaranteed to return a Cogl texture of the right size,
            // but will be empty/transparent if the source image isn't loaded yet or the coords are out of bounds
            
            CoglHandle get_subtexture( int x, int y, int w, int h );
            
            SpriteSheet * sheet;
            
        private:
            static void async_img_callback( Image * image, Source * source ) { source->handle_async_img( image ); }
            void handle_async_img( Image * image );
            
            void make_texture( bool immediately );
            void lost_texture() {};
            
            std::string cache_key;
            char * source_uri;
    };
    
    // A sprite within the spritesheet, which other objects can take pointers to
    // Use PushTexture's PingMe and get_texture() to interface with it
    
    class Sprite : public PushTexture
    {
        public:
            Sprite() : source( NULL ), x(0), y(0), w(0), h(0) {};
            ~Sprite() {}

            void assign( Source * _source, int _x, int _y, int _w, int _h )
            {
                g_assert( _source );
                source = _source;
                x = MAX( _x, 0 ); y = MAX( _y, 0 ); w = _w; h = _h;
            }
            
            void update();
            void get_natural_dimensions( int * _w, int * _h ) { * _w = w; * _h = h; }
            
        private:
            void make_texture( bool immediately );
            void lost_texture();

            PushTexture::PingMe ping;
            Source * source;
            int x, y, w, h;
    };
    
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    ~SpriteSheet();
    
    // load_json() will load (possibly asynchronously) a JSON map from a URI, parse it, and then call parse_json() on it
    
    void load_json( const char * json );
    void parse_json( const JSON::Value & root );

    // SpriteSheet-creation functions will use this to register new source images and sprites with the spritesheet

    Source * add_source();
    void add_sprite( Source * source, const char * id, int x, int y, int w, int h );

    // Fires off the "load-finished" GSignal on this spritesheet if asynchronous, or emits a g_warning

    void emit_signal( const char * msg );
    
    // Other objects will use this to map an id to a sprite in this spritesheet
    
    Sprite * get_sprite( const char * id );
    std::list< std::string > * get_ids();
    
    bool has_id( const char * id );

    char * get_json_uri() { return json_uri ? json_uri : (char *) ""; }

    App * app;
    GObject * extra;
    bool async;
    bool loaded;

private:
    char * json_uri;
    std::map < std::string, Sprite * > * sprites;
    std::list < Source * > * sources;
};

#endif
