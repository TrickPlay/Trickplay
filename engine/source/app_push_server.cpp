
#include <cstdlib>

#include "app_push_server.h"
#include "context.h"
#include "app.h"
#include "util.h"

//.............................................................................

static Debug_ON log( "APP-PUSH" );

//.............................................................................

AppPushServer * AppPushServer::make( TPContext * context )
{
#ifdef TP_PRODUCTION
    return 0;
#else
    g_assert( context );

    if ( ! context->get_bool( TP_APP_PUSH_ENABLED , TP_APP_PUSH_ENABLED_DEFAULT ) )
    {
        return 0;
    }

    try
    {

        log( "INITIALIZING" );

        return new AppPushServer( context ,
            context->get_int( TP_APP_PUSH_PORT , TP_APP_PUSH_PORT_DEFAULT ) );
    }
    catch ( const String & e )
    {
        g_warning( "FAILED TO START APP PUSH SERVER : %s" , e.c_str() );
        return 0;
    }
#endif
}

//.............................................................................

AppPushServer::~AppPushServer()
{
    if ( listener )
    {
        g_socket_listener_close( listener );
        g_object_unref( G_OBJECT( listener ) );
        listener = 0;
    }
}

//.............................................................................

AppPushServer::AppPushServer( TPContext * _context , guint16 port )
:
    context( _context ),
    listener( 0 )
{
    GInetAddress * ia = g_inet_address_new_any( G_SOCKET_FAMILY_IPV4 );

    GSocketAddress * address = g_inet_socket_address_new( ia, port );

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

        String e( sub_error->message );

        g_clear_error( & sub_error );

        throw e ;
    }

    port = g_inet_socket_address_get_port( G_INET_SOCKET_ADDRESS( ea ) );

    g_socket_listener_accept_async( listener, NULL, accept_callback, this );

    if ( ea )
    {
        g_object_unref( G_OBJECT( ea ) );
    }

    log( "READY ON PORT %u" , port );
}


//.............................................................................

void AppPushServer::accept_callback( GObject * source, GAsyncResult * result, gpointer data )
{
    GSocketConnection * connection = g_socket_listener_accept_finish( G_SOCKET_LISTENER( source ), result, NULL, NULL );

    if ( connection )
    {
        // Get the remote address

        gchar * remote_address = g_inet_address_to_string(
                g_inet_socket_address_get_address(
                        G_INET_SOCKET_ADDRESS(
                                g_socket_connection_get_remote_address(
                                        connection, NULL ) ) ) );

        log( "CONNECTION ACCEPTED FROM %s" , remote_address );

        g_free( remote_address );

        // Get the input stream for the connection
        // Start reading from the input stream

        GDataInputStream * input_stream = g_data_input_stream_new( g_io_stream_get_input_stream( G_IO_STREAM( connection ) ) );

        g_assert( input_stream );

        ConnectionState * state = new ConnectionState;

        state->connection = connection;
        state->state = ConnectionState::APP;
        state->files_remaining = 0;

        g_object_set_data_full( G_OBJECT( input_stream ) , "tp-state" , state , ( GDestroyNotify ) ConnectionState::destroy );

        g_data_input_stream_read_line_async( input_stream , 0 , NULL , line_read , data );

        g_object_unref( input_stream );
    }

    // Accept again

    g_socket_listener_accept_async( G_SOCKET_LISTENER( source ), NULL, accept_callback, data );
}

//.............................................................................

void AppPushServer::line_read( GObject * stream , GAsyncResult * result , gpointer me )
{
    ( ( AppPushServer * ) me )->line_read( stream , result );
}

//.............................................................................

