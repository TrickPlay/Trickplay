
#include <cstdlib>

#include <glib/gstdio.h>

#include "unzip.h"

#include "installer.h"
#include "context.h"
#include "app.h"
#include "sysdb.h"
#include "signature.h"


//=============================================================================

bool recursive_delete_path( GFile * file )
{
    bool result = false;

    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS, NULL, NULL );

    if ( info )
    {
        if ( g_file_info_get_file_type( info ) == G_FILE_TYPE_DIRECTORY )
        {
            GFileEnumerator * enumerator = g_file_enumerate_children( file, "standard::*", G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS, NULL, NULL );

            if ( enumerator )
            {
                while ( true )
                {
                    GError * error = NULL;

                    GFileInfo * child_info = g_file_enumerator_next_file( enumerator, NULL, &error );

                    if ( ! child_info )
                    {
                        g_clear_error( &error );

                        break;
                    }

                    GFile * child = g_file_resolve_relative_path( file, g_file_info_get_name( child_info ) );

                    bool child_deleted = recursive_delete_path( child );

                    g_object_unref( G_OBJECT( child_info ) );

                    g_object_unref( G_OBJECT( child ) );

                    if ( ! child_deleted )
                    {
                        break;
                    }
                }

                g_object_unref( G_OBJECT( enumerator ) );
            }
        }

        g_object_unref( G_OBJECT( info ) );

        gchar * s = g_file_get_path( file );
        g_debug( "DELETING '%s'", s );
        g_free( s );

        // Will delete the file or directory

        result = g_file_delete( file, NULL, NULL );
    }

    return result;
}



bool recursive_delete_path( const gchar * path )
{
    GFile * file = g_file_new_for_path( path );

    bool result = recursive_delete_path( file );

    g_object_unref( G_OBJECT( file ) );

    return result;
}

//=============================================================================

class InstallAppTask : public ThreadPool::Task
{
public:

    InstallAppTask( Installer * _installer, Installer::Info * _info )
    :
        installer( _installer ),
        info( * _info )
    {}

    //.........................................................................
    // Adds an idle for the given progress

    class ProgressTask : public ThreadPool::Task
    {
    public:

        ProgressTask( Installer * _installer, const Installer::Info & _info )
        :
            installer( _installer ),
            info( _info )
        {}

        void process_main_thread()
        {
            installer->install_progress( info );
        }

    private:

        Installer *     installer;
        Installer::Info info;
    };

    void send_progress()
    {
        installer->thread_pool.push( new ProgressTask( installer, info ) );
    }

    //.........................................................................

    bool verify_and_strip_signatures()
    {
        g_debug( "CHECKING SIGNATURE(S)" );

        Signature::Info::List signatures;

        gsize signature_length = 0;

        // This means that the signatures are invalid or we had a problem
        // dealing with them. If there are no signatures, this will return
        // true and give us an empty list.

        if ( ! Signature::get_signatures( info.source_file.c_str(), signatures, &signature_length ) )
        {
            return false;
        }

        unsigned int found = 0;

        if ( signatures.empty() )
        {
            g_debug( "  NOT SIGNED" );
        }
        else
        {
            for ( Signature::Info::List::const_iterator it = signatures.begin(); it != signatures.end(); ++it )
            {
                info.fingerprints.insert( it->fingerprint );
            }

            // Now, see how many of the required ones are found in the signatures

            for ( StringSet::const_iterator it = info.required_fingerprints.begin(); it != info.required_fingerprints.end(); ++it )
            {
                found += info.fingerprints.count( *it );
            }
        }

        if ( found != info.required_fingerprints.size() )
        {
            // Signature(s) missing

            g_warning( "APP IS MISSING AT LEAST ONE REQUIRED SIGNATURE" );

            return false;
        }

        // If there were no signatures, we are done

        if ( signatures.empty() )
        {
            return true;
        }

        // Otherwise, we need to strip the signature block from the file

        bool result = false;

        GFile * file = g_file_new_for_path( info.source_file.c_str() );

        if ( file )
        {

            GFileIOStream * stream = g_file_open_readwrite( file, NULL, NULL );

            if ( stream )
            {
                GSeekable * seekable = G_SEEKABLE( stream );

                if ( g_seekable_can_seek( seekable ) && g_seekable_can_truncate( seekable ) )
                {
                    if ( g_seekable_seek( seekable, 0, G_SEEK_END, NULL, NULL ) )
                    {
                        goffset file_size = g_seekable_tell( seekable );

                        file_size -= signature_length;

                        if ( g_seekable_truncate( seekable, file_size, NULL, NULL ) )
                        {
                            g_debug( "TRUNCATING FILE TO %" G_GOFFSET_FORMAT " BYTES", file_size );
                            result = true;
                        }
                    }
                }

                g_io_stream_close( G_IO_STREAM( stream ), NULL, NULL );

                g_object_unref( G_OBJECT( stream ) );
            }

            g_object_unref( G_OBJECT( file ) );
        }

        if ( ! result )
        {
            g_warning( "FAILED TO STRIP SIGNATURE(S)" );
        }

        return result;
    }


