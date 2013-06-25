
#include "clutter-gst/clutter-gst.h"
#include "gst/video/video.h"

#include <string.h>
#include <stdio.h>
#include <signal.h>

#include "trickplay/trickplay.h"
#include "trickplay/mediaplayer.h"
#include "trickplay/controller.h"

//-----------------------------------------------------------------------------

extern void* connect_audio_sampler( TPContext* context );

extern void disconnect_audio_sampler( void* sampler );


//-----------------------------------------------------------------------------

static ClutterActor *background_texture = NULL;

//-----------------------------------------------------------------------------

typedef struct
{
    ClutterActor*   vt;
    gulong          load_signal;
    gint            video_width;
    gint            video_height;
    int             media_type;
    int             mute;
    double          volume;
}
UserData;

#define USERDATA(mp) UserData * ud=(UserData*)(mp->user_data)
#define CM(ud)       ClutterMedia * cm=CLUTTER_MEDIA(ud->vt)

static TPContext* context = 0;

//-----------------------------------------------------------------------------

static inline void g_info( const gchar* format, ... )
{
    va_list args;
    va_start( args, format );
    g_logv( G_LOG_DOMAIN, G_LOG_LEVEL_INFO, format, args );
    va_end( args );
}

//-----------------------------------------------------------------------------
// Signal handlers

static void mp_end_of_stream( ClutterMedia* cm, TPMediaPlayer* mp )
{
    tp_media_player_end_of_stream( mp );
    clutter_media_set_playing( cm, FALSE );
}

static void mp_error( ClutterMedia* cm, GError* error, TPMediaPlayer* mp )
{
    tp_media_player_error( mp, error->code, error->message );
    clutter_actor_hide( CLUTTER_ACTOR( cm ) );
}

//-----------------------------------------------------------------------------
// This is used to collect tags from a gstreamer tag list

void collect_tags( const GstTagList* list, const gchar* tag, gpointer user_data )
{
    GValue original_value = {0};

    if ( gst_tag_list_copy_value( &original_value, list, tag ) )
    {
        GValue string_value = {0};

        g_value_init( &string_value, G_TYPE_STRING );

        if ( g_value_transform( &original_value, &string_value ) )
        {
            const gchar* value = g_value_get_string( &string_value );

            if ( value )
            {
                tp_media_player_tag_found( ( TPMediaPlayer* )user_data, tag, value );
            }
        }

        g_value_unset( &string_value );
    }

    g_value_unset( &original_value );
}

//-----------------------------------------------------------------------------
// Looks for the stream types and video size

static void get_stream_information( TPMediaPlayer* mp )
{
    USERDATA( mp );
    CM( ud );

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline )
    {
        return;
    }

    //.........................................................................
    // Use stream info to get the type of each stream

#if (CLUTTER_GST_MAJOR_VERSION < 1)
    GValueArray* info_array = NULL;

    g_object_get( G_OBJECT( pipeline ), "stream-info-value-array", &info_array, NULL );

    if ( info_array )
    {
        // Each entry in the array is information for a single stream

        guint i;

        for ( i = 0; i < info_array->n_values; ++i )
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

#if 0
                    // This lets you get the enum value associated with the stream type

                    GParamSpec* pspec;
                    GEnumValue* value;

                    pspec = g_object_class_find_property( G_OBJECT_GET_CLASS( stream_info ), "type" );

                    value = g_enum_get_value( G_PARAM_SPEC_ENUM( pspec )->enum_class, type );

                    g_debug( "  STREAM TYPE IS %d %s", type, value->value_nick );
#endif
                }
            }
        }

        g_value_array_free( info_array );
    }

#else
    gint n_audio, n_video;
    g_object_get( G_OBJECT( pipeline ), "n-video", &n_video, NULL );
    g_object_get( G_OBJECT( pipeline ), "n-audio", &n_audio, NULL );

    if ( n_video ) { ud->media_type |= TP_MEDIA_TYPE_VIDEO; }

    if ( n_audio ) { ud->media_type |= TP_MEDIA_TYPE_AUDIO; }

