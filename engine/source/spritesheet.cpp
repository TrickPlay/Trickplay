#include "pushtexture.h"
#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"

typedef SpriteSheet::Source Source;
typedef SpriteSheet::Sprite Sprite;

/* Source */

CoglHandle ref_texture_from_image( Image * image )
{
    g_assert( image );
    
    ClutterActor * actor = clutter_texture_new();
    Images::load_texture( CLUTTER_TEXTURE( actor ), image );
    
    CoglHandle texture = (CoglHandle) clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) );
    cogl_handle_ref( texture );
    
    clutter_actor_destroy( actor );
    
    return texture;
}

void Source::handle_async_img( Image * image )
{
    if ( image )
    {
        CoglHandle texture = ref_texture_from_image( image );
        set_texture( texture );
        delete image;
        
        Images::cache_put( sheet->app->get_context(), cache_key, texture, JSON::Object() );
        
        ping_all();
    }
    else
    {
        g_warning( "Could not download image %s", uri );
    }
}

void Source::make_texture()
{
    g_assert( uri );
    
    JSON::Object * jo = new JSON::Object();
    CoglHandle texture = Images::cache_get( cache_key, * jo );
    delete jo;
    
    if ( all_pings_async )
    {
        if ( texture == COGL_INVALID_HANDLE )
        {
            sheet->app->load_image_async( uri, false, (Image::DecodeAsyncCallback) Source::async_img_callback, this, NULL );
            texture = cogl_texture_new_with_size( 1, 1, COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 );
        }
        else
        {
            ping_all_later();
        }
        
        set_texture( texture );
    }
    else
    {
        if ( texture == COGL_INVALID_HANDLE )
        {
            Image * image = sheet->app->load_image( uri, false );
            texture = ref_texture_from_image( image );
            delete image;
            
            Images::cache_put( sheet->app->get_context(), cache_key, texture, JSON::Object() );
        }
        
        set_texture( texture );
        ping_all();
    }
}

void Source::set_source( const char * _uri )
{
    if ( sheet->native_json_path )
    {
        char * json = g_path_get_dirname( sheet->native_json_path );
        uri = g_build_filename( json, _uri, NULL );
        free( json );
    }
    else
    {
        uri = strdup( _uri );
    }
    
    cache_key = sheet->app->get_id() + ':' + uri;
}

void Source::set_source( Image * image )
{
    set_texture( ref_texture_from_image( image ) );
    cache = true;
}

CoglHandle Source::get_subtexture( int x, int y, int w, int h )
{
    int tw, th;
    get_dimensions( &tw, &th );
    
    if ( w < 0 ) tw = MAX( tw - x, 0 );
    if ( h < 0 ) th = MAX( th - y, 0 );
    
    if ( tw < x + w || th < y + h )
    {
        return cogl_texture_new_with_size( MAX( w, 1 ), MAX( h, 1 ), COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 );
    }
    
    return cogl_texture_new_from_sub_texture( (TP_CoglTexture) get_texture(), x, y, w, h );
}

/* Sprite */

void Sprite::update()
{
    g_assert( source );
    set_texture( cogl_handle_ref( source->get_subtexture( x, y, w, h ) ) );
    ping_all();
}

void on_ping( PushTexture * source, void * target )
{
    ((Sprite *) target)->update();
}

void Sprite::on_sync_change()
{
    g_assert( source );
    
    ping.set( source, * on_ping, this, all_pings_async );
}

void Sprite::make_texture()
{
    on_sync_change();
    update();
}

void Sprite::lost_texture()
{
    ping.set( NULL, NULL, NULL, true );
}

/* SpriteSheet */

class AsyncCallback : public Action
{
    SpriteSheet * self;
    bool failed;
    
    public: AsyncCallback( SpriteSheet * self, bool failed ) : self( self ), failed( failed ) {}
    
    protected: bool run()
    {
        g_signal_emit_by_name( self->extra, "load-finished", GINT_TO_POINTER( failed ) );
        return false;
    }
};

SpriteSheet::SpriteSheet() : app( NULL ), extra( G_OBJECT( g_object_new( G_TYPE_OBJECT, NULL ) ) ), async( false ), loaded( false ), native_json_path( NULL )
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
    if ( native_json_path ) g_free( native_json_path );
}

