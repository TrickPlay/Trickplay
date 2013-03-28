#ifndef _TRICKPLAY_CONTROLLER_DELEGATES_H
#define _TRICKPLAY_CONTROLLER_DELEGATES_H

#include "controller_list.h"
#include "user_data.h"

class ControllerListDelegate;

//=============================================================================

class ControllerDelegate : public Controller::Delegate
{
public:

    ControllerDelegate( lua_State* _LS , Controller* _controller , ControllerListDelegate* _list );

    ~ControllerDelegate();

    inline Controller* get_controller()
    {
        return controller;
    }

    inline bool has_cap( unsigned long long cap )
    {
        return controller->get_capabilities( ) & cap;
    }

    //.........................................................................
    // Delegate functions

    virtual void disconnected();
    virtual bool key_down( unsigned int key_code, unsigned long int unicode, unsigned long int modifiers );
    virtual bool key_up( unsigned int key_code, unsigned long int unicode, unsigned long int modifiers );
    virtual void accelerometer( double x, double y, double z, unsigned long int modifiers );
    virtual void gyroscope( double x, double y, double z, unsigned long int modifiers );
    virtual void magnetometer( double x, double y, double z, unsigned long int modifiers );
    virtual void attitude( double roll, double pitch, double yaw, unsigned long int modifiers );
    virtual bool pointer_move( int x, int y , unsigned long int modifiers );
    virtual bool pointer_button_down( int button , int x, int y , unsigned long int modifiers );
    virtual bool pointer_button_up( int button , int x, int y , unsigned long int modifiers );
    virtual void pointer_active();
    virtual void pointer_inactive();
    virtual void touch_down( int finger, int x, int y, unsigned long int modifiers );
    virtual void touch_move( int finger, int x, int y, unsigned long int modifiers );
    virtual void touch_up( int finger, int x, int y, unsigned long int modifiers );
    virtual bool scroll( int direction , unsigned long int modifiers );
    virtual void ui_event( const String& parameters );
    virtual void submit_image( void* data, unsigned int size, const char* mime_type );
    virtual void submit_audio_clip( void* data, unsigned int size, const char* mime_type );
    virtual void cancel_image( void );
    virtual void cancel_audio_clip( void );
    virtual void advanced_ui_ready( void );
    virtual void advanced_ui_event( const char* json );
    virtual void streaming_video_connected( const char* address );
    virtual void streaming_video_failed( const char* address, const char* reason );
    virtual void streaming_video_dropped( const char* address, const char* reason );
    virtual void streaming_video_ended( const char* address, const char* who );
    virtual void streaming_video_status( const char* status, const char* arg );

    bool declare_resource( const String& name , const String& uri );

private:

    lua_State*                  L;
    Controller*                 controller;
    ControllerListDelegate*     list;
    String                      resource_group;
};

//=============================================================================

class ControllerListDelegate : public ControllerList::Delegate
{
public:

    ControllerListDelegate( lua_State* l );
    ~ControllerListDelegate();

    //.........................................................................
    // Delegate function

    virtual void connected( Controller* controller );

    void push_connected();

    void proxy_disconnected( ControllerDelegate* proxy );

    void start_pointer();

private:

    lua_State*          L;
    ControllerList*     list;

    typedef std::map< ControllerDelegate* , UserData::Handle* > ProxyMap;

    ProxyMap            proxies;
};

//=============================================================================

#endif // _TRICKPLAY_CONTROLLER_DELEGATES_H