#endif

    //.........................................................................
    // If there is a video stream, we get the video sink and try to find the
    // video size

    if ( ud->media_type & TP_MEDIA_TYPE_VIDEO )
    {
        GstElement* video_sink = NULL;

        g_object_get( G_OBJECT( pipeline ), "video-sink", &video_sink, NULL );

        if ( video_sink )
        {
            GstPad* pad = gst_element_get_static_pad( video_sink, "sink" );

            if ( pad )
            {
                // Get its video width and height

                gint width = 0;
                gint height = 0;

                GstCaps *caps = gst_pad_get_current_caps(pad);
                GstStructure *st = gst_caps_get_structure(caps, 0);

                gst_structure_get_int(st, "width", &width);
                gst_structure_get_int(st, "height", &width);

                gst_caps_unref(caps);

                ud->video_width = width;
                ud->video_height = height;

                gst_object_unref( GST_OBJECT( pad ) );
            }

            gst_object_unref( GST_OBJECT( video_sink ) );
        }
    }

#if 1

    if ( ud->media_type & TP_MEDIA_TYPE_AUDIO )
    {
        GstElement* audio_sink = gst_element_factory_make( "autoaudiosink", "TPAudioSink" );

        if ( !audio_sink )
        {
            g_debug( "Failed to create autoaudiosink" );
        }
        else
        {
            g_object_set( G_OBJECT( pipeline ), "audio-sink", audio_sink, NULL );
        }
    }

#endif
}

//-----------------------------------------------------------------------------
// Used to disconnect the loading_messages signal handler during a reset

static void disconnect_loading_messages( TPMediaPlayer* mp )
{
    USERDATA( mp );
    CM( ud );

    if ( !ud->load_signal )
    {
        return;
    }

#if (CLUTTER_GST_MAJOR_VERSION<1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline )
    {
        return;
    }

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

    if ( !bus )
    {
        return;
    }

    g_signal_handler_disconnect( bus, ud->load_signal );
    ud->load_signal = 0;

    gst_object_unref( GST_OBJECT( bus ) );
}

//-----------------------------------------------------------------------------
// gstreamer messages we receive while we are loading

static void loading_messages( GstBus* bus, GstMessage* message, TPMediaPlayer* mp )
{
    USERDATA( mp );

    switch ( message->type )
    {
            //.....................................................................
            // When a tag is found

        case GST_MESSAGE_TAG:
        {
            GstTagList* tags = NULL;
            gst_message_parse_tag( message, &tags );

            if ( tags )
            {
                gst_tag_list_foreach( tags, collect_tags, mp );
                gst_tag_list_free( tags );
            }

            break;
        }

        //.....................................................................
        // When the load is done - the stream is paused and ready to go

        case GST_MESSAGE_ASYNC_DONE:
        {
            get_stream_information( mp );

            // Now, notify that the stream is loaded

            tp_media_player_loaded( mp );

            // Disconnect this signal handler

            g_signal_handler_disconnect( bus, ud->load_signal );
            ud->load_signal = 0;

            break;
        }

        default:
        {
            // Default handler to make clang shut up
            break;
        }
    }
}

//-----------------------------------------------------------------------------
// Implementation of TPMediaPlayer functions

static void mp_destroy( TPMediaPlayer* mp )
{
    USERDATA( mp );

    if ( ud )
    {
        g_object_unref( G_OBJECT( ud->vt ) );
        g_free( ud );
        mp->user_data = NULL;
    }
}

static int mp_load( TPMediaPlayer* mp, const char* uri, const char* extra )
{
    USERDATA( mp );
    CM( ud );

    clutter_media_set_uri( cm, uri );

#if (CLUTTER_GST_MAJOR_VERSION<1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline )
    {
        return 1;
    }

    GstStateChangeReturn r = gst_element_set_state( pipeline, GST_STATE_PAUSED );

    g_debug( "STATE CHANGE RETURN IS %d", r );

    switch ( r )
    {
        case GST_STATE_CHANGE_FAILURE:
        {
            return 2;
        }

        case GST_STATE_CHANGE_SUCCESS:
        case GST_STATE_CHANGE_NO_PREROLL:
        {
            get_stream_information( mp );
            tp_media_player_loaded( mp );
            break;
        }

        case GST_STATE_CHANGE_ASYNC:
        {
            // The state change happens asynchronously, so we connect a signal
            // handler to see when it is done

            GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

            if ( !bus )
            {
                return 3;
            }

            ud->load_signal = g_signal_connect( bus, "message", G_CALLBACK( loading_messages ), mp );

            gst_object_unref( GST_OBJECT( bus ) );

            break;
        }
    }

    return 0;
}

