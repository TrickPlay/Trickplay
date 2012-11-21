#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>
#include "common.h"
#include "app_resource.h"
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
    
    class RefTexture
    {
        public:
            
            class Signal : public Action
            {
                RefTexture * self;
                
                public: Signal( RefTexture * self ) : self( self ) {}
                
                protected: bool run()
                {
                    self->deref_signal();
                    return false;
                }
            };
            
            RefTexture() : texture( NULL ), can_signal( true ), refs( 0 ) {};
            ~RefTexture();
            
            CoglHandle ref_texture();
            void deref_texture();
            void deref_signal();
            
        protected:
            virtual CoglHandle make_texture() = 0;
            virtual void before_deref_signal() = 0;
            
        private:
            CoglHandle texture;
            bool can_signal;
            int refs;
    };
    
    class Source : public RefTexture
    {
        public:
            Source( SpriteSheet * sheet ) : sheet( sheet ), image( NULL ) {};
            
            void load( Image * image );
            void get_dimensions( int * w, int * h );
            CoglHandle ref_subtexture( int x, int y, int w, int h );
            CoglHandle make_texture();
            
            SpriteSheet * sheet;
            
        private:
            void before_deref_signal() {};
            
            Image * image;
    };

    class Sprite : public RefTexture
    {
        public:
            Sprite() : id( NULL ) {};
            
            void set( const char * _id, Source * _source, int _x, int _y, int _w, int _h )
            {
                id = _id;
                source = _source;
                x = _x; y = _y; w = _w; h = _h;
            }
            
            int get_w() { return w; }
            int get_h() { return h; }
            const char * get_id() { return id; }
            CoglHandle make_texture();
            
        private:
            void before_deref_signal() { source->deref_texture(); };
            
            Source * source;
            const char * id;
            int x, y, w, h;
    };
    
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    ~SpriteSheet();

    Source * add_source();

    void emit_signal( const char * msg );
    void map_subtexture( const char * id, int x, int y, int w, int h );
    
    Sprite * get_sprite( const char * id );
    std::list< std::string > * get_ids();

    GObject * extra;
    char * native_json_path;
    bool async;

private:
    std::map < std::string, Sprite > sprites;
    std::list < Source > sources;
};

#endif
