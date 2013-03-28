#ifndef _TRICKPLAY_SOCKET_H
#define _TRICKPLAY_SOCKET_H

#include "common.h"
#include "gio/gio.h"

namespace TrickPlay
{

class Socket
{
public:

    Socket();

    ~Socket();

    void connect( const gchar* host_and_port, guint16 default_port );

    void disconnect();

    bool is_connected();

    void write( const guint8* data, gsize count );

    class Delegate
    {
    public:
        virtual ~Delegate() {}

        virtual void on_connected() = 0;
        virtual void on_connect_failed() = 0;

        virtual void on_disconnected() = 0;

        virtual void on_write_failed() = 0;

        virtual void on_data_read( const guint8* data, gsize count ) = 0;
        virtual void on_read_failed() = 0;
    };

    void set_delegate( Delegate* delegate );

private:

    static void connect_async( GObject* source_object, GAsyncResult* res, gpointer me );

    static void read_async( GObject* source_object, GAsyncResult* res, gpointer me );

    static void write_async( GObject* source_object, GAsyncResult* res, gpointer me );

    void start_async_read();

    void start_async_write();

    GSocketClient*      client;
    GSocketConnection* connection;
    GInputStream*       input;
    GOutputStream*      output;

    bool                writing;
    GByteArray*         output_buffer;

    Delegate*           delegate;
};

} // namespace TrickPlay

#endif // _TRICKPLAY_SOCKET_H
