
#include <cstring>

//------------------------------------------------------------------------------
#include "server.h"
//------------------------------------------------------------------------------
static gsize SERVER_BUFFER_SIZE = 128;
//------------------------------------------------------------------------------

Server::Server( guint16 p, Delegate * del, char acc, GError ** error )
    :
    port( 0 ),
    listener( NULL ),
    delegate( del ),
    accumulate( acc )
{
    GInetAddress * ia = g_inet_address_new_any( G_SOCKET_FAMILY_IPV4 );

    GSocketAddress * address = g_inet_socket_address_new( ia, p );

    g_object_unref( G_OBJECT( ia ) );

    GSocketAddress * ea = NULL;

    listener = g_socket_listener_new();

    GError * sub_error = NULL;

    g_socket_listener_add_address( listener, address, G_SOCKET_TYPE_STREAM, G_SOCKET_PROTOCOL_TCP, NULL, &ea, &sub_error );

    g_object_unref( G_OBJECT( address ) );

    if ( sub_error )
    {
        g_socket_listener_close( listener );
        g_object_unref( G_OBJECT( listener ) );
        listener = NULL;

        g_propagate_error( error, sub_error );
    }
    else
    {
        port = g_inet_socket_address_get_port( G_INET_SOCKET_ADDRESS( ea ) );

        g_socket_listener_accept_async( listener, NULL, accept_callback, this );
    }

    if ( ea )
    {
        g_object_unref( G_OBJECT( ea ) );
    }
}

//------------------------------------------------------------------------------

Server::~Server()
{
    if ( listener )
    {
        g_socket_listener_close( listener );
        g_object_unref( G_OBJECT( listener ) );
    }

    for ( ConnectionSet::iterator it = connections.begin(); it != connections.end(); ++it )
    {
        g_io_stream_close( G_IO_STREAM( *it ), NULL, NULL );
    }
}

//------------------------------------------------------------------------------

void Server::close_connection( gpointer connection )
{
    g_io_stream_close( G_IO_STREAM( connection ), NULL, NULL );
}

//------------------------------------------------------------------------------

bool Server::write( gpointer connection, const char * data , gssize size )
{
    GOutputStream * output_stream = g_io_stream_get_output_stream( G_IO_STREAM( connection ) );

    // Try to write - if we fail, we close the stream, this should also cause
    // our read operation to fail, which will unref the stream.

    GError * error = NULL;

    g_output_stream_write_all( output_stream, data, size < 0 ? strlen( data ) : size , NULL, NULL, &error );

    if ( error )
    {
        connections.erase( G_SOCKET_CONNECTION( connection ) );
        g_debug( "CONNECTION WRITE ERROR %p : %s", connection, error->message );

        g_clear_error( &error );
        g_io_stream_close( G_IO_STREAM( connection ), NULL, NULL );
        return false;
    }
    else
    {
        return true;
    }
}

//------------------------------------------------------------------------------

bool Server::write_printf( gpointer connection, const char * format, ... )
{
    va_list args;
    va_start( args, format );
    gchar * line = g_strdup_vprintf( format, args );
    va_end( args );
    bool result = write( connection, line );
    g_free( line );
    return result;
}

//------------------------------------------------------------------------------

void Server::write_to_all( const char * data )
{
    for ( ConnectionSet::iterator it = connections.begin(); it != connections.end(); ++it )
    {
        write( *it, data );
    }
}

//------------------------------------------------------------------------------

bool Server::write_file( gpointer connection, const char * path, bool http_headers )
{
    // Get the output stream for the connection

    GOutputStream * output_stream = g_io_stream_get_output_stream( G_IO_STREAM( connection ) );

    // Get the file

    GFile * file = g_file_new_for_path( path );

    if ( !file )
    {
        return false;
    }

    // Get the input stream

    GFileInputStream * input_stream = g_file_read( file, NULL, NULL );

    if ( !input_stream )
    {
        g_object_unref( file );
        return false;
    }

    // Get the size of the file and write http headers

    if ( http_headers )
    {
        GFileInfo * info = g_file_query_info( file,
                                              G_FILE_ATTRIBUTE_STANDARD_SIZE,
                                              G_FILE_QUERY_INFO_NONE,
                                              NULL,
                                              NULL );

        if ( !info )
        {
            g_object_unref( file );
            return false;
        }

        goffset size = g_file_info_get_size( info );

        g_object_unref( info );

        // TODO: It would be nice to send the Content-Type, but it doesn't look like
        // we will have a mime type mapping on the TV.
        // gio has GContentType, which uses xdgmime, but it relies on a system
        // database of mime types.

        gchar * headers = g_strdup_printf( "HTTP/1.1 200 OK\r\nContent-Length: %"G_GOFFSET_FORMAT"\r\n\r\n", size );

        g_output_stream_write_all( output_stream, headers, strlen( headers ), NULL, NULL, NULL );

        g_free( headers );
    }


    g_output_stream_splice_async(
        output_stream,
        G_INPUT_STREAM( input_stream ),
        G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE,
        TRICKPLAY_PRIORITY,
        NULL,
        splice_callback,
        NULL );

    g_object_unref( input_stream );
    g_object_unref( file );

    return true;
}

