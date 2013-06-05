#ifndef _TRICKPLAY_INSTALLER_H
#define _TRICKPLAY_INSTALLER_H

#include "common.h"
#include "network.h"
#include "downloads.h"
#include "thread_pool.h"

class Installer : private Downloads::Delegate
{
public:

    Installer( TPContext* context );

    virtual ~Installer();

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
            const String& owner,
            const String& app_id,
            const String& app_name,
            bool locked,
            const Network::Request& request,
            Network::CookieJar* cookie_jar,
            const StringSet& required_fingerprints = StringSet(),
            const StringMap& extra = StringMap() );

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
        enum InfoStatus { DOWNLOADING, INSTALLING, FAILED, FINISHED };

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

        Info( guint _id,
                const String& _app_id,
                const String& _app_name,
                const String& _owner,
                bool _locked,
                guint _download_id,
                const StringSet& _required_fingerprints,
                const StringMap& _extra )
            :
            id( _id ),
            status( DOWNLOADING ),
            app_id( _app_id ),
            app_name( _app_name ),
            owner( _owner ),
            locked( _locked ),
            download_id( _download_id ),
            required_fingerprints( _required_fingerprints ),
            extra( _extra ),
            percent_downloaded( 0 ),
            percent_installed( 0 ),
            moved( false )
        {}

        guint       id;
        InfoStatus  status;
        String      app_id;
        String      app_name;
        String      owner;
        bool        locked;
        guint       download_id;
        StringSet   required_fingerprints;
        StringMap   extra;
        gdouble     percent_downloaded;
        gdouble     percent_installed;
        bool        moved;
        String      source_file;
        String      install_directory;
        String      app_directory;
        StringSet   fingerprints;
    };

    //.........................................................................

    Info* get_install( guint id );

    //.........................................................................

    typedef std::list<Info> InfoList;

    InfoList get_all_installs() const;

    //.........................................................................
    // Delegates

    class Delegate
    {
    public:

        virtual void download_progress( const Info& install_info, const Downloads::Info& download_info ) = 0;
        virtual void download_finished( const Info& install_info, const Downloads::Info& download_info ) = 0;
        virtual void install_progress( const Info& install_info ) = 0;
        virtual void install_finished( const Info& install_info ) = 0;
    };

    void add_delegate( Delegate* delegate );
    void remove_delegate( Delegate* delegate );

private:

    //.........................................................................

    Info* get_info_for_download( guint download_id );

    //.........................................................................
    // Downloads::Delegate methods

    virtual void download_progress( const Downloads::Info& dl_info );

    virtual void download_finished( const Downloads::Info& dl_info );

    //.........................................................................

    void install_progress( const Installer::Info& progress_info );

    //.........................................................................

    friend class InstallAppTask;

    //.........................................................................

    TPContext*      context;
    guint           next_id;
    ThreadPool      thread_pool;

    //.........................................................................
    // A map of Info structures by id

    typedef std::map<guint, Info>    InfoMap;

    InfoMap         info_map;

    //..........................................................................
    // Delegates

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet     delegates;
};

#endif // _TRICKPLAY_INSTALLER_H
