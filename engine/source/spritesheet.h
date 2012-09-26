#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>
#include "util.h"

class SpriteSheet : public RefCounted
{
public:
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    SpriteSheet ( CoglHandle texture );
    ~SpriteSheet();

    void set_texture( CoglHandle texture );

    bool map_subtexture( const gchar * id , int x , int y , int w , int h );
    CoglHandle get_subtexture( const gchar * id );
    GList * get_ids();
    void dump();
    void make_material_from_subtexture( const gchar * id , CoglMaterial ** material , int * w , int * h );

private:
    GHashTable *map;
    CoglHandle texture;

    inline void check_initialized() { if ( ! texture ) g_error( "SpriteSheet not initialized" ); }
    SpriteSheet( const SpriteSheet& ){}
};

#endif
