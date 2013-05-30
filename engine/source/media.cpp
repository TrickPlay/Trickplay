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
Media* Media::make( TPContext* context, Delegate* delegate, ClutterActor * actor )
{
    tplog( "[%p] <- constructor", this );

    if ( !actor )
    {
        tplog( "[%p]    FAILED TO CREATE CLUTTER GST VIDEO TEXTURE %d", this, TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER );
        return NULL;
    }

    g_object_ref_sink( G_OBJECT( actor ) ); // We own it

    return new Media( context , delegate, actor );
}


Media::Media( TPContext* c, Delegate* d, ClutterActor * actor )
    :
    context( c ),
    state( TP_MEDIAPLAYER_IDLE ),
    queue( g_async_queue_new_full( ( GDestroyNotify )Event::destroy ) ),
    vt( actor )
{
#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_init( &mutex );
#else
    g_rec_mutex_init( &mutex );
#endif

    add_delegate( d );

    StringVector s = split_string( context->get( TP_MEDIAPLAYER_SCHEMES, TP_MEDIAPLAYER_SCHEMES_DEFAULT ), "," );

    schemes.insert( s.begin(), s.end() );

    // Connect signals
    g_signal_connect( actor, "eos", G_CALLBACK( gst_end_of_stream ), this );
    g_signal_connect( actor, "error", G_CALLBACK( gst_error ), this );

    gst_set_audio_volume( 0.5 ); // Initialize volume
}

Media::~Media()
{
    {
        MPLOCK;

        check( TP_MEDIAPLAYER_ANY_STATE );

        // Reset to return state to IDLE

        reset();

        g_object_unref( G_OBJECT( vt ) );

        clear_events();

        g_async_queue_unref( queue );
    }

#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_free( &mutex );
#else
    g_rec_mutex_clear( &mutex );
#endif
}

void Media::check( int valid_states )
{
    if ( !( state & valid_states ) )
    {
        g_error( "MP[%p]   INVALID STATE %d", this, state );
    }
}

int Media::get_state()
{
    MPLOCK;
    check( TP_MEDIAPLAYER_ANY_STATE );
    return state;
}

void Media::reset()
{
    MPLOCK;

    if ( state == TP_MEDIAPLAYER_IDLE ) return;

    tplog( "MP[%p] <- reset", this );

    check( TP_MEDIAPLAYER_LOADING | TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED );

    disconnect_loading_messages();

    video_width  = 0;
    video_height = 0;
    media_type   = 0;

    // TODO: Reset truly forget all about the resource

    clutter_media_set_playing ( CLUTTER_MEDIA( vt ), FALSE );
    clutter_media_set_progress( CLUTTER_MEDIA( vt ), 0 );

    clear_events(); // Flush all pending events

    tags.clear(); // Clear tags

    state = TP_MEDIAPLAYER_IDLE;
}