    //.........................................................................

    virtual void process()
    {
        // This happens in the installer thread, so we cannot mess with
        // anything else.

        HZIP zip = NULL;

        try
        {
            g_debug( "STARTING INSTALL OF %s", info.source_file.c_str() );

            //.................................................................

            if ( ! verify_and_strip_signatures() )
            {
                throw String( "SIGNATURE CHECK FAILED" );
            }

            //.................................................................
            // Open the source file to make sure it is ok

            zip = OpenZip( info.source_file.c_str(), NULL );

            if ( ! zip )
            {
                throw String( "FAILED TO OPEN ZIP FILE" );
            }

            ZIPENTRY entry;

            //.................................................................
            // Figure out how many items are in the zip file

            if ( ZR_OK != GetZipItem( zip, -1, &entry ) )
            {
                throw String( "FAILED TO GET ZIP ENTRY COUNT" );
            }

            int entry_count = entry.index;

            if ( entry_count <= 0 )
            {
                throw String( "ZIP FILE HAS TOO FEW ENTRIES" );
            }

            //.................................................................
            // Now go through all the items in the zip file, figure out
            // their total uncompressed size and find the 'app' file.

            guint64 total_uncompressed_size = 0;

            String app_file_zip_path;

            int app_file_zip_index = -1;

            guint64 app_file_uncompressed_size = 0;

            for ( int i = 0; i < entry_count; ++i )
            {
                if ( ZR_OK != GetZipItem( zip, i, &entry ) )
                {
                    throw String( "FAILED TO GET ZIP ENTRY" );
                }

                total_uncompressed_size += entry.unc_size;

                // See if this is the app file

                if ( app_file_zip_path.empty() )
                {
                    // THIS IS PLATFORM SPECIFIC

                    if ( ! ( entry.attr & S_IFDIR ) )
                    {
                        gchar * basename = g_path_get_basename( entry.name );

                        if ( ! strcmp( basename , "app" ) )
                        {
                            app_file_zip_path = entry.name;

                            app_file_zip_index = i;

                            app_file_uncompressed_size = entry.unc_size;
                        }

                        g_free( basename );
                    }
                }
            }

            if ( app_file_zip_path.empty() )
            {
                throw String( "ZIP FILE IS MISSING APP FILE" );
            }

            if ( app_file_uncompressed_size == 0 )
            {
                throw String( "APP FILE UNCOMPRESSED SIZE IS INCORRECT" );
            }

            g_debug( "FOUND APP FILE IN ZIP AT %s", app_file_zip_path.c_str() );

            //.................................................................
            // Uncompress the app file to memory and load its metadata.
            // We must ensure it is valid and its app_id is the same as the
            // one passed in.

            // g_new0 serves to NULL-terminate the contents, which
            // load_metadata_from_data expects.

            gchar * app_file_buffer = g_new0( gchar, app_file_uncompressed_size * 2 );

            if ( ! app_file_buffer )
            {
                throw String( "FAILED TO ALLOCATE MEMORY TO UNCOMPRESS APP FILE" );
            }

            FreeLater free_later;

            free_later( app_file_buffer );

            if ( ZR_OK != UnzipItem( zip, app_file_zip_index, app_file_buffer, app_file_uncompressed_size * 2 ) )
            {
                throw String( "FAILED TO UNCOMPRESS APP FILE" );
            }

            App::Metadata metadata;

            if ( ! App::load_metadata_from_data( app_file_buffer, metadata ) )
            {
                throw String( "FAILED TO READ METADATA" );
            }

            if ( metadata.id != info.app_id )
            {
                throw String( "APP ID DOES NOT MATCH" );
            }

            //.................................................................
            // Figure out where to unzip it to
            // - should be in the same volume as the app's data directory
            //
            // The app may already live in  trickplay/apps/<id hash>/source
            //
            // We could unzip it to         trickplay/apps/installing/<id hash>
            //      The benefit of this is that it would be easy to clean up unfinished
            //      installations by deleting everything in "installing".
            //
            // We could unzip it to         trickplay/apps/<id hash>/installing
            //      This puts it event closer to its final destination, but we would
            //      have to do more work to clean up. CHOOSING THIS ONE FOR NOW

            gchar * unzip_path = g_build_filename( info.app_directory.c_str(), "installing", NULL );

            free_later( unzip_path );

            //.................................................................
            // If our destination directory already exists, it is probably
            // from a failed attempt to install this app. We need to get rid of it.

            if ( g_file_test( unzip_path, G_FILE_TEST_EXISTS ) )
            {
                g_debug( "DELETING OLD INSTALL DIRECTORY %s", unzip_path );

                if ( ! recursive_delete_path( unzip_path ) )
                {
                    throw String( "FAILED TO DELETE OLD INSTALL DIRECTORY" );
                }
            }

            if ( 0 != g_mkdir_with_parents( unzip_path, 0700 ) )
            {
                throw String( "FAILED TO CREATE INSTALL DIRECTORY" );
            }

            //.................................................................
            // TODO: We should now check for free space - and make sure we have at
            // least total_uncompressed_size available.


            //.................................................................
            // OK, everything seems to be in order.
            // We get the dirname of the path to the app file in the zip.
            // So, for example, inside the zip, the app file might be in
            // "foor/bar/app". We have to take all the files in the zip that
            // are in "foo/bar" and unzip them to our real destination.

            gchar * app_file_zip_dirname = g_path_get_dirname( app_file_zip_path.c_str() );
            g_assert(app_file_zip_dirname);

            free_later( app_file_zip_dirname );

            guint app_file_zip_dirname_length = strlen( app_file_zip_dirname );

            // If there is no dirname, the above gets set to "."

            bool no_zip_root = ! strcmp( app_file_zip_dirname, "." );

            // Now, it is time to unzip

            g_debug( "UNZIPPING TO %s", unzip_path );

            guint64 total_processed = 0;

            Util::GTimer progress_timer;

#ifndef TP_PRODUCTION

            static float slow = -1;

            if ( slow == -1 )
            {
                if ( const char * e = g_getenv( "TP_INSTALL_DELAY" ) )
                {
                    slow = atof( e );
                }
                else
                {
                    slow = 0;
                }
            }

#endif

            for ( int i = 0; i < entry_count; ++i )
            {

#ifndef TP_PRODUCTION

                if ( slow )
                {
                    usleep( slow * G_USEC_PER_SEC );
                }

#endif

                if ( ZR_OK != GetZipItem( zip, i, &entry ) )
                {
                    throw String( "FAILED TO GET ZIP ENTRY" );
                }

                gchar * destination_file_name = NULL;

                if ( no_zip_root )
                {
                    destination_file_name = g_build_filename( unzip_path, entry.name, NULL );
                }
                else if ( g_str_has_prefix( entry.name, app_file_zip_dirname ) )
                {
                    destination_file_name = g_build_filename( unzip_path, entry.name + app_file_zip_dirname_length, NULL );
                }

                if ( ! destination_file_name )
                {
                    g_debug( "  SKIPPING %s", entry.name );
                }
                else
                {
                    free_later( destination_file_name );

                    g_debug( "  UNZIPPING %s", entry.name );

                    if ( ZR_OK != UnzipItem( zip, i, destination_file_name ) )
                    {
                        throw String( "FAILED TO UNZIP" );
                    }
                }

                // Report progress

                total_processed += entry.unc_size;

                if ( progress_timer.elapsed() >= 1 )
                {
                    progress_timer.reset();

                    info.status = Installer::Info::INSTALLING;
                    info.percent_installed = gdouble( total_processed ) / gdouble( total_uncompressed_size ) * 100.0;

                    send_progress();
                }
            }

            //.................................................................
            // At this point, the app should be uncompressed to the "installing"
            // directory and ready to go.

            //.................................................................
            // Finally, under the right conditions, we delete the existing install
            // of the app and move the "installing" directory over it.

            info.moved = false;

            gchar * source_path = g_build_filename( info.app_directory.c_str(), "source", NULL );

            free_later( source_path );

            bool source_exists = g_file_test( source_path, G_FILE_TEST_EXISTS );

            // If the source directory exists and the app is locked, we can
            // delete the source directory

            if ( source_exists && info.locked )
            {
                if ( ! recursive_delete_path( source_path ) )
                {
                    throw String( "FAILED TO DELETE PREVIOUS APP SOURCE" );
                }

                source_exists = false;
            }

            // If the source directory does not already exist, or we deleted in the
            // previous step, we can rename the install directory.

            if ( ! source_exists )
            {
                if ( 0 != g_rename( unzip_path, source_path ) )
                {
                    throw String( "FAILED TO RENAME INSTALL DIRECTORY TO SOURCE DIRECTORY" );
                }

                info.moved = true;
            }

            // Once this is done, the caller needs to call 'complete_install'. This will
            // move the app to its final resting place (if necessary) and also add its
            // entry to the system database.

            g_debug( "FINISHED INSTALL OF %s TO %s", info.app_id.c_str(), info.moved ? source_path : unzip_path );

            info.status = Installer::Info::FINISHED;

            info.install_directory = unzip_path;

            info.app_directory = source_path;

            send_progress();

            // Caller is also reponsible for getting rid of the original zip file.
        }
        catch( const String & e )
        {
            g_warning( "FAILED TO INSTALL %s FROM %s : %s", info.app_id.c_str(), info.source_file.c_str(), e.c_str() );

            info.status = Installer::Info::FAILED;

            send_progress( );
        }

        // Close the zip file

        if ( zip )
        {
            CloseZip( zip );
        }

        // Always return true - to keep the thread running
    }

private:

