#include "pushtexture.h"
#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"

typedef SpriteSheet::Source Source;
typedef SpriteSheet::Sprite Sprite;

/* Source */

// cogl_handle_ref will be called for the texture returned
CoglHandle ref_texture_from_image( Image* image, bool release )
{
    g_assert( image );

    ClutterActor* actor = clutter_texture_new();
    Images::load_texture( CLUTTER_TEXTURE( actor ), image );

    CoglHandle t = ( CoglHandle ) clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) );
    cogl_handle_ref( t );

    clutter_actor_destroy( actor );

    if ( release ) { delete( image ); }

    return t;
}

void Source::handle_async_img( Image* image )
{
    if ( image )
    {
        failed = false;
        cache = false; // When used next time, need to check cache to see whether in cache or not

        CoglHandle t = ref_texture_from_image( image, true );
        set_texture( t, true, true ); // Will update texture

        Images::cache_put( sheet->app->get_context(), cache_key, t, JSON::Object() );
    }
    else
    {
        failed = true;
        cache = false;

        g_warning( "Could not download image %s", source_uri );
        set_texture( NULL, false, true );
    }

    async_loading = false;
}

void Source::make_texture( bool immediately )
{
    g_assert( source_uri );
    g_assert( !cache ); // Should not reach this function if already in cache

    JSON::Object jo;
    CoglHandle cache_texture = Images::cache_get( cache_key, jo );

    if ( cache_texture != COGL_INVALID_HANDLE ) // In cache
    {
        failed = false;
        cache = true;

        set_texture( cogl_handle_ref( cache_texture ), true, true );

        return;
    }

    if ( immediately )
    {
        Image* image = sheet->app->load_image( source_uri, false );

        if ( image )
        {
            failed = false;
            CoglHandle t = ref_texture_from_image( image, true );
            set_texture( t, true, true ); // Will update texture

            // Set variable cache next time when used, because we do not know whether
            // this time the image is saved in cache properly or not.
            Images::cache_put( sheet->app->get_context(), cache_key, t, JSON::Object() );
        }
        else
        {
            failed = true;
            set_texture( NULL, false, true );
        }
    }
    else
    {
        if ( !async_loading )
        {
            async_loading = true;
            failed = false;
            sheet->app->load_image_async( source_uri, false, ( Image::DecodeAsyncCallback ) Source::async_img_callback, this, NULL );
            set_texture( NULL, false, false ); // Do not fire on_loaded event
        }
    }
}

void Source::set_source( const char* uri )
{
    AppResource resource( sheet->app, uri );

    if ( sheet->json_uri && resource.is_native() )
    {
        char* json_path = g_path_get_dirname( sheet->json_uri );
        source_uri = g_build_filename( json_path, uri, NULL );
        free( json_path );
    }
    else
    {
        source_uri = g_strdup( uri );
    }

    cache_key = sheet->app->get_id() + ':' + source_uri;
}

void Source::set_source( Image* image )
{
    // TODO: need to increase ref counter of image
    cache = true; // Coming from memory
    failed = false;

    set_texture( ref_texture_from_image( image, false ), true, true );
}

CoglHandle Source::get_subtexture( int x, int y, int w, int h )
{
    int tw, th;
    CoglHandle subtexture;
    get_dimensions( &tw, &th );

    if ( w < 0 ) { tw = MAX( tw - x, 0 ); }

    if ( h < 0 ) { th = MAX( th - y, 0 ); }

    if ( tw < x + w || th < y + h )
    {
        subtexture = cogl_texture_new_with_size( MAX( w, 1 ), MAX( h, 1 ), COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 );
    }
    else
    {
        subtexture = cogl_texture_new_from_sub_texture( ( TP_CoglTexture ) get_texture(), x, y, w, h );
    }

    return subtexture;
}

void Source::unsubscribe( PingMe* ping, bool release_now )
{
    pings.erase( ping );

    if ( can_signal && pings.empty() )
    {
        if ( release_now )
        {
            cache = false;
            release_texture(); // Will update failed and real
            can_signal = true;
        }
        else
        {
            action = new SpriteSheet::ReleaseLater( this );
            Action::post( action );
            can_signal = false; // Prevents a second instance of ReleaseSheet from being created
        }
    }
}

