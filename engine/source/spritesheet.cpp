#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"

typedef SpriteSheet::Source Source;
typedef SpriteSheet::Sprite Sprite;

CoglHandle Sprite::ref_subtexture()
{
    if ( init )
    {
        init = false;
        int tw, th;
        source->get_dimensions( &tw, &th );
        
        x = MAX( x, 0 );
        y = MAX( y, 0 );
        w = MIN( w < 0 ? tw : x + w, tw ) - x;
        h = MIN( h < 0 ? th : y + h, th ) - y;
    }
    
    return source->get_subtexture( x, y, w, h );
}

void Sprite::deref_subtexture()
{
    source->deref();
}

Source::~Source()
{
    if ( texture ) cogl_handle_unref( texture );
}

class UnloadSignal : public Action
{
public:
    UnloadSignal( Source * source ) : source( source ) {}

protected:
    bool run()
    {
        source->deref_signal();
        return false;
    }

private:
    Source * source;
};

void Source::deref()
{
    refs = MAX( 0, refs - 1 );
    
    g_message( "Deref'ed, now %i", refs );
    
    if ( !refs && sheet->weak && can_signal )
    {
        Action::post( new UnloadSignal( this ) );
        can_signal = false;
    }
}

void Source::deref_signal()
{
    g_message( "Sourse::deref_signal %i", refs );
    
    if ( !refs )
    {
        cogl_handle_unref( texture );
        texture = NULL;
    }
    
    can_signal = true;
}

void Source::ensure()
{
    if ( !texture )
    {
        g_message( "Source::load" );
        
        if ( !image )
        {
            g_error( "Source image has not been loaded." );
        }
        
        ClutterActor * actor = clutter_texture_new();
        Images::load_texture( CLUTTER_TEXTURE( actor ), image );
        texture = TP_COGL_TEXTURE( clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) ) );
        
        cogl_handle_ref( texture );
        
        clutter_actor_destroy( actor );
    }
}

void async_img_callback( Image * image, Source * source )
{
    source->image = image ;
    source->sheet->emit_signal( image ? NULL : "FAILED_IMG_LOAD" );
}

void Source::set_source( const char * path )
{
    if ( sheet->async )
    {
        sheet->app->load_image_async( path, false, (Image::DecodeAsyncCallback) async_img_callback, this, 0 );
    }
    else
    {
        image = sheet->app->load_image( path, false );
    }
}

void Source::set_source( Bitmap * bitmap )
{
    image = bitmap->get_image();
}

void Source::get_dimensions( int * w, int * h )
{
    ensure();
    * w = cogl_texture_get_width ( texture );
    * h = cogl_texture_get_height( texture );
}

CoglHandle Source::get_subtexture( int x, int y, int w, int h )
{
    ensure();
    ref();
    return cogl_texture_new_from_sub_texture( texture, x, y, w, h );
}

/* SpriteSheet */

SpriteSheet::SpriteSheet() :
    extra( G_OBJECT( g_object_new( G_TYPE_OBJECT, NULL ) ) )
{
    g_object_set_data( extra, "tp-sheet", this );

    static bool init( true );
    if ( init )
    {
        init = false;
        g_signal_new( "load-finished", G_TYPE_OBJECT, G_SIGNAL_RUN_FIRST,
            0, 0, 0, 0, G_TYPE_NONE, 1, G_TYPE_POINTER );
    }
}

SpriteSheet::~SpriteSheet()
{
    g_free( extra );
}

void SpriteSheet::emit_signal( const char * msg )
{
    g_signal_emit_by_name( extra, "load-finished", msg );
}

Source * SpriteSheet::add_source()
{
    sources.push_back( Source( this ) );
    return & sources.back();
}

void SpriteSheet::map_subtexture( const char * id, int x, int y, int w, int h )
{
    if ( sources.empty() )
    {
        g_error( "Trying to map sprite id '%s' before any source textures have been added.", id );
    }
    
    sprites[ std::string( id ) ].set( id, & sources.back(), x, y, w, h );
}

Sprite * SpriteSheet::get_sprite( const char * id )
{
    if ( sprites.count( id ) )
    {
        return & sprites[ std::string( id ) ];
    }
    return NULL;
}

CoglHandle SpriteSheet::get_subtexture( const char * id )
{
    Sprite * sprite = get_sprite( id );
    
    if ( !sprite )
    {
        g_warning( "Trying to use unknown sprite id '%s'.", id );
        return NULL;
    }
    
    return sprite->ref_subtexture();
}

std::list< const char * > * SpriteSheet::get_ids() // untested
{
    std::list< const char * > * ids = new std::list< const char * >;
    for ( std::map< std::string, Sprite >::iterator it = sprites.begin(); it != sprites.end(); ++it )
    {
        ids->push_back( it->first.c_str() );
    }
    
    return ids;
}
