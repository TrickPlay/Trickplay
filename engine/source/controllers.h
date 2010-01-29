#ifndef _TP_CONTROLLERS_H
#define _TP_CONTROLLERS_H

#include <string>
#include <map>
#include <memory>
#include <set>
#include <list>

#include "glib.h"
#include "gio/gio.h"

#include "mdns.h"

typedef std::string                             String;
typedef std::set<String>                        StringSet;
typedef std::list<std::pair<String,String> >    StringPairList;

class Controllers
{
public:
    
    //..........................................................................
    // Pass 0 for the port to have one automatically chosen
    
    Controllers(int port);
    ~Controllers();
    
    //..........................................................................
    // Returns true if our listener is up and the mDNS service was established
    
    bool is_ready() const;
    
    //..........................................................................
    // Information we get from a controller when it connects
    
    struct ControllerInfo
    {
        ControllerInfo() : version(0) {}
        
        bool has_accelerometer() const;
        
        String      address;
        String      name;
        int         version;
        StringSet   caps;
    };
    
    //..........................................................................
    // Delegate to handle controller events
    
    class Delegate
    {
    public:
        
        virtual void connected(gpointer source,const ControllerInfo & info)=0;
        virtual void disconnected(gpointer source)=0;
        virtual void accelerometer(gpointer source,double x,double y,double z)=0;
        virtual void ui_event(gpointer source,const gchar * event)=0;
    };
   
    void set_delegate(Delegate * delegate);
    
    //..........................................................................
    // Things we can tell a controller to do
    
    bool start_accelerometer(gpointer source,const char * filter,double interval);
    bool stop_accelerometer(gpointer source);
    bool reset(gpointer source);
    bool ui_clear(gpointer source);
    bool ui_show_multiple_choice(gpointer source,const String & label,const StringPairList & choices);
    
    //..........................................................................
    // Find info for a controller
    
    ControllerInfo * find_controller(gpointer source);
        
private:

    Controllers(const Controllers &) {}
    
    //..........................................................................
    // Data for each connection
    
    struct ConnectionInfo
    {
        ControllerInfo  controller;
        String          input_buffer;
    };
    
    //..........................................................................
    // The mDNS instance
    
    std::auto_ptr<MDNS> mdns;

    //..........................................................................
    // The delegate
    
    Delegate * delegate;
    
    //..........................................................................
    // Writes a line of output to the given controller
    
    bool write_line(gpointer source,const gchar * line);
        
#if GLIB_CHECK_VERSION(2,22,0)

    //..........................................................................
    // Find a connection in our map
    
    ConnectionInfo * find_connection(GSocketConnection * connection);

    //..........................................................................
    // When a controller doesn't identify itself quickly by sending us a valid
    // "DEVICE" line, we disconnect it. This structire holds the information
    // for the timer we use.
    
    struct TimerClosure
    {
        TimerClosure(GSocketConnection * c,Controllers * s) : connection(c) , self(s) {}
        
        GSocketConnection * connection;
        Controllers *       self;
    };
    
    static gboolean timed_disconnect_callback(gpointer data);
    
    //..........................................................................
    // gio callbacks for the clients/controllers
    
    static void accept_callback(GObject * source,GAsyncResult * result,gpointer data);
    static void data_read_callback(GObject * source,GAsyncResult * result,gpointer data);
    
    //..........................................................................
    // We ref to the connection so we know when it goes away
    
    static void connection_destroyed(gpointer data,GObject*connection);
    
    //..........................................................................
    // Our internal routines for dealing with the controllers
    
    void connection_accepted(GSocketConnection * connection);
    void connection_closed(GObject * connection);
    void connection_data_received(GSocketConnection * connection,gchar * buffer);
    void process_command(GSocketConnection * connection,ControllerInfo & info,gchar ** parts);
    
    //..........................................................................
    // The map of connections
    
    typedef std::map<GSocketConnection*,ConnectionInfo> ConnectionMap;
    
    ConnectionMap       connections;
    
    //..........................................................................
    // Our listener 
    
    GSocketListener *   listener;
    
#endif    

};


#endif