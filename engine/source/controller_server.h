#ifndef _TRICKPLAY_CONTROLLER_SERVER_H
#define _TRICKPLAY_CONTROLLER_SERVER_H


#include "trickplay/controller.h"

#include "common.h"
#include "server.h"
#include "context.h"

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

    String serve_path( const String & group, const String & path );

    void drop_web_server_group( const String & group );

    ControllerServer( const ControllerServer & ) {}

    //..........................................................................

    struct HTTPInfo
    {
        HTTPInfo()
            :
            is_http( false ),
            headers_done( false )
        {}

        void reset()
        {
            is_http = false;
            method.clear();
            url.clear();
            version.clear();
            headers.clear();
            headers_done = false;
        }

        bool        is_http;
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
        ConnectionInfo()
            :
            disconnect( true ),
            version( 0 ),
            controller( NULL )
        {}

        bool            disconnect;
        String		address;
        int		version;
        HTTPInfo        http;
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

    void handle_http_get( gpointer connection, const gchar * line );
    void handle_http_line( gpointer connection, ConnectionInfo & info, const gchar * line );

    String handle_http_api( gpointer connection , const String & url );

    // The key is a hash we generate, the first string is the real path
    // and the second string is the group.

    typedef std::map<String, StringPair> WebServerPathMap;

    WebServerPathMap    path_map;

    //..........................................................................
    // The map of connections

    typedef std::map<gpointer, ConnectionInfo> ConnectionMap;

    ConnectionMap       connections;

    //..........................................................................

    TPContext * context;
};


#endif // _TRICKPLAY_CONTROLLER_SERVER_H