//------------------------------------------------------------------------------

guint16 Server::get_port() const
{
    return port;
}

//------------------------------------------------------------------------------

void Server::accept_callback( GObject * source, GAsyncResult * result, gpointer data )
{
    Server * server = ( Server * )data;

    GSocketConnection * connection = g_socket_listener_accept_finish( G_SOCKET_LISTENER( source ), result, NULL, NULL );

    if ( connection )
    {
        // Track it

        server->connections.insert( connection );

        // Get the remote address

        gchar * remote_address = g_inet_address_to_string( g_inet_socket_address_get_address( G_INET_SOCKET_ADDRESS( g_socket_connection_get_remote_address( connection, NULL ) ) ) );

        // Notify the delegate

        if ( server->delegate )
        {
            server->delegate->connection_accepted( connection, remote_address );
        }

        g_free( remote_address );

        // Now, we attach us to the connection

        g_object_set_data( G_OBJECT( connection ), "tp-server", data );

        // Get the input stream for the connection

        GInputStream * input_stream = g_io_stream_get_input_stream( G_IO_STREAM( connection ) );

        // Allocate an input buffer and stick it to the input stream

        gpointer buffer = g_malloc( SERVER_BUFFER_SIZE );

        g_object_set_data_full( G_OBJECT( input_stream ), "tp-buffer", buffer, g_free );

        // If we are set to accumulate, add a GString to the input stream too

        if ( server->accumulate )
        {
            g_object_set_data_full( G_OBJECT( input_stream ), "tp-line", g_string_new( NULL ), destroy_gstring );
        }

        // Start reading from the input stream

        g_input_stream_read_async( input_stream, buffer, SERVER_BUFFER_SIZE - 1, TRICKPLAY_PRIORITY, NULL, data_read_callback, connection );

        // Hook up a weak ref callback so we know when the connection is destroyed

        g_object_weak_ref( G_OBJECT( connection ), connection_destroyed, data );
    }

    g_socket_listener_accept_async( G_SOCKET_LISTENER( source ), NULL, accept_callback, data );
}

//------------------------------------------------------------------------------

void Server::data_read_callback( GObject * source, GAsyncResult * result, gpointer data )
{
    GInputStream * input_stream = G_INPUT_STREAM( source );

    GSocketConnection * connection = G_SOCKET_CONNECTION( data );

    Server * server = ( Server * )g_object_get_data( G_OBJECT( data ), "tp-server" );

    // Finish the async read

    GError * error = NULL;

    gsize bytes_read = g_input_stream_read_finish( input_stream, result, &error );

    if ( error || bytes_read <= 0 )
    {
        server->connections.erase( G_SOCKET_CONNECTION( connection ) );

        g_debug( "CONNECTION READ ERROR %p : %s", connection, error ? error->message : "NO DATA" );
        g_clear_error( &error );

        g_io_stream_close( G_IO_STREAM( connection ), NULL, NULL );
        g_object_unref( G_OBJECT( connection ) );
    }
    else
    {
        // We have some data - get the buffer from the input stream, append a
        // NULL and process it

        gchar * buffer = ( gchar * )g_object_get_data( G_OBJECT( input_stream ), "tp-buffer" );

        buffer[bytes_read>SERVER_BUFFER_SIZE-1?SERVER_BUFFER_SIZE-1:bytes_read] = 0;

        if ( server->accumulate )
        {
            GString * line = ( GString * )g_object_get_data( G_OBJECT( input_stream ), "tp-line" );

            g_string_append( line, buffer );

            gchar * s = line->str;
            gchar * e = NULL;

            while ( ( *s ) && ( e = strchr( s, server->accumulate ) ) )
            {
                *e = 0;
                s = g_strstrip( s );

//                g_debug("GOT DATA %p [%s]",connection,s);

                if ( server->delegate )
                {
                    server->delegate->connection_data_received( connection, s , bytes_read );
                }

                s = e + 1;
            }

            // Erase what we processed from the line buffer

            if ( s != line->str )
            {
                g_string_erase( line, 0, s - line->str );
            }
        }
        else if ( server->delegate )
        {
            server->delegate->connection_data_received( connection, buffer , bytes_read );
        }

        // Read again

        g_input_stream_read_async( input_stream, buffer, SERVER_BUFFER_SIZE - 1, TRICKPLAY_PRIORITY, NULL, data_read_callback, data );
    }
}

//------------------------------------------------------------------------------

void Server::connection_destroyed( gpointer data, GObject * connection )
{
    g_debug( "CONNECTION DESTROYED %p", connection );

    Server * server = ( Server * )data;

    if ( server->delegate )
    {
        server->delegate->connection_closed( connection );
    }
}

//------------------------------------------------------------------------------

void Server::destroy_gstring( gpointer s )
{
    g_string_free( ( GString * )s, TRUE );
}

//------------------------------------------------------------------------------

void Server::splice_callback( GObject * source, GAsyncResult * result, gpointer data )
{
    g_output_stream_splice_finish( G_OUTPUT_STREAM( source ), result, NULL );
}

//------------------------------------------------------------------------------

