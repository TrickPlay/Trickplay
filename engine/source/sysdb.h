#ifndef _TRICKPLAY_SYSDB_H
#define _TRICKPLAY_SYSDB_H

#include "common.h"
#include "db.h"
#include "app.h"

//-----------------------------------------------------------------------------
#define TP_DB_FIRST_PROFILE_NAME    "TrickPlay User"

#define TP_DB_CURRENT_PROFILE_ID    "profile.current"
//-----------------------------------------------------------------------------

class SystemDatabase
{
public:

    static SystemDatabase * open( const char * path );

    ~SystemDatabase();

    bool flush();

    bool was_restored() const;

    //.....................................................................
    // Generic

    bool set( const char * key, int value );
    bool set( const char * key, const char * value );
    bool set( const char * key, const String & value );

    String get_string( const char * key, const char * def = "" );
    int get_int( const char * key, int def = 0 );

    //.....................................................................
    // Profile

    struct Profile
    {
        Profile() : id( 0 ) {}

        int     id;
        String  name;
        String  pin;
    };

    int create_profile( const String & name, const String & pin );
    Profile get_current_profile();
    Profile get_profile( int id );

    //.....................................................................
    // Apps

    struct AppInfo
    {
        typedef std::list<AppInfo> List;

        AppInfo()
        :
            release( 0 )
        {}

        String      id;
        String      path;
        String      name;
        int         release;
        String      version;
        StringSet   fingerprints;
    };

    int get_app_count();
    bool delete_all_apps();
    bool insert_app( const App::Metadata & metadata, const StringSet & fingerprints = StringSet() );
    String get_app_path( const String & id );
    AppInfo::List get_all_apps();
    void update_all_apps( const App::Metadata::List & apps );

private:

    bool insert_initial_data();

    SystemDatabase( SQLite::DB & d, const char * p, bool c );
    SystemDatabase( const SystemDatabase & ) {}

    String      path;
    SQLite::DB  db;
    bool        dirty;
    bool        restored;
};


#endif // _TRICKPLAY_SYSDB_H
