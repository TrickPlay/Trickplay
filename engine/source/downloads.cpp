
#include "downloads.h"
#include "event_group.h"

//-----------------------------------------------------------------------------

Downloads::Downloads( const String & _path )
:
    path( _path ),
    next_id( 1 )
{
    // The path must already exist

    g_assert( g_file_test( path.c_str(), G_FILE_TEST_IS_DIR ) );

    EventGroup * event_group = new EventGroup();

    network.reset( new Network( event_group ) );

    event_group->unref();

    // TODO: We should delete all existing files since they will be orphaned
}

//-----------------------------------------------------------------------------

unsigned int Downloads::start_download( const String & owner, const Network::Request & request, Network::CookieJar * cookie_jar )
{
    // First, we need a file name for the download

    gchar * dest_filename = g_build_filename( path.c_str(), "download.XXXXXX", NULL );
    Util::GFreeLater free_dest_filename( dest_filename );

    // Create and open the destination file

    gint fd = g_mkstemp( dest_filename );

    if ( fd == -1 )
    {
        g_warning( "FAILED TO CREATE TEMP FILE FOR DOWNLOAD" );

        return 0;
    }

    close( fd );

    // Create the GFile for it

    GFile * file = g_file_new_for_path( dest_filename );

    if ( !file )
    {
        g_warning( "FAILED TO CREATE FILE FOR DOWNLOAD" );

        return 0;
    }

    // Get an output stream for the file

    GError * error = NULL;

    GFileOutputStream * stream = g_file_append_to( file, G_FILE_CREATE_NONE, NULL, &error );

    if ( error )
    {
        g_object_unref( G_OBJECT( file ) );

        g_warning( "FAILED TO OPEN DOWNLOAD FILE FOR APPEND : %s", error->message );

        g_clear_error( &error );

        return 0;
    }

    // This is the id for this download

    unsigned int result = next_id++;

    // Add an Info entry to our map

    info_map[ result ] = Info( result, owner, dest_filename );

    // Create the closure for the request

    Closure * closure = new Closure( this, result, file, stream );

    // Start it!

    g_debug( "STARTING DOWNLOAD %d TO %s", result, dest_filename );

    network->perform_request_async_incremental( request, cookie_jar, incremental_callback, closure, Closure::destroy );

    return result;
}

//-----------------------------------------------------------------------------

bool Downloads::remove_download( unsigned int id, bool delete_file )
{
    InfoMap::iterator it = info_map.find( id );

    if ( it != info_map.end() )
    {
        if ( it->second.status != Info::RUNNING )
        {
            if ( delete_file )
            {
                GFile * file = g_file_new_for_path( it->second.file_name.c_str() );

                g_file_delete( file, NULL, NULL );

                g_object_unref( G_OBJECT( file ) );
            }

            info_map.erase( it );

            return true;
        }
    }

    return false;
}

//-----------------------------------------------------------------------------

bool Downloads::get_download_info( unsigned int id, Info & info )
{
    InfoMap::iterator it = info_map.find( id );

    if ( it != info_map.end() )
    {
        info = it->second;

        return true;
    }

    return false;
}

//-----------------------------------------------------------------------------

bool Downloads::incremental_callback( const Network::Response & response, gpointer body, guint len, bool finished, gpointer user )
{
    Closure * closure = ( Closure * )user;

    g_assert( closure );
    g_assert( closure->file );
    g_assert( closure->stream );

    if ( !finished )
    {
        // This happens in the network thread, all we need to do is write the
        // chunk to the file.

        GOutputStream * stream = G_OUTPUT_STREAM( closure->stream );

        gsize written = 0;

        GError * error = NULL;

        if ( !g_output_stream_write_all( stream, body, len, &written, NULL, &error ) )
        {
            // Write failed, so we abort the download

            g_warning( "FAILED TO WRITE DOWNLOAD CHUNK : %s", error->message );

            g_clear_error( &error );

            return false;
        }

        // Update the content length and bytes written

        if ( closure->content_length == 0 )
        {
            StringMultiMap::const_iterator it = response.headers.find( "Content-Length" );

            if ( it != response.headers.end() )
            {
                closure->content_length = g_ascii_strtoull( it->second.c_str(), NULL, 10 );

                g_debug( "CONTENT LENGTH FOR DOWNLOAD %d IS %" G_GUINT64_FORMAT, closure->id, closure->content_length );
            }
        }

        closure->written += written;

        g_debug( "WROTE %" G_GUINT64_FORMAT "/%" G_GUINT64_FORMAT " BYTES FOR DOWNLOAD %d", closure->written, closure->content_length, closure->id );

    }
    else
    {
        // The download is done. This happens in the main thread, so it is safe to modify
        // the Downloads object.

        // TODO: should we check the status code of the response? If it is a 404, we may
        // have a body and response.failed will be false.

        g_debug( "FINISHED DOWNLOAD %d : %s", closure->id, response.failed ? "FAILED" : "OK" );

        // Clean up the closure. If the request failed, this will delete the underlying file.
        // In either case, it frees the closure's file and stream members.

        closure->close( response.failed );

        // Update our info map

        Info & info = closure->downloads->info_map[ closure->id ];

        info.status = response.failed ? Downloads::Info::FAILED : Downloads::Info::FINISHED;

        info.code = response.code;

        info.message = response.status;

        info.headers = response.headers;

        // The closure will be deleted by its destroy notify
    }

    return true;
}
