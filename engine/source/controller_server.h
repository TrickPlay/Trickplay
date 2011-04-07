#ifndef _TRICKPLAY_CONTROLLER_SERVER_H
#define _TRICKPLAY_CONTROLLER_SERVER_H


#include "trickplay/controller.h"

#include "common.h"
#include "server.h"
#include "context.h"
#include "app_resource_request_handler.h"

class ControllerServer : private Server::Delegate
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
    // returns the object which handles all HTTP requests for uri http://<host>:<port>/api/*
    HttpServer::RequestHandler& get_api_request_handler( ) const;

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
        String		address;
        int		version;
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
    // The map of connections

    typedef std::map<gpointer, ConnectionInfo> ConnectionMap;

    ConnectionMap       connections;

    //..........................................................................

    TPContext * context;
    AppResourceRequestHandler * app_resource_request_handler;
};


#endif // _TRICKPLAY_CONTROLLER_SERVER_H
