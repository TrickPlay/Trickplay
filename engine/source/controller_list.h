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

    Controller( ControllerList * list, const char * name, const TPControllerSpec * spec, void * data );

    TPController * get_tp_controller();

    String get_name() const;

    unsigned int get_capabilities() const;

    void get_input_size( unsigned int & width, unsigned int & height );

    void get_ui_size( unsigned int & width, unsigned int & height );

    bool is_connected() const;

    static int default_execute_command( TPController * controller, unsigned int, void *, void * );

    //.........................................................................
    // Events that a controller generates - they are passed to all the delegates.

    void disconnected();

    void key_down( unsigned int key_code, unsigned long int unicode );

    void key_up( unsigned int key_code, unsigned long int unicode );

    void accelerometer( double x, double y, double z );

    void click( int x, int y );

    void touch_down( int x, int y );

    void touch_move( int x, int y );

    void touch_up( int x, int y );

    void ui_event( const String & parameters );

    //.........................................................................

    class Delegate
    {
    public:
        virtual void disconnected() = 0;
        virtual void key_down( unsigned int key_code, unsigned long int unicode ) = 0;
        virtual void key_up( unsigned int key_code, unsigned long int unicode ) = 0;
        virtual void accelerometer( double x, double y, double z ) = 0;
        virtual void click( int x, int y ) = 0;
        virtual void touch_down( int x, int y ) = 0;
        virtual void touch_move( int x, int y ) = 0;
        virtual void touch_up( int x, int y ) = 0;
        virtual void ui_event( const String & parameters ) = 0;
    };

    void add_delegate( Delegate * delegate );

    void remove_delegate( Delegate * delegate );

    //.........................................................................
    // Things you can tell a controller to do

    enum UIBackgroundMode {CENTER, STRETCH, TILE};
    enum AccelerometerFilter {NONE, LOW, HIGH};

    bool reset();

    bool start_accelerometer( AccelerometerFilter filter, double interval );

    bool stop_accelerometer();

    bool start_clicks();

    bool stop_clicks();

    bool start_touches();

    bool stop_touches();

    bool show_multiple_choice( const String & label, const StringPairList & choices );

    bool clear_ui();

    bool set_ui_background( const String & resource, UIBackgroundMode mode );

    bool set_ui_image( const String & resource, int x, int y, int width, int height );

    bool play_sound( const String & resource, unsigned int loop );

    bool stop_sound();

    bool declare_resource( const String & resource, const String & uri );

    bool enter_text( const String & label, const String & text );

protected:

    virtual ~Controller();

private:

    unsigned int map_key_code( unsigned int key_code );

    TPController    *   tp_controller;

    bool                connected;
    String              name;
    TPControllerSpec    spec;
    void        *       data;

    typedef std::set<Delegate *> DelegateSet;

    DelegateSet         delegates;

    typedef std::map<unsigned int, unsigned int> KeyMap;

    KeyMap              key_map;
};

//-----------------------------------------------------------------------------

class ControllerList
{
public:

    ControllerList();

    virtual ~ControllerList();

    TPController * add_controller( const char * name, const TPControllerSpec * spec, void * data );

    void remove_controller( TPController * controller );

    void controller_added( Controller * controller );

    class Delegate
    {
    public:
        virtual void connected( Controller * controller ) = 0;
    };

    void add_delegate( Delegate * delegate );

    void remove_delegate( Delegate * delegate );

    typedef std::set<Controller *> ControllerSet;

    ControllerSet get_controllers();

private:

    void post_event( gpointer event );

    friend void tp_controller_key_down( TPController * controller, unsigned int key_code, unsigned long int unicode );
    friend void tp_controller_key_up( TPController * controller, unsigned int key_code, unsigned long int unicode );
    friend void tp_controller_accelerometer( TPController * controller, double x, double y, double z );
    friend void tp_controller_click( TPController * controller, int x, int y );
    friend void tp_controller_touch_down( TPController * controller, int x, int y );
    friend void tp_controller_touch_move( TPController * controller, int x, int y );
    friend void tp_controller_touch_up( TPController * controller, int x, int y );
    friend void tp_controller_ui_event( TPController * controller, const char * parameters );

    //.........................................................................

    static gboolean process_events( gpointer self );

    //.........................................................................

    GStaticRecMutex mutex;

    //.........................................................................

    typedef std::set<TPController *> TPControllerSet;

    TPControllerSet controllers;

    //.........................................................................

    GAsyncQueue  *  queue;

    //.........................................................................

    typedef std::set<Delegate *> DelegateSet;

    DelegateSet     delegates;
};

#endif // _TRICKPLAY_CONTROLLER_LIST_H
