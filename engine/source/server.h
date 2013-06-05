#ifndef _TRICKPLAY_SERVER_H
#define _TRICKPLAY_SERVER_H

#include "common.h"
#include "gio/gio.h"

class Server
{
public:

    class Delegate
    {
    public:

        virtual void connection_accepted( gpointer connection, const char* remote_address ) {}
        virtual void connection_data_received( gpointer connection, const char* data , gsize size , bool* read_again ) = 0;
        virtual void connection_closed( gpointer connection ) {}
    };

    Server( guint16 port, Delegate* delegate, char accumulate, GError** error );

    ~Server();

    void close_connection( gpointer connection );
    bool write( gpointer connection, const char* data , gssize size = -1 );
    bool write_printf( gpointer connection, const char* format, ... );
    void write_to_all( const char* data );
    bool write_file( gpointer connection, const char* path, bool http_headers );
    gssize read( gpointer connection , void* buffer , gsize count );

    guint16 get_port() const;

private:

    static void accept_callback( GObject* source, GAsyncResult* result, gpointer data );
    static void data_read_callback( GObject* source, GAsyncResult* result, gpointer data );
    static void splice_callback( GObject* source, GAsyncResult* result, gpointer data );
    static void connection_destroyed( gpointer data, GObject* connection );
    static void destroy_gstring( gpointer s );

    typedef std::set<GSocketConnection*> ConnectionSet;

    guint16             port;
    GSocketListener*    listener;
    Delegate*           delegate;
    char                accumulate;
    ConnectionSet       connections;
};



#endif // _TRICKPLAY_SERVER_H