    Installer *         installer;
    Installer::Info     info;
};

//=============================================================================

Installer::Installer( TPContext * _context )
:
    context( _context ),
    next_id( 1 ),
    thread_pool( 2 )
{
    g_assert( context );

    context->get_downloads()->add_delegate( this );
}

//-----------------------------------------------------------------------------

Installer::~Installer()
{
    context->get_downloads()->remove_delegate( this );
}

//-----------------------------------------------------------------------------

guint Installer::download_and_install_app(
        const String & owner,
        const String & app_id,
        const String & app_name,
        bool locked,
        const Network::Request & request,
        Network::CookieJar * cookie_jar,
        const StringSet & required_fingerprints,
        const StringMap & extra )
{
    guint download_id = context->get_downloads()->start_download( owner, request, cookie_jar );

    if ( download_id == 0 )
    {
        return 0;
    }

    guint result = next_id++;

    info_map[ result ] = Info( result, app_id, app_name, owner, locked, download_id, required_fingerprints, extra );

    return result;
}


//-----------------------------------------------------------------------------

void Installer::add_delegate( Delegate * delegate )
{
    delegates.insert( delegate );
}

//-----------------------------------------------------------------------------

void Installer::remove_delegate( Delegate * delegate )
{
    delegates.erase( delegate );
}