int Media::load( const char* uri, const char* extra )
{
    MPLOCK;

    reset(); // back to IDLE

    gchar* unescaped_uri = g_uri_unescape_string( uri , 0 );

    if ( ! unescaped_uri )
    {
        g_warning( "MP[%p] INVALID URI '%s'" , this , uri );
        return TP_MEDIAPLAYER_ERROR_INVALID_URI;
    }

    tplog( "[%p] <- load('%s','%s')", this, unescaped_uri , extra );

    if ( int result = gst_load( unescaped_uri, extra ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        g_free( unescaped_uri );
        return result;
    }

    g_free( unescaped_uri );

    state = TP_MEDIAPLAYER_LOADING;

    return 0;
}

int Media::play()
{
    MPLOCK;

    if ( !( state & ( TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    play CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- play", this );

    if ( int result = gst_play() )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    state = TP_MEDIAPLAYER_PLAYING;

    return 0;
}

int Media::seek( double seconds )
{
    MPLOCK;

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    seek CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- seek(%f)", this, seconds );

    if ( int result = gst_seek( seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    return 0;
}

int Media::pause()
{
    MPLOCK;

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING ) ) )
    {
        g_warning( "MP[%p]    pause CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- pause", this );

    if ( int result = gst_pause() )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    state = TP_MEDIAPLAYER_PAUSED;

    return 0;
}

int Media::get_position( double* seconds )
{
    MPLOCK;

    g_assert( seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_position CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_position", this );

    if ( int result = gst_get_position( seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", this, *seconds );

    return 0;
}

int Media::get_duration( double* seconds )
{
    MPLOCK;

    g_assert( seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_duration CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_duration", this );

    if ( int result = gst_get_duration( seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", this, *seconds );

    return 0;
}

int Media::get_buffered_duration( double* start_seconds, double* end_seconds )
{
    MPLOCK;

    g_assert( start_seconds );
    g_assert( end_seconds );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_buffered_duration CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_buffered_duration", this );

    if ( int result = gst_get_buffered_duration( start_seconds, end_seconds ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f,%f", this, *start_seconds, *end_seconds );

    return 0;
}

int Media::get_video_size( int* width, int* height )
{
    MPLOCK;

    g_assert( width );
    g_assert( height );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_video_size CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_video_size", this );

    if ( int result = gst_get_video_size( width, height ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d,%d", this, *width, *height );

    return 0;
}

int Media::get_media_type( int* type )
{
    MPLOCK;

    g_assert( type );

    if ( !( state & ( TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED ) ) )
    {
        g_warning( "MP[%p]    get_media_type CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    tplog( "[%p] <- get_media_type", this );

    if ( int result = gst_get_media_type( type ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d", this, *type );

    return 0;
}

int Media::get_audio_volume( double* volume )
{
    MPLOCK;

    g_assert( volume );

    tplog( "[%p] <- get_audio_volume", this );

    if ( int result = gst_get_audio_volume( volume ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %f", this, *volume );

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

int Media::set_audio_volume( double volume )
{
    MPLOCK;

    if ( volume < 0 )
    {
        volume = 0;
    }
    else if ( volume > 1 )
    {
        volume = 1;
    }

    tplog( "[%p] <- set_audio_volume(%f)", this, volume );

    if ( int result = gst_set_audio_volume( volume ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    return 0;
}

int Media::get_audio_mute( int* mute )
{
    MPLOCK;

    g_assert( mute );

    tplog( "[%p] <- get_audio_mute", this );

    if ( int result = gst_get_audio_mute( mute ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d", this, *mute );

    return 0;
}

int Media::set_audio_mute( int mute )
{
    MPLOCK;

    if ( mute != 0 ) mute = 1;

    tplog( "[%p] <- set_audio_mute(%d)", this, mute );

    if ( int result = gst_set_audio_mute( mute ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    return 0;
}

int Media::get_loop_flag( bool* loop )
{
    MPLOCK;

    g_assert( loop );

    tplog( "[%p] <- get_loop_flag", this );

    if ( int result = gst_get_loop_flag( loop ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    tplog( "[%p]    RETURNED %d", this, *loop );

    return 0;
}

int Media::set_loop_flag( bool loop )
{
    MPLOCK;

    tplog( "[%p] <- set_loop_flag(%d)", this, loop );

    if ( int result = gst_set_loop_flag( loop ) )
    {
        g_warning( "MP[%p]    FAILED %d. Loop mode is not supported", this, result );
        return result;
    }

    return 0;
}

int Media::play_sound( const char* uri )
{
    if ( int result = gst_play_sound( uri ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    return 0;
}

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

void Media::error( int code, const char* message )
{
    post_event( Event::make( Event::ERROR, code, message ) );
}

void Media::end_of_stream()
{
    post_event( Event::make( Event::EOS ) );
}

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

gboolean Media::process_events( gpointer data )
{
    ( ( Media* )data )->process_events();
    return FALSE;
}

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
                    if ( state != TP_MEDIAPLAYER_IDLE ) reset(); // back to IDLE

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

void Media::clear_events()
{
    while ( Event* event = ( Event* )g_async_queue_try_pop( queue ) )
    {
        Event::destroy( event );
    }
}

void Media::add_delegate( Delegate* delegate )
{
    if ( !delegate ) return;

    MPLOCK;
    delegates.insert( delegate );
}

void Media::remove_delegate( Delegate* delegate )
{
    if ( !delegate ) return;

    MPLOCK;
    delegates.erase( delegate );
}

int Media::gst_set_audio_volume( double _volume )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    volume = _volume;

    if ( !mute ) clutter_media_set_audio_volume( cm, volume );

    return 0;
}

void Media::disconnect_loading_messages()
{
    if ( !load_signal ) return;

    ClutterMedia * cm=CLUTTER_MEDIA( vt );

#if (CLUTTER_GST_MAJOR_VERSION<1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline ) return;

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

    if ( !bus ) return;

    g_signal_handler_disconnect( bus, load_signal );
    load_signal = 0;

    gst_object_unref( GST_OBJECT( bus ) );
}

int Media::gst_load( const char* uri, const char* extra )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    clutter_media_set_uri( cm, uri );

#if (CLUTTER_GST_MAJOR_VERSION<1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline ) return 1;

    GstStateChangeReturn r = gst_element_set_state( pipeline, GST_STATE_PAUSED );

    g_debug( "STATE CHANGE RETURN IS %d", r );

    switch ( r )
    {
        case GST_STATE_CHANGE_FAILURE: return 2;

        case GST_STATE_CHANGE_SUCCESS:
        case GST_STATE_CHANGE_NO_PREROLL:
        {
            get_stream_information();
            tp_mediaplayer_loaded( this );
            break;
        }

        case GST_STATE_CHANGE_ASYNC:
        {
            // The state change happens asynchronously, so we connect a signal
            // handler to see when it is done

            GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

            if ( !bus ) return 3;

            load_signal = g_signal_connect( bus, "message", G_CALLBACK( loading_messages ), this );

            gst_object_unref( GST_OBJECT( bus ) );

            break;
        }
    }

    return 0;
}

void Media::get_stream_information()
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline ) return;

    //.........................................................................
    // Use stream info to get the type of each stream

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    GValueArray* info_array = NULL;

    g_object_get( G_OBJECT( pipeline ), "stream-info-value-array", &info_array, NULL );

    if ( info_array )
    {
        // Each entry in the array is information for a single stream
        for (guint i = 0; i < info_array->n_values; ++i )
        {
            GValue* info_value = g_value_array_get_nth( info_array, i );

            if ( G_VALUE_HOLDS( info_value, G_TYPE_OBJECT ) )
            {
                GObject* stream_info = g_value_get_object( info_value );

                if ( stream_info )
                {
                    gint type = -1;

                    g_object_get( stream_info, "type", &type, NULL );

                    switch ( type )
                    {
                        case 1:
                            ud->media_type |= TP_MEDIA_TYPE_AUDIO;
                            break;

                        case 2:
                            ud->media_type |= TP_MEDIA_TYPE_VIDEO;
                            break;
                    }
                }
            }
        }

        g_value_array_free( info_array );
    }

#else
    gint n_audio, n_video;
    g_object_get( G_OBJECT( pipeline ), "n-video", &n_video, NULL );
    g_object_get( G_OBJECT( pipeline ), "n-audio", &n_audio, NULL );

    if ( n_video ) { media_type |= TP_MEDIA_TYPE_VIDEO; }
    if ( n_audio ) { media_type |= TP_MEDIA_TYPE_AUDIO; }

#endif

    if ( media_type & TP_MEDIA_TYPE_VIDEO )
    { // If there is a video stream, get the video sink to find the video size
        GstElement* video_sink = NULL;

        g_object_get( G_OBJECT( pipeline ), "video-sink", &video_sink, NULL );

        if ( video_sink )
        {
            GstPad* pad = gst_element_get_static_pad( video_sink, "sink" );

            if ( pad ) // Get its video width and height
            {
                gint width = 0;
                gint height = 0;

                GstCaps *caps = gst_pad_get_current_caps( pad );
                GstStructure *st = gst_caps_get_structure( caps, 0 );

                gst_structure_get_int( st, "width", &width );
                gst_structure_get_int( st, "height", &height );

                gst_caps_unref( caps );

                video_width = width;
                video_height = height;

                gst_object_unref( GST_OBJECT( pad ) );
            }

            gst_object_unref( GST_OBJECT( video_sink ) );
        }
    }

    if ( media_type & TP_MEDIA_TYPE_AUDIO )
    {
        //g_object_get( G_OBJECT( pipeline ), "audio-sink", &audio_sink, NULL );
        GstElement* audio_sink = gst_element_factory_make( "autoaudiosink", NULL );

        if ( !audio_sink )
        {
            g_debug( "Failed to create autoaudiosink" );
        }
        else
        {
            //gst_object_unref( GST_OBJECT( audio_sink ) );
            g_object_set( G_OBJECT( pipeline ), "audio-sink", audio_sink, NULL );
        }
    }
}

//-----------------------------------------------------------------------------
// Gstreamer messages received while loading

void loading_messages( GstBus* bus, GstMessage* message, Media* media )
{
    switch ( message->type )
    {
        case GST_MESSAGE_TAG: // When a tag is found
        {
            GstTagList* tags = NULL;
            gst_message_parse_tag( message, &tags );

            if ( tags )
            {
                gst_tag_list_foreach( tags, collect_tags, media );
                gst_tag_list_free( tags );
            }

            break;
        }

        case GST_MESSAGE_ASYNC_DONE: // When the load is done - the stream is paused and ready to go
        {
            media->get_stream_information();

            // Now, notify that the stream is loaded
            tp_mediaplayer_loaded( media );

            // Disconnect this signal handler
            g_signal_handler_disconnect( bus, media->get_load_signal() );
            media->set_load_signal( 0 );

            break;
        }

        default:
            break; // Default handler to make clang shut up
    }
}

//-----------------------------------------------------------------------------
// Collect tags from a gstreamer tag list

void collect_tags( const GstTagList* list, const gchar* tag, gpointer user_data )
{
    GValue original_value = { 0 };

    if ( gst_tag_list_copy_value( &original_value, list, tag ) )
    {
        GValue string_value = {0};

        g_value_init( &string_value, G_TYPE_STRING );

        if ( g_value_transform( &original_value, &string_value ) )
        {
            const gchar* value = g_value_get_string( &string_value );

            if ( value ) tp_mediaplayer_tag_found( ( Media* ) user_data, tag, value );
        }

        g_value_unset( &string_value );
    }

    g_value_unset( &original_value );
}

int Media::gst_play()
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    clutter_media_set_playing( cm, TRUE );

    return 0;
}

int Media::gst_seek( double seconds )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    if ( !clutter_media_get_can_seek( cm ) ) return 1;

    clutter_media_set_progress( cm, seconds / clutter_media_get_duration( cm ) );

    return 0;
}

int Media::gst_pause()
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    clutter_media_set_playing( cm, FALSE );
    return 0;
}

int Media::gst_get_position( double * seconds )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    *seconds = clutter_media_get_duration( cm ) * clutter_media_get_progress( cm );

    return 0;
}

int Media::gst_get_duration( double * seconds )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    *seconds = clutter_media_get_duration( cm );
    return 0;
}

int Media::gst_get_buffered_duration( double* start_seconds, double* end_seconds )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    *start_seconds = 0;
    *end_seconds = clutter_media_get_duration( cm ) * clutter_media_get_buffer_fill( cm );
    return 0;
}

int Media::gst_get_video_size( int* width, int* height )
{
    if ( !( media_type & TP_MEDIA_TYPE_VIDEO ) ) return TP_MEDIAPLAYER_ERROR_NA;

    *width  = video_width;
    *height = video_height;

    return 0;
}

int Media::gst_get_media_type( int * type )
{
    *type = media_type;
    return 0;
}

int Media::gst_get_audio_volume( double* _volume )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    * _volume = mute ? volume : clutter_media_get_audio_volume( cm );

    return 0;
}

int Media::gst_get_audio_mute( int* _mute )
{
    * _mute = mute;

    return 0;
}

int Media::gst_set_audio_mute( int _mute )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    int old_mute = mute;

    mute = _mute ? 1 : 0;

    if ( old_mute != mute )
    {
        if ( mute )
        {
            clutter_media_set_audio_volume( cm, 0 );
        }
        else
        {
            clutter_media_set_audio_volume( cm, volume );
        }
    }

    return 0;
}

int Media::gst_get_loop_flag( bool* _loop )
{
    *_loop = loop;

    return 0;
}

int Media::gst_set_loop_flag( bool flag )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

    loop = flag;

    return flag && !clutter_media_get_can_seek( cm );
}

void play_sound_done( GstBus* bus, GstMessage* message, GstElement* playbin )
{
    gst_element_set_state( playbin, GST_STATE_NULL );

    gst_object_unref( GST_OBJECT( playbin ) );
}

int Media::gst_play_sound( const char* uri )
{
    ClutterMedia * cm = CLUTTER_MEDIA( vt );

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    GstElement* audio_sink = NULL;
    g_object_get( G_OBJECT( pipeline ), "audio-sink", &audio_sink, NULL );

    if ( !audio_sink ) return 2;

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( audio_sink ) );

    g_object_set( G_OBJECT( audio_sink ), "uri", uri, NULL );

    gst_bus_add_signal_watch( bus );

    g_signal_connect_object( bus, "message::error" , G_CALLBACK( play_sound_done ), audio_sink, G_CONNECT_AFTER );
    g_signal_connect_object( bus, "message::eos",    G_CALLBACK( play_sound_done ), audio_sink, G_CONNECT_AFTER );

    gst_object_unref( GST_OBJECT( bus ) );
    gst_object_unref( GST_OBJECT( audio_sink ) );

    if ( GST_STATE_CHANGE_FAILURE == gst_element_set_state( audio_sink, GST_STATE_PLAYING ) ) return 2;

    return 0;
}

//=============================================================================
// External callbacks
//=============================================================================

void tp_mediaplayer_loaded( Media* media )
{
    tplog( "[%p] -> tp_media_player_loaded", media );
    media->loaded();
}

void tp_mediaplayer_error( Media* media, int code, const char* message )
{
    tplog( "[%p] -> tp_media_player_error(%d,'%s')", media, code, message );
    media->error( code, message );
}

void tp_mediaplayer_end_of_stream( Media* media )
{
    tplog( "[%p] -> tp_media_player_end_of_stream", mp );
    media->end_of_stream();
}

void tp_mediaplayer_tag_found( Media* media, const char* name, const char* value )
{
    tplog( "[%p] -> tp_media_player_tag_found('%s','%s')", media, name, value );

    if ( name && value ) media->tag_found( name, value );
}

//-----------------------------------------------------------------------------
// Signal handlers
void gst_end_of_stream( ClutterMedia* cm, Media* media )
{
    if ( ! media->get_loop() ) tp_mediaplayer_end_of_stream( media );

/* Keep last frame on screen after video is done
#if (CLUTTER_GST_MAJOR_VERSION<1)
        GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
        GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

        int attempts = 0;
        gboolean re;
        do {
            re = ! gst_element_seek( pipeline, -1.0, GST_FORMAT_TIME,
                ( GstSeekFlags ) ( GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE ),
                GST_SEEK_TYPE_SET, 0, GST_SEEK_TYPE_END, 0 );
            if ( re ) sleep( 1 );
        } while ( re && ++attempts > 3 );
*/

    clutter_media_set_playing( cm, media->get_loop() );
}

void gst_error( ClutterMedia* cm, GError* error, Media* media )
{
    tp_mediaplayer_error( media, error->code, error->message );
    clutter_actor_hide( CLUTTER_ACTOR( cm ) );
}
