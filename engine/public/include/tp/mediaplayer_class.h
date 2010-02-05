#ifndef MEDIAPLAYER_CLASS_H
#define MEDIAPLAYER_CLASS_H

#include "tp/mediaplayer.h"

class MediaPlayer
{
    public:
        
        static void initialize(TPContext * context)
        {
            tp_context_set_media_player_constructor(context,mp_constructor);
        }
        
        TPMediaPlayer * get_tp_media_player()
        {
            return &mp;
        }
        
    protected:
        
        MediaPlayer()
        {
            mp.destroy=mp_destroy;
            mp.load=mp_load;
            mp.reset=mp_reset;
            mp.play=mp_play;
            mp.seek=mp_seek;
            mp.pause=mp_pause;
            mp.set_playback_rate=mp_set_playback_rate;
            mp.get_position=mp_get_position;
            mp.get_duration=mp_get_duration;
            mp.get_buffered_duration=mp_get_buffered_duration;
            mp.get_video_size=mp_get_video_size;
            mp.get_viewport_geometry=mp_get_viewport_geometry;
            mp.set_viewport_geometry=mp_set_viewport_geometry;
            mp.get_media_type=mp_get_media_type;
            mp.get_audio_volume=mp_get_audio_volume;
            mp.set_audio_volume=mp_set_audio_volume;
            mp.get_audio_mute=mp_get_audio_mute;
            mp.set_audio_mute=mp_set_audio_mute;
            mp.get_viewport_texture=mp_get_viewport_texture;

            mp.user_data=this;            
        }

        virtual ~MediaPlayer()
        {
        }
        
        // Functions we can call
        
        int get_state()
        {
            return tp_media_player_get_state(&mp);
        }
        
        void loaded()
        {
            tp_media_player_loaded(&mp);
        }
        
        void error(int code,const char * message)
        {
            tp_media_player_error(&mp,code,message);
        }
        
        void end_of_stream()
        {
            tp_media_player_end_of_stream(&mp);
        }
        
        // Functions TrickPlay calls and we must implement.
        // All of them fail by default
        
        virtual int load(const char * uri,const char * extra)
        {
            return 1;
        }
        
        virtual void reset()
        {
        }

        virtual int play()
        {
            return 1;
        }
        
        virtual int seek(double seconds)
        {
            return 1;
        }

        virtual int pause()
        {
            return 1;
        }
        
        virtual int set_playback_rate(int rate)
        {
            return 1;
        }
        
        virtual int get_position(double * seconds)
        {
            return 1;
        }
        
        virtual int get_duration(double * seconds)
        {
            return 1;
        }
        
        virtual int get_buffered_duration(double * start_seconds,double * end_seconds)
        {
            return 1;
        }

        virtual int get_video_size(int * width,int * height)
        {
            return 1;
        }
    
        virtual int get_viewport_geometry(int * left,int * top,int * width,int * height)
        {
            return 1;
        }
        
        virtual int set_viewport_geometry(int left,int top,int width,int height)
        {
            return 1;
        }
        
        virtual int get_media_type(int * type)
        {
            return 1;
        }
        
        virtual int get_audio_volume(double * volume)
        {
            return 1;
        }
        
        virtual int set_audio_volume(double volume)
        {
            return 1;
        }

        virtual int get_audio_mute(int * mute)
        {
            return 1;
        }

        virtual int set_audio_mute(int mute)
        {
            return 1;
        }
        
        virtual void * get_viewport_texture()
        {
            return NULL;
        }
    
    private:
                
        MediaPlayer(const MediaPlayer&)
        {
        }
                
        static TPMediaPlayer * mp_constructor()
        {
            // WRONG - won't let you create derived instance
            return &((new MediaPlayer())->mp);
        }
        
        static void mp_destroy(TPMediaPlayer *mp)
        {
            delete (MediaPlayer*)mp->user_data;
        }
        
        static int mp_load(TPMediaPlayer * mp,const char * uri,const char * extra)
        {
            return ((MediaPlayer*)mp->user_data)->load(uri,extra);
        }
        
        static void mp_reset(TPMediaPlayer * mp)
        {
            ((MediaPlayer*)mp->user_data)->reset();
        }

        static int mp_play(TPMediaPlayer * mp)
        {
            return ((MediaPlayer*)mp->user_data)->play();
        }
        
        static int mp_seek(TPMediaPlayer * mp,double seconds)
        {
            return ((MediaPlayer*)mp->user_data)->seek(seconds);
        }

        static int mp_pause(TPMediaPlayer * mp)
        {
            return ((MediaPlayer*)mp->user_data)->pause();
        }
        
        static int mp_set_playback_rate(TPMediaPlayer * mp,int rate)
        {
            return ((MediaPlayer*)mp->user_data)->set_playback_rate(rate);
        }
        
        static int mp_get_position(TPMediaPlayer * mp,double * seconds)
        {
            return ((MediaPlayer*)mp->user_data)->get_position(seconds);            
        }
        
        static int mp_get_duration(TPMediaPlayer * mp,double * seconds)
        {
            return ((MediaPlayer*)mp->user_data)->get_duration(seconds);            
        }
        
        static int mp_get_buffered_duration(TPMediaPlayer * mp,double * start_seconds,double * end_seconds)
        {
            return ((MediaPlayer*)mp->user_data)->get_buffered_duration(start_seconds,end_seconds);            
        }

        static int mp_get_video_size(TPMediaPlayer * mp,int * width,int * height)
        {
            return ((MediaPlayer*)mp->user_data)->get_video_size(width,height);            
        }
    
        static int mp_get_viewport_geometry(TPMediaPlayer * mp,int * left,int * top,int * width,int * height)
        {
            return ((MediaPlayer*)mp->user_data)->get_viewport_geometry(left,top,width,height);                        
        }
        
        static int mp_set_viewport_geometry(TPMediaPlayer * mp,int left,int top,int width,int height)
        {
            return ((MediaPlayer*)mp->user_data)->set_viewport_geometry(left,top,width,height);                        
        }
        
        static int mp_get_media_type(TPMediaPlayer * mp,int * type)
        {
            return ((MediaPlayer*)mp->user_data)->get_media_type(type);
        }
        
        static int mp_get_audio_volume(TPMediaPlayer * mp,double * volume)
        {
            return ((MediaPlayer*)mp->user_data)->get_audio_volume(volume);
        }
        
        static int mp_set_audio_volume(TPMediaPlayer * mp,double volume)
        {
            return ((MediaPlayer*)mp->user_data)->set_audio_volume(volume);
        }
        
        static int mp_get_audio_mute(TPMediaPlayer * mp,int * mute)
        {
            return ((MediaPlayer*)mp->user_data)->get_audio_mute(mute);
        }
        
        static int mp_set_audio_mute(TPMediaPlayer * mp,int mute)
        {
            return ((MediaPlayer*)mp->user_data)->set_audio_mute(mute);
        }

        static void * mp_get_viewport_texture(TPMediaPlayer * mp)
        {
            return ((MediaPlayer*)mp->user_data)->get_viewport_texture();            
        }
        
        TPMediaPlayer mp;
};


#endif // MEDIAPLAYER_CLASS_H