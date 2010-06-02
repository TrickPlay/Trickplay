#ifndef _TRICKPLAY_SYSDB_H
#define _TRICKPLAY_SYSDB_H

#include "common.h"
#include "db.h"
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

    struct App
    {
        App() : release( 0 ) {}

        String  id;
        String  path;
        int     release;
        String  version;
    };

    typedef std::list<App> AppList;

    int get_app_count();
    bool delete_all_apps();
    bool insert_app( const String & id, const String & path, int release, const String & version, const StringSet & fingerprints = StringSet() );
    String get_app_path( const String & id );
    AppList get_all_apps();

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
