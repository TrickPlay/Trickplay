
#include "controller_list.h"
#include "clutter_util.h"

//-----------------------------------------------------------------------------
// This is the structure we give the outside world. To them, it is opaque.
// It has a pointer to a Controller instance, the associated ControllerList
// and a marker, which points to itself. The marker lets us do sanity checks
// to ensure the outside doesn't pass garbage.

struct TPController
{
    TPController(Controller * _controller,ControllerList * _list)
    :
        controller(_controller),
        list(_list),
        marker(this)
    {
        check(this);
    }
    
    inline static void check(TPController * controller)
    {
        g_assert(controller);
        g_assert(controller->list);    
        g_assert(controller->controller);
        
        // An assertion here means that either the controller is garbage or
        // it has already been disconnected.
        
        g_assert(controller->marker==controller);        
    }
    
    Controller *        controller;
    ControllerList *    list;
    TPController *      marker;
};

//-----------------------------------------------------------------------------


Controller::Controller(ControllerList * _list,const char * _name,const TPControllerSpec * _spec,void * _data)
:
    tp_controller(new TPController(this,_list)),
    connected(true),
    name(_name),
    spec(*_spec),
    data(_data)
{
    // If the outside world did not provide a function to execute commands,
    // we set our own which always fails.
    
    if (!spec.execute_command)
    {
        spec.execute_command=default_execute_command;
    }
}

//.............................................................................

Controller::~Controller()
{
    delete tp_controller;
}

//.............................................................................

int Controller::default_execute_command(TPController * controller,unsigned int,void *,void *)
{
    // Failure
    return 1;
}

//.............................................................................

TPController * Controller::get_tp_controller()
{
    return tp_controller;
}

//.............................................................................

String Controller::get_name() const
{
    return name;
}

//.............................................................................

unsigned int Controller::get_capabilities() const
{
    return spec.capabilities;
}

//.............................................................................

void Controller::get_input_size(unsigned int & width,unsigned int & height)
{
    width=spec.input_width;
    height=spec.input_height;
}

//.............................................................................

void Controller::get_ui_size(unsigned int & width,unsigned int & height)
{
    width=spec.ui_width;
    height=spec.ui_height;
}

//.............................................................................

bool Controller::is_connected() const
{
    return connected;
}

//.............................................................................

void Controller::disconnected()
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->disconnected();
    }
    
    connected=false;
    
    // We nuke the marker, so that TPController::check will assert if this
    // controller is used again after it has been disconnected.
    
    tp_controller->marker=NULL;
}

//.............................................................................

void Controller::key_down(unsigned int key_code,unsigned long int unicode)
{
    ClutterUtil::inject_key_down(key_code,unicode);
    
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->key_down(key_code,unicode);    
    }
}

//.............................................................................

void Controller::key_up(unsigned int key_code,unsigned long int unicode)
{
    ClutterUtil::inject_key_up(key_code,unicode);

    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->key_up(key_code,unicode);
    }
}

//.............................................................................

void Controller::accelerometer(double x,double y,double z)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->accelerometer(x,y,z);
    }
}

//.............................................................................

void Controller::click(int x,int y)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->click(x,y);
    }
}

//.............................................................................

void Controller::touch_down(int x,int y)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->touch_down(x,y);    
    }
}

//.............................................................................

void Controller::touch_move(int x,int y)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->touch_move(x,y);    
    }
}

//.............................................................................

void Controller::touch_up(int x,int y)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->touch_up(x,y);    
    }
}

//.............................................................................

void Controller::ui_event(const String & parameters)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->ui_event(parameters);    
    }
}

//.............................................................................

void Controller::add_delegate(Delegate * delegate)
{
    delegates.insert(delegate);
}
    
//.............................................................................

void Controller::remove_delegate(Delegate * delegate)
{
    delegates.erase(delegate);
}

//.............................................................................

bool Controller::reset()
{
    return
        (connected)&&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_RESET,
            NULL,
            data)==0);
}

bool Controller::start_accelerometer(AccelerometerFilter filter,double interval)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_ACCELEROMETER))
    {
        return false;
    
    }
    
    TPControllerStartAccelerometer parameters;
    
    switch(filter)
    {
        case LOW:
            parameters.filter=TP_CONTROLLER_ACCELEROMETER_FILTER_LOW;
            break;
        
        case HIGH:
            parameters.filter=TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH;
            break;
        
        default:
            parameters.filter=TP_CONTROLLER_ACCELEROMETER_FILTER_NONE;
            break;
    }
    
    parameters.interval=interval;
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_START_ACCELEROMETER,
        &parameters,
        data)==0;
}

