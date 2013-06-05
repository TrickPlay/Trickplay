#include "pushtexture.h"

typedef PushTexture::PingMe PingMe;

PushTexture::~PushTexture()
{
    if ( texture )
    {
        cogl_handle_unref( texture );
        texture = NULL;
    }

    if ( !pings.empty() ) { pings.clear(); }
}

void PushTexture::subscribe( PingMe* ping, bool immediately )
{
    g_assert( pings.count(ping) == 0 );
    pings.insert( ping );

    if ( texture )
    {
        ping->ping(); // No need to trigger ping_all cause other subscribers have been pinged before
    }
    else
    {
        make_texture( immediately ); // Will trigger ping_all. Through ping_all, trigger ping->ping()
    }
}

void PushTexture::release_texture()
{
    if ( texture && pings.empty() )
    {
        cogl_handle_unref( texture );

        texture = NULL;

        lost_texture();
    }
}

void PushTexture::get_dimensions( int* w, int* h )
{
    * w = texture ? cogl_texture_get_width( ( TP_CoglTexture ) texture ) : 1;
    * h = texture ? cogl_texture_get_height( ( TP_CoglTexture ) texture ) : 1;
}

CoglHandle PushTexture::get_texture()
{
    return texture;
}

void PushTexture::set_texture( CoglHandle _texture, bool trigger )
{
    if ( texture ) { cogl_handle_unref( texture ); }

    texture = _texture;
    // Skip cogl_handle_ref as it is done before calling set_texture

    if ( trigger ) { ping_all(); }
}

void PushTexture::ping_all()
{
    for ( std::set< PingMe* >::iterator it = pings.begin(); it != pings.end(); ++it )
    {
        ( * it )->ping();
    }
}

/* PingMe */

void PingMe::assign( PushTexture* _instance, PingMe::Callback* _callback, void* _target, bool immediately )
{
    if ( instance == _instance )
    {
        callback = _callback;
        target   = _target;

        // TODO: handle the case when we just want to change flag immediately
        return;
    }

    // Sprite instances will always have texture released immediately
    // Source instances will have it released later when the app is running
    if ( instance ) { instance->unsubscribe( this, false ); }

    instance = _instance;
    callback = _callback;
    target   = _target;

    if ( instance ) { instance->subscribe( this, immediately ); }
}

PingMe::~PingMe()
{
    if ( instance ) { instance->unsubscribe( this, true ); } // Sprite release reference to Source

    instance = NULL;
    callback = NULL;
    target   = NULL;
}


void PingMe::ping()
{
    if ( callback ) { callback( instance, target ); }
}
