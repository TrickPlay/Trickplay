#ifndef _TRICKPLAY_MEDIA_H
#define _TRICKPLAY_MEDIA_H

#include "gst.h"
#include "common.h"
#include "trickplay/mediaplayer.h"
#include "json.h"

class Media
{
public:

    //.........................................................................
    // Delegate class to handle events

    class Delegate
    {
    public:
        virtual ~Delegate() {};
        virtual void loaded( Media* player ) = 0;
        virtual void error( Media* player, int code, const char* message ) = 0;
        virtual void end_of_stream( Media* player ) = 0;
    };

    //.........................................................................
    // Constructing a media player

    static Media* make( TPContext* context , Delegate* delegate, ClutterActor * actor );

    // Getting one from a GST_Player

    static Media* get( GST_Player* mp );

    ~Media();

    //.........................................................................
    // Functions that we can call from Lua

    int get_state();
    void reset();
    int load( const char* uri, const char* extra );
    int play();
    int seek( double seconds );
    int pause();
    int get_position( double* seconds );
    int get_duration( double* seconds );
    int get_buffered_duration( double* start_seconds, double* end_seconds );
    int get_video_size( int* width, int* height );
    int get_media_type( int* type );
    int get_audio_volume( double* volume );
    int set_audio_volume( double volume );
    int get_audio_mute( int* mute );
    int set_audio_mute( int mute );
    int get_loop_flag( bool* loop );
    int set_loop_flag( bool mute );
    int play_sound( const char* uri );
    void* get_viewport_texture();
    StringPairList get_tags();

    //.........................................................................
    // Add and remove delegates

    void add_delegate( Delegate* delegate );
    void remove_delegate( Delegate* delegate );

    //.........................................................................

    const StringSet& get_valid_schemes() const
    {
        return schemes;
    }

private:

    //.........................................................................
    // The external callbacks. They push an event into the queue and post an
    // idle source to process the event in the main thread.

    void loaded();
    void error( int code, const char* message );
    void end_of_stream();
    void tag_found( const char* name, const char* value );

    // The external functions are friends

    friend void tp_mediaplayer_loaded( GST_Player* mp );
    friend void tp_mediaplayer_error( GST_Player* mp, int code, const char* message );
    friend void tp_mediaplayer_end_of_stream( GST_Player* mp );
    friend void tp_mediaplayer_tag_found( GST_Player* mp, const char* name, const char* value );

    //.........................................................................
    // Structure to hold an event

    struct Event
    {
        enum Type {LOADED, ERROR, EOS, TAG};

        static Event* make( Type type, int code = 0, const gchar* message = NULL, const gchar* value = NULL );
        static void destroy( Event* event );

        Type    type;
        int     code;
        gchar* message;
        gchar* value;
    };

    // Post an event and add an idle source to process it later

    void post_event( Event* event );

    // Callback from the idle source to process events

    static gboolean process_events( gpointer data );

    // Actually process the events

    void process_events();

    // Clear all pending events

    void clear_events();

private:

    //.........................................................................
    // We use this to hold the GST_Player instance. We bolt on a marker, that
    // lets us verify its sanity and a pointer to us.

    struct Wrapper
    {
        // DO NOT ADD ANYTHING ABOVE mp. We rely on the address of mp being the
        // same as the address of the whole wrapper.

        GST_Player  mp;
        void*       marker;
        Media*      player;
    };

    //.........................................................................
    // Constructor given a wrapper and a delegate (from make)

    Media( TPContext*, Wrapper*, Delegate* );

    //.........................................................................
    // Not allowed

    Media()
    {
        g_assert( FALSE );
    }

    Media( const Media& )
    {
        g_assert( FALSE );
    }

    //.........................................................................
    // Checks the sanity of the wrapper and that the state is one of the valid
    // states passed in.

    void check( int valid_states );

    //.........................................................................
    // Returns the pointer to the GST_Player inside our wrapper

    GST_Player* get_mp();

    //.........................................................................

    typedef std::set<Delegate*> DelegateSet;

    TPContext*      context;
    Wrapper*        wrapper;
    int             state;
#ifndef GLIB_VERSION_2_32
    GStaticRecMutex mutex;
#else
    GRecMutex mutex;
#endif
    GAsyncQueue*    queue;
    DelegateSet     delegates;
    StringPairList  tags;
    StringSet       schemes;
};

#endif // _TRICKPLAY_MEDIA_H
