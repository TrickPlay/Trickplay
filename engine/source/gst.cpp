#include <string.h>
#include <stdio.h>
#include <signal.h>

#include "gst.h"

typedef struct
{
    ClutterActor*   vt;
    gulong          load_signal;
    gint            video_width;
    gint            video_height;
    int             media_type;
    int             mute;
    bool            loop;
    double          volume;
}
UserData;

//-----------------------------------------------------------------------------

int gst_seek( GST_Player* mp, double seconds );

#define USERDATA(mp) UserData * ud=(UserData*)(mp->user_data)
#define CM(ud)       ClutterMedia * cm=CLUTTER_MEDIA(ud->vt)

//-----------------------------------------------------------------------------

inline void g_info( const gchar* format, ... )
{
    va_list args;
    va_start( args, format );
    g_logv( G_LOG_DOMAIN, G_LOG_LEVEL_INFO, format, args );
    va_end( args );
}

//-----------------------------------------------------------------------------
// Signal handlers

void gst_end_of_stream( ClutterMedia* cm, GST_Player* mp )
{
    USERDATA( mp );

    if ( ud->loop )
    {
        gst_seek( mp, 0.0 );
    }
    else
    {
        tp_mediaplayer_end_of_stream( mp );
    }

    clutter_media_set_playing( cm, ud->loop );
}

void gst_error( ClutterMedia* cm, GError* error, GST_Player* mp )
{
    tp_mediaplayer_error( mp, error->code, error->message );
    //clutter_actor_hide( CLUTTER_ACTOR( cm ) );
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

            if ( value ) tp_mediaplayer_tag_found( ( GST_Player* )user_data, tag, value );
        }

        g_value_unset( &string_value );
    }

    g_value_unset( &original_value );
}

//-----------------------------------------------------------------------------
// Looks for the stream types and video size

void get_stream_information( GST_Player* mp )
{
    USERDATA( mp );
    CM( ud );

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

    if ( n_video ) { ud->media_type |= TP_MEDIA_TYPE_VIDEO; }
    if ( n_audio ) { ud->media_type |= TP_MEDIA_TYPE_AUDIO; }

#endif

    if ( ud->media_type & TP_MEDIA_TYPE_VIDEO )
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

                GstCaps *caps = gst_pad_get_current_caps(pad);
                GstStructure *st = gst_caps_get_structure(caps, 0);

                gst_structure_get_int(st, "width", &width);
                gst_structure_get_int(st, "height", &height);

                gst_caps_unref(caps);

                ud->video_width = width;
                ud->video_height = height;

                gst_object_unref( GST_OBJECT( pad ) );
            }

            gst_object_unref( GST_OBJECT( video_sink ) );
        }
    }

    /*if ( ud->media_type & TP_MEDIA_TYPE_AUDIO )
    {
        GstElement* audio_sink = NULL;
        g_object_get( G_OBJECT( pipeline ), "audio-sink", &audio_sink, NULL );
        //GstElement* audio_sink = gst_element_factory_make( "autoaudiosink", "TPAudioSink" );

        if ( !audio_sink )
        {
            g_debug( "Failed to create autoaudiosink" );
        }
        else
        {
            gst_object_unref( GST_OBJECT( audio_sink ) );
            //g_object_set( G_OBJECT( pipeline ), "audio-sink", audio_sink, NULL );
        }
    }*/
}

//-----------------------------------------------------------------------------
// Used to disconnect the loading_messages signal handler during a reset

