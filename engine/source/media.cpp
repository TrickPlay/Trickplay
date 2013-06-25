#include "glib-object.h"
#include "media.h"
#include "util.h"
#include "context.h"
#include "app_resource.h"

#define TP_LOG_DOMAIN   "MP"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false
#define MPLOCK Util::GSRMutexLock lock(&mutex)

#include "log.h"

Media::Event* Media::Event::make( Type type, int code, const gchar* message, const gchar* value )
{
    Event* result   = g_slice_new( Event );

    result->type    = type;
    result->code    = code;
    result->message = message ? g_strdup( message ) : NULL;
    result->value   = value ? g_strdup( value ) : NULL;

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
    if ( !actor )
    {
        tplog( "[%p]    FAILED TO CREATE CLUTTER GST VIDEO TEXTURE %d", this, TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER );
        return NULL;
    }

    g_object_ref_sink( G_OBJECT( actor ) ); // We own it

    return new Media( context , delegate, actor );
}


Media::Media( TPContext* c, Delegate* d, ClutterActor * actor )
    : context( c )
    , state( TP_MEDIAPLAYER_IDLE )
    , queue( g_async_queue_new_full( ( GDestroyNotify ) Event::destroy ) )
    , vt( actor )
    , pipeline( NULL )
    , loaded_flag( false )
    , actor_hidden( false )
    , keep_aspect_ratio( false )
    , idle_material_set_flag( false )
{
#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_init( &mutex );
#else
    g_rec_mutex_init( &mutex );
#endif

    add_delegate( d );

    StringVector s = split_string( context->get( TP_MEDIAPLAYER_SCHEMES, TP_MEDIAPLAYER_SCHEMES_DEFAULT ), "," );

    schemes.insert( s.begin(), s.end() );

    cm = CLUTTER_MEDIA( vt );

    // Connect signals
    g_signal_connect( actor, "eos",   G_CALLBACK( gst_end_of_stream ), this );
    g_signal_connect( actor, "error", G_CALLBACK( gst_error ),         this );

    set_audio_volume( 1.0 ); // Initialize volume
}

