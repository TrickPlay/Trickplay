#ifndef _TRICKPLAY_CONTROLLER_LIST_H
#define _TRICKPLAY_CONTROLLER_LIST_H

#include "trickplay/controller.h"
#include "common.h"
#include "util.h"

//-----------------------------------------------------------------------------

class ControllerList;

//-----------------------------------------------------------------------------

class Controller : public RefCounted
{
public:

    Controller( ControllerList* list, TPContext* context , const char* name, const TPControllerSpec* spec, void* data );

    TPController* get_tp_controller();

    String get_name() const;

    const String& get_id() const
    {
        return id;
    }

    unsigned long long get_capabilities() const;

    inline bool has_cap( unsigned long long cap ) const
    {
        return spec.capabilities & cap;
    }

    void get_input_size( unsigned int& width, unsigned int& height );

    void get_ui_size( unsigned int& width, unsigned int& height );

    bool is_connected() const;

    static int default_execute_command( TPController* controller, unsigned int, void*, void* );

    //.........................................................................
    // Events that a controller generates - they are passed to all the delegates.

    void disconnected();

    void key_down( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers );

    void key_up( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers );

    void accelerometer( double x, double y, double z , unsigned long int modifiers );

    void gyroscope( double x, double y, double z , unsigned long int modifiers );

    void magnetometer( double x, double y, double z , unsigned long int modifiers );

    void attitude( double roll, double pitch, double yaw , unsigned long int modifiers );

    void pointer_move( int x, int y , unsigned long int modifiers );

    void pointer_button_down( int button , int x, int y , unsigned long int modifiers );

    void pointer_button_up( int button , int x, int y , unsigned long int modifiers );

    void pointer_active();

    void pointer_inactive();

    void touch_down( int finger , int x, int y , unsigned long int modifiers );

    void touch_move( int finger , int x, int y , unsigned long int modifiers );

    void touch_up( int finger , int x, int y , unsigned long int modifiers );

    void scroll( int direction , unsigned long int modifiers );

    void ui_event( const String& parameters );

    void submit_image( void* data, unsigned int size, const char* mime_type );

    void submit_audio_clip( void* data, unsigned int size, const char* mime_type );

    void cancel_image( void );

    void cancel_audio_clip( void );

    void advanced_ui_ready( void );

    void advanced_ui_event( const char* json );

    void streaming_video_connected( const char* address );

    void streaming_video_failed( const char* address, const char* reason );

    void streaming_video_dropped( const char* address, const char* reason );

    void streaming_video_ended( const char* address, const char* who );

    void streaming_video_status( const char* status, const char* arg );

    //.........................................................................

    class Delegate
    {
    public:
        virtual ~Delegate() {}
        virtual void disconnected() = 0;
        virtual bool key_down( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers ) = 0;
        virtual bool key_up( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers ) = 0;
        virtual void accelerometer( double x, double y, double z , unsigned long int modifiers ) = 0;
        virtual void gyroscope( double x, double y, double z , unsigned long int modifiers ) = 0;
        virtual void magnetometer( double x, double y, double z , unsigned long int modifiers ) = 0;
        virtual void attitude( double roll, double pitch, double yaw , unsigned long int modifiers ) = 0;
        virtual bool pointer_move( int x, int y , unsigned long int modifiers ) = 0;
        virtual bool pointer_button_down( int button , int x, int y , unsigned long int modifiers ) = 0;
        virtual bool pointer_button_up( int button , int x, int y , unsigned long int modifiers ) = 0;
        virtual void pointer_active() = 0;
        virtual void pointer_inactive() = 0;
        virtual void touch_down( int finger , int x, int y , unsigned long int modifiers ) = 0;
        virtual void touch_move( int finger , int x, int y , unsigned long int modifiers ) = 0;
        virtual void touch_up( int finger , int x, int y , unsigned long int modifiers ) = 0;
        virtual bool scroll( int direction , unsigned long int modifiers ) = 0;
        virtual void ui_event( const String& parameters ) = 0;
        virtual void submit_image( void* data, unsigned int size, const char* mime_type ) = 0;
        virtual void submit_audio_clip( void* data, unsigned int size, const char* mime_type ) = 0;
        virtual void cancel_image( void ) = 0;
        virtual void cancel_audio_clip( void ) = 0;
        virtual void advanced_ui_ready( void ) = 0;
        virtual void advanced_ui_event( const char* json ) = 0;
        virtual void streaming_video_connected( const char* address ) = 0;
        virtual void streaming_video_failed( const char* address, const char* reason ) = 0;
        virtual void streaming_video_dropped( const char* address, const char* reason ) = 0;
        virtual void streaming_video_ended( const char* address, const char* who ) = 0;
        virtual void streaming_video_status( const char* status, const char* arg ) = 0;
    };