void disconnect_loading_messages( GST_Player* mp )
{
    USERDATA( mp );
    CM( ud );

    if ( !ud->load_signal ) return;

#if (CLUTTER_GST_MAJOR_VERSION<1)
    GstElement* pipeline = clutter_gst_video_texture_get_playbin( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#else
    GstElement* pipeline = clutter_gst_video_texture_get_pipeline( CLUTTER_GST_VIDEO_TEXTURE( cm ) );
#endif

    if ( !pipeline ) return;

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

    if ( !bus ) return;

    g_signal_handler_disconnect( bus, ud->load_signal );
    ud->load_signal = 0;

    gst_object_unref( GST_OBJECT( bus ) );
}

//-----------------------------------------------------------------------------
// gstreamer messages we receive while we are loading

void loading_messages( GstBus* bus, GstMessage* message, GST_Player* mp )
{
    USERDATA( mp );

    switch ( message->type )
    {
        case GST_MESSAGE_TAG: // When a tag is found
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

        case GST_MESSAGE_ASYNC_DONE: // When the load is done - the stream is paused and ready to go
        {
            get_stream_information( mp );

            // Now, notify that the stream is loaded
            tp_mediaplayer_loaded( mp );

            // Disconnect this signal handler
            g_signal_handler_disconnect( bus, ud->load_signal );
            ud->load_signal = 0;

            break;
        }

        default:
            break; // Default handler to make clang shut up
    }
}

//-----------------------------------------------------------------------------
// Implementation of GST_Player functions

void gst_destroy( GST_Player* mp )
{
    USERDATA( mp );

    if ( ud )
    {
        g_object_unref( G_OBJECT( ud->vt ) );
        g_free( ud );
        mp->user_data = NULL;
    }
}

int gst_load( GST_Player* mp, const char* uri, const char* extra )
{
    USERDATA( mp );
    CM( ud );

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
        case GST_STATE_CHANGE_FAILURE:
        {
            return 2;
        }

        case GST_STATE_CHANGE_SUCCESS:
        case GST_STATE_CHANGE_NO_PREROLL:
        {
            get_stream_information( mp );
            tp_mediaplayer_loaded( mp );
            break;
        }

        case GST_STATE_CHANGE_ASYNC:
        {
            // The state change happens asynchronously, so we connect a signal
            // handler to see when it is done

            GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( pipeline ) );

            if ( !bus ) return 3;

            ud->load_signal = g_signal_connect( bus, "message", G_CALLBACK( loading_messages ), mp );

            gst_object_unref( GST_OBJECT( bus ) );

            break;
        }
    }

    return 0;
}

void gst_reset( GST_Player* mp )
{
    USERDATA( mp );
    CM( ud );

    disconnect_loading_messages( mp );

    ud->video_width  = 0;
    ud->video_height = 0;
    ud->media_type   = 0;

    // TODO: Reset truly forget all about the resource

    clutter_media_set_playing( cm, FALSE );
    clutter_media_set_progress( cm, 0 );

    //clutter_actor_hide( CLUTTER_ACTOR( cm ) );
}

int gst_play( GST_Player* mp )
{
    USERDATA( mp );
    CM( ud );

    clutter_media_set_playing( cm, TRUE );

    if ( ud->media_type & TP_MEDIA_TYPE_VIDEO ) clutter_actor_show( CLUTTER_ACTOR( cm ) );

    return 0;
}

int gst_seek( GST_Player* mp, double seconds )
{
    USERDATA( mp );
    CM( ud );

    if ( !clutter_media_get_can_seek( cm ) ) return 1;

    clutter_media_set_progress( cm, seconds / clutter_media_get_duration( cm ) );
    return 0;
}

int gst_pause( GST_Player* mp )
{
    USERDATA( mp );
    CM( ud );

    clutter_media_set_playing( cm, FALSE );
    return 0;
}

int gst_set_playback_rate( GST_Player* mp, int rate )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

int gst_get_position( GST_Player* mp, double* seconds )
{
    USERDATA( mp );
    CM( ud );

    *seconds = clutter_media_get_duration( cm ) * clutter_media_get_progress( cm );
    return 0;
}

int gst_get_duration( GST_Player* mp, double* seconds )
{
    USERDATA( mp );
    CM( ud );

    *seconds = clutter_media_get_duration( cm );
    return 0;
}

int gst_get_buffered_duration( GST_Player* mp, double* start_seconds, double* end_seconds )
{
    USERDATA( mp );
    CM( ud );

    *start_seconds = 0;
    *end_seconds = clutter_media_get_duration( cm ) * clutter_media_get_buffer_fill( cm );
    return 0;
}

int gst_get_video_size( GST_Player* mp, int* width, int* height )
{
    USERDATA( mp );

    if ( !( ud->media_type & TP_MEDIA_TYPE_VIDEO ) ) return TP_MEDIAPLAYER_ERROR_NA;

    *width = ud->video_width;
    *height = ud->video_height;

    return 0;
}