void AppPushServer::line_read( GObject * stream , GAsyncResult * result )
{
    ConnectionState * state = ( ConnectionState * ) g_object_get_data( stream , "tp-state" );

    g_assert( state );

    GError * error = 0;

    char * line = g_data_input_stream_read_line_finish( G_DATA_INPUT_STREAM( stream ) , result , NULL , & error );

    if ( error )
    {
        log( "READ ERROR : %s" , error->message );
        g_clear_error( & error );
        close( state );
        return;
    }

    if ( line )
    {
        //log( "READ LINE [%s]" , g_strstrip( line ) );

        std::vector<String> parts;

        // Split the incoming line by spaces.

        {
            gint tokens = state->state == ConnectionState::APP ? 3 : 2;

            gchar * * p = g_strsplit( g_strstrip( line ) , " " , tokens );

            for ( guint i = 0; i < g_strv_length( p ); ++i )
            {
                parts.push_back( p[ i ] );
            }

            g_strfreev( p );
        }

        g_free( line );

        try
        {
            switch( state->state )
            {
                // We are expecting an APP line, which has the number of files
                // followed by the contents of the app file.

                case ConnectionState::APP:
                {
                    if ( parts.size() != 3 )
                    {
                        throw String( "INVALID 'APP' LINE" );
                    }

                    if ( parts[ 0 ] != "APP" )
                    {
                        throw String( "EXPECTING 'APP' LINE" );
                    }

                    state->app_file = parts[ 2 ];
                    state->file_count = atoi( parts[ 1 ].c_str() );
                    state->files_remaining = state->file_count;
                    state->state = ConnectionState::FILE_LIST;

                    if ( state->file_count <= 0 )
                    {
                        throw String( "INVALID FILE COUNT, OR NO FILES" );
                    }
                }
                break;

                // We are reading the list of files after the APP line.
                // Each line has an MD5 hash followed by the path/file name.

                case ConnectionState::FILE_LIST:
                {
                    if ( parts.size() != 2 )
                    {
                        throw String( "INVALID FILE LINE" );
                    }

                    state->file_hashes.push_back( StringPair( parts[ 0 ] , parts[ 1 ] ) );

                    state->files_remaining -= 1;

                    if ( state->files_remaining == 0 )
                    {
                        // If we have received all the file lines, we figure out
                        // what the response will be. This could be to send all
                        // files, to send some files or that we are up to date
                        // and need no files at all.

                        send_response( state );

                        state->next_file_index = 0;
                        state->files_remaining = state->changed_files.size();
                        state->state = ConnectionState::FILE_SIZE;

                        // The response is that we need no more files. We
                        // launch the app, close the connection and are done.

                        if ( state->files_remaining == 0 )
                        {
                            launch_it( state );
                            close( state );
                            return;
                        }
                    }
                }
                break;

                // We are expecting a line with the size of the next file.

                case ConnectionState::FILE_SIZE:
                {
                    if ( parts.size() != 1 )
                    {
                        throw String( "INVALID FILE SIZE" );
                    }

                    state->next_file_size = atoi( parts[ 0 ].c_str() );

                    if ( state->next_file_size < 0 )
                    {
                        throw String( "FILE SIZE < 0" );
                    }

                    // Once we have the size of the file, we switch away
                    // from line oriented input and instead read the
                    // file contents.

                    state->state = ConnectionState::FILE_CONTENTS;

                    log( "RECEIVING %s" , state->file_hashes[ state->changed_files[ state->next_file_index ] ].second.c_str() );
                }
                break;

                default:
                {
                    throw String( "INVALID LINE" );
                }
                break;

            }
        }
        catch ( const String & e )
        {
            log( "%s" , e.c_str() );
            close( state );
            return;
        }
    }

    if ( state->state == ConnectionState::FILE_CONTENTS )
    {
        // Reading file contents - at most the size of our input buffer

        gsize to_read = std::min( sizeof( state->input_buffer ) , size_t( state->next_file_size ) );

        g_input_stream_read_async( G_INPUT_STREAM( stream ) , state->input_buffer , to_read , G_PRIORITY_DEFAULT , NULL , file_read , this );
    }
    else
    {
        // Read another line.

        g_data_input_stream_read_line_async( G_DATA_INPUT_STREAM( stream ) , 0 , NULL , line_read , this );
    }
}

//.............................................................................

void AppPushServer::close( ConnectionState * state )
{
    g_assert( state );
    GSocketConnection * connection = state->connection;
    g_io_stream_close( G_IO_STREAM( connection ) , NULL , NULL );
    g_object_unref( connection );
}

//.............................................................................
// Compare the file list against what we have on disk and calculate a 'diff' to
// send to the client.