    void add_delegate( Delegate* delegate );

    void remove_delegate( Delegate* delegate );

    //.........................................................................
    // Things you can tell a controller to do

    enum UIBackgroundMode {CENTER, STRETCH, TILE};
    enum MotionFilter {NONE, LOW, HIGH};

    bool reset();

    bool start_accelerometer( MotionFilter filter, double interval );

    bool stop_accelerometer();

    bool start_gyroscope( double interval );

    bool stop_gyroscope();

    bool start_magnetometer( double interval );

    bool stop_magnetometer();

    bool start_attitude( double interval );

    bool stop_attitude();

    bool start_pointer();

    bool stop_pointer();

    bool show_pointer_cursor();

    bool hide_pointer_cursor();

    bool set_pointer_cursor( int x , int y , const String& image_uri );

    bool start_touches();

    bool stop_touches();

    bool show_multiple_choice( const String& label, const StringPairList& choices );

    bool clear_ui();

    bool set_ui_background( const String& resource, UIBackgroundMode mode );

    bool set_ui_image( const String& resource, int x, int y, int width, int height );

    bool play_sound( const String& resource, unsigned int loop );

    bool stop_sound();

    bool declare_resource( const String& resource, const String& uri , const String& group );

    bool drop_resource_group( const String& group );

    bool enter_text( const String& label, const String& text );

    bool request_image( unsigned int max_width , unsigned int max_height , bool edit ,
            const String& mask_resource, const String& dialog_label,
            const String& cancel_label );

    bool request_audio_clip( const String& dialog_label, const String& cancel_label );

    bool advanced_ui( const String& payload , String& result );

    bool show_virtual_remote();

    bool hide_virtual_remote();

    bool streaming_video_start_call( const String& address );

    bool streaming_video_end_call( const String& address );

    bool streaming_video_send_status();

    inline bool wants_accelerometer_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_ACCELEROMETER ) && g_atomic_int_get( & ts_accelerometer_started );
    }

    inline bool wants_gyroscope_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) && g_atomic_int_get( & ts_gyroscope_started );
    }

    inline bool wants_magnetometer_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) && g_atomic_int_get( & ts_magnetometer_started );
    }

    inline bool wants_attitude_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) && g_atomic_int_get( & ts_attitude_started );
    }

    inline bool wants_pointer_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_POINTER ) && g_atomic_int_get( & ts_pointer_started );
    }

    inline bool wants_touch_events() const
    {
        return ( spec.capabilities & TP_CONTROLLER_HAS_TOUCHES ) && g_atomic_int_get( & ts_touch_started );
    }

    typedef std::map< unsigned int, unsigned int > KeyMap;

    bool save_key_map( const KeyMap& km );

    bool is_advanced_ui_ready() const
    {
        return advanced_ui_is_ready;
    }

protected:

    virtual ~Controller();

private:

    unsigned int map_key_code( unsigned int key_code );

    String get_key_map_file_name() const;

    void load_external_map();

    TPController*       tp_controller;

    bool                connected;
    String              name;
    TPControllerSpec    spec;
    void*               data;
    TPContext*          context;
    bool                loaded_external_map;

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet         delegates;

    KeyMap              key_map;

    gint                ts_accelerometer_started;
    gint                ts_gyroscope_started;
    gint                ts_magnetometer_started;
    gint                ts_attitude_started;
    gint                ts_pointer_started;
    gint                ts_touch_started;

    bool                advanced_ui_is_ready;

    String              id;
};

