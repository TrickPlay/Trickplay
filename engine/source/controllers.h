#ifndef _TRICKPLAY_CONTROLLERS_H
#define _TRICKPLAY_CONTROLLERS_H


#include "common.h"
#include "mdns.h"
#include "server.h"
#include "context.h"

class Controllers : private Server::Delegate
{
public:
    
    //..........................................................................
    // Pass 0 for the port to have one automatically chosen
    
    Controllers(TPContext * context,const String & name,int port);
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

    bool ui_declare_resource(gpointer source,const String &label, const String &url);
    bool ui_background_image(gpointer source,const String &resource_label);
    bool ui_play_sound(gpointer source,const String &resource_label, unsigned int loop=1);
    bool ui_stop_sound(gpointer source);

    //..........................................................................
    
    String serve_path(const String & group,const String & path);
    
    void drop_web_server_group(const String & group);
    
    //..........................................................................
    // Find info for a controller
    
    ControllerInfo * find_controller(gpointer source);
        
private:

    Controllers(const Controllers &) {}
    
    //..........................................................................
    
    struct HTTPInfo
    {
        HTTPInfo() : headers_done(false) {}
        
        String      method;
        String      url;
        String      version;
        StringList  headers;
        bool        headers_done;
    };
    
    //..........................................................................
    // Data for each connection
    
    struct ConnectionInfo
    {
        ConnectionInfo() : is_http(false) {}

        ControllerInfo  controller;

        bool            is_http;        
        HTTPInfo        http_info;
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
    
    void handle_http_get(gpointer connection,const gchar * line);
    void handle_http_line(gpointer connection,ConnectionInfo & info,const gchar * line);
    
    // The key is a hash we generate, the first string is the real path
    // and the second string is the group.
    
    typedef std::map<String,StringPair> WebServerPathMap;
    
    WebServerPathMap    path_map;
    
    //..........................................................................
    // The map of connections
    
    typedef std::map<gpointer,ConnectionInfo> ConnectionMap;
    
    ConnectionMap       connections;    

    //..........................................................................
    
    TPContext * context;
};


#endif // _TRICKPLAY_CONTROLLERS_H