int gst_get_media_type( GST_Player* mp, int* type )
{
    USERDATA( mp );
    *type = ud->media_type;
    return 0;
}

int gst_get_audio_volume( GST_Player* mp, double* volume )
{
    USERDATA( mp );
    CM( ud );

    * volume = ud->mute ? ud->volume : clutter_media_get_audio_volume( cm );

    return 0;
}

int gst_set_audio_volume( GST_Player* mp, double volume )
{
    USERDATA( mp );
    CM( ud );

    ud->volume = volume;

    if ( !ud->mute ) clutter_media_set_audio_volume( cm, volume );

    return 0;
}

int gst_get_audio_mute( GST_Player* mp, int* mute )
{
    USERDATA( mp );

    *mute = ud->mute;

    return 0;
}

int gst_set_audio_mute( GST_Player* mp, int mute )
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

int gst_get_loop_flag( GST_Player* mp, bool* loop )
{
    USERDATA( mp );

    *loop = ud->loop;

    return 0;
}

int gst_set_loop_flag( GST_Player* mp, bool flag )
{
    USERDATA( mp );

    ud->loop = flag;

    return 0;
}

void play_sound_done( GstBus* bus, GstMessage* message, GstElement* playbin )
{
    gst_element_set_state( playbin, GST_STATE_NULL );

    gst_object_unref( GST_OBJECT( playbin ) );
}

int gst_play_sound( GST_Player* mp, const char* uri )
{
    GstElement* playbin = gst_element_factory_make( "playbin" , "play" );

    GstBus* bus = gst_pipeline_get_bus( GST_PIPELINE( playbin ) );

    g_object_set( G_OBJECT( playbin ), "uri", uri, NULL );

    gst_bus_add_signal_watch( bus );

    g_signal_connect_object( bus, "message::error" , G_CALLBACK( play_sound_done ), playbin, G_CONNECT_AFTER );
    g_signal_connect_object( bus, "message::eos", G_CALLBACK( play_sound_done ), playbin, G_CONNECT_AFTER );

    gst_object_unref( GST_OBJECT( bus ) );

    if ( GST_STATE_CHANGE_FAILURE == gst_element_set_state( playbin, GST_STATE_PLAYING ) ) return 2;

    return 0;
}

void* gst_get_viewport_texture( GST_Player* mp )
{
    USERDATA( mp );

    return ud->vt;
}

//-----------------------------------------------------------------------------

int gst_constructor( GST_Player* mp, ClutterActor * video_texture )
{
    if ( !video_texture )
    {
        g_warning( "FAILED TO CREATE CLUTTER GST VIDEO TEXTURE" );
        return TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER;
    }

    g_object_ref_sink( G_OBJECT( video_texture ) ); // We own it

    // Connect signals
    g_signal_connect( video_texture, "eos", G_CALLBACK( gst_end_of_stream ), mp );
    g_signal_connect( video_texture, "error", G_CALLBACK( gst_error ), mp );

    UserData* user_data = ( UserData* ) g_malloc0( sizeof( UserData ) ); // zero out the whole structure

    user_data->vt = video_texture;

    mp->user_data = user_data;

    mp->destroy = gst_destroy;
    mp->load = gst_load;
    mp->reset = gst_reset;
    mp->play = gst_play;
    mp->seek = gst_seek;
    mp->pause = gst_pause;
    mp->set_playback_rate = gst_set_playback_rate;
    mp->get_position = gst_get_position;
    mp->get_duration = gst_get_duration;
    mp->get_buffered_duration = gst_get_buffered_duration;
    mp->get_video_size = gst_get_video_size;
    mp->get_media_type = gst_get_media_type;
    mp->get_audio_volume = gst_get_audio_volume;
    mp->set_audio_volume = gst_set_audio_volume;
    mp->get_audio_mute = gst_get_audio_mute;
    mp->set_audio_mute = gst_set_audio_mute;
    mp->get_loop_flag = gst_get_loop_flag;
    mp->set_loop_flag = gst_set_loop_flag;
    mp->play_sound = gst_play_sound;
    mp->get_viewport_texture = gst_get_viewport_texture;

    gst_set_audio_volume( mp, 0.5 ); // Initialize volume

    return 0;
}
