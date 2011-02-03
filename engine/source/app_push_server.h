#ifndef _TRICKPLAY_APP_PUSH_SERVER_H
#define _TRICKPLAY_APP_PUSH_SERVER_H

#include "gio/gio.h"

#include "common.h"
#include "app.h"

class AppPushServer
{
public:

    static AppPushServer * make( TPContext * context );

    ~AppPushServer();

private:

    typedef std::vector<StringPair> StringPairVector;
    typedef std::vector<int>        IntVector;
    typedef std::vector<String>     StringVector;

    struct ConnectionState
    {
        enum State { APP , FILE_LIST , FILE_SIZE , FILE_CONTENTS };

        GSocketConnection * connection;

        State               state;
        String              app_file;
        App::Metadata       metadata;
        int                 file_count;
        int                 files_remaining;
        StringPairVector    file_hashes;
        IntVector           changed_files;
        StringVector        target_file_names;
        int                 next_file_index;
        int                 next_file_size;
        guchar              input_buffer[ 1024 ];

        void reset()
        {
            state = APP;
            app_file.clear();
            file_count = 0;
            files_remaining = 0;
            file_hashes.clear();
            changed_files.clear();
            target_file_names.clear();
            next_file_index = 0;
            next_file_size = 0;
        }

        static void destroy( ConnectionState * me )
        {
            delete me;
        }
    };

    AppPushServer() { g_assert( 0 ); }

    AppPushServer( TPContext * context , guint16 port );

    static void accept_callback( GObject * source, GAsyncResult * result, gpointer data );

    static void line_read( GObject * stream , GAsyncResult * result , gpointer me );

    void line_read( GObject * stream , GAsyncResult * result );

    void close( ConnectionState * state );

    static void file_read( GObject * stream , GAsyncResult * result , gpointer me );

    void file_read( GObject * stream , GAsyncResult * result );

    void send_response( ConnectionState * state );

    void launch_it( ConnectionState * state );

    TPContext *         context;

    GSocketListener  *  listener;
};



#endif // _TRICKPLAY_APP_PUSH_SERVER_H
