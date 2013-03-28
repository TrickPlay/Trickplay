#ifndef _TRICKPLAY_DOWNLOADS_H
#define _TRICKPLAY_DOWNLOADS_H

#include "gio/gio.h"

#include "common.h"
#include "network.h"

class Downloads
{
public:

    Downloads( TPContext* context );

    //.........................................................................
    // Starts a download. Returns zero if it failed to start. Otherwise,
    // returns an integer download identifier. The owner could be an app id

    unsigned int start_download( const String& owner, const Network::Request& request, Network::CookieJar* cookie_jar );

    //..........................................................................
    // Remove an entry for a download that is finished or failed.

    bool remove_download( unsigned int id, bool delete_file = false );

    //..........................................................................
    // Struct to hold information about a download

    struct Info
    {
        enum InfoStatus { RUNNING, FAILED, FINISHED };

        Info()
            :
            id( 0 ),
            status( FAILED ),
            content_length( 0 ),
            written( 0 ),
            elapsed_seconds( 0 ),
            seconds_left( -1 ),
            code( 0 )
        {}

        Info( unsigned int _id, const String& _owner, const String& _file_name )
            :
            id( _id ),
            owner( _owner ),
            file_name( _file_name ),
            status( RUNNING ),
            content_length( 0 ),
            written( 0 ),
            elapsed_seconds( 0 ),
            seconds_left( -1 ),
            code( 0 )
        {}

        gdouble percent_downloaded() const
        {
            if ( content_length > 0 )
            {
                return 100.0 * ( gdouble( written ) / gdouble( content_length ) );
            }
            else
            {
                return -1;
            }
        }

        void progress( guint64 _content_length, guint64 _written, gdouble _seconds )
        {
            content_length = _content_length;
            written = _written;
            elapsed_seconds += _seconds;

            if ( status == RUNNING )
            {
                if ( content_length > 0 && written > 0 )
                {
                    seconds_left = ( elapsed_seconds * ( 1 / ( gdouble( written ) / gdouble( content_length ) ) ) ) - elapsed_seconds ;
                }
                else
                {
                    seconds_left = -1;
                }
            }
            else
            {
                seconds_left = 0;
            }
        }

        void finished( const Network::Response& response )
        {
            status = response.failed ? FAILED : FINISHED;

            code = response.code;
            message = response.status;
            headers = response.headers;
            seconds_left = 0;
        }

        unsigned int    id;
        String          owner;
        String          file_name;
        InfoStatus      status;
        guint64         content_length;
        guint64         written;
        gdouble         elapsed_seconds;
        gdouble         seconds_left;

        // These come from the response, once the download is done

        int             code;
        String          message;
        StringMultiMap  headers;
    };

    //..........................................................................
    // Get the information for a download

    bool get_download_info( unsigned int id, Info& info );

    //..........................................................................
    // Delegate class, to get callbacks. Note that all delegates get callbacks
    // for all downloads. Callbacks happen in the main thread and the
    // download_progress callback frequency is throttled.

    class Delegate
    {
    public:

        virtual void download_progress( const Info& info ) = 0;
        virtual void download_finished( const Info& info ) = 0;
    };

    void add_delegate( Delegate* delegate );
    void remove_delegate( Delegate* delegate );

private:

    //..........................................................................
    // Structure that holds information about a download while it is in progress

    struct Closure
    {
        Closure( Downloads* _downloads, unsigned int _id, GFile* _file, GFileOutputStream* _stream )
            :
            downloads( _downloads ),
            id( _id ),
            file( _file ),
            stream( _stream ),
            content_length( 0 ),
            written( 0 ),
            timer( g_timer_new() )
        {}

        ~Closure()
        {
            // When a download finishes with no problems, we close the file
            // and null it out. If it is not null when the closure is destroyed,
            // we assume that the download is being canceled out of our control,
            // so we clean up the file.

            close( true );

            g_timer_destroy( timer );
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
            delete( Closure* )closure;
        }

        Downloads*          downloads;
        unsigned int        id;
        GFile*              file;
        GFileOutputStream* stream;
        guint64             content_length;
        guint64             written;
        GTimer*             timer;
    };

    //..........................................................................
    // Structure to pass progress information from the network thread to the
    // main thread.

    struct Progress
    {
        static Progress* make( Closure* closure )
        {
            Progress* result = g_slice_new( Progress );

            result->downloads = closure->downloads;
            result->id = closure->id;
            result->content_length = closure->content_length;
            result->written = closure->written;
            result->seconds = g_timer_elapsed( closure->timer, NULL );

            return result;
        }

        static void destroy( gpointer progress )
        {
            g_slice_free( Progress, progress );
        }

        Downloads*      downloads;
        unsigned int    id;
        guint64         content_length;
        guint64         written;
        gdouble         seconds;
    };

    static gboolean progress_callback( gpointer progress );

    //..........................................................................
    // Network callback. This gets called in the network thread while the request
    // is not finished. When the request is finished, it gets called in the main
    // thread.

    static bool incremental_callback( const Network::Response& response, gpointer body, guint len, bool finished, gpointer user );

    String                  path;
    std::auto_ptr<Network>  network;
    unsigned int            next_id;

    //..........................................................................
    // Map that holds information about each download, keyed by id

    typedef std::map<unsigned int, Info> InfoMap;

    InfoMap                 info_map;

    //..........................................................................
    // Delegates

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet             delegates;

};



#endif // _TRICKPLAY_DOWNLOADS_H
