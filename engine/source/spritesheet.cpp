#include <cogl/cogl.h>
#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"
 
//void log_subtexture( gpointer id_ptr, gpointer subtexture_ptr, gpointer none );
//void init_extra( SpriteSheet * sheet );

bool SpriteSheet::class_initialized = false;

typedef SpriteSheet::Source Source;

class Sprite
{
public:
    Sprite( const char * id, Source * source, int x, int y, int w, int h )
      : id( id ), source( source ), x( x ), y( y ), w( w ), h( h ), dirty( true ) {};
    
    CoglHandle get_subtexture()
    {
        TP_CoglTexture texture = source->get_texture();
        
        if ( !texture )
        {
            g_error( "Trying to use sprite id '%s' before its source texture has been loaded.", id );
            return NULL;
        }
    
        if ( dirty )
        {
            dirty = false;
            int tw = cogl_texture_get_width ( texture ),
                th = cogl_texture_get_height( texture );
            
            x = MAX( x, 0 );
            y = MAX( y, 0 );
            w = MIN( w < 0 ? tw : x + w, tw ) - x;
            h = MIN( h < 0 ? th : y + h, th ) - y;
        }
        
        source->ref_inc();
        return cogl_texture_new_from_sub_texture( texture, x, y, w, h );
    }
    
private:
    const char * id;
    Source * source;
    int x, y, w, h;
    bool dirty;
};

Source::~Source()
{
    if ( texture ) cogl_handle_unref( texture );
}

static CoglUserDataKey source_key;
void source_key_destroy( Source * source ) { source->ref_dec(); }

void Source::load_image( Image * image )
{
    g_message( "Source::load" );
    
    ClutterActor * actor = clutter_texture_new();
    Images::load_texture( CLUTTER_TEXTURE( actor ), image );
    texture = TP_COGL_TEXTURE( clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) ) );
    
    cogl_handle_ref( texture );
    
    //cogl_object_set_user_data( COGL_OBJECT( texture ), &source_key,
    //    this, (CoglUserDataDestroyCallback) source_key_destroy );
    
    clutter_actor_destroy( actor );
}

void Source::ref_dec()
{
    refs -= 1;
    
    g_message( "Deref'ed, now %i", refs );
    
    if ( !refs )
    {
        // do some kind of release
        
    }
}

TP_CoglTexture Source::get_texture()
{
    return texture;
}

void sprite_free( Sprite * sprite ) { delete sprite; }
void source_free( Source * source ) { delete source; }

SpriteSheet::SpriteSheet() :
    extra( G_OBJECT( g_object_new( G_TYPE_OBJECT, NULL ) ) ),
    sprites( g_hash_table_new_full( g_str_hash, g_str_equal, g_free, (GDestroyNotify) sprite_free ) ),
    sources( g_ptr_array_new_with_free_func( (GDestroyNotify) source_free ) )
{
    g_object_set_data( extra, "tp-sheet", this );

    if ( ! SpriteSheet::class_initialized )
    {
        SpriteSheet::class_initialized = true;
        g_signal_new(
            "load-finished",
            G_TYPE_OBJECT,
            G_SIGNAL_RUN_FIRST,
            0, 0, 0, 0,
            G_TYPE_NONE,
            1,
            G_TYPE_POINTER
        );
    }
}

SpriteSheet::~SpriteSheet()
{
    g_hash_table_destroy( sprites );
    g_ptr_array_free( sources, TRUE );
    g_free( extra );
}

Source * SpriteSheet::add_source()
{
    Source * source = new Source( this );
    g_ptr_array_add( sources, source );
    return source;
}

void SpriteSheet::map_subtexture( const char * id, int x, int y, int w, int h )
{
    if ( !sources->len )
    {
        g_error( "Trying to map sprite id '%s' before any source textures have been added.", id );
    }
    
    Source * source = (Source *) g_ptr_array_index( sources, sources->len - 1 );
    g_hash_table_insert( sprites, (char *) id, new Sprite( id, source, x, y, w, h ) );
}

CoglHandle SpriteSheet::get_subtexture( const char * id )
{
    Sprite * sprite = (Sprite *) g_hash_table_lookup( sprites, (char *) id );
    
    if ( !sprite )
    {
        g_error( "Trying to use unknown sprite id '%s'.", id );
        return NULL;
    }
        
    return sprite->get_subtexture();
}

GList * SpriteSheet::get_ids()
{
    return g_hash_table_get_keys( sprites );
}

void SpriteSheet::dump()
{
    //tpinfo( "{" );
    //g_hash_table_foreach( map, (GHFunc) log_subtexture, NULL );
    //tpinfo( "}" );
}

/*

bool SpriteSheet::is_initialized()
{
    return g_ptr_array_index( sources, 0 ) ? true : false;
}

void SpriteSheet::make_material_from_subtexture( const gchar * id, CoglMaterial ** material, int * w, int * h )
{
    check_initialized();

    CoglHandle subtexture_handle = (CoglHandle) g_hash_table_lookup( map, id );

    if ( ! subtexture_handle )
    {
        g_error( "No subtexture with id '%s' found in this SpriteSheet!", id );
        return;
    }

    TP_CoglTexture subtexture = TP_COGL_TEXTURE( subtexture_handle );

    CoglMaterial * new_material = cogl_material_new();
    cogl_material_set_layer( new_material, 0, subtexture );

    * material = new_material;
    * w = cogl_texture_get_width( subtexture );
    * h = cogl_texture_get_height( subtexture );
}

void log_subtexture( gpointer id_ptr, gpointer subtexture_ptr, gpointer none )
{
    TP_CoglTexture subtexture = TP_COGL_TEXTURE( (CoglHandle) subtexture_ptr );

    gchar * id = (gchar*) id_ptr;
    int     w = cogl_texture_get_width( subtexture );
    int     h = cogl_texture_get_height( subtexture );

    tplog( "\t%15s : %10dx%-10d", id, w, h );
}
*/
