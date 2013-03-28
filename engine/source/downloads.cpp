
#include "downloads.h"
#include "context.h"
#include "event_group.h"

//-----------------------------------------------------------------------------

Downloads::Downloads( TPContext* context )
    :
    path( context->get( TP_DOWNLOADS_PATH ) ),
    next_id( 1 )
{
    // The path must already exist

    g_assert( g_file_test( path.c_str(), G_FILE_TEST_IS_DIR ) );

    EventGroup* event_group = new EventGroup();

    network.reset( new Network( context , event_group ) );

    event_group->unref();

    // TODO: We should delete all existing files since they will be orphaned
}

//-----------------------------------------------------------------------------

unsigned int Downloads::start_download( const String& owner, const Network::Request& request, Network::CookieJar* cookie_jar )
{
    // First, we need a file name for the download

    gchar* dest_filename = g_build_filename( path.c_str(), "download.XXXXXX", NULL );

    FreeLater free_later( dest_filename );

    // Create and open the destination file

    gint fd = g_mkstemp( dest_filename );

    if ( fd == -1 )
    {
        g_warning( "FAILED TO CREATE TEMP FILE FOR DOWNLOAD" );

        return 0;
    }

    close( fd );

    // Create the GFile for it

    GFile* file = g_file_new_for_path( dest_filename );

    if ( !file )
    {
        g_warning( "FAILED TO CREATE FILE FOR DOWNLOAD" );

        return 0;
    }

    // Get an output stream for the file

    GError* error = NULL;

    GFileOutputStream* stream = g_file_append_to( file, G_FILE_CREATE_NONE, NULL, &error );

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

    Closure* closure = new Closure( this, result, file, stream );

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
                GFile* file = g_file_new_for_path( it->second.file_name.c_str() );

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

bool Downloads::get_download_info( unsigned int id, Info& info )
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

void Downloads::add_delegate( Delegate* delegate )
{
    delegates.insert( delegate );
}

//-----------------------------------------------------------------------------

void Downloads::remove_delegate( Delegate* delegate )
{
    delegates.erase( delegate );
}

//-----------------------------------------------------------------------------

bool Downloads::incremental_callback( const Network::Response& response, gpointer body, guint len, bool finished, gpointer user )
{
    Closure* closure = ( Closure* )user;

    g_assert( closure );
    g_assert( closure->downloads );
    g_assert( closure->file );
    g_assert( closure->stream );

    if ( !finished )
    {
        // This happens in the network thread, all we need to do is write the
        // chunk to the file.

        // WE CANNOT TOUCH THE DOWNLOADS OBJECT HERE, SINCE IT IS NOT THREAD SAFE

        GOutputStream* stream = G_OUTPUT_STREAM( closure->stream );

        gsize written = 0;

        GError* error = NULL;

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

        // Now, see if we are due for a progress update. We only do this once per second.

        if ( g_timer_elapsed( closure->timer, NULL ) >= 1 )
        {
            // Send a progress report to the main thread

            g_idle_add_full( TRICKPLAY_PRIORITY, progress_callback, Progress::make( closure ), Progress::destroy );

            // Reset the timer

            g_timer_start( closure->timer );
        }
    }
    else
    {
        // The download is done. This happens in the main thread, so it is safe to modify
        // the Downloads object.

        // TODO: should we check the status code of the response? If it is a 404, we may
        // have a body and response.failed will be false.

        g_debug( "FINISHED DOWNLOAD %d : %s", closure->id, response.failed ? "FAILED" : "OK" );


        Downloads* self = closure->downloads;

        // Clean up the closure. If the request failed, this will delete the underlying file.
        // In either case, it frees the closure's file and stream members.

        closure->close( response.failed );

        // Update the Info entry

        Info& info = self->info_map[ closure->id ];

        info.progress( closure->content_length, closure->written, g_timer_elapsed( closure->timer, NULL ) );

        info.finished( response );

        // Tell the delegates

        for ( DelegateSet::iterator it = self->delegates.begin(); it != self->delegates.end(); ++it )
        {
            ( *it )->download_finished( info );
        }

        // The closure will be deleted by its destroy notify
    }

    return true;
}

//-----------------------------------------------------------------------------

gboolean Downloads::progress_callback( gpointer _progress )
{
    Progress* progress = ( Progress* )_progress;

    Downloads* self = progress->downloads;

    InfoMap::iterator it = self->info_map.find( progress->id );

    if ( it != self->info_map.end() )
    {
        Info& info = it->second;

        info.progress( progress->content_length, progress->written, progress->seconds );

        g_debug( "PROGRESS %" G_GUINT64_FORMAT "/%" G_GUINT64_FORMAT " BYTES FOR DOWNLOAD %d : %1.1f %% : %1.0f s : %1.0f s LEFT : %1.0f TOTAL",
                info.written,
                info.content_length,
                info.id,
                info.percent_downloaded(),
                info.elapsed_seconds,
                info.seconds_left,
                info.elapsed_seconds + info.seconds_left );

        // Tell the delegates

        for ( DelegateSet::iterator dit = self->delegates.begin(); dit != self->delegates.end(); ++dit )
        {
            ( *dit )->download_progress( info );
        }
    }

    return FALSE;
}
