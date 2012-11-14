#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>
#include "common.h"
#include "app_resource.h"
#include "bitmap.h"
#include "util.h"

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
    
    class Source
    {
    public:
        Source( SpriteSheet * sheet ) : sheet( sheet ), texture( NULL ), refs( 0 ) {};
        ~Source();
        
        void set_source( const char * path );
        void set_source( Bitmap * bitmap );
        void load_image( Image * image );
        void get_dimensions( int * w, int * h );
        CoglHandle get_subtexture( int x, int y, int w, int h );
        
        void ref() { refs++; g_message( "Ref'ed, now %i", refs ); }
        void deref();
        
        SpriteSheet * sheet;
        
    private:
        void ensure();
        
        TP_CoglTexture texture;
        int refs;
    };

    class Sprite
    {
    public:
        Sprite() : id( NULL ), init( true ) {};
        void set( const char * _id, Source * _source, int _x, int _y, int _w, int _h )
        {
            id = _id;
            source = _source;
            x = _x; y = _y; w = _w; h = _h;
        }
        
        CoglHandle get_subtexture();
        const char * id;
        
    private:
        Source * source;
        int x, y, w, h;
        bool init;
    };
    
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    ~SpriteSheet();

    Source * add_source();

    void emit_signal( const char * msg );
    void map_subtexture( const char * id, int x, int y, int w, int h );
    CoglHandle get_subtexture( const char * id );
    std::list< const char * > * get_ids();

    App * app;
    GObject * extra;
    bool async;
    bool weak;

private:
    std::map < std::string, Sprite > sprites;
    std::list < Source > sources;
};

#endif
