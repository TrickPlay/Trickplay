#ifndef _TRICKPLAY_MEDIA_H
#define _TRICKPLAY_MEDIA_H

#include "common.h"
#include "trickplay/mediaplayer.h"
#include "json.h"

class Media
{
  public:
    class Delegate // Delegate class to handle events
    {
      public:
        virtual ~Delegate() {};
        virtual void loaded( Media* player ) = 0;
        virtual void error( Media* player, int code, const char* message ) = 0;
        virtual void end_of_stream( Media* player ) = 0;
    };

    static Media* make( TPContext* context , Delegate* delegate, ClutterActor * actor ); // Constructing a media player

    // Functions called from Lua
    int get_state();
    int load( lua_State* L, const char* uri, const char* extra );
    int play();
    int seek( double seconds );
    int pause();
    int get_position( double* seconds );
    int get_duration( double* seconds );
    int get_buffered_duration( double* start_seconds, double* end_seconds );
    int get_video_size( int* width, int* height );
    int get_audio_volume( double* volume );
    int set_audio_volume( double volume );
    int get_audio_mute( int* mute );
    int set_audio_mute( int mute );
    int get_loop_flag( bool* _loop );
    int set_loop_flag( bool _loop );
    int has_media_type( bool * has_type, bool check_video );
    void reset();
    StringPairList get_tags();

    void add_delegate( Delegate* delegate );
    void remove_delegate( Delegate* delegate );

    gboolean get_loop()        { return loop; }
    gboolean get_loaded_flag() { return loaded_flag; }

    gboolean get_actor_hidden() { return actor_hidden; }
    void set_actor_hidden( bool _actor_hidden ) { actor_hidden = _actor_hidden; }

    gboolean get_keep_aspect_ratio() { return keep_aspect_ratio; }
    void set_keep_aspect_ratio( bool _keep_aspect_ratio ) { keep_aspect_ratio = _keep_aspect_ratio; }
    GstElement * get_pipeline() { return pipeline; }

    gint get_video_width()  { return video_width; }
    gint get_video_height() { return video_height; }
    ClutterActor* get_actor() { return vt; }

    ~Media();

  private:
    // Constructor given a delegate (from make)
    Media( TPContext*, Delegate*, ClutterActor* );

    Media()               { g_assert( FALSE ); } // Not allowed
    Media( const Media& ) { g_assert( FALSE ); } // Not allowed

    const StringSet& get_valid_schemes() const { return schemes; }
    void disconnect_loading_messages();
    int  get_media_type( int* type );
    void get_stream_information();
    int  gst_load( const char* uri, const char* extra );
    gulong get_load_signal() { return load_signal; }
    void set_load_signal( gulong _load_signal ) { load_signal = _load_signal; }
    void set_actor_size();

    void check( int valid_states ); // Checks whether the input state is valid

    struct Event // Structure to hold an event
    {
        enum Type {LOADED, ERROR, EOS, TAG};

        static Event* make( Type type, int code = 0, const gchar* message = NULL, const gchar* value = NULL );
        static void destroy( Event* event );

        Type    type;
        int     code;
        gchar * message;
        gchar * value;
    };

    void post_event( Event* event );                 // Post an event, add an idle source to process later
    static gboolean process_events( gpointer data ); // Callback from the idle source to process events
    void process_events();                           // Actually process the events
    void clear_events();                             // Clear all pending events

    // The external callbacks. They push an event into the queue and post an
    // idle source to process the event in the main thread.
    void loaded();
    void error( int code, const char* message );
    void end_of_stream();
    void tag_found( const char* name, const char* value );

    // Privte member fields
    typedef std::set<Delegate*> DelegateSet;
    TPContext*      context;
    int             state;
    GAsyncQueue*    queue;
    DelegateSet     delegates;
    StringPairList  tags;
    StringSet       schemes;
    ClutterActor*   vt;
    GstElement*     pipeline;
    ClutterMedia*   cm;
    gulong          load_signal;
    gint            video_width;
    gint            video_height;
    int             media_type;
    int             mute;
    bool            loop;
    double          volume;
    bool            loaded_flag;
    bool            actor_hidden;
    bool            keep_aspect_ratio;

#ifndef GLIB_VERSION_2_32
    GStaticRecMutex mutex;
#else
    GRecMutex       mutex;
#endif

    // External friend functions
    friend void loading_messages( GstBus* bus, GstMessage* message, Media* media );
    friend void gst_end_of_stream( ClutterMedia* cm, Media* media );
    friend void gst_error( ClutterMedia* cm, GError* error, Media* media );
    friend void collect_tags( const GstTagList* list, const gchar* tag, gpointer user_data );
};

void gst_end_of_stream( ClutterMedia* cm, Media* media );
void gst_error( ClutterMedia* cm, GError* error, Media* media );
void collect_tags( const GstTagList* list, const gchar* tag, gpointer user_data );
void loading_messages( GstBus* bus, GstMessage* message, Media* media );

#endif // _TRICKPLAY_MEDIA_H