Media::~Media()
{
    {
        MPLOCK;

        check( TP_MEDIAPLAYER_ANY_STATE );

        reset(); // return state to IDLE

        g_object_unref( G_OBJECT( vt ) );

        clear_events();

        g_async_queue_unref( queue );

        vt       = NULL;
        cm       = NULL;
        pipeline = NULL;
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

    check( TP_MEDIAPLAYER_LOADING | TP_MEDIAPLAYER_PLAYING | TP_MEDIAPLAYER_PAUSED );

    disconnect_loading_messages();

    video_width  = 0;
    video_height = 0;
    media_type   = 0;

    // TODO: Reset truly forget all about the resource

    clutter_media_set_playing ( cm, FALSE );
    clutter_media_set_progress( cm, 0.0 );

    if ( actor_hidden )
    { // Hide actor when playing music files, or when there is an error
        clutter_actor_show( CLUTTER_ACTOR( cm ) );
        actor_hidden = false;
    }

    clear_events(); // Flush all pending events

    tags.clear(); // Clear tags

    clear_idle_material();

    state = TP_MEDIAPLAYER_IDLE;
}

int Media::load( lua_State * L, const char* uri, const char* extra )
{
    MPLOCK;

    reset(); // back to IDLE

    AppResource resource = AppResource( L , uri , 0 , get_valid_schemes() );
    if ( !resource )
    {
        g_warning( "MP[%p] INVALID URI '%s'" , this , uri );
        return TP_MEDIAPLAYER_ERROR_INVALID_URI;
    }

    tplog( "[%p] <- load('%s','%s')", this, resource.get_uri().c_str() , extra );

    if ( int result = gst_load( resource.get_uri().c_str(), extra ) )
    {
        g_warning( "MP[%p]    FAILED %d", this, result );
        return result;
    }

    state = TP_MEDIAPLAYER_LOADING;

    return 0;
}

int Media::play()
{
    MPLOCK;

    int media_type;

    if ( !( state & ( TP_MEDIAPLAYER_PAUSED ) ) || get_media_type( &media_type ) )
    {
        g_warning( "MP[%p]    play CALLED IN INVALID STATE", this );
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }

    if ( !( media_type & TP_MEDIA_TYPE_VIDEO ) )
    {
        g_assert ( media_type & TP_MEDIA_TYPE_AUDIO );

        g_assert( !actor_hidden );
        clutter_actor_hide( CLUTTER_ACTOR( cm ) );
        actor_hidden = true;
    }

    clutter_media_set_playing( cm, TRUE );

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

    if ( !clutter_media_get_can_seek( cm ) ) return 1;

    clear_idle_material();

    gdouble duration = clutter_media_get_duration( cm );

    if ( duration > 1e-9 ) clutter_media_set_progress( cm, ( seconds > duration ) ? 1.0 : seconds / duration );

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

    clear_idle_material();

    clutter_media_set_playing( cm, FALSE );

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

    * seconds = clutter_media_get_duration( cm ) * clutter_media_get_progress( cm );

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

    *seconds = clutter_media_get_duration( cm );

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

    * start_seconds = 0;
    * end_seconds   = clutter_media_get_duration( cm ) * clutter_media_get_buffer_fill( cm );

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

    if ( !( media_type & TP_MEDIA_TYPE_VIDEO ) ) return TP_MEDIAPLAYER_ERROR_NA;

    *width  = video_width;
    *height = video_height;

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

    *type = media_type;

    return 0;
}

int Media::has_media_type( bool * has_type, bool check_video )
{
    MPLOCK;

    int type;

    int ret = get_media_type( &type );

    *has_type = ret
              ? false
              : type & ( check_video ? TP_MEDIA_TYPE_VIDEO : TP_MEDIA_TYPE_AUDIO );

    return ret;
}

int Media::get_audio_volume( double* _volume )
{
    MPLOCK;

    g_assert( _volume );

    /* Cannot get volume by using
     * volume = clutter_media_get_audio_volume( cm );
     * as the media may not be played yet
     */

    * _volume = volume;

    return 0;
}

int Media::set_audio_volume( double _volume )
{
    MPLOCK;

    if      ( _volume < 0.0 ) { volume = 0.0; }
    else if ( _volume > 1.0 ) { volume = 1.0; }
    else                      { volume = _volume; }

    if ( !mute ) clutter_media_set_audio_volume( cm, volume );

    return 0;
}

int Media::get_audio_mute( int* _mute )
{
    MPLOCK;

    g_assert( _mute );

    * _mute = mute;

    return 0;
}

int Media::set_audio_mute( int _mute )
{
    MPLOCK;

    if ( mute != 0 ) mute = 1;

    int old_mute = mute;

    mute = _mute ? 1 : 0;

    if ( old_mute != mute )
    {
        clutter_media_set_audio_volume( cm, mute ? 0.0 : volume );
    }

    return 0;
}

int Media::get_loop_flag( bool* _loop )
{
    MPLOCK;

    g_assert( _loop );

    * _loop = loop;

    return 0;
}

int Media::set_loop_flag( bool _loop )
{
    MPLOCK;

    loop = _loop;

    int result = loop && !clutter_media_get_can_seek( cm );
    if ( result )
    {
        g_warning( "MP[%p]    FAILED %d. Loop mode is not supported", this, result );
    }

    return result;
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
    loaded_flag = true;

    // According to the clutter-gst example program video-player.c
    clutter_gst_video_texture_set_seek_flags( CLUTTER_GST_VIDEO_TEXTURE( vt ),
                                              CLUTTER_GST_SEEK_FLAG_ACCURATE );

    post_event( Event::make( Event::LOADED ) );
}

void Media::error( int code, const char* message )
{
    loaded_flag = false;
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
    ( ( Media* ) data )->process_events();
    return FALSE;
}

void Media::process_events()
{
    MPLOCK;

    while ( Event* event = ( Event* ) g_async_queue_try_pop( queue ) )
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

void Media::disconnect_loading_messages()
{
    if ( !load_signal ) return;

    g_assert( pipeline );

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

    if ( !bus ) return;

    g_signal_handler_disconnect( bus, load_signal );
    load_signal = 0;

    gst_object_unref( GST_OBJECT( bus ) );
}

int Media::gst_load( const char* uri, const char* extra )
{
    if ( !pipeline )
    {
#if (CLUTTER_GST_MAJOR_VERSION < 1)
        pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
        pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif
    }

    if ( !pipeline ) return 1;

    clutter_media_set_uri( cm, uri );

    GstStateChangeReturn r = gst_element_set_state( pipeline, GST_STATE_PAUSED );

    g_debug( "STATE CHANGE RETURN IS %d", r );

    switch ( r )
    {
        case GST_STATE_CHANGE_FAILURE: return 2;

        case GST_STATE_CHANGE_SUCCESS:
        case GST_STATE_CHANGE_NO_PREROLL:
        {
            get_stream_information();
            loaded();
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

void Media::set_actor_size()
{
    gboolean explicit_height, explicit_width; // Whether width/height been set explicitly
    guint actor_width, actor_height;
    gfloat f_width, f_height; // floating point value used in calculation

    if ( ( video_width == 0 ) || ( video_height == 0 ) ) return;

    g_object_get( G_OBJECT( vt ), "natural-height-set", &explicit_height, NULL );
    g_object_get( G_OBJECT( vt ), "natural-width-set",  &explicit_width,  NULL );

    clutter_actor_get_size( vt, &f_width, &f_height );
    actor_width  = f_width;
    actor_height = f_height;

    if ( explicit_height && explicit_width )
    {
        // Check whether consistent with video aspect ratio
        // Use multiplication instead of division to make it accurate
        if ( keep_aspect_ratio && ( video_width * actor_height != video_height * actor_width ) )
        {
            // Update actor width and height to preserve aspect ratio
            if ( video_width * actor_height > video_height * actor_width )
            {
                f_height = video_height * actor_width / video_width;
            }
            else
            {
                f_width = video_width * actor_height / video_height;
            }

            clutter_actor_set_size( vt, f_width, f_height );
        }
    }
    else if ( !explicit_height && !explicit_width )
    { // Set actor size as the video size
        clutter_actor_set_size( vt, ( gfloat ) video_width, ( gfloat ) video_height );
    }
    else if ( explicit_height )
    { // Use the specifiec height and keep the video aspect ratio
        clutter_actor_set_size( vt, video_width * actor_height / video_height , f_height );
    }
    else /* explicit_width is true */
    { // Use the specifiec width and keep the video aspect ratio
        clutter_actor_set_size( vt, f_width, video_height * actor_width / video_width );
    }
}

void Media::get_stream_information()
{
    g_assert( pipeline );

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    // Use stream info to get the type of each stream
    GValueArray* info_array = NULL;
    g_object_get( G_OBJECT( pipeline ), "stream-info-value-array", &info_array, NULL );
    if ( info_array ) { // Each entry in the array is information for a single stream
        for (guint i = 0; i < info_array->n_values; ++i ) {
            GValue* info_value = g_value_array_get_nth( info_array, i );
            if ( G_VALUE_HOLDS( info_value, G_TYPE_OBJECT ) ) {
                GObject* stream_info = g_value_get_object( info_value );
                if ( stream_info ) {
                    gint type = -1;
                    g_object_get( stream_info, "type", &type, NULL );
                    switch ( type ) {
                      case 1: ud->media_type |= TP_MEDIA_TYPE_AUDIO; break;
                      case 2: ud->media_type |= TP_MEDIA_TYPE_VIDEO; break;
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
                GstCaps *caps = gst_pad_get_current_caps( pad );
                GstStructure *st = gst_caps_get_structure( caps, 0 );

                gst_structure_get_int( st, "width", &video_width );
                gst_structure_get_int( st, "height", &video_height );

                gst_caps_unref( caps );
                gst_object_unref( GST_OBJECT( pad ) );
            }

            gst_object_unref( GST_OBJECT( video_sink ) );

            set_actor_size();
        }
    }

    /*if ( media_type & TP_MEDIA_TYPE_AUDIO )
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
    }*/
}

void Media::clear_idle_material()
{
    if ( idle_material_set_flag )
    {
        clutter_gst_video_texture_set_idle_material( CLUTTER_GST_VIDEO_TEXTURE( vt ), COGL_INVALID_HANDLE );
        idle_material_set_flag = false;
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
            media->loaded();

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

            if ( tag && value ) ( ( Media * ) user_data )->tag_found( tag, value );
        }

        g_value_unset( &string_value );
    }

    g_value_unset( &original_value );
}

//-----------------------------------------------------------------------------
// Signal handlers
void gst_end_of_stream( ClutterMedia* cm, Media* media )
{
    if ( media->get_loop() )
    {
        clutter_media_set_progress( cm, 0.0 );
        clutter_media_set_playing( cm, TRUE );
        return;
    }

    if ( !media->check_idle_material() )
    {
        ClutterActor* actor = media->get_actor();
        CoglMaterial *material = cogl_material_copy( ( CoglMaterial * ) clutter_texture_get_cogl_material( CLUTTER_TEXTURE( actor ) ) );
        clutter_gst_video_texture_set_idle_material( CLUTTER_GST_VIDEO_TEXTURE( actor ), ( CoglHandle ) material );
        media->set_idle_material( true );
    }

    //clutter_media_set_playing( cm, FALSE );

    media->end_of_stream();
}

void gst_error( ClutterMedia* cm, GError* error, Media* media )
{
    if ( !( media->get_actor_hidden() ) )
    {
        clutter_actor_hide( CLUTTER_ACTOR( cm ) );
        media->set_actor_hidden( true );
    }

    media->error( error->code, error->message );
}
