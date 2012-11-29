#ifndef _TRICKPLAY_SYSDB_H
#define _TRICKPLAY_SYSDB_H

#include "common.h"
#include "db.h"
#include "app.h"

//-----------------------------------------------------------------------------
#define TP_DB_FIRST_PROFILE_NAME    "TrickPlay User"

#define TP_DB_CURRENT_PROFILE_ID    "profile.current"
#define TP_DB_FIRST_PROFILE_ID    	"profile.first"

#define TP_DB_UUID                  "uuid"

//-----------------------------------------------------------------------------

class SystemDatabase
{
public:

    static SystemDatabase * open( const char * path );

    ~SystemDatabase();

    bool flush();

    bool was_restored() const;

    bool is_dirty() const
    {
        return dirt > 0;
    }

    guint64 get_dirt() const
    {
        return dirt;
    }

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
        String      badge_style;
        String      badge_text;
        StringSet   attributes;
    };

    int get_app_count();

    bool insert_app( const App::Metadata & metadata, const StringSet & fingerprints = StringSet() );

    String get_app_path( const String & id );

    AppInfo::List get_all_apps();

    void update_all_apps( const App::Metadata::List & apps );

    void set_app_badge( const String & id, const String & badge_style, const String & badge_text );

    //.....................................................................
    // Profile Apps

    bool add_app_to_all_profiles( const String & app_id );

    bool add_app_to_current_profile( const String & app_id );

    enum AppSort { BY_NAME , BY_DATE_USED , BY_TIMES_USED };

    AppInfo::List get_apps_for_current_profile( AppSort sort = BY_NAME , bool reverse = false );

    bool remove_app_from_all_profiles( const String & app_id );

    bool remove_app_from_current_profile( const String & app_id );

    std::list<int> get_profiles_for_app( const String & app_id );

    bool is_app_in_current_profile( const String & app_id );

    void app_launched( const String & app_id );

    //.....................................................................
    // App actions

    typedef std::map< String , App::Action::Map > AppActionMap;

    AppActionMap get_app_actions_for_current_profile();

private:

    AppInfo::List get_app_list( SQLite::Statement * select );

    bool delete_all_apps();

    bool insert_initial_data();

    SystemDatabase( SQLite::DB & d, const char * p, bool c );
    SystemDatabase( const SystemDatabase & ) {}

    inline void make_dirty()
    {
        ++dirt;
    }

    String      path;
    SQLite::DB  db;
    guint64     dirt;
    bool        restored;
};


#endif // _TRICKPLAY_SYSDB_H
