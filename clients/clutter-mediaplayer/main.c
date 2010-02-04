
#include "clutter-gst/clutter-gst.h"

#include <string.h>
#include <stdio.h>

#include "tp/tp.h"
#include "tp/mediaplayer.h"

//-----------------------------------------------------------------------------
// Signal handlers

static void mp_end_of_stream(ClutterMedia * cm,TPMediaPlayer * mp)
{
    tp_media_player_end_of_stream(mp);
    clutter_media_set_playing(cm,FALSE);
}

static void mp_error(ClutterMedia * cm,GError * error,TPMediaPlayer * mp)
{
    tp_media_player_error(mp,error->code,error->message);
    clutter_actor_hide(CLUTTER_ACTOR(cm));
}

//-----------------------------------------------------------------------------
// Implementation of TPMediaPlayer functions

static void mp_destroy(TPMediaPlayer *mp)
{
    if (mp->user_data)
    {
        g_object_unref(G_OBJECT(mp->user_data));
        mp->user_data=NULL;
    }
}

static void bus_message(GstBus * bus,GstMessage * message,gpointer data)
{
    g_debug("GST MESSAGE %s",gst_message_type_get_name(message->type));   
}

static int mp_load(TPMediaPlayer * mp,const char * uri,const char * extra)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);

#if 0
    GstElement * playbin=clutter_gst_video_texture_get_playbin(CLUTTER_GST_VIDEO_TEXTURE(cm));
    
    if (playbin)
    {
        GstBus * bus=gst_pipeline_get_bus(GST_PIPELINE(playbin));
        
        if (bus)
        {
            g_signal_connect_object (bus, "message",
                G_CALLBACK (bus_message),
                NULL,0);
            
            gst_object_unref(GST_OBJECT(bus));
        }
    }
#endif

    clutter_media_set_uri(cm,uri);
    
    // In reality, we would wait for the resource to be loaded successfully
    // before we call this, but clutter-gst does not have that capability
    tp_media_player_loaded(mp);
    return 0;
}

static void mp_reset(TPMediaPlayer * mp)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    clutter_media_set_playing(cm,FALSE);
    clutter_media_set_progress(cm,0);
    
    clutter_actor_hide(CLUTTER_ACTOR(cm));
}

static int mp_play(TPMediaPlayer * mp)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    clutter_media_set_playing(cm,TRUE);
    
    clutter_actor_show(CLUTTER_ACTOR(cm));
    return 0;
}

static int mp_seek(TPMediaPlayer * mp,double seconds)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    if (!clutter_media_get_can_seek(cm))
        return 1;
    clutter_media_set_progress(cm,seconds/clutter_media_get_duration(cm));
    return 0;
}

static int mp_pause(TPMediaPlayer * mp)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    clutter_media_set_playing(cm,FALSE);
    return 0;
}

static int mp_set_playback_rate(TPMediaPlayer * mp,int rate)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_get_position(TPMediaPlayer * mp,double * seconds)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    *seconds=clutter_media_get_duration(cm) * clutter_media_get_progress(cm);
    return 0;
}

static int mp_get_duration(TPMediaPlayer * mp,double * seconds)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);    
    *seconds=clutter_media_get_duration(cm);
    return 0;
}

static int mp_get_buffered_duration(TPMediaPlayer * mp,double * start_seconds,double * end_seconds)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    *start_seconds=0;
    *end_seconds=clutter_media_get_duration(cm) * clutter_media_get_buffer_fill(cm);
    return 0;
}

static int mp_get_video_size(TPMediaPlayer * mp,int * width,int * height)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_get_viewport_geometry(TPMediaPlayer * mp,int * left,int * top,int * width,int * height)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    gfloat x,y,w,h;
    clutter_actor_get_position(CLUTTER_ACTOR(cm),&x,&y);
    clutter_actor_get_size(CLUTTER_ACTOR(cm),&w,&h);
    *left=x;
    *top=y;
    *width=w;
    *height=h;
    return 0;
}

static int mp_set_viewport_geometry(TPMediaPlayer * mp,int left,int top,int width,int height)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    clutter_actor_set_position(CLUTTER_ACTOR(cm),left,top);
    clutter_actor_set_size(CLUTTER_ACTOR(cm),width,height);
    return 0;
}

static int mp_get_media_type(TPMediaPlayer * mp,int * type)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_get_audio_volume(TPMediaPlayer * mp,double * volume)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    *volume=clutter_media_get_audio_volume(cm);
    return 0;
}

static int mp_set_audio_volume(TPMediaPlayer * mp,double volume)
{
    ClutterMedia * cm=CLUTTER_MEDIA(mp->user_data);
    clutter_media_set_audio_volume(cm,volume);
    return 0;
}

static int mp_get_audio_mute(TPMediaPlayer * mp,int * mute)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_set_audio_mute(TPMediaPlayer * mp,int mute)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static void * mp_get_viewport_texture(TPMediaPlayer * mp)
{
    return mp->user_data;
}

//-----------------------------------------------------------------------------

static int mp_constructor(TPMediaPlayer * mp)
{
    static int init=0;
    
    if (!init)
    {
        init=1;
        gst_init(NULL,NULL);
    }
    
    ClutterActor * video_texture=clutter_gst_video_texture_new();
    
    if (!video_texture)
    {
        g_warning("FAILED TO CREATE CLUTTER GST VIDEO TEXTURE");
        return TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER;
    }
    
    // We own it
    
    g_object_ref_sink(G_OBJECT(video_texture));
    
    // Get the stage, size the video texture and add it to the stage
    
    clutter_actor_hide(video_texture);
    
    ClutterActor * stage=clutter_stage_get_default();
    
    gfloat width,height;
    
    clutter_actor_get_size(stage,&width,&height);
    clutter_actor_set_size(video_texture,width,height);
    clutter_actor_set_position(video_texture,0,0);
    
    clutter_container_add_actor(CLUTTER_CONTAINER(stage),video_texture);
    
    // Connect signals
    
    g_signal_connect(video_texture,"eos",G_CALLBACK(mp_end_of_stream),mp);
    g_signal_connect(video_texture,"error",G_CALLBACK(mp_error),mp);
        
    mp->user_data=video_texture;
    
    mp->destroy=mp_destroy;
    mp->load=mp_load;
    mp->reset=mp_reset;
    mp->play=mp_play;
    mp->seek=mp_seek;
    mp->pause=mp_pause;
    mp->set_playback_rate=mp_set_playback_rate;
    mp->get_position=mp_get_position;
    mp->get_duration=mp_get_duration;
    mp->get_buffered_duration=mp_get_buffered_duration;
    mp->get_video_size=mp_get_video_size;
    mp->get_viewport_geometry=mp_get_viewport_geometry;
    mp->set_viewport_geometry=mp_set_viewport_geometry;
    mp->get_media_type=mp_get_media_type;
    mp->get_audio_volume=mp_get_audio_volume;
    mp->set_audio_volume=mp_set_audio_volume;
    mp->get_audio_mute=mp_get_audio_mute;
    mp->set_audio_mute=mp_set_audio_mute;
    mp->get_viewport_texture=mp_get_viewport_texture;
    
    return 0;
}

void notify(gpointer data,GObject * p)
{
    g_debug("NOTIFIED %p",p);
}

//-----------------------------------------------------------------------------

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    if (argc>1)
        tp_context_set(context,"app.path",argv[1]);
    
    tp_context_set_media_player_constructor(context,mp_constructor);
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}