//-----------------------------------------------------------------------------

Installer::Info * Installer::get_info_for_download( guint download_id )
{
    for( InfoMap::iterator it = info_map.begin(); it != info_map.end(); ++it )
    {
        if ( it->second.download_id == download_id )
        {
            return & it->second;
        }
    }
    return NULL;
}

//-----------------------------------------------------------------------------

bool Installer::complete_install( guint id )
{
    InfoMap::iterator it = info_map.find( id );

    if ( it == info_map.end() )
    {
        return false;
    }

    const Info & info( it->second );

    if ( info.status != Info::FINISHED )
    {
        return false;
    }

    if ( ! info.moved )
    {
        // The app was succesfully installed to the "installing" directory
        // but it was not moved over to the "source" directory. We try to
        // do that now.

        if ( ! recursive_delete_path( info.app_directory.c_str() ) )
        {
            // This is VERY bad. The original app may have been partially deleted.
            // It may not even run any more.

            // TODO: better solution

            g_warning( "FAILED TO DELETE APP SOURCE DIRECTORY %s", info.app_directory.c_str() );

            return false;
        }

        if ( 0 != g_rename( info.install_directory.c_str(), info.app_directory.c_str() ) )
        {
            // This is bad too - because the original app was deleted, but is still in
            // the database. It will simply fail to load, which may be better than
            // the case above.

            g_warning( "FAILED TO RENAME APP INSTALL DIRECTORY TO SOURCE DIRECTORY" );

            return false;
        }
    }

    // The move is fine, we just need to insert it into the system database

    App::Metadata metadata;

    if ( ! App::load_metadata( info.app_directory.c_str(), metadata ) )
    {
        // This app will never launch

        g_warning( "FAILED TO LOAD APP METADATA" );

        return false;
    }

    if ( ! context->get_db()->insert_app( metadata , info.fingerprints ) )
    {
        g_warning( "FAILED TO UPDATE SYSTEM DATABASE FOR %s", metadata.id.c_str() );

        return false;
    }

    context->get_db()->add_app_to_current_profile( metadata.id );

    info_map.erase( it );

    return true;
}

