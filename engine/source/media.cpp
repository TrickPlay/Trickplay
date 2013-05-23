
#include "glib-object.h"
#include "media.h"
#include "util.h"
#include "context.h"

#define TP_LOG_DOMAIN   "MP"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false
#define MPLOCK Util::GSRMutexLock lock(&mutex)

#include "log.h"

Media::Event* Media::Event::make( Type type, int code, const gchar* message, const gchar* value )
{
    Event* result = g_slice_new( Event );
    result->type = type;
    result->code = code;
    result->message = message ? g_strdup( message ) : NULL;
    result->value = value ? g_strdup( value ) : NULL;
    return result;
}

void Media::Event::destroy( Event* event )
{
    g_assert( event );
    g_free( event->message );
    g_free( event->value );
    g_slice_free( Event, event );
}

//-----------------------------------------------------------------------------
// Allocates a new wrapper and invokes the outside world's media player
// constructor function to initialize the media player. If that fails,
// return NULL. Sets up the wrapper and returns a new MediaPlayer instance.

Media* Media::make( TPContext* context , GST_PlayerConstructor constructor, Delegate* delegate, ClutterActor * actor )
{
    if ( !constructor )
    {
        g_warning( "MP[]   NO MEDIA PLAYER CONSTRUCTOR" );
        return NULL;
    }

    Wrapper* wrapper = ( Wrapper* )g_malloc0( sizeof( Wrapper ) );

    GST_Player* mp = &wrapper->mp;

    wrapper->marker = mp;

    tplog( "[%p] <- constructor", mp );

    if ( int result G_GNUC_UNUSED = constructor( mp, context, actor ) )
    {
        // Construction failed

        tplog( "[%p]    FAILED %d", mp, result );

        g_free( wrapper );
        return NULL;
    }

    return new Media( context , wrapper , delegate );
}

//-----------------------------------------------------------------------------

Media::Media( TPContext* c , Wrapper* w, Delegate* d )
    :
    context( c ),
    wrapper( w ),
    state( TP_MEDIAPLAYER_IDLE ),
    queue( g_async_queue_new_full( ( GDestroyNotify )Event::destroy ) )
{
    g_assert( wrapper );
    wrapper->player = this;

#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_init( &mutex );
#else
    g_rec_mutex_init( &mutex );
#endif

    add_delegate( d );

    StringVector s = split_string( context->get( TP_MEDIAPLAYER_SCHEMES , TP_MEDIAPLAYER_SCHEMES_DEFAULT ) , "," );

    schemes.insert( s.begin() , s.end() );
}

//-----------------------------------------------------------------------------

Media::~Media()
{
    {
        MPLOCK;

        check( TP_MEDIAPLAYER_ANY_STATE );

        // Reset to return state to IDLE

        reset();

        if ( wrapper->mp.destroy )
        {
            tplog( "[%p] <- destroy", get_mp() );
            wrapper->mp.destroy( get_mp() );
        }

        wrapper->marker = NULL;
        wrapper->player = NULL;

        g_free( wrapper );

        wrapper = NULL;

        clear_events();

        g_async_queue_unref( queue );
    }

#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_free( &mutex );
#else
    g_rec_mutex_clear( &mutex );
#endif
}

//-----------------------------------------------------------------------------
// Given a GST_Player pointer, this casts it to a Wrapper pointer and
// ensures that everything is in order. This relies on the GST_Player pointer
// having the same address as its wrapper.
//
// Very pedantic, but better safe than sorry when these come from the outside
// world.

Media* Media::get( GST_Player* mp )
{
    g_assert( mp );
    Wrapper* wrapper = ( Wrapper* )mp;
    g_assert( &wrapper->mp == mp );
    g_assert( wrapper->marker == mp );
    g_assert( wrapper->player );
    g_assert( wrapper->player->wrapper == wrapper );

    return wrapper->player;
}

//-----------------------------------------------------------------------------

GST_Player* Media::get_mp()
{
    return &wrapper->mp;
}

//-----------------------------------------------------------------------------

void Media::check( int valid_states )
{
    g_assert( wrapper );
    g_assert( wrapper->marker == &wrapper->mp );
    g_assert( wrapper->player == this );

    if ( !( state & valid_states ) )
    {
        g_error( "MP[%p]   INVALID STATE %d", get_mp(), state );
    }
}

//-----------------------------------------------------------------------------

int Media::get_state()
{
    MPLOCK;
    check( TP_MEDIAPLAYER_ANY_STATE );
    return state;
}

//-----------------------------------------------------------------------------

void Media::reset()
{
    MPLOCK;

    if ( state == TP_MEDIAPLAYER_IDLE )
    {
        return;
    }

    if ( wrapper->mp.reset )
    {
        tplog( "MP[%p] <- reset", get_mp() );

        check( TP_MEDIAPLAYER_LOADING | TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED );

        wrapper->mp.reset( get_mp() );
    }

    // Flush all pending events

    clear_events();

    // Clear tags

    tags.clear();

    state = TP_MEDIAPLAYER_IDLE;
}

