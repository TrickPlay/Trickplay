#ifndef _TRICKPLAY_CONTROLLERS_H
#define _TRICKPLAY_CONTROLLERS_H


#include "common.h"
#include "mdns.h"
#include "server.h"

class Controllers : private Server::Delegate
{
public:
    
    //..........................................................................
    // Pass 0 for the port to have one automatically chosen
    
    Controllers(const String & name,int port);
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
   
    void add_delegate(Delegate * delegate);
    void remove_delegate(Delegate * delegate);
    
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
    // The delegates
    
    typedef std::set<Delegate*> DelegateSet;
    
    DelegateSet delegates;
    
    //..........................................................................
    // Writes a line of output to the given controller
    
    bool write_line(gpointer source,const gchar * line);
        
    //..........................................................................    
    // The socket server
    
    std::auto_ptr<Server> server;
    
    // Server delegate methods
    
    virtual void connection_accepted(gpointer connection,const char * remote_address);
    virtual void connection_data_received(gpointer connection,const char * data);
    virtual void connection_closed(gpointer connection);
            
    //..........................................................................
    // Find a connection in our map
    
    ConnectionInfo * find_connection(gpointer connection);

    //..........................................................................
    // When a controller doesn't identify itself quickly by sending us a valid
    // "DEVICE" line, we disconnect it. This structire holds the information
    // for the timer we use.
    
    struct TimerClosure
    {
        TimerClosure(gpointer c,Controllers * s) : connection(c) , self(s) {}
        
        gpointer        connection;
        Controllers *   self;
    };
    
    static gboolean timed_disconnect_callback(gpointer data);
    
    //..........................................................................
    // Process a command sent in by a controller

    void process_command(gpointer connection,ControllerInfo & info,gchar ** parts);
    
    //..........................................................................
    // The map of connections
    
    typedef std::map<gpointer,ConnectionInfo> ConnectionMap;
    
    ConnectionMap       connections;    
};


#endif // _TRICKPLAY_CONTROLLERS_H