//-----------------------------------------------------------------------------

class ControllerList
{
public:

    ControllerList();

    virtual ~ControllerList();

    TPController* add_controller( TPContext* context , const char* name, const TPControllerSpec* spec, void* data );

    void remove_controller( TPController* controller );

    void controller_added( Controller* controller );

    void controller_removed( Controller* controller );

    class Delegate
    {
    public:
        virtual ~Delegate() {}
        virtual void connected( Controller* controller ) = 0;
    };

    void add_delegate( Delegate* delegate );

    void remove_delegate( Delegate* delegate );

    typedef std::set<Controller*> ControllerSet;

    ControllerSet get_controllers();

    void reset_all();

    void stop_events();

private:

    void post_event( gpointer event );

    friend void tp_controller_key_down( TPController* controller, unsigned int key_code, unsigned long int unicode , unsigned long int modifiers );
    friend void tp_controller_key_up( TPController* controller, unsigned int key_code, unsigned long int unicode , unsigned long int modifiers );
    friend void tp_controller_accelerometer( TPController* controller, double x, double y, double z , unsigned long int modifiers );
    friend void tp_controller_gyroscope( TPController* controller, double x, double y, double z , unsigned long int modifiers );
    friend void tp_controller_magnetometer( TPController* controller, double x, double y, double z , unsigned long int modifiers );
    friend void tp_controller_attitude( TPController* controller, double roll, double pitch, double yaw , unsigned long int modifiers );
    friend void tp_controller_pointer_move( TPController* controller, int x, int y , unsigned long int modifiers );
    friend void tp_controller_pointer_button_down( TPController* controller, int button, int x, int y , unsigned long int modifiers );
    friend void tp_controller_pointer_button_up( TPController* controller, int button, int x, int y , unsigned long int modifiers );
    friend void tp_controller_pointer_active( TPController* controller );
    friend void tp_controller_pointer_inactive( TPController* controller );
    friend void tp_controller_touch_down( TPController* controller, int finger, int x, int y , unsigned long int modifiers );
    friend void tp_controller_touch_move( TPController* controller, int finger, int x, int y , unsigned long int modifiers );
    friend void tp_controller_touch_up( TPController* controller, int finger, int x, int y , unsigned long int modifiers );
    friend void tp_controller_ui_event( TPController* controller, const char* parameters );
    friend void tp_controller_submit_image( TPController* controller, const void* data, unsigned int size, const char* mime_type );
    friend void tp_controller_submit_audio_clip( TPController* controller, const void* data, unsigned int size, const char* mime_type );
    friend void tp_controller_cancel_image( TPController* controller );
    friend void tp_controller_cancel_audio_clip( TPController* controller );
    friend void tp_controller_advanced_ui_ready( TPController* controller );
    friend void tp_controller_advanced_ui_event( TPController* controller , const char* json );
    friend void tp_controller_scroll( TPController* controller , int direction , unsigned long int modifiers );
    friend void tp_controller_streaming_video_connected( TPController* controller, const char* address );
    friend void tp_controller_streaming_video_failed( TPController* controller, const char* address, const char* reason );
    friend void tp_controller_streaming_video_dropped( TPController* controller, const char* address, const char* reason );
    friend void tp_controller_streaming_video_ended( TPController* controller, const char* address, const char* who );
    friend void tp_controller_streaming_video_status( TPController* controller, const char* status, const char* arg );

    //.........................................................................

    static gboolean process_events( gpointer self );

    //.........................................................................

#ifndef GLIB_VERSION_2_32
    GStaticRecMutex mutex;
#else
    GRecMutex mutex;
#endif

    //.........................................................................

    typedef std::set<TPController*> TPControllerSet;

    TPControllerSet controllers;

    //.........................................................................

    GAsyncQueue*    queue;

    //.........................................................................

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet     delegates;

    gint            stopped;
};

#endif // _TRICKPLAY_CONTROLLER_LIST_H