//-----------------------------------------------------------------------------

int Media::load( const char* uri, const char* extra )
{
    MPLOCK;

    // Get us back to IDLE

    reset();

    GST_Player* mp = get_mp();

    gchar* unescaped_uri = g_uri_unescape_string( uri , 0 );

    if ( ! unescaped_uri )
    {
        g_warning( "MP[%p] INVALID URI '%s'" , mp , uri );
        return TP_MEDIAPLAYER_ERROR_INVALID_URI;
    }

    tplog( "[%p] <- load('%s','%s')", mp, unescaped_uri , extra );

    if ( int result = mp->load( mp, unescaped_uri, extra ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        g_free( unescaped_uri );
        return result;
    }

    g_free( unescaped_uri );

    state = TP_MEDIAPLAYER_LOADING;

    return 0;
}

//-----------------------------------------------------------------------------

int Media::play()
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( !( state & ( TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    play CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- play", mp );

    if ( int result = mp->play( mp ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    state = TP_MEDIAPLAYER_PLAYING;

    return 0;
}

//-----------------------------------------------------------------------------

int Media::seek( double seconds )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    seek CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- seek(%f)", mp, seconds );

    if ( int result = mp->seek( mp, seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int Media::pause()
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING ) ) )
    {
        g_warning( "MP[%p]    pause CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- pause", mp );

    if ( int result = mp->pause( mp ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    state = TP_MEDIAPLAYER_PAUSED;

    return 0;
}

//-----------------------------------------------------------------------------

int Media::set_playback_rate( int rate )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( rate == 0 )
    {
        g_warning( "MP[%p]    set_playback_rate CALLED WITH INVALID RATE %d", mp, rate );
        return TP_MEDIAPLAYER_ERROR_BAD_PARAMETER;
    }

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING ) ) )
    {
        g_warning( "MP[%p]    set_playback_rate CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- set_playback_rate(%d)", mp, rate );

    if ( int result = mp->set_playback_rate( mp, rate ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_position( double* seconds )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_position CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_position", mp );

    if ( int result = mp->get_position( mp, seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", mp, *seconds );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_duration( double* seconds )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_duration CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_duration", mp );

    if ( int result = mp->get_duration( mp, seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", mp, *seconds );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_buffered_duration( double* start_seconds, double* end_seconds )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( start_seconds );
    g_assert( end_seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_buffered_duration CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_buffered_duration", mp );

    if ( int result = mp->get_buffered_duration( mp, start_seconds, end_seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f,%f", mp, *start_seconds, *end_seconds );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_video_size( int* width, int* height )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( width );
    g_assert( height );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_video_size CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_video_size", mp );

    if ( int result = mp->get_video_size( mp, width, height ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d,%d", mp, *width, *height );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_media_type( int* type )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( type );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_media_type CALLED IN INVALID STATE", mp );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_media_type", mp );

    if ( int result = mp->get_media_type( mp, type ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d", mp, *type );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_audio_volume( double* volume )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( volume );

    tplog( "[%p] <- get_audio_volume", mp );

    if ( int result = mp->get_audio_volume( mp, volume ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", mp, *volume );

    if ( *volume < 0 )
    {
        *volume = 0;
    }
    else if ( *volume > 1 )
    {
        *volume = 1;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int Media::set_audio_volume( double volume )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( volume < 0 )
    {
        volume = 0;
    }
    else if ( volume > 1 )
    {
        volume = 1;
    }

    tplog( "[%p] <- set_audio_volume(%f)", mp, volume );

    if ( int result = mp->set_audio_volume( mp, volume ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int Media::get_audio_mute( int* mute )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    g_assert( mute );

    tplog( "[%p] <- get_audio_mute", mp );

    if ( int result = mp->get_audio_mute( mp, mute ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d", mp, *mute );

    return 0;
}

//-----------------------------------------------------------------------------

int Media::set_audio_mute( int mute )
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( mute != 0 )
    {
        mute = 1;
    }

    tplog( "[%p] <- set_audio_mute(%d)", mp, mute );

    if ( int result = mp->set_audio_mute( mp, mute ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int Media::play_sound( const char* uri )
{
    GST_Player* mp = get_mp();

    if ( int result = mp->play_sound( mp, uri ) )
    {
        g_warning( "MP[%p]    FAILED %d", mp, result );
        return result;
    }

    return 0;
}
//-----------------------------------------------------------------------------

void* Media::get_viewport_texture()
{
    MPLOCK;

    GST_Player* mp = get_mp();

    if ( !mp->get_viewport_texture )
    {
        return NULL;
    }

    return mp->get_viewport_texture( mp );
}


//-----------------------------------------------------------------------------

StringPairList Media::get_tags()
{
    MPLOCK;

    return tags;
}

//=============================================================================
// Called by external callbacks - they all push an event into the queue

void Media::loaded()
{
    post_event( Event::make( Event::LOADED ) );
}

//-----------------------------------------------------------------------------

void Media::error( int code, const char* message )
{
    post_event( Event::make( Event::ERROR, code, message ) );
}

//-----------------------------------------------------------------------------

void Media::end_of_stream()
{
    post_event( Event::make( Event::EOS ) );
}

//-----------------------------------------------------------------------------

void Media::tag_found( const char* name, const char* value )
{
    post_event( Event::make( Event::TAG, 0, name, value ) );
}

//-----------------------------------------------------------------------------
// Puts the event in the queue and adds an idle source that will process
// events in the main thread

void Media::post_event( Event* event )
{
    g_async_queue_push( queue, event );

    g_idle_add_full( TRICKPLAY_PRIORITY , process_events, this, NULL );
}

//-----------------------------------------------------------------------------
// Process the events

gboolean Media::process_events( gpointer data )
{
    ( ( Media* )data )->process_events();
    return FALSE;
}

//-----------------------------------------------------------------------------

void Media::process_events()
{
    MPLOCK;

    while ( Event* event = ( Event* )g_async_queue_try_pop( queue ) )
    {
        switch ( event->type )
        {
            case Event::LOADED:

                if ( state == TP_MEDIAPLAYER_LOADING )
                {
                    state = TP_MEDIAPLAYER_PAUSED;

                    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
                    {
                        ( *it )->loaded( this );
                    }
                }

                break;

            case Event::ERROR:

                if ( state == TP_MEDIAPLAYER_LOADING || state == TP_MEDIAPLAYER_IDLE )
                {
                    // Take it back to IDLE
                    if ( state != TP_MEDIAPLAYER_IDLE )
                    {
                        reset();
                    }

                    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
                    {
                        ( *it )->error( this, event->code, event->message );
                    }
                }
                else if ( state == TP_MEDIAPLAYER_PLAYING )
                {
                    state = TP_MEDIAPLAYER_PAUSED;

                    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
                    {
                        ( *it )->error( this, event->code, event->message );
                    }
                }

                break;

            case Event::EOS:

                if ( state == TP_MEDIAPLAYER_PLAYING )
                {
                    state = TP_MEDIAPLAYER_PAUSED;

                    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
                    {
                        ( *it )->end_of_stream( this );
                    }
                }

                break;

            case Event::TAG:

                if ( state == TP_MEDIAPLAYER_LOADING )
                {
                    tags.push_back( std::make_pair( String( event->message ), String( event->value ) ) );
                }
        }

        Event::destroy( event );
    }
}

//-----------------------------------------------------------------------------

void Media::clear_events()
{
    while ( Event* event = ( Event* )g_async_queue_try_pop( queue ) )
    {
        Event::destroy( event );
    }
}

//-----------------------------------------------------------------------------

void Media::add_delegate( Delegate* delegate )
{
    if ( !delegate )
    {
        return;
    }

    MPLOCK;
    delegates.insert( delegate );
}

//-----------------------------------------------------------------------------

void Media::remove_delegate( Delegate* delegate )
{
    if ( !delegate )
    {
        return;
    }

    MPLOCK;
    delegates.erase( delegate );
}

//=============================================================================
// External callbacks
//=============================================================================

// TODO: Find out where thet are being used within TrickPlay source code

int tp_mediaplayer_get_state( GST_Player* mp )
{
    tplog( "[%p] -> tp_media_player_get_state", mp );
    return Media::get( mp )->get_state();
}

//-----------------------------------------------------------------------------

void tp_mediaplayer_loaded( GST_Player* mp )
{
    tplog( "[%p] -> tp_media_player_loaded", mp );
    Media::get( mp )->loaded();
}

//-----------------------------------------------------------------------------

void tp_mediaplayer_error( GST_Player* mp, int code, const char* message )
{
    tplog( "[%p] -> tp_media_player_error(%d,'%s')", mp, code, message );
    Media::get( mp )->error( code, message );
}


//-----------------------------------------------------------------------------

void tp_mediaplayer_end_of_stream( GST_Player* mp )
{
    tplog( "[%p] -> tp_media_player_end_of_stream", mp );
    Media::get( mp )->end_of_stream();
}

//-----------------------------------------------------------------------------

void tp_mediaplayer_tag_found( GST_Player* mp, const char* name, const char* value )
{
    tplog( "[%p] -> tp_media_player_tag_found('%s','%s')", mp, name, value );

    if ( name && value )
    {
        Media::get( mp )->tag_found( name, value );
    }
}
