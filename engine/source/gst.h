#ifndef _TRICKPLAY_GST_H
#define _TRICKPLAY_GST_H

#include "clutter-gst/clutter-gst.h"
#include "gst/video/video.h"

#include "trickplay/mediaplayer.h"
#include "trickplay/controller.h"

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
typedef int (*GST_PlayerConstructor)( GST_Player * mp, ClutterActor * actor );

void tp_mediaplayer_loaded( GST_Player * mp );
void tp_mediaplayer_error( GST_Player * mp, int code, const char * message );
void tp_mediaplayer_end_of_stream( GST_Player * mp );
void tp_mediaplayer_tag_found( GST_Player * mp, const char * name, const char * value);

struct GST_Player
{
    void * user_data;

    void gst_destroy              ();
    void gst_reset                ();
    int  gst_pause                ();
    int  gst_play                 ();
    int  gst_play_sound           ( const char * uri );
    int  gst_get_duration         ( double * seconds );
    int  gst_load                 ( const char * uri, const char * extra );
    int  gst_get_buffered_duration( double * start_seconds, double * end_seconds );
    int  gst_get_video_size       ( int * width, int * height );
    int  gst_get_media_type       ( int * type );

    int  gst_seek                 ( double seconds );
    int  gst_get_position         ( double * seconds );

    int  gst_get_audio_volume     ( double * volume );
    int  gst_set_audio_volume     ( double volume );

    int  gst_get_audio_mute       ( int * mute );
    int  gst_set_audio_mute       ( int mute );

    int  gst_get_loop_flag        ( bool * flag );
    int  gst_set_loop_flag        ( bool flag );
};

extern int gst_constructor( GST_Player* mp, ClutterActor * actor );

#endif // _TRICKPLAY_GST_H