bool Controller::stop_accelerometer()
{  
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_ACCELEROMETER) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER,
            NULL,
            data)==0);
}

bool Controller::start_clicks()
{   
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_CLICKS) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_CLICKS,
            NULL,
            data)==0);
}

bool Controller::stop_clicks()
{   
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_CLICKS) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_STOP_CLICKS,
            NULL,
            data)==0);
}

bool Controller::start_touches()
{
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_TOUCHES) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_TOUCHES,
            NULL,
            data)==0);    
}

bool Controller::stop_touches()
{    
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_TOUCHES) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_STOP_TOUCHES,
            NULL,
            data)==0);    
}

bool Controller::show_multiple_choice(const String & label,const StringPairList & choices)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_MULTIPLE_CHOICE)||choices.empty())
    {
        return false;
    }
    
    GPtrArray * id_array=g_ptr_array_new();
    GPtrArray * choice_array=g_ptr_array_new();
    
    for(StringPairList::const_iterator it=choices.begin();it!=choices.end();++it)
    {
        g_ptr_array_add(id_array,(void*)it->first.c_str());
        g_ptr_array_add(choice_array,(void*)it->second.c_str());
    }
    
    TPControllerMultipleChoice parameters;
    
    parameters.label=label.c_str();
    parameters.count=choices.size();
    parameters.ids=(const char **)id_array->pdata;
    parameters.choices=(const char **)choice_array->pdata;
    
    bool result=spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE,
        &parameters,
        data)==0;
    
    g_ptr_array_free(id_array,FALSE);
    g_ptr_array_free(choice_array,FALSE);
    
    return result;    
}

bool Controller::clear_ui()
{
    return
        (connected)&&
        (spec.capabilities&
            (TP_CONTROLLER_HAS_UI|
             TP_CONTROLLER_HAS_MULTIPLE_CHOICE|
             TP_CONTROLLER_HAS_TEXT_ENTRY)) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_CLEAR_UI,
            NULL,
            data)==0);        
}

bool Controller::set_ui_background(const String & resource,UIBackgroundMode mode)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_UI))
    {
        return false;
    }
    
    TPControllerSetUIBackground parameters;
    
    parameters.resource=resource.c_str();
    
    switch(mode)
    {
        case CENTER:
            parameters.mode=TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER;
            break;
        
        case TILE:
            parameters.mode=TP_CONTROLLER_UI_BACKGROUND_MODE_TILE;
            break;
        
        default:
            parameters.mode=TP_CONTROLLER_UI_BACKGROUND_MODE_STRETCH;
            break;
    }
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND,
        &parameters,
        data)==0;        
}

bool Controller::set_ui_image(const String & resource,int x,int y,int width,int height)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_UI))
    {
        return false;
    }
    
    TPControllerSetUIImage parameters;
    
    parameters.resource=resource.c_str();
    parameters.x=x;
    parameters.y=y;
    parameters.width=width;
    parameters.height=height;
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_SET_UI_IMAGE,
        &parameters,
        data)==0;        
}

bool Controller::play_sound(const String & resource,unsigned int loop)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_SOUND))
    {
        return false;
    }
    
    TPControllerPlaySound parameters;
    
    parameters.resource=resource.c_str();
    parameters.loop=loop;
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_PLAY_SOUND,
        &parameters,
        data)==0;        
}

bool Controller::stop_sound()
{
    return
        (connected)&&
        (spec.capabilities&TP_CONTROLLER_HAS_SOUND) &&
        (spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_STOP_SOUND,
            NULL,
            data)==0);        
}

bool Controller::declare_resource(const String & resource,const String & uri)
{
    if (!connected||!(spec.capabilities&(TP_CONTROLLER_HAS_UI|TP_CONTROLLER_HAS_SOUND)))
    {
        return false;
    }
    
    TPControllerDeclareResource parameters;
    
    parameters.resource=resource.c_str();
    parameters.uri=uri.c_str();
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_DECLARE_RESOURCE,
        &parameters,
        data)==0;        
}

bool Controller::enter_text(const String & label,const String & text)
{
    if (!connected||!(spec.capabilities&TP_CONTROLLER_HAS_TEXT_ENTRY))
    {
        return false;
    }
    
    TPControllerEnterText parameters;
    
    parameters.label=label.c_str();
    parameters.text=text.c_str();
    
    return spec.execute_command(
        tp_controller,
        TP_CONTROLLER_COMMAND_ENTER_TEXT,
        &parameters,
        data)==0;        
}

