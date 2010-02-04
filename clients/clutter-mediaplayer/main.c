
#include "clutter-gst/clutter-gst.h"

#include <string.h>
#include <stdio.h>

#include "tp/tp.h"
#include "tp/mediaplayer.h"

//-----------------------------------------------------------------------------

typedef struct 
{
    ClutterActor *  vt;
    gulong          load_signal;  
}
UserData;

#define USERDATA(mp) UserData * ud=(UserData*)(mp->user_data)
#define CM(ud)       ClutterMedia * cm=CLUTTER_MEDIA(ud->vt)

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
    USERDATA(mp);
    
    if (ud)
    {
        g_object_unref(G_OBJECT(ud->vt));
        g_free(ud);
        mp->user_data=NULL;
    }
}


void collect_tags(const GstTagList * list,const gchar * tag,gpointer user_data)
{
    GValue original_value={0};
    
    if (gst_tag_list_copy_value(&original_value,list,tag))
    {
        GValue string_value={0};
        
        g_value_init(&string_value,G_TYPE_STRING);
        
        if (g_value_transform(&original_value,&string_value))
        {
            const gchar * value=g_value_get_string(&string_value);
            
            if (value)
            {
                tp_media_player_tag_found((TPMediaPlayer*)user_data,tag,value);
            }
        }
        g_value_unset(&string_value);        
    }
    g_value_unset(&original_value);
}

static void loading_messages(GstBus * bus,GstMessage * message,TPMediaPlayer * mp)
{
    USERDATA(mp);
    
    switch(message->type)
    {
        case GST_MESSAGE_TAG:
        {
            GstTagList * tags=NULL;
            gst_message_parse_tag(message,&tags);
            if (tags)
            {
                gst_tag_list_foreach(tags,collect_tags,mp);    
                gst_tag_list_free(tags);
            }
            break;    
        }

        case GST_MESSAGE_ASYNC_DONE:
        {
            tp_media_player_loaded(mp);
            g_signal_handler_disconnect(bus,ud->load_signal);
            ud->load_signal=0;
            break;
        }
    }
}

static int mp_load(TPMediaPlayer * mp,const char * uri,const char * extra)
{
    USERDATA(mp);
    CM(ud);
    
    clutter_media_set_uri(cm,uri);
    
    GstElement * playbin=clutter_gst_video_texture_get_playbin(CLUTTER_GST_VIDEO_TEXTURE(cm));
    
    if (!playbin)
        return 1;
    
    GstStateChangeReturn r=gst_element_set_state(playbin,GST_STATE_PAUSED);
    
    g_debug("STATE CHANGE RETURN IS %d",r);
    
    switch(r)
    {
        case GST_STATE_CHANGE_FAILURE:
        {
            return 2;
        }
        
        case GST_STATE_CHANGE_SUCCESS:
        case GST_STATE_CHANGE_NO_PREROLL:
        {
            tp_media_player_loaded(mp);
            break;
        }
        
        case GST_STATE_CHANGE_ASYNC:
        {
            // The state change happens asynchronously, so we connect a signal
            // handler to see when it is done
            
            GstBus * bus=gst_pipeline_get_bus(GST_PIPELINE(playbin));
            
            if (!bus)
                return 3;
            
            ud->load_signal=g_signal_connect(bus,"message",G_CALLBACK(loading_messages),mp);
            
            gst_object_unref(GST_OBJECT(bus));
            
            break;
        }
    }
    
    return 0;
}

static void mp_reset(TPMediaPlayer * mp)
{
    USERDATA(mp);
    CM(ud);
    
    // Reset should do more - it should truly forget all about the resource
    
    clutter_media_set_playing(cm,FALSE);
    clutter_media_set_progress(cm,0);
    
    clutter_actor_hide(CLUTTER_ACTOR(cm));
}

static int mp_play(TPMediaPlayer * mp)
{
    USERDATA(mp);
    CM(ud);

    clutter_media_set_playing(cm,TRUE);
    
    clutter_actor_show(CLUTTER_ACTOR(cm));
    return 0;
}

static int mp_seek(TPMediaPlayer * mp,double seconds)
{
    USERDATA(mp);
    CM(ud);

    if (!clutter_media_get_can_seek(cm))
        return 1;
    clutter_media_set_progress(cm,seconds/clutter_media_get_duration(cm));
    return 0;
}

static int mp_pause(TPMediaPlayer * mp)
{
    USERDATA(mp);
    CM(ud);

    clutter_media_set_playing(cm,FALSE);
    return 0;
}

static int mp_set_playback_rate(TPMediaPlayer * mp,int rate)
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
}

static int mp_get_position(TPMediaPlayer * mp,double * seconds)
{
    USERDATA(mp);
    CM(ud);

    *seconds=clutter_media_get_duration(cm) * clutter_media_get_progress(cm);
    return 0;
}

static int mp_get_duration(TPMediaPlayer * mp,double * seconds)
{
    USERDATA(mp);
    CM(ud);

    *seconds=clutter_media_get_duration(cm);
    return 0;
}

static int mp_get_buffered_duration(TPMediaPlayer * mp,double * start_seconds,double * end_seconds)
{
    USERDATA(mp);
    CM(ud);

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
    USERDATA(mp);
    CM(ud);

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
    USERDATA(mp);
    CM(ud);

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
    USERDATA(mp);
    CM(ud);

    *volume=clutter_media_get_audio_volume(cm);
    return 0;
}

static int mp_set_audio_volume(TPMediaPlayer * mp,double volume)
{
    USERDATA(mp);
    CM(ud);

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
    USERDATA(mp);

    return ud->vt;
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
    
    clutter_actor_lower_bottom(video_texture);
    
    // Connect signals
    
    g_signal_connect(video_texture,"eos",G_CALLBACK(mp_end_of_stream),mp);
    g_signal_connect(video_texture,"error",G_CALLBACK(mp_error),mp);

    UserData * user_data=(UserData*) g_malloc0(sizeof(UserData));
    
    user_data->vt=video_texture;
    user_data->load_signal=0;
    
    mp->user_data=user_data;
    
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

