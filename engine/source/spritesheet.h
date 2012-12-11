#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include <clutter/clutter.h>
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
    
    class Source : public PushTexture
    {
        public:
            Source( SpriteSheet * sheet ) : sheet( sheet ), uri( NULL ) {};
            
            void set_source( const char * uri );
            void set_source( Image * image );
            
            CoglHandle get_subtexture( int x, int y, int w, int h );
            
            SpriteSheet * sheet;
            
        private:
            static void async_img_callback( Image * image, Source * source ) { source->handle_async_img( image ); }
            void handle_async_img( Image * image );
            
            void on_sync_change() {};
            void make_texture();
            void lost_texture() {};
            
            std::string cache_key;
            const char * uri;
    };
    
    class Sprite : public PushTexture
    {
        public:
            Sprite() : source( NULL ), id( NULL ) {};
            
            void set( const char * _id, Source * _source, int _x, int _y, int _w, int _h )
            {
                id = _id;
                source = _source;
                x = MAX( _x, 0 ); y = MAX( _y, 0 ); w = _w; h = _h;
            }
            
            void update();
            void get_natural_dimensions( int * _w, int * _h ) { * _w = w; * _h = h; }
            const char * get_id() { return id; }
            
        private:
            void on_sync_change();
            void make_texture();
            void lost_texture();
            
            PushTexture::PingMe ping;
            Source * source;
            const char * id;
            int x, y, w, h;
    };
    
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    ~SpriteSheet();
    
    void load_json( const char * json );
    void parse_json( const JSON::Value & root );

    Source * add_source();

    void emit_signal( const char * msg );
    void add_sprite( Source * source, const char * id, int x, int y, int w, int h );
    
    Sprite * get_sprite( const char * id );
    std::list< std::string > * get_ids();
    
    bool has_id( const char * id );

    App * app;
    GObject * extra;
    bool async;
    
    friend class Source;

private:
    char * native_json_path;
    std::map < std::string, Sprite > sprites;
    std::list < Source > sources;
};

#endif
