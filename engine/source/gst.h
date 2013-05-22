#include "clutter-gst/clutter-gst.h"
#include "gst/video/video.h"

#include "trickplay/mediaplayer.h"
#include "trickplay/controller.h"

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

#define TP_MEDIAPLAYER_IDLE         0x01
#define TP_MEDIAPLAYER_LOADING      0x02
#define TP_MEDIAPLAYER_PAUSED       0x04
#define TP_MEDIAPLAYER_PLAYING      0x08

#define TP_MEDIAPLAYER_ANY_STATE    (TP_MEDIAPLAYER_IDLE|TP_MEDIAPLAYER_LOADING|TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)

#define TP_MEDIA_TYPE_AUDIO         0x01
#define TP_MEDIA_TYPE_VIDEO         0x02
#define TP_MEDIA_TYPE_AUDIO_VIDEO   (TP_MEDIA_TYPE_AUDIO|TP_MEDIA_TYPE_VIDEO)

#define TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED    -1    
#define TP_MEDIAPLAYER_ERROR_INVALID_STATE      -2
#define TP_MEDIAPLAYER_ERROR_BAD_PARAMETER      -3
#define TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER     -4
#define TP_MEDIAPLAYER_ERROR_INVALID_URI        -5
#define TP_MEDIAPLAYER_ERROR_NA                 -6

typedef struct GST_Player GST_Player;
typedef int (*GST_PlayerConstructor)( GST_Player * mp );

void tp_context_set_media_player_constructor( TPContext * context, GST_PlayerConstructor constructor);
int tp_media_player_get_state( GST_Player * mp );
void tp_media_player_loaded( GST_Player * mp );
void tp_media_player_error( GST_Player * mp, int code, const char * message );
void tp_media_player_end_of_stream( GST_Player * mp );
void tp_media_player_tag_found( GST_Player * mp, const char * name, const char * value);

struct GST_Player
{
    void * user_data;

    void (*destroy)( GST_Player * mp);
    int (*load)( GST_Player * mp, const char * uri, const char * extra);
    void (*reset)( GST_Player * mp);
    int (*play)( GST_Player * mp);
    int (*seek)( GST_Player * mp, double seconds);
    int (*pause)( GST_Player * mp);
    int (*set_playback_rate)( GST_Player * mp, int rate);
    int (*get_position)( GST_Player * mp, double * seconds);
    int (*get_duration)( GST_Player * mp, double * seconds);
    int (*get_buffered_duration)( GST_Player * mp, double * start_seconds, double * end_seconds);
    int (*get_video_size)( GST_Player * mp, int * width, int * height); 
    int (*get_viewport_geometry)( GST_Player * mp, int * left, int * top, int * width, int * height);
    int (*set_viewport_geometry)( GST_Player * mp, int left, int top, int width, int height);
    int (*get_media_type)( GST_Player * mp, int * type);
    int (*get_audio_volume)( GST_Player * mp, double * volume); 
    int (*set_audio_volume)( GST_Player * mp, double volume);
    int (*get_audio_mute)( GST_Player * mp, int * mute);
    int (*set_audio_mute)( GST_Player * mp, int mute);
    int (*play_sound)( GST_Player * mp, const char * uri);
    void * (*get_viewport_texture)( GST_Player * mp);
};

