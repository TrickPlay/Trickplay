
#include "socket.h"
#include "util.h"

//-----------------------------------------------------------------------------
#define TP_LOG_DOMAIN   "SOCKET"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"
//-----------------------------------------------------------------------------

#define INPUT_BUFFER_SIZE   1024
#define INPUT_BUFFER_KEY    "tp-input-buffer"
#define OUTPUT_BUFFER_KEY   "tp-output-buffer"

//.............................................................................

Socket::Socket()
:
    client( NULL ),
    connection( NULL ),
    input( NULL ),
    output( NULL ),
    writing( false ),
    output_buffer( g_byte_array_new() ),
    delegate( NULL )
{
}

//.............................................................................

Socket::~Socket()
{
    delegate = NULL;

    disconnect();

    g_byte_array_unref( output_buffer );
}

//.............................................................................

void Socket::connect( const gchar * host_and_port, guint16 default_port )
{
    disconnect();

    client = g_socket_client_new();

    g_socket_client_connect_to_host_async( client, host_and_port, default_port, NULL, connect_async, this );
}

//.............................................................................

void Socket::disconnect()
{
    if ( connection )
    {
        g_io_stream_close( G_IO_STREAM( connection ) , NULL, NULL );
        g_object_unref( G_OBJECT( connection ) );
        connection = NULL;
    }

    if ( client )
    {
        g_object_unref( G_OBJECT( client ) );
        client = NULL;
    }

    writing = false;

    g_byte_array_set_size( output_buffer, 0 );

    if ( delegate )
    {
        delegate->on_disconnected();
    }
}

//.............................................................................

bool Socket::is_connected()
{
    return connection && input && output;
}

//.............................................................................

void Socket::write( const guint8 * data, gsize count )
{
    if ( ! is_connected() )
    {
        return;
    }

    g_byte_array_append( output_buffer, data, count );

    start_async_write();
}

//.............................................................................

void Socket::set_delegate( Delegate * _delegate )
{
    delegate = _delegate;
}

//.............................................................................

void Socket::connect_async( GObject * source_object, GAsyncResult * res, gpointer me )
{
    Socket * self = ( Socket * ) me;

    GError * error = NULL;

    self->connection = g_socket_client_connect_to_host_finish( G_SOCKET_CLIENT( source_object ), res, & error );

    if ( error )
    {
        tpwarn( "CONNECT FAILED : %s", error->message );

        g_clear_error( & error );

        if ( self->delegate )
        {
            self->delegate->on_connect_failed();
        }

        self->disconnect();
    }
    else
    {
        self->input = g_io_stream_get_input_stream( G_IO_STREAM( self->connection ) );

        self->output = g_io_stream_get_output_stream( G_IO_STREAM( self->connection ) );

        g_assert( self->input );
        g_assert( self->output );
        g_assert( self->connection );

        guint8 * input_buffer = g_new( guint8, INPUT_BUFFER_SIZE );

        g_object_set_data_full( G_OBJECT( self->input ), INPUT_BUFFER_KEY, input_buffer, g_free );

        if ( self->delegate )
        {
            self->delegate->on_connected();
        }

        self->start_async_read();
    }
}

//.............................................................................

void Socket::start_async_read()
{
    if ( ! is_connected() )
    {
        return;
    }

    guint8 * input_buffer = ( guint8 * ) g_object_get_data( G_OBJECT( input ), INPUT_BUFFER_KEY );

    g_assert( input_buffer );

    g_input_stream_read_async( input, input_buffer, INPUT_BUFFER_SIZE, TRICKPLAY_PRIORITY, NULL, read_async, this );
}

//.............................................................................

void Socket::read_async( GObject * source_object, GAsyncResult * res, gpointer me )
{
    Socket * self = ( Socket * ) me;

    GError * error = NULL;

    gssize bytes_read = g_input_stream_read_finish( self->input, res, & error );

    if ( error || bytes_read <= 0 )
    {
        gint code = error ? error->code : 0;

        if ( code != G_IO_ERROR_CLOSED )
        {
            tpwarn( "READ ERROR : %s", error ? error->message : "SHORT READ" );

            if ( self->delegate )
            {
                self->delegate->on_read_failed();
            }
        }

        g_clear_error( & error );
    }
    else
    {
        if ( self->delegate )
        {
            guint8 * input_buffer = ( guint8 * ) g_object_get_data( G_OBJECT( self->input ), INPUT_BUFFER_KEY );

            self->delegate->on_data_read( input_buffer, bytes_read );
        }

        self->start_async_read();
    }
}

//.............................................................................

void Socket::start_async_write()
{
    if ( ! writing && output_buffer->len > 0 )
    {
        writing = true;

        // We give our current output buffer to the output stream - so it
        // remains unchanged until the write operation completes. We
        // Create a new output buffer to hold anything else that wants to
        // be written in the meantime.

        g_object_set_data_full( G_OBJECT( output ), OUTPUT_BUFFER_KEY, output_buffer, ( GDestroyNotify) g_byte_array_unref );

        g_output_stream_write_async( output, output_buffer->data, output_buffer->len, TRICKPLAY_PRIORITY, NULL, write_async, this );

        output_buffer = g_byte_array_new();
    }
}

//.............................................................................

void Socket::write_async( GObject * source_object, GAsyncResult * res, gpointer me )
{
    Socket * self = ( Socket * ) me;

    GError * error = NULL;

    self->writing = false;

    gssize bytes_written = g_output_stream_write_finish( self->output, res, & error );

    tplog( "WROTE %" G_GSSIZE_FORMAT " BYTES", bytes_written );

    if ( error || bytes_written <= 0 )
    {
        gint code = error ? error->code : 0;

        if ( code != G_IO_ERROR_CLOSED )
        {
            tpwarn( "SOCKET WRITE ERROR : %s", error ? error->message : "SHORT WRITE" );

            if ( self->delegate )
            {
                self->delegate->on_write_failed();
            }
        }

        g_clear_error( & error );

        g_object_set_data( G_OBJECT( self->output ), OUTPUT_BUFFER_KEY, NULL );
    }
    else
    {
        GByteArray * write_buffer = ( GByteArray * ) g_object_get_data( G_OBJECT( self->output ), OUTPUT_BUFFER_KEY );

        tplog( "BYTES LEFT IN BUFFER %" G_GSSIZE_FORMAT , write_buffer->len - bytes_written );

        if ( bytes_written < gssize( write_buffer->len ) )
        {
            // Any bytes that were not written are prepended to the output buffer

            g_byte_array_prepend( self->output_buffer, write_buffer->data + bytes_written, write_buffer->len - bytes_written );
        }

        self->start_async_write();
    }
}

//.............................................................................