static void mp_reset( TPMediaPlayer* mp )
{
    USERDATA( mp );
    CM( ud );

    disconnect_loading_messages( mp );

    ud->video_width = 0;
    ud->video_height = 0;
    ud->media_type = 0;

    // Reset should do more - it should truly forget all about the resource

    clutter_media_set_playing( cm, FALSE );
    clutter_media_set_progress( cm, 0 );

    clutter_actor_hide( CLUTTER_ACTOR( cm ) );
}

static int mp_play( TPMediaPlayer* mp )
{
    USERDATA( mp );
    CM( ud );

    clutter_media_set_playing( cm, TRUE );

    if ( ud->media_type & TP_MEDIA_TYPE_VIDEO )
    {
        clutter_actor_show( CLUTTER_ACTOR( cm ) );
    }

    return 0;
}

static int mp_seek( TPMediaPlayer* mp, double seconds )
{
    USERDATA( mp );
    CM( ud );

    if ( !clutter_media_get_can_seek( cm ) )
    {
        return 1;
    }

    clutter_media_set_progress( cm, seconds / clutter_media_get_duration( cm ) );
    return 0;
}

static int mp_pause( TPMediaPlayer* mp )
{
    USERDATA( mp );
    CM( ud );

    clutter_media_set_playing( cm, FALSE );
    return 0;
}

static int mp_set_playback_rate( TPMediaPlayer* mp, int rate )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_get_position( TPMediaPlayer* mp, double* seconds )
{
    USERDATA( mp );
    CM( ud );

    *seconds = clutter_media_get_duration( cm ) * clutter_media_get_progress( cm );
    return 0;
}

static int mp_get_duration( TPMediaPlayer* mp, double* seconds )
{
    USERDATA( mp );
    CM( ud );

    *seconds = clutter_media_get_duration( cm );
    return 0;
}

static int mp_get_buffered_duration( TPMediaPlayer* mp, double* start_seconds, double* end_seconds )
{
    USERDATA( mp );
    CM( ud );

    *start_seconds = 0;
    *end_seconds = clutter_media_get_duration( cm ) * clutter_media_get_buffer_fill( cm );
    return 0;
}

static int mp_get_video_size( TPMediaPlayer* mp, int* width, int* height )
{
    USERDATA( mp );

    if ( !( ud->media_type & TP_MEDIA_TYPE_VIDEO ) )
    {
        return TP_MEDIAPLAYER_ERROR_NA;
    }

    *width = ud->video_width;
    *height = ud->video_height;

    return 0;
}

static int mp_get_viewport_geometry( TPMediaPlayer* mp, int* left, int* top, int* width, int* height )
{
    USERDATA( mp );
    CM( ud );

    gfloat x, y, w, h;
    clutter_actor_get_position( CLUTTER_ACTOR( cm ), &x, &y );
    clutter_actor_get_size( CLUTTER_ACTOR( cm ), &w, &h );
    *left = x;
    *top = y;
    *width = w;
    *height = h;
    return 0;
}

static int mp_set_viewport_geometry( TPMediaPlayer* mp, int left, int top, int width, int height )
{
    USERDATA( mp );
    CM( ud );

    clutter_actor_set_position( CLUTTER_ACTOR( cm ), left, top );
    clutter_actor_set_size( CLUTTER_ACTOR( cm ), width, height );
    return 0;
}

static int mp_get_media_type( TPMediaPlayer* mp, int* type )
{
    USERDATA( mp );
    *type = ud->media_type;
    return 0;
}

static int mp_get_audio_volume( TPMediaPlayer* mp, double* volume )
{
    USERDATA( mp );
    CM( ud );

    if ( ud->mute )
    {
        * volume = ud->volume;
    }
    else
    {
        *volume = clutter_media_get_audio_volume( cm );
    }

    return 0;
}

static int mp_set_audio_volume( TPMediaPlayer* mp, double volume )
{
    USERDATA( mp );
    CM( ud );

    ud->volume = volume;

    if ( !ud->mute )
    {
        clutter_media_set_audio_volume( cm, volume );
    }

    return 0;
}

static int mp_get_audio_mute( TPMediaPlayer* mp, int* mute )
{
    USERDATA( mp );

    *mute = ud->mute;

    return 0;
}