//==============================================================================
// Event classes

class Event
{
public:

    Event(Controller * _controller)
    {
        _controller->ref();
        controller=_controller;
    }
    
    virtual ~Event()
    {
        controller->unref();    
    }
    
    virtual void process(ControllerList * list)=0;
    
    static void destroy(Event * event)
    {
        delete event;
    }
    
protected:
    
    Controller * controller;
};

//-----------------------------------------------------------------------------

class ControllerAddedRemovedEvent : public Event
{
public:
    
    enum Type {ADDED,REMOVED};
    
    ControllerAddedRemovedEvent(Controller * _controller,Type _type)
    :
        Event(_controller),
        type(_type)
    {}

    virtual void process(ControllerList * list)
    {
        switch(type)
        {
            case ADDED:
                list->controller_added(controller);
                break;
            
            case REMOVED:
                controller->disconnected();
                controller->unref();
                break;
        }
    }
    
    const Type type;
};

//-----------------------------------------------------------------------------

class KeyEvent : public Event
{
public:
    
    enum Type {KEY_DOWN,KEY_UP};

    KeyEvent(Controller * _controller,Type _type,unsigned int _key_code,unsigned long int _unicode)
    :
        Event(_controller),
        type(_type),
        key_code(_key_code),
        unicode(_unicode)
    {}

    virtual void process(ControllerList * list)
    {
        if (controller->is_connected())
        {
            switch(type)
            {
                case KEY_DOWN:
                    controller->key_down(key_code,unicode);
                    break;
            
                case KEY_UP:
                    controller->key_up(key_code,unicode);
                    break;
            }
        }        
    }

    const Type type;    
    const unsigned int key_code;
    const unsigned long int unicode;
};

//-----------------------------------------------------------------------------

class AccelerometerEvent : public Event
{
public:
    
    AccelerometerEvent(Controller * _controller,double _x,double _y,double _z)
    :
        Event(_controller),
        x(_x),
        y(_y),
        z(_z)
    {}
    
    virtual void process(ControllerList * list)
    {
        if (controller->is_connected())
        {
            controller->accelerometer(x,y,z);
        }        
    }
    
    const double x;
    const double y;
    const double z;
};

//-----------------------------------------------------------------------------

class ClickTouchEvent : public Event
{
public:
    
    enum Type {CLICK,TOUCH_DOWN,TOUCH_MOVE,TOUCH_UP};
    
    ClickTouchEvent(Controller * _controller,Type _type,int _x,int _y)
    :
        Event(_controller),
        type(_type),
        x(_x),
        y(_y)
    {}
    
    virtual void process(ControllerList * list)
    {
        if (controller->is_connected())
        {
            switch(type)
            {
                case CLICK:
                    controller->click(x,y);
                    break;
                
                case TOUCH_DOWN:
                    controller->touch_down(x,y);
                    break;

                case TOUCH_MOVE:
                    controller->touch_move(x,y);
                    break;

                case TOUCH_UP:
                    controller->touch_up(x,y);
                    break;
            }
        }        
    }

    const Type type;
    const int x;
    const int y;
};

//-----------------------------------------------------------------------------

class UIEvent : public Event
{
public:
    
    UIEvent(Controller * _controller,const char * _parameters)
    :
        Event(_controller),
        parameters(_parameters)
    {}
    
    virtual void process(ControllerList * list)
    {
        if (controller->is_connected())
        {
            controller->ui_event(parameters);
        }
    }
    
    const String parameters;
};

//==============================================================================

#define LOCK Util::GSRMutexLock _lock(&mutex)

//-----------------------------------------------------------------------------

ControllerList::ControllerList()
:
    queue(g_async_queue_new_full((GDestroyNotify)Event::destroy))
{
    g_static_rec_mutex_init(&mutex);
}

//.............................................................................

ControllerList::~ControllerList()
{
    for(TPControllerSet::iterator it=controllers.begin();it!=controllers.end();++it)
    {
        (*it)->controller->unref();    
    }
    
    g_static_rec_mutex_free(&mutex);
    g_async_queue_unref(queue);
}

//.............................................................................
// Called in any thread. Adds event to queue and adds an idle source to pump
// events.

void ControllerList::post_event(Event * event)
{
    g_assert(event);
    
    g_async_queue_push(queue,event);        
    g_idle_add(process_events,this);    
}

