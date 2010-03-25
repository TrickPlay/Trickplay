#ifndef _TRICKPLAY_CONTROLLER_LIST_H
#define _TRICKPLAY_CONTROLLER_LIST_H

#include "trickplay/controller.h"
#include "common.h"
#include "util.h"

//-----------------------------------------------------------------------------

class Event;
class ControllerList;

//-----------------------------------------------------------------------------

class Controller : public RefCounted
{
public:
    
    Controller(ControllerList * list,const char * name,const TPControllerSpec * spec,void * data);
    
    TPController * get_tp_controller();
    
    String get_name() const;
    
    unsigned int get_capabilities() const;
    
    void get_input_size(unsigned int & width,unsigned int & height);
    
    void get_ui_size(unsigned int & width,unsigned int & height);
    
    bool is_connected() const;
    
    static int default_execute_command(TPController * controller,unsigned int,void *,void *);
    
    //.........................................................................
    // Events that a controller generates - they are passed to all the delegates.
    
    void disconnected();
    
    void key_down(unsigned int key_code,unsigned long int unicode);
    
    void key_up(unsigned int key_code,unsigned long int unicode);
    
    void accelerometer(double x,double y,double z);
    
    void click(int x,int y);

    void touch_down(int x,int y);

    void touch_move(int x,int y);

    void touch_up(int x,int y);
    
    void ui_event(const String & parameters);
    
    //.........................................................................
    
    class Delegate
    {
    public:        
        virtual void disconnected()=0;
        virtual void key_down(unsigned int key_code,unsigned long int unicode)=0;
        virtual void key_up(unsigned int key_code,unsigned long int unicode)=0;
        virtual void accelerometer(double x,double y,double z)=0;
        virtual void click(int x,int y)=0;
        virtual void touch_down(int x,int y)=0;
        virtual void touch_move(int x,int y)=0;  
        virtual void touch_up(int x,int y)=0;    
        virtual void ui_event(const String & parameters)=0;
    };
    
    void add_delegate(Delegate * delegate);
    
    void remove_delegate(Delegate * delegate);
    
    //.........................................................................
    // Things you can tell a controller to do
    
    enum UIBackgroundMode {CENTER,STRETCH,TILE};
    enum AccelerometerFilter {NONE,LOW,HIGH};
    
    bool reset();
    
    bool start_accelerometer(AccelerometerFilter filter,double interval);
    
    bool stop_accelerometer();
    
    bool start_clicks();
    
    bool stop_clicks();
    
    bool start_touches();
    
    bool stop_touches();
    
    bool show_multiple_choice(const String & label,const StringPairList & choices);
    
    bool clear_ui();
    
    bool set_ui_background(const String & resource,UIBackgroundMode mode);
    
    bool set_ui_image(const String & resource,int x,int y,int width,int height);
    
    bool play_sound(const String & resource,unsigned int loop);
    
    bool stop_sound();
    
    bool declare_resource(const String & resource,const String & uri);
    
    bool enter_text(const String & label,const String & text);

protected:
    
    virtual ~Controller();
        
private:
    
    TPController *      tp_controller;
    
    bool                connected;    
    String              name;
    TPControllerSpec    spec;
    void *              data;
    
    typedef std::set<Delegate*> DelegateSet;
    
    DelegateSet         delegates;
};

//-----------------------------------------------------------------------------

class ControllerList
{
public:
    
    ControllerList();
    
    virtual ~ControllerList();
    
    TPController * add_controller(const char * name,const TPControllerSpec * spec,void * data);
    
    void remove_controller(TPController * controller);

    void post_event(Event * event);
    
    void controller_added(Controller * controller);
    
    class Delegate
    {
    public:
        virtual void connected(Controller * controller)=0;
    };
    
    void add_delegate(Delegate * delegate);
    
    void remove_delegate(Delegate * delegate);
    
    typedef std::set<Controller*> ControllerSet;
    
    ControllerSet get_controllers();
    
private:

    //.........................................................................

    static gboolean process_events(gpointer self);
    
    void process_events();

    //.........................................................................
    
    GStaticRecMutex mutex;
    
    //.........................................................................

    typedef std::set<TPController*> TPControllerSet;
    
    TPControllerSet controllers;
    
    //.........................................................................

    GAsyncQueue *   queue;
    
    //.........................................................................
    
    typedef std::set<Delegate *> DelegateSet;
    
    DelegateSet     delegates;
};

#endif // _TRICKPLAY_CONTROLLER_LIST_H