static int mp_set_audio_mute( TPMediaPlayer* mp, int mute )
{
    USERDATA( mp );
    CM( ud );

    int old_mute = ud->mute;

    ud->mute = mute ? 1 : 0;

    if ( old_mute != ud->mute )
    {
        if ( ud->mute )
        {
            clutter_media_set_audio_volume( cm, 0 );
        }
        else
        {
            clutter_media_set_audio_volume( cm, ud->volume );
        }
    }

    return 0;
}

static void play_sound_done( GstBus* bus, GstMessage* message, GstElement* playbin )
{
    gst_element_set_state( playbin, GST_STATE_NULL );

    gst_object_unref( GST_OBJECT( playbin ) );
}

static int mp_play_sound( TPMediaPlayer* mp, const char* uri )
{
    GstElement* playbin = gst_element_factory_make( "playbin" , "play" );

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( playbin ) );

    g_object_set( G_OBJECT( playbin ), "uri", uri, NULL );

    gst_bus_add_signal_watch( bus );

    g_signal_connect_object( bus, "message::error" , G_CALLBACK( play_sound_done ), playbin, G_CONNECT_AFTER );
    g_signal_connect_object( bus, "message::eos", G_CALLBACK( play_sound_done ), playbin, G_CONNECT_AFTER );

    gst_object_unref( GST_OBJECT( bus ) );

    if ( GST_STATE_CHANGE_FAILURE == gst_element_set_state( playbin, GST_STATE_PLAYING ) )
    {
        return 2;
    }

    return 0;
}

static void* mp_get_viewport_texture( TPMediaPlayer* mp )
{
    USERDATA( mp );

    return ud->vt;
}

//-----------------------------------------------------------------------------

static void stage_allocation_notify( GObject* actor , GParamSpec* p , gpointer vt )
{
    ClutterActor* video_texture = CLUTTER_ACTOR( vt );

    if ( vt )
    {
        // HACK ALERT
        ClutterActor* stage = ( ClutterActor* )tp_context_get( context, "sekrit-stage" );

        gfloat width;
        gfloat height;

        clutter_actor_get_size( stage , & width , & height );

        clutter_actor_set_size( video_texture , width , height );
    }
}

//-----------------------------------------------------------------------------

static int mp_constructor( TPMediaPlayer* mp )
{
    ClutterActor* video_texture = clutter_gst_video_texture_new();

    if ( !video_texture )
    {
        g_warning( "FAILED TO CREATE CLUTTER GST VIDEO TEXTURE" );
        return TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER;
    }

    // We own it

    g_object_ref_sink( G_OBJECT( video_texture ) );

    // Get the stage, size the video texture and add it to the stage

    clutter_actor_hide( video_texture );

    // This is a total hack, but there's no clean way to leak the ClutterStage out of the context
    // and clutter_stage_get_default() might give us the wrong stage in a multi-stage enviroment (like Ubuntu or OSX)
    ClutterActor* stage = ( ClutterActor* )tp_context_get( context, "sekrit-stage" );

    gfloat width, height;

    clutter_actor_get_size( stage, &width, &height );
    clutter_actor_set_size( video_texture, width, height );
    clutter_actor_set_position( video_texture, 0, 0 );

    if(background_texture)
    {
        clutter_actor_insert_child_above( stage, video_texture, background_texture );
    } else {
        clutter_actor_insert_child_below( stage, video_texture, NULL );
    }

    g_signal_connect( stage , "notify::allocation" , ( GCallback ) stage_allocation_notify , video_texture );

    // Connect signals

    g_signal_connect( video_texture, "eos", G_CALLBACK( mp_end_of_stream ), mp );
    g_signal_connect( video_texture, "error", G_CALLBACK( mp_error ), mp );

    // We use gmalloc0 to zero out the whole structure

    UserData* user_data = ( UserData* ) g_malloc0( sizeof( UserData ) );

    user_data->vt = video_texture;

    mp->user_data = user_data;

    mp->destroy = mp_destroy;
    mp->load = mp_load;
    mp->reset = mp_reset;
    mp->play = mp_play;
    mp->seek = mp_seek;
    mp->pause = mp_pause;
    mp->set_playback_rate = mp_set_playback_rate;
    mp->get_position = mp_get_position;
    mp->get_duration = mp_get_duration;
    mp->get_buffered_duration = mp_get_buffered_duration;
    mp->get_video_size = mp_get_video_size;
    mp->get_viewport_geometry = mp_get_viewport_geometry;
    mp->set_viewport_geometry = mp_set_viewport_geometry;
    mp->get_media_type = mp_get_media_type;
    mp->get_audio_volume = mp_get_audio_volume;
    mp->set_audio_volume = mp_set_audio_volume;
    mp->get_audio_mute = mp_get_audio_mute;
    mp->set_audio_mute = mp_set_audio_mute;
    mp->play_sound = mp_play_sound;
    mp->get_viewport_texture = mp_get_viewport_texture;

    // Initialize volume
    mp_set_audio_volume( mp, 0.5 );

    return 0;
}

