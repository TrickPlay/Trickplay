#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>
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
    
    class Source
    {
    public:
        Source( SpriteSheet * sheet ) : sheet( sheet ), texture( NULL ), refs( 0 ) {};
        ~Source();
        
        void load_image( Image * image );
        TP_CoglTexture get_texture();
        void ref_inc() { refs += 1; g_message( "Ref'ed, now %i", refs ); }
        void ref_dec();
        
        SpriteSheet * sheet;
        
    private:
        TP_CoglTexture texture;
        int refs;
    };
    
  
    static bool class_initialized;
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    ~SpriteSheet();

    Source * add_source();
    //bool is_initialized();

    void map_subtexture( const char * id, int x, int y, int w, int h );
    CoglHandle get_subtexture( const char * id );
    GList * get_ids();
    void dump();
    //void make_material_from_subtexture( const char * id, CoglMaterial ** material, int * w, int * h );

    GObject * extra;

private:
    GHashTable * sprites;
    GPtrArray  * sources;

    //inline void check_initialized() { if ( ! g_ptr_array_index( this->textures, 0 ) ) g_error( "SpriteSheet not initialized" ); }
};

#endif
