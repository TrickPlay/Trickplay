#include "spritesheet.h"
#include <glib.h>
#include <string.h>
#include <stdio.h>

#include "log.h"

void log_subtexture( gpointer id_ptr , gpointer subtexture_ptr , gpointer none );
void init_extra( SpriteSheet * sheet );

bool SpriteSheet::class_initialized = false;

SpriteSheet::SpriteSheet() : map(g_hash_table_new_full( g_str_hash , g_str_equal , g_free , g_free )) , texture(0) {
    init_extra( this );
}

SpriteSheet::SpriteSheet ( CoglHandle texture ) : map(g_hash_table_new_full( g_str_hash , g_str_equal , g_free , g_free )) , texture(cogl_handle_ref(texture)) {
    init_extra( this );
}

SpriteSheet::~SpriteSheet()
{
    g_hash_table_destroy( map );
    cogl_handle_unref( texture );
    g_free( extra );
}

void SpriteSheet::set_texture( CoglHandle texture )
{
    if ( this->texture )
    {
        g_error( "SpriteSheet texture is already set." );
    }

    this->texture = texture;
}

bool SpriteSheet::is_initialized()
{
    return this->texture ? true : false;
}

bool SpriteSheet::map_subtexture( const gchar * id , int x , int y , int w , int h )
{
    check_initialized();
    CoglHandle subtexture = cogl_texture_new_from_sub_texture( COGL_TEXTURE( texture ) , x , y , w , h );

    // We don't need the extra reference taken by cogl_texture_new_from_sub_texture
    cogl_handle_unref( texture );

    if ( subtexture )
    {
        g_hash_table_insert( map , (gpointer) id , (gpointer) subtexture );
        return true;
    }

    return false;
}

CoglHandle SpriteSheet::get_subtexture( const gchar * id )
{
    check_initialized();
    return (CoglHandle) g_hash_table_lookup( map , id );
}

GList * SpriteSheet::get_ids()
{
    return g_hash_table_get_keys( map );
}

void SpriteSheet::dump()
{
    tpinfo( "{" );
    g_hash_table_foreach( map , (GHFunc) log_subtexture , NULL );
    tpinfo( "}" );
}

void SpriteSheet::make_material_from_subtexture( const gchar * id , CoglMaterial ** material , int * w , int * h )
{
    check_initialized();

    CoglHandle subtexture_handle = (CoglHandle) g_hash_table_lookup( map , id );

    if ( ! subtexture_handle )
    {
        g_error( "No subtexture with id '%s' found in this SpriteSheet!" , id );
        return;
    }

    CoglTexture * subtexture = COGL_TEXTURE( subtexture_handle );

    CoglMaterial * new_material = cogl_material_new();
    cogl_material_set_layer( new_material , 0 , subtexture );

    *material = new_material;
    *w = cogl_texture_get_width( subtexture );
    *h = cogl_texture_get_height( subtexture );
}

void log_subtexture( gpointer id_ptr , gpointer subtexture_ptr , gpointer none )
{
    CoglTexture * subtexture = COGL_TEXTURE( (CoglHandle) subtexture_ptr );

    gchar * id = (gchar*) id_ptr;
    int     w = cogl_texture_get_width( subtexture );
    int     h = cogl_texture_get_height( subtexture );

    tplog( "\t%15s : %10dx%-10d" , id , w , h );
}

void init_extra( SpriteSheet * sheet )
{
    sheet->extra = G_OBJECT(g_object_new( G_TYPE_OBJECT , NULL ));
    g_object_set_data( sheet->extra , "tp-sheet" , sheet );

    if ( ! SpriteSheet::class_initialized )
    {
        g_signal_new(
            "load-finished",
            G_TYPE_OBJECT,
            G_SIGNAL_RUN_FIRST,
            0, 0, 0, 0,
            G_TYPE_NONE,
            1,
            G_TYPE_POINTER
        );

        SpriteSheet::class_initialized = true;
    }
}