void Source::cancel_release_later()
{
    // Remove ReleaseLater from Action queue
    // so that Source instance can be immediately released

    g_assert( !can_signal );
    g_assert( action );

    Action::cancel( action );
    can_signal = true;
    action = NULL;
}

/* Sprite */

void Sprite::unsubscribe( PingMe* ping, bool release_now )
{
    pings.erase( ping );

    if ( pings.empty() ) // Sprite texture should always be release immediately
    {
        release_texture();
    }
}

void Sprite::update()
{
    g_assert( source );

    failed = source->is_failed();
    bool is_real = source->is_real();

    g_assert( !failed || !is_real );

    if ( !failed && is_real )
    {
        set_texture( source->get_subtexture( x, y, w, h ), true, true );
    }
    else
    {
        set_texture( cogl_handle_ref( cogl_texture_new_with_size( 1, 1, COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 ) ), false, true );
    }
}

void on_ping( PushTexture* source, void* target )
{
    ( ( Sprite* ) target )->update();
}

void Sprite::make_texture( bool immediately )
{
    ping.assign( source, * on_ping, this, immediately );
}

void Sprite::lost_texture()
{
    ping.assign( NULL, NULL, NULL, false ); // Unregister Sprite call back function
}

/* SpriteSheet */

class AsyncCallback : public Action
{
    SpriteSheet* self;
    bool failed;

public: AsyncCallback( SpriteSheet* s, bool f ) : self( s ), failed( f ) {}

protected: bool run()
    {
        g_signal_emit_by_name( self->extra, "load-finished", GINT_TO_POINTER( failed ) );
        self->can_fire = true;
        return false;
    }
};

SpriteSheet::SpriteSheet() : app( NULL ), extra( G_OBJECT( g_object_new( G_TYPE_OBJECT, NULL ) ) ),
    async( false ), loaded( false ), can_fire( true ), json_uri( NULL ), action( NULL )
{
    g_object_set_data( extra, "tp-sheet", this );

    static bool init( true );

    if ( init )
    {
        init = false;
        g_signal_new( "load-finished", G_TYPE_OBJECT, G_SIGNAL_RUN_FIRST,
                0, 0, 0, 0, G_TYPE_NONE, 1, G_TYPE_POINTER );
    }

    sprites = new std::map < std::string, Sprite* >();
    g_assert( sprites );

    sources = new std::list < Source* >();
    g_assert( sources );
}

SpriteSheet::~SpriteSheet()
{
    g_object_unref( extra );

    if ( json_uri ) { g_free( json_uri ); }

    if ( sprites )
    {
        for ( std::map < std::string, Sprite* >::iterator it = sprites->begin() ; it != sprites->end(); ++it )
        {
            delete( ( Sprite* )( it->second ) );
        }

        sprites->clear();
        delete( sprites );
    }

    if ( sources )
    {
        for ( std::list < Source* >::iterator it = sources->begin() ; it != sources->end(); ++it )
        {
            Source* source = ( Source* )( * it );

            if ( ! source->can_signal ) { source->cancel_release_later(); }

            delete( source );
        }

        sources->clear();
        delete( sources );
    }

    if ( !can_fire )
    {
        g_assert( action );
        Action::cancel( action );
        can_fire = true;
        action = NULL;
    }
}

void SpriteSheet::emit_signal( const char* msg )
{
    if ( async && can_fire )
    {
        action = new AsyncCallback( this, msg != NULL );
        Action::post( action );
        can_fire = false;
    }
    else if ( msg )
    {
        g_warning( "SpriteSheet: %s", msg );
    }
}

