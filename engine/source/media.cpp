#include "clutter_util.h"
#include "tp-clutter.h"
#include "media.h"

Media * Media::get( ClutterActor * _actor, lua_State *l )
{
    g_assert( _actor );

    Media* instance = ( Media* ) g_object_get_data( G_OBJECT( _actor ), "media-extra" );

    if ( instance ) return instance;

    g_assert( l );

    instance = new Media();
    instance->L = l;

    if ( _actor ) instance->actor = _actor;

    g_object_set_data_full( G_OBJECT( _actor ), "media-extra", instance, ( GDestroyNotify ) Media::destroy );

    return instance;
}

void Media::destroy( Media * instance )
{
    delete instance;
}

void Media::loaded()
{
    lb_invoke_callbacks( L, G_OBJECT( actor ), "MEDIA_METATABLE", "on_loaded", 0, 0 );
}

void Media::error( int code, const char * message )
{
    lua_pushinteger( L, code );
    lua_pushstring( L, message );
    lb_invoke_callbacks( L, G_OBJECT( actor ), "MEDIA_METATABLE", "on_error", 2, 0 );
}

void Media::end_of_stream()
{
    lb_invoke_callbacks( L, G_OBJECT( actor ), "MEDIA_METATABLE", "on_end_of_stream", 0, 0 );
}

bool Media::load_media()
{
    // Don't load when constructing. Not all properties may have been set yet
    if ( constructing ) return false;

    g_assert( L );
    g_assert( actor );

    //int result;

    tags         = JSON::Object();
    loaded_flag  = false;

    //.........................................................................
    // Get the media source
    char * uri = ( char * ) g_object_get_data( G_OBJECT( actor ), "tp-src" );
    if ( !uri ) return false;

    /*MediaPlayer * mp = extra->get_player();
    if ( mp )
    {
        AppResource resource = AppResource( L , uri , 0 , mp->get_valid_schemes() );

        result = resource ? mp->load( resource.get_uri().c_str(), "" )
                          : TP_MEDIAPLAYER_ERROR_INVALID_URI;
    }
    else
    {
        result = TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER;
    }*/

    g_warning( "AT %s", Util::where_am_i_lua(L).c_str() );

    return true;
}
