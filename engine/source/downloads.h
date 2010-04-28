#ifndef _TRICKPLAY_DOWNLOADS_H
#define _TRICKPLAY_DOWNLOADS_H

#include "gio/gio.h"

#include "common.h"
#include "network.h"

class Downloads
{
public:

    Downloads( const String & path );

    //.........................................................................
    // Starts a download. Returns zero if it failed to start. Otherwise,
    // returns an integer download identifier. The owner could be an app id

    unsigned int start_download( const String & owner, const Network::Request & request, Network::CookieJar * cookie_jar );

    //..........................................................................
    // Remove an entry for a download that is finished or failed.

    bool remove_download( unsigned int id, bool delete_file = false );

    //..........................................................................
    // Struct to hold information about a download

    struct Info
    {
        enum Status { RUNNING, FAILED, FINISHED };

        Info()
        :
            id( 0 ),
            status( FAILED ),
            code( 0 )
        {}

        Info( unsigned int _id, const String & _owner, const String & _file_name )
        :
            id( _id ),
            owner( _owner ),
            file_name( _file_name ),
            status( RUNNING ),
            code( 0 )
        {}

        unsigned int    id;
        String          owner;
        String          file_name;
        Status          status;
        int             code;
        String          message;
        StringMultiMap  headers;
    };

    //..........................................................................
    // Get the information for a download

    bool get_download_info( unsigned int id, Info & info );

private:

    //..........................................................................
    // Structure that holds information about a download while it is in progress

    struct Closure
    {
        Closure( Downloads * _downloads, unsigned int _id, GFile * _file, GFileOutputStream * _stream )
        :
            downloads( _downloads ),
            id( _id ),
            file( _file ),
            stream( _stream ),
            content_length( 0 ),
            written( 0 )
        {}

        ~Closure()
        {
            // When a download finishes with no problems, we close the file
            // and null it out. If it is not null when the closure is destroyed,
            // we assume that the download is being canceled out of our control,
            // so we clean up the file.

            close( true );

            g_debug( "DESTROYED CLOSURE FOR DOWNLOAD %d", id );
        }

        void close( bool delete_file )
        {
            if ( stream )
            {
                g_output_stream_close( G_OUTPUT_STREAM( stream ), NULL, NULL );

                g_object_unref( G_OBJECT( stream ) );

                stream = NULL;
            }

            if ( file )
            {
                if ( delete_file )
                {
                    g_file_delete( file, NULL, NULL );
                }

                g_object_unref( G_OBJECT( file ) );

                file = NULL;
            }
        }

        static void destroy( gpointer closure )
        {
            delete ( Closure * )closure;
        }

        Downloads *         downloads;
        unsigned int        id;
        GFile *             file;
        GFileOutputStream * stream;
        guint64             content_length;
        guint64             written;
    };

    //..........................................................................
    // Network callback. This gets called in the network thread while the request
    // is not finished. When the request is finished, it gets called in the main
    // thread.

    static bool incremental_callback( const Network::Response & response, gpointer body, guint len, bool finished, gpointer user );

    String                  path;
    std::auto_ptr<Network>  network;
    unsigned int            next_id;

    //..........................................................................
    // Map that holds information about each download, keyed by id

    typedef std::map<unsigned int,Info> InfoMap;

    InfoMap                 info_map;
};



#endif // _TRICKPLAY_DOWNLOADS_H