void SpriteSheet::parse_json( const JSON::Value& root )
{
    if ( root.is<JSON::Array>() )
    {
        JSON::Array& maps = ( JSON::Array& ) root.as<JSON::Array>();

        for ( unsigned i = 0; i < maps.size(); i++ )
        {
            JSON::Object& map = ( JSON::Object& ) maps[i].as<JSON::Object>();

            std::string img = map.at( "img" ).as<std::string>();

            if ( !img.empty() )
            {
                Source* source = NULL;

                JSON::Array& json_sprites = ( JSON::Array& ) map.at( "sprites" ).as<JSON::Array>();

                for ( unsigned i = 0; i < json_sprites.size(); i++ )
                {
                    JSON::Object& sprite = ( JSON::Object& ) json_sprites[i].as<JSON::Object>();

                    std::string id = sprite.at( "id" ).as<std::string>();
                    // Safe to convert long to int as image should be less than 4096x4096
                    int x = sprite.at( "x" ).as<long long>();
                    int y = sprite.at( "y" ).as<long long>();
                    int w = sprite.at( "w" ).as<long long>();
                    int h = sprite.at( "h" ).as<long long>();

                    // Should check whether x, y, w, h are within the image when using the id
                    // No need to check whether x, y, w, h are valid when creating because the app
                    // can correct them later
                    if ( !id.empty() )
                    {
                        // Load source only when needed, thus no need to delete source given invalid input
                        if ( source == NULL )
                        {
                            source = add_source();
                            source->set_source( img.c_str() );
                        }

                        add_sprite( source, id.c_str(), x, y, w, h );
                    }
                }
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

void async_map_callback( const Network::Response& response, SpriteSheet* self )
{
    if ( !response.failed && response.body->len )
    {
        self->parse_json( JSON::Parser::parse( ( char* ) response.body->data, response.body->len ) );
    }
    else
    {
        self->emit_signal( "Could not download JSON map." );
    }
}

void SpriteSheet::load_json( const char* json )
{
    gchar* map = NULL;
    gsize length;
    Network::Response response;

    // Check whether variable json is the content of a json file instead of the address of a json file
    if ( g_regex_match_simple( "^\\s*\\[", json, ( GRegexCompileFlags ) 0, ( GRegexMatchFlags ) 0 ) )
    {
        map = ( char* ) json;
        length = strlen( map );
    }
    else
    {
        json_uri = g_strdup( json );

        AppResource resource( app, json );

        if ( resource.is_native() )
        {
            // TODO: Support loading native files in async mode if needed
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
                        ( Network::ResponseCallback ) async_map_callback, this, 0 );
            }
            else
            {
                response = app->get_network()->perform_request( request, app->get_cookie_jar() );

                if ( response.failed || response.body->len == 0 )
                {
                    emit_signal( g_strdup_printf( "Could not download map %s", json ) );
                }

                map = ( char* ) response.body->data;
                length = response.body->len;
            }
        }
    }

    if ( map && length )
    {
        // map does not have to be a string ending with \0.
        parse_json( JSON::Parser::parse( map, length ) );
    }

    if ( map ) { g_free( map ); }
}

Source* SpriteSheet::add_source()
{
    g_assert( app );
    Source* source = new Source( this );
    sources->push_back( source );
    return source;
}

void SpriteSheet::add_sprite( Source* source, const char* id, int x, int y, int w, int h )
{
    g_assert( source );
    std::string s = std::string( id );

    // If the same ID has been used before, the old definition will be replaced silently
    Sprite* sprite = ( * sprites )[s];

    if ( sprite ) { delete( sprite ); }

    sprite = new Sprite();
    sprite->set_sprite( source, s.c_str(), x, y, w, h );
    ( * sprites )[s] = sprite;
}

Sprite* SpriteSheet::get_sprite( const char* id )
{
    std::string s = std::string( id );

    if ( !id || !sprites->count( s ) )
    {
        return NULL;
    }

    return ( * sprites )[s];
}

std::list< std::string >* SpriteSheet::get_ids()
{
    std::list< std::string >* ids = new std::list< std::string >();

    for ( std::map< std::string, Sprite*>::iterator it = sprites->begin(); it != sprites->end(); ++it )
    {
        ids->push_back( it->first );
    }

    return ids;
}

bool SpriteSheet::has_id( const char* id )
{
    return id && sprites->count( std::string( id ) );
}