void SpriteSheet::emit_signal( const char * msg )
{
    if ( async )
    {
        Action::post( new AsyncCallback( this, msg != NULL ) );
    }
    else if ( msg )
    {
        g_warning( "SpriteSheet: %s", msg );
    }
}

void SpriteSheet::parse_json ( const JSON::Value & root )
{
    if ( root.is<JSON::Array>() )
    {
        JSON::Array & maps = (JSON::Array &) root.as<JSON::Array>();
        
        for ( unsigned i = 0; i < maps.size(); i++ )
        {
            JSON::Object & map = (JSON::Object &) maps[i].as<JSON::Object>();

            Source * source = add_source();
            source->set_source( map.at( "img" ).as<std::string>().c_str() );
            JSON::Array & sprites = (JSON::Array &) map.at( "sprites" ).as<JSON::Array>();

            for( unsigned i = 0; i < sprites.size(); i++ )
            {
                JSON::Object & sprite = (JSON::Object &) sprites[i].as<JSON::Object>();
                
                add_sprite( source, strdup( sprite.at( "id" ).as<std::string>().c_str() ),
                    (int) sprite.at( "x" ).as<long long>(),
                    (int) sprite.at( "y" ).as<long long>(),
                    (int) sprite.at( "w" ).as<long long>(),
                    (int) sprite.at( "h" ).as<long long>() );
            }
        }
        
        loaded = true;
        emit_signal( NULL );
    }
    else
    {
        emit_signal( "Could not parse JSON map" );
    }
}

void async_map_callback ( const Network::Response & response, SpriteSheet * self )
{
    if ( !response.failed && response.body->len )
    {
        self->parse_json( JSON::Parser::parse( (char *) response.body->data, response.body->len ) );
    }
    else
    {
        self->emit_signal( "Could not download JSON map." );
    }
}

void SpriteSheet::load_json( const char * json )
{
    native_json_path = strdup( json );

    char * map = NULL;
    gsize length;
    

    if ( g_regex_match_simple( "^\\s*\\[", json, (GRegexCompileFlags) 0, (GRegexMatchFlags) 0 ) )
    {
        map = (char *) json;
        length = strlen( map );
    }
    else
    {
        AppResource resource( app, json );
        if ( resource.is_native() )
        {
            if ( ! g_file_get_contents( resource.get_native_path().c_str(), &map, &length, NULL ) )
            {
                emit_signal( g_strdup_printf( "Could not open map %s", json ) );
            }
        }
        else if ( resource.is_http() )
        {
            Network::Request request( app->get_user_agent(), resource.get_uri() );

            if ( async )
            {
                app->get_network()->perform_request_async( request, app->get_cookie_jar(),
                    (Network::ResponseCallback) async_map_callback, this, 0 );
            }
            else
            {
                Network::Response response = app->get_network()->perform_request( request, app->get_cookie_jar() );

                if ( response.failed || response.body->len == 0 )
                {
                    emit_signal( g_strdup_printf( "Could not download map %s", json ) );
                }

                map = (char *) response.body->data;
                length = response.body->len;
            }
        }
    }

    if ( map && length )
    {
        parse_json( JSON::Parser::parse( map, length ) );
    }
}

Source * SpriteSheet::add_source()
{
    g_assert( app );
    sources.push_back( Source( this ) );
    return & sources.back();
}

void SpriteSheet::add_sprite( Source * source, const char * id, int x, int y, int w, int h )
{
    g_assert( source );
    
    sprites[ std::string( id ) ].set( id, source, x, y, w, h );
}

Sprite * SpriteSheet::get_sprite( const char * id )
{
    if ( !id || !sprites.count( id ) )
    {
        return NULL;
    }
    
    return & sprites[ std::string( id ) ];
}

std::list< std::string > * SpriteSheet::get_ids()
{
    std::list< std::string > * ids = new std::list< std::string >();
    
    for ( std::map< std::string, Sprite >::iterator it = sprites.begin(); it != sprites.end(); ++it )
    {
        ids->push_back( it->first );
    }
    
    return ids;
}

bool SpriteSheet::has_id( const char * id )
{
    return id && sprites.count( id );
}
