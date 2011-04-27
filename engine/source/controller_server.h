#ifndef _TRICKPLAY_CONTROLLER_SERVER_H
#define _TRICKPLAY_CONTROLLER_SERVER_H


#include "trickplay/controller.h"

#include "common.h"
#include "server.h"
#include "context.h"
#include "http_server.h"

class ControllerServer : private Server::Delegate , public HttpServer::RequestHandler
{
public:

    //..........................................................................
    // Pass 0 for the port to have one automatically chosen

    ControllerServer( TPContext * context, const String & name, int port );
    ~ControllerServer();

    //..........................................................................
    // Returns true if our listener is up and the mDNS service was established

    bool is_ready() const;

    //..........................................................................

    class Discovery
    {
    public:

        virtual ~Discovery()
        {}

        virtual bool is_ready() const = 0;

    protected:

        Discovery()
        {}

    private:


        Discovery( const Discovery & )
        {}
    };


private:

    static int execute_command( TPController * controller, unsigned int command, void * parameters, void * data );

    int execute_command( TPController * controller, unsigned int command, void * parameters );

    //..........................................................................

    ControllerServer( const ControllerServer & ) {}

     //..........................................................................
    // Data for each connection

    struct ConnectionInfo
    {
        ConnectionInfo()
            :
            disconnect( true ),
            version( 0 ),
            controller( NULL )
        {}

        bool            disconnect;
        String		    address;
        int		        version;
        TPController *	controller;
    };

    //..........................................................................
    // The discovery mechanisms

    std::auto_ptr<Discovery> discovery_mdns;

    std::auto_ptr<Discovery> discovery_upnp;

    //..........................................................................
    // The socket server

    std::auto_ptr<Server> server;

    // Server delegate methods

    virtual void connection_accepted( gpointer connection, const char * remote_address );
    virtual void connection_data_received( gpointer connection, const char * data , gsize size );
    virtual void connection_closed( gpointer connection );

    //..........................................................................
    // Find a connection in our map

    ConnectionInfo * find_connection( gpointer connection );

    //..........................................................................
    // When a controller doesn't identify itself quickly by sending us a valid
    // "DEVICE" line, we disconnect it. This structure holds the information
    // for the timer we use.

    struct TimerClosure
    {
        TimerClosure( gpointer c, ControllerServer * s ) : connection( c ) , self( s ) {}

        gpointer       		connection;
        ControllerServer *	self;
    };

    static gboolean timed_disconnect_callback( gpointer data );

    //..........................................................................
    // Process a command sent in by a controller

    void process_command( gpointer connection, ConnectionInfo & info, gchar ** parts );

    //..........................................................................
    // The HTTP stuff.

    // Resource map

    // The key is the web path, such as /controllers/resource/<something>.

    struct ResourceInfo
    {
        String      file_name;
        String      group;
        gpointer    connection;
    };

    typedef std::map< String , ResourceInfo > ResourceMap;

    ResourceMap resources;

    virtual void handle_http_get( const HttpServer::Request & request , HttpServer::Response & response );

    String start_serving_resource( gpointer connection , const String & file_name , const String & group );

    void drop_resource_group( gpointer connection , const String & group );

    // Post for submitting pictures and audio clips

    struct PostInfo
    {
        enum Type { PICTURES , AUDIO };

        Type        type;
        gpointer    connection;
    };

    typedef std::map< String , PostInfo > PostMap;

    PostMap post_map;

    String start_post_endpoint( gpointer connection , PostInfo::Type type );

    void drop_post_endpoint( gpointer connection );

    virtual void handle_http_post( const HttpServer::Request & request , HttpServer::Response & response );

    //..........................................................................
    // The map of connections

    typedef std::map<gpointer, ConnectionInfo> ConnectionMap;

    ConnectionMap       connections;

    //..........................................................................

    TPContext * context;
};


#endif // _TRICKPLAY_CONTROLLER_SERVER_H
