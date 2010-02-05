#ifndef TP_MEDIAPLAYERS_H
#define TP_MEDIAPLAYERS_H

#include <string>
#include <list>

#include "glib.h"

#include "tp/mediaplayer.h"

typedef std::string String;
typedef std::list< std::pair<String,String> > StringPairList;

class MediaPlayer
{
public:
    
    //.........................................................................
    // Delegate class to handle events
    
    class Delegate
    {
    public:
        
        virtual void loaded(MediaPlayer * player)=0;
        virtual void error(MediaPlayer * player,int code,const char * message)=0;
        virtual void end_of_stream(MediaPlayer * player)=0;
    };
    
    //.........................................................................
    // Constructing a media player
    
    static MediaPlayer * make(TPMediaPlayerConstructor constructor,Delegate * delegate=NULL);
    
    // Getting one from a TPMediaPlayer
    
    static MediaPlayer * get(TPMediaPlayer * mp);

    ~MediaPlayer();

    //.........................................................................
    // Functions that we can call from Lua

    int get_state();    
    void reset();    
    int load(const char * uri,const char * extra);    
    int play();    
    int seek(double seconds);    
    int pause();    
    int set_playback_rate(int rate);
    int get_position(double * seconds);
    int get_duration(double * seconds);
    int get_buffered_duration(double * start_seconds,double * end_seconds);
    int get_video_size(int * width,int * height);
    int get_viewport_geometry(int * left,int * top,int * width,int * height);
    int set_viewport_geometry(int left,int top,int width,int height);    
    int get_media_type(int * type);
    int get_audio_volume(double * volume);    
    int set_audio_volume(double volume);
    int get_audio_mute(int * mute );    
    int set_audio_mute(int mute);
    void * get_viewport_texture();
    StringPairList get_tags();

    //.........................................................................
    // Changing the delegate
    
    void set_delegate(Delegate * delegate);
    
private:
    
    //.........................................................................
    // The external callbacks. They push an event into the queue and post an
    // idle source to process the event in the main thread.
    
    void loaded();
    void error(int code,const char * message);
    void end_of_stream();
    void tag_found(const char * name,const char * value);
    
    // The external functions are friends
    
    friend int tp_media_player_get_state(TPMediaPlayer * mp);
    friend void tp_media_player_loaded(TPMediaPlayer * mp);
    friend void tp_media_player_error(TPMediaPlayer * mp,int code,const char * message);
    friend void tp_media_player_end_of_stream(TPMediaPlayer * mp);
    friend void tp_media_player_tag_found(TPMediaPlayer * mp,const char * name,const char * value);

    //.........................................................................
    // Structure to hold an event
    
    struct Event
    {
        enum Type {LOADED,ERROR,EOS,TAG};
        
        static Event * make(Type type,int code=0,const gchar * message=NULL,const gchar * value=NULL);
        static void destroy(Event * event);
        
        Type    type;
        int     code;
        gchar * message;
        gchar * value;
    };

    // Post an event and add an idle source to process it later
    
    void post_event(Event * event);
    
    // Callback from the idle source to process events
    
    static gboolean process_events(gpointer data);
    
    // Actually process the events
    
    void process_events();
    
    // Clear all pending events
    
    void clear_events();
    
private:
    
    //.........................................................................
    // We use this to hold the TPMediaPlayer instance. We bolt on a marker, that
    // lets us verify its sanity and a pointer to us.
    
    struct Wrapper
    {
        // DO NOT ADD ANYTHING ABOVE mp. We rely on the address of mp being the
        // same as the address of the whole wrapper.
        
        TPMediaPlayer   mp;
        void *          marker;
        MediaPlayer *   player;
    };

    //.........................................................................
    // Constructor given a wrapper and a delegate (from make)
    
    MediaPlayer(Wrapper *,Delegate *);
    
    //.........................................................................
    // Not allowed
    
    MediaPlayer()
    {
        g_assert(FALSE);
    }
    
    MediaPlayer(const MediaPlayer &)
    {
        g_assert(FALSE);
    }
        
    //.........................................................................
    // Checks the sanity of the wrapper and that the state is one of the valid
    // states passed in.

    void check(int valid_states);
    
    //.........................................................................
    // Returns the pointer to the TPMediaPlayer inside our wrapper
    
    TPMediaPlayer * get_mp();
    
    //.........................................................................
    
    Wrapper *       wrapper;
    int             state;
    GStaticRecMutex mutex;
    GAsyncQueue *   queue;
    Delegate *      delegate;
    StringPairList  tags;
};

#endif // TP_MEDIAPLAYERS_H