static void background_loop_media( ClutterMedia *cm, gpointer *dummy )
{
    clutter_media_set_progress(cm, 0.0);
    clutter_media_set_playing(cm, TRUE);
}

static void background_error( ClutterMedia *cm, GError *error, gpointer *dummy )
{
    g_warning("BACKGROUND MEDIA ERROR: %s", error->message);
}

static void run_background_video(const gchar *uri)
{
    background_texture = clutter_gst_video_texture_new();

    if ( !background_texture )
    {
        g_warning( "FAILED TO CREATE CLUTTER GST VIDEO TEXTURE" );
        return;
    }

    // Get the stage, size the video texture and add it to the stage

    // This is a total hack, but there's no clean way to leak the ClutterStage out of the context
    // and clutter_stage_get_default() might give us the wrong stage in a multi-stage enviroment (like Ubuntu or OSX)
    ClutterActor* stage = ( ClutterActor* )tp_context_get( context, "sekrit-stage" );

    gfloat width, height;

    clutter_actor_get_size( stage, &width, &height );
    clutter_actor_set_size( background_texture, width, height );
    clutter_actor_set_position( background_texture, 0, 0 );
    clutter_actor_set_name( background_texture, "BACKGROUND VIDEO");

    clutter_actor_insert_child_below( stage, background_texture, NULL );

    g_signal_connect( stage , "notify::allocation" , ( GCallback ) stage_allocation_notify , background_texture );

    // Now we have an actor, in position.  Load and play the media in a loop

    g_signal_connect( background_texture, "eos", G_CALLBACK( background_loop_media ), NULL );
    g_signal_connect( background_texture, "error", G_CALLBACK( background_error ), NULL );

    g_info("BACKGROUND VIDEO INITIALIZED: LOADING URI %s", uri);

    clutter_media_set_uri( CLUTTER_MEDIA( background_texture ), uri );

    clutter_media_set_playing( CLUTTER_MEDIA( background_texture ), TRUE );
}


//-----------------------------------------------------------------------------
// We get notified when Trickplay is running - we start our audio sampler

static void trickplay_running( TPContext* context , const char* subject , void* data )
{
    void * * sampler = ( void ** ) data;

    * sampler = connect_audio_sampler( context );


    const gchar *background_video = tp_context_get( context, "background_video");
    if(background_video)
    {
        run_background_video(background_video);
    }
}

static void trickplay_exiting( TPContext* context , const char* subject , void* data )
{
    void * * sampler = ( void ** ) data;

    disconnect_audio_sampler( * sampler );
}

//-----------------------------------------------------------------------------

static void quit( int sig )
{
    if ( context )
    {
        tp_context_quit( context );
    }
}

int main( int argc, char* argv[] )
{
#ifndef TP_NEW_MEDIA
    if ( clutter_gst_init( NULL, NULL ) != CLUTTER_INIT_SUCCESS )
    {
        g_error( "Failed to initialize clutter\n" );
        return -1;
    }
#endif

    signal( SIGINT , quit );

    tp_init( &argc, &argv );

    context = tp_context_new();

    if ( argc > 1 && * ( argv[ argc - 1 ] ) != '-' )
    {
        tp_context_set( context, "app_path", argv[ argc - 1  ] );
    }

    // Media player constructor

    tp_context_set_media_player_constructor( context, mp_constructor );

    // Populate a sampler info structure with the context
    // and add a notification handler

    void* sampler = 0;

    tp_context_add_notification_handler( context, TP_NOTIFICATION_RUNNING, trickplay_running, &sampler );
    tp_context_add_notification_handler( context, TP_NOTIFICATION_EXITING, trickplay_exiting, &sampler );

    // Run the context

    int result = tp_context_run( context );

    tp_context_free( context );

    context = 0;

    return result;
}