void AppPushServer::send_response( ConnectionState * state )
{
    g_assert( state );
    g_assert( state->state == ConnectionState::FILE_LIST );
    g_assert( state->files_remaining == 0 );

    if ( ! App::load_metadata_from_data( state->app_file.c_str() , state->metadata ) )
    {
        throw String( "INVALID APP METADATA" );
    }

    state->changed_files.clear();
    state->target_file_names.clear();

    FreeLater free_later;

    // Establish the base directory for this app

    gchar * app_path = g_build_filename( context->get( TP_DATA_PATH ) , "pushed" , state->metadata.id.c_str() , NULL );

    state->metadata.path = app_path;

    free_later( app_path );

    if ( g_mkdir_with_parents( app_path , 0700 ) != 0 )
    {
        throw String( "FAILED TO CREATE DESTINATION DIRECTORY" );
    }

    // Now, go through the file list that was sent and compare hashes

    int index = 0;

    for ( StringPairVector::iterator it = state->file_hashes.begin(); it != state->file_hashes.end(); ++it , ++index )
    {
        String source_hash( it->first );
        String source_name( it->second );

        gchar * target_path = Util::rebase_path( app_path , source_name.c_str() );

        g_assert( target_path );

        free_later( target_path );

        // If the target file does not exist, we add it to the list of changed files.

        if ( ! g_file_test( target_path , G_FILE_TEST_EXISTS ) )
        {
            state->changed_files.push_back( index );
            state->target_file_names.push_back( target_path );

            // Create the destination directory for this file

            gchar * d = g_path_get_dirname( target_path );

            if ( strcmp( d , "." ) )
            {
                g_mkdir_with_parents( d , 0700 );
            }

            g_free( d );

            continue;
        }

        // It exists, so we have to get its MD5 hash

        GFile * f = g_file_new_for_path( target_path );

        GFileInputStream * input = g_file_read( f , NULL , NULL );

        if ( ! input )
        {
            g_file_delete( f , NULL , NULL );
            g_object_unref( f );
            state->changed_files.push_back( index );
            state->target_file_names.push_back( target_path );
        }

        static guint BUFFER_SIZE = 1024;

        guchar buffer[ BUFFER_SIZE ];


        String target_hash;
        GChecksum * ck = g_checksum_new( G_CHECKSUM_MD5 );

        while ( true )
        {
            gssize read = g_input_stream_read( G_INPUT_STREAM( input ) , buffer , BUFFER_SIZE , NULL , NULL );

            if ( read == 0 )
            {
                // Done, populate the hash
                target_hash = g_checksum_get_string( ck );
                break;
            }
            else if ( read == -1 )
            {
                // Break with an empty hash signals a problem
                break;
            }
            else
            {
                g_checksum_update( ck , buffer , read );
            }
        }

        g_checksum_free( ck );

        g_object_unref( input );

        if ( target_hash == source_hash )
        {
            // It is the same, no need to ask for it
        }
        else
        {
            // It is different, we delete our copy of it, since we will
            // soon over-write it.

            g_file_delete( f , NULL , NULL );
            state->changed_files.push_back( index );
            state->target_file_names.push_back( target_path );
        }

        g_object_unref( f );
    }

    // Now, state->changed_files contains the indices of all the files we need

    GOutputStream * output = g_io_stream_get_output_stream( G_IO_STREAM( state->connection ) );

    String response;

    if ( state->changed_files.empty() )
    {
        response = "DONE";
    }
    else if ( state->changed_files.size() == state->file_hashes.size() )
    {
        // Shortcut, if we need all files

        response = "SENDALL";
    }
    else
    {
        response = "SEND";

        for ( IntVector::const_iterator it = state->changed_files.begin(); it != state->changed_files.end(); ++it )
        {
            gchar * s = g_strdup_printf( " %d" , *it );
            response += s;
            g_free( s );
        }
    }

    log( "%s" , response.c_str() );

    response += "\n";

    // Write out the response

    gsize written;

    g_output_stream_write_all( output , response.c_str() , response.length() , & written , NULL , NULL );
}

//.............................................................................

void AppPushServer::file_read( GObject * stream , GAsyncResult * result , gpointer me )
{
    ( ( AppPushServer * ) me )->file_read( stream , result );
}

//.............................................................................

void AppPushServer::file_read( GObject * stream , GAsyncResult * result )
{
    // When we are reading file contents, this means we got a piece of a file

    ConnectionState * state = ( ConnectionState * ) g_object_get_data( stream , "tp-state" );

    g_assert( state );

    gssize read = g_input_stream_read_finish( G_INPUT_STREAM( stream ) , result , NULL );

    // An error (-1) or EOF (0) are treated the same way here - both unexpected

    if ( read <= 0 )
    {
        log( "READ ERROR" );
        close( state );
        return;
    }

    // Check that the amount of data we read is no more than we expect

    if ( read > state->next_file_size )
    {
        log( "DATA READ EXCEEDS FILE SIZE" );
        close( state );
        return;
    }

    // Now, we append the data to the file. This will create it if it doesn't
    // exist.

    String target_path = state->target_file_names[ state->next_file_index ];

    GFile * f = g_file_new_for_path( target_path.c_str() );

    GFileOutputStream * output = g_file_append_to( f , G_FILE_CREATE_NONE , NULL , NULL );

    if ( ! output )
    {
        log( "FAILED TO APPEND TO FILE" );
        close( state );
        g_object_unref( f );
        return;
    }

    gsize written;

    g_output_stream_write_all( G_OUTPUT_STREAM( output ) , state->input_buffer , read , & written , NULL , NULL );

    g_object_unref( output );

    g_object_unref( f );

    // Update our state, subtracting the bytes we just read/wrote.

    state->next_file_size -= read;

    if ( state->next_file_size == 0 )
    {
        // Done reading this file, move on to the next one, if any

        state->files_remaining -= 1;

        if ( state->files_remaining == 0 )
        {
            // This was the last file, we launch the app and close the connection

            launch_it( state );
            close( state );
        }
        else
        {
            // Move to the next file.

            state->next_file_index += 1;
            state->state = ConnectionState::FILE_SIZE;

            // Read the next file size

            g_data_input_stream_read_line_async( G_DATA_INPUT_STREAM( stream ) , 0 , NULL , line_read , this );
        }
    }
    else
    {
        // Read more

        gsize to_read = std::min( sizeof( state->input_buffer ) , size_t( state->next_file_size ) );

        g_input_stream_read_async( G_INPUT_STREAM( stream ) , state->input_buffer , to_read , G_PRIORITY_DEFAULT , NULL , file_read , this );
    }
}

//.............................................................................
// When the push is complete, we launch the app.

void AppPushServer::launch_it( ConnectionState * state )
{
    log( "LAUNCHING FROM %s" , state->metadata.path.c_str() );

    context->close_current_app();

    tp_context_set( context , TP_APP_ID , 0 );

    tp_context_set( context , TP_APP_PATH , state->metadata.path.c_str() );

    context->reload_app();
}

//.............................................................................

