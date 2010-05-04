#ifndef _TRICKPLAY_INSTALLER_H
#define _TRICKPLAY_INSTALLER_H

#include "common.h"
#include "network.h"
#include "downloads.h"

class Installer : private Downloads::Delegate
{
public:

    Installer( TPContext * context );

    ~Installer();

    //.........................................................................
    // This will download and install an app. The download is done in a download
    // thread and the installation is done in this thread. It returns an
    // installation id if it started successfully, or zero otherwise.
    //
    // "locked" means that we are guaranteed that the app will not be running,
    // which allows the installer to completely replace it. If locked is false
    // and the app already exists, the installer will not completely replace it
    // and you will need to call "complete_install" to finish up (when you know)
    // the app is not running.

    guint download_and_install_app(
            const String & owner,
            const String & app_id,
            bool locked,
            const Network::Request & request,
            Network::CookieJar * cookie_jar,
            const StringMap & extra = StringMap() );

    //.........................................................................
    // An installation that is FINISHED, may still need a bit of processing
    // to be done by the caller - when we know for certain that it is not
    // running.

    bool complete_install( guint id );

    //.........................................................................
    // This can be called to clean up if complete_install fails. It will try
    // to delete the installation directory for the app and remove the info
    // entry from the installer.

    void abandon_install( guint id );

    //.........................................................................
    // Info about an installation

    struct Info
    {
        enum Status { DOWNLOADING, INSTALLING, FAILED, FINISHED };

        Info()
        :
            id( 0 ),
            status( FAILED ),
            locked( false ),
            download_id( 0 ),
            percent_downloaded( 0 ),
            percent_installed( 0 ),
            moved( false )
        {}

        Info( guint _id, const String & _app_id, const String & _owner, bool _locked, guint _download_id, const StringMap & _extra )
        :
            id( _id ),
            status( DOWNLOADING ),
            app_id( _app_id ),
            owner( _owner ),
            locked( _locked ),
            download_id( _download_id ),
            extra( _extra ),
            percent_downloaded( 0 ),
            percent_installed( 0 ),
            moved( false )
        {}

        guint       id;
        Status      status;
        String      app_id;
        String      owner;
        bool        locked;
        guint       download_id;
        StringMap   extra;
        gdouble     percent_downloaded;
        gdouble     percent_installed;
        bool        moved;
        String      install_directory;
        String      app_directory;
    };

    //.........................................................................

    Info * get_install( guint id );

    //.........................................................................

    typedef std::list<Info> InfoList;

    InfoList get_all_installs() const;

    //.........................................................................
    // Delegates

    class Delegate
    {
    public:

        virtual void download_progress( const Info & install_info, const Downloads::Info & download_info ) = 0;
        virtual void download_finished( const Info & install_info, const Downloads::Info & download_info ) = 0;
        virtual void install_progress( const Info & install_info ) = 0;
        virtual void install_finished( const Info & install_info ) = 0;
    };

    void add_delegate( Delegate * delegate );
    void remove_delegate( Delegate * delegate );

private:

    //.........................................................................

    Info * get_info_for_download( guint download_id );

    //.........................................................................
    // Starts the thread if it has not been started already

    void start_thread();

    //.........................................................................
    // The thread function. It sits around waiting for an event in the queue

    static gpointer process( gpointer _queue );

    //.........................................................................
    // Downloads::Delegate methods

    virtual void download_progress( const Downloads::Info & dl_info );

    virtual void download_finished( const Downloads::Info & dl_info );

    //.........................................................................
    // InstallEvent sends us progress using this closure

    struct ProgressClosure
    {
        enum Status { INSTALLING, FINISHED, FAILED };

        static ProgressClosure * make_progress( Installer * installer, guint id, gdouble percent_complete )
        {
            ProgressClosure * result = g_slice_new0( ProgressClosure );

            result->installer = installer;
            result->id = id;
            result->status = INSTALLING;
            result->percent_complete = percent_complete;

            return result;
        }

        static ProgressClosure * make_failed( Installer * installer, guint id )
        {
            ProgressClosure * result = g_slice_new0( ProgressClosure );

            result->installer = installer;
            result->id = id;
            result->status = FAILED;
            result->percent_complete = 100;

            return result;
        }

        static ProgressClosure * make_finished( Installer * installer, guint id, bool moved, const gchar * install_directory, const gchar * app_directory )
        {
            ProgressClosure * result = g_slice_new0( ProgressClosure );

            result->installer = installer;
            result->id = id;
            result->status = FINISHED;
            result->percent_complete = 100;
            result->moved = moved;
            result->install_directory = g_strdup( install_directory );
            result->app_directory = g_strdup( app_directory );

            return result;
        }

        static void destroy( gpointer pc )
        {
            ProgressClosure * self = ( ProgressClosure * )pc;

            g_free( self->install_directory );
            g_free( self->app_directory );

            g_slice_free( ProgressClosure, self );
        }

        Installer * installer;
        guint       id;
        Status      status;
        gdouble     percent_complete;
        bool        moved;
        gchar *     install_directory;
        gchar *     app_directory;
    };

    void install_progress( ProgressClosure * progress_closure );

    //.........................................................................

    friend class InstallAppEvent;

    //.........................................................................

    TPContext *     context;
    GAsyncQueue  *  queue;
    GThread *       thread;
    guint           next_id;

    //.........................................................................
    // A map of Info structures by id

    typedef std::map<guint,Info>    InfoMap;

    InfoMap         info_map;

    //..........................................................................
    // Delegates

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet     delegates;
};

#endif // _TRICKPLAY_INSTALLER_H