//-----------------------------------------------------------------------------

void Installer::abandon_install( guint id )
{
    InfoMap::iterator it = info_map.find( id );

    if ( it == info_map.end() )
    {
        return;
    }

    const Info & info( it->second );

    if ( info.status == Info::FINISHED )
    {
        // Now delete the installation directory

        recursive_delete_path( info.install_directory.c_str() );

        info_map.erase( it );
    }
}

//-----------------------------------------------------------------------------

Installer::Info * Installer::get_install( guint id )
{
    InfoMap::iterator it = info_map.find( id );

    if ( it == info_map.end() )
    {
        return NULL;
    }

    return & it->second;
}

//-----------------------------------------------------------------------------

Installer::InfoList Installer::get_all_installs() const
{
    InfoList result;

    for ( InfoMap::const_iterator it = info_map.begin(); it != info_map.end(); ++it )
    {
        result.push_back( it->second );
    }

    return result;
}

//-----------------------------------------------------------------------------

void Installer::download_progress( const Downloads::Info & dl_info )
{
    if ( Info * info = get_info_for_download( dl_info.id ) )
    {
        info->percent_downloaded = dl_info.percent_downloaded();

        for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
        {
            ( * dit )->download_progress( * info , dl_info );
        }
    }
}

//-----------------------------------------------------------------------------

void Installer::download_finished( const Downloads::Info & dl_info )
{
    Info * info = get_info_for_download( dl_info.id );

    // It is not one of ours

    if ( ! info )
    {
        return;
    }

    info->percent_downloaded = 100;

    // Tell the delegates that the download is done

    for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
    {
        ( * dit )->download_finished( * info , dl_info );
    }

    // TODO: Should we also check the HTTP code?

    bool failed = dl_info.status == Downloads::Info::FAILED;

    if ( ! failed )
    {
        // Get the required info

        String app_directory( App::get_data_directory( context, info->app_id ) );

        if ( app_directory.empty() )
        {
            failed = true;
        }
        else
        {
            info->app_directory = app_directory;

            info->source_file = dl_info.file_name;

            info->status = Info::INSTALLING;

            thread_pool.push( new InstallAppTask( this, info ) );

            for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
            {
                ( * dit )->install_progress( *info );
            }
        }
    }

    // Failure case

    if ( failed )
    {
        // Update the status

        info->status = Info::FAILED;

        // Tell the delegates that the installation is finished/failed

        for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
        {
            ( * dit )->install_finished( * info );
        }

        // Get rid of the download and the file.

        context->get_downloads()->remove_download( dl_info.id , true );

        // Now, remove the entry from our map

        info_map.erase( info->id );
    }
}

//-----------------------------------------------------------------------------

void Installer::install_progress( const Installer::Info & progress )
{
    InfoMap::iterator it = info_map.find( progress.id );

    if ( it == info_map.end() )
    {
        g_debug( "THIS SHOULD NEVER HAPPEN - I GOT PROGRESS FOR UNKNOWN INSTALL %u", progress.id );

        return;
    }

    Info & info( it->second );

    if ( progress.status == Info::INSTALLING )
    {
        g_debug( "INSTALL PROGRESS FOR %u IS %1.2f %%", progress.id, progress.percent_installed );

        info.percent_installed = progress.percent_installed;

        for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
        {
            ( * dit )->install_progress( info );
        }
    }
    else
    {
        bool failed = ( progress.status == Info::FAILED );

        if ( failed )
        {
            g_debug( "INSTALL %u FAILED", progress.id );

            info.status = Info::FAILED;
        }
        else
        {
            g_debug( "INSTALL %u FINISHED", progress.id );

            info.status = Info::FINISHED;
            info.moved = progress.moved;
            info.app_directory = progress.app_directory;
            info.install_directory = progress.install_directory;
            info.fingerprints = progress.fingerprints;
        }

        // Get rid of the download and the file.

        context->get_downloads()->remove_download( info.download_id , true );

        info.download_id = 0;

        // Tell the delegates

        for( DelegateSet::iterator dit = delegates.begin(); dit != delegates.end(); ++dit )
        {
            ( * dit )->install_finished( info );
        }

        if ( failed )
        {
            // Now, remove the entry from our map

            info_map.erase( info.id );
        }
    }
}

//-----------------------------------------------------------------------------