//.............................................................................
// Called in main thread by an idle source.

gboolean ControllerList::process_events(gpointer self)
{
    g_assert(self);
    
    ((ControllerList*)self)->process_events();
    return FALSE;
}
    
//.............................................................................
// Called in main thread, by an idle source.

void ControllerList::process_events()
{
    while(Event * event=(Event*)g_async_queue_try_pop(queue))
    {
        event->process(this);
        delete event;
    }
}

//.............................................................................
// Most likely called in a different thread.
// Adds the controller to our list and posts an event.

TPController * ControllerList::add_controller(const char * name,const TPControllerSpec * spec,void * data)
{
    g_assert(name);
    g_assert(spec);
    
    Controller * controller=new Controller(this,name,spec,data);
    
    TPController * result=controller->get_tp_controller();
    
    LOCK;
    
    controllers.insert(result);
    
    post_event(new ControllerAddedRemovedEvent(controller,ControllerAddedRemovedEvent::ADDED));
    
    return result;
}    
    
//.............................................................................
// Most likely called in a different thread.
// Removes the controller from the list and posts an event.

void ControllerList::remove_controller(TPController * controller)
{
    TPController::check(controller);
    
    LOCK;
    
    if (controllers.erase(controller)==1)
    {
        post_event(new ControllerAddedRemovedEvent(controller->controller,ControllerAddedRemovedEvent::REMOVED));        
    }
}

//.............................................................................
// Called in main thread - to let delegates know that a new controller is here.

void ControllerList::controller_added(Controller * controller)
{
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->connected(controller);    
    }
}

//.............................................................................

void ControllerList::add_delegate(Delegate * delegate)
{
    delegates.insert(delegate);    
}    
    
//.............................................................................

void ControllerList::remove_delegate(Delegate * delegate)
{
    delegates.erase(delegate);
}

//.............................................................................
// Be careful with this one. It returns a copy of the list of connected
// controllers as the list is now.
// A different thread could come in and remove one from our internal list at any
// time. (This won't affect the copy you have)
// On top of that, the returned list does not add a ref to the controllers...
// The expectation is that you will only use the returned list in the main thread
// in which case the controllers won't be unrefed from under you.

ControllerList::ControllerSet ControllerList::get_controllers()
{
    ControllerSet result;
    
    LOCK;
    
    for (TPControllerSet::iterator it=controllers.begin();it!=controllers.end();++it)
    {
        Controller * controller=(*it)->controller;
        
        if (controller->is_connected())
        {
            result.insert(controller);
        }
    }
    
    return result;
}

//==============================================================================
// External-facing functions. They all do a sanity check and then post an event.

void tp_controller_key_down(TPController * controller,unsigned int key_code,unsigned long int unicode)
{
    TPController::check(controller);
    
    controller->list->post_event(new KeyEvent(controller->controller,KeyEvent::KEY_DOWN,key_code,unicode));
}

void tp_controller_key_up(TPController * controller,unsigned int key_code,unsigned long int unicode)
{
    TPController::check(controller);
    
    controller->list->post_event(new KeyEvent(controller->controller,KeyEvent::KEY_UP,key_code,unicode));
}

void tp_controller_accelerometer(TPController * controller,double x,double y,double z)
{
    TPController::check(controller);
    
    controller->list->post_event(new AccelerometerEvent(controller->controller,x,y,z));
}

void tp_controller_click(TPController * controller,int x,int y)
{
    TPController::check(controller);
    
    controller->list->post_event(new ClickTouchEvent(controller->controller,ClickTouchEvent::CLICK,x,y));
}

void tp_controller_touch_down(TPController * controller,int x,int y)
{
    TPController::check(controller);
    
    controller->list->post_event(new ClickTouchEvent(controller->controller,ClickTouchEvent::TOUCH_DOWN,x,y));
}

void tp_controller_touch_move(TPController * controller,int x,int y)
{
    TPController::check(controller);
    
    controller->list->post_event(new ClickTouchEvent(controller->controller,ClickTouchEvent::TOUCH_MOVE,x,y));
}

void tp_controller_touch_up(TPController * controller,int x,int y)
{
    TPController::check(controller);
    
    controller->list->post_event(new ClickTouchEvent(controller->controller,ClickTouchEvent::TOUCH_UP,x,y));
}

void tp_controller_ui_event(TPController * controller,const char * parameters)
{
    TPController::check(controller);
    
    controller->list->post_event(new UIEvent(controller->controller,parameters));    
}

