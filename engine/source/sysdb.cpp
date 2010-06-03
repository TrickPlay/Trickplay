
#include "glib/gstdio.h"

#include "sysdb.h"
#include "util.h"
#include "db.h"

//-----------------------------------------------------------------------------

static const char * schema_create =

    "create table generic( key TEXT PRIMARY KEY NOT NULL , value TEXT );"

    "create table profiles( id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "                       name TEXT,pin TEXT);"

    "create table apps( id TEXT PRIMARY KEY NOT NULL,"
    "                   path TEXT NOT NULL, "
    "                   name TEXT,"
    "                   release INTEGER NOT NULL,"
    "                   version TEXT NOT NULL,"
    "                   fingerprints TEXT );"

    "create table profile_apps( profile_id INTEGER NOT NULL,"
    "                           app_id TEXT NOT NULL,"
    "                           PRIMARY KEY( profile_id, app_id) );"

    // When a profile is deleted, all of its apps are also deleted

    "create trigger profiles_profile_apps_delete after delete on profiles"
    "   begin"
    "       delete from profile_apps where profile_id = OLD.id; "
    "   end;"

    // When an app is deleted, it is removed from all profiles

    "create trigger apps_profile_apps_delete after delete on apps"
    "   begin"
    "       delete from profile_apps where app_id = OLD.id;"
    "   end;"

#if 0
    // When an app is inserted, we add it to all profiles - if it belongs to none
    "create trigger apps_profile_apps_insert after insert on apps"
    "   when ( select 1 from profile_apps where app_id = NEW.id limit 1 ) IS NULL"
    "   begin"
    "       insert into profile_apps ( profile_id , app_id ) select id , NEW.id from profiles;"
    "   end;"
#endif

    // When an new profile is created, it gets all apps

    "create trigger profiles_profile_apps_insert after insert on profiles"
    "   begin"
    "       insert into profile_apps ( profile_id , app_id ) select NEW.id , id from apps;"
    "   end;"
    ;

//-----------------------------------------------------------------------------

SystemDatabase * SystemDatabase::open( const char * path )
{
    // Create the in-memory database

    SQLite::DB db( ":memory:" );

    // If that fails, there is not much we can do - a warning will have been
    // printed out already

    if ( !db.ok() )
    {
        return NULL;
    }

    // Construct the filename for the on-disk db

    gchar * filename = g_build_filename( path, "system.db", NULL );
    Util::GFreeLater free_filename( filename );

    bool create = true;

    if ( !g_file_test( filename, G_FILE_TEST_EXISTS ) )
    {
        g_info( "SYSTEM DATABASE DOES NOT EXIST" );
    }

    // Try to open the on-disk database in read-only mode

    else
    {
        SQLite::DB source( filename, SQLITE_OPEN_READONLY );

        if ( !source.ok() )
        {
            g_warning( "FAILED TO OPEN EXISTING SYSTEM DATABASE" );
        }
        else
        {
            // Perform an integrity check on it

            SQLite::Statement integrity( source, "pragma integrity_check;" );
            integrity.step();

            if ( !integrity.ok() || integrity.get_string( 0 ) != "ok" )
            {
                g_warning( "FAILED INTEGRITY CHECK ON EXISTING SYSTEM DATABASE" );
            }
            else
            {
                // Backup the existing database into the in-memory database

                if ( !SQLite::Backup( db, source ).ok() )
                {
                    g_warning( "FAILED TO RESTORE EXISTING SYSTEM DATABASE" );
                }
                else
                {
                    create = false;
                    g_info( "SYSTEM DATABASE LOADED" );
                }
            }
        }
    }

    // If anything failed above, we (re)create the database schema. If this
    // fails, there is not much we can do

    if ( create )
    {
        db.exec( schema_create );

        if ( !db.ok() )
        {
            g_warning( "FAILED TO CREATE INITIAL SYSTEM DATABASE SCHEMA" );
            return NULL;
        }

        g_info( "SYSTEM DATABASE CREATED" );
    }

    // Now, we create an instance of a system database - which will steal the
    // underlying sqlite db from our local instance...we transfer ownership of it.

    SystemDatabase * result = new SystemDatabase( db, path, create );

    // If we fail to populate the database, we should not continue since we may
    // have inconsistent data. Plus, if this fails, it is very likely that
    // future stuff will also fail.

    if ( !result->insert_initial_data() )
    {
        g_warning( "FAILED TO POPULATE SYSTEM DATABASE" );

        // We reset dirty so that this bad database doesn't get flushed when
        // we delete it

        result->dirt = 0;
        delete result;
        return NULL;
    }

    // Everything is OK

    return result;
}

//.............................................................................

SystemDatabase::SystemDatabase( SQLite::DB & d, const char * p, bool c )
    :
    path( p ),
    db( d ),
    dirt( 0 ),
    restored( !c )
{
}

//.............................................................................

SystemDatabase::~SystemDatabase()
{
    flush();
}

//.............................................................................

bool SystemDatabase::flush()
{
    if ( ! dirt )
    {
        return true;
    }

    gchar * backup_filename = g_build_filename( path.c_str(), "system.db.XXXXXX", NULL );
    Util::GFreeLater free_backup_filename( backup_filename );

    // Make a temporary file to backup to

    gint fd = g_mkstemp( backup_filename );

    if ( fd == -1 )
    {
        g_warning( "FAILED TO CREATE TEMPORARY FILE FOR SYSTEM DATABASE" );
        return false;
    }

    close( fd );

    SQLite::DB dest( backup_filename );

    if ( !dest.ok() )
    {
        g_warning( "FAILED TO OPEN TEMPORARY BACKUP FOR SYSTEM DATABASE" );
        g_unlink( backup_filename );
        return false;
    }

    if ( !SQLite::Backup( dest, db ).ok() )
    {
        g_warning( "FAILED TO BACKUP SYSTEM DATABASE" );
        g_unlink( backup_filename );
        return false;
    }

    // Now move the backup file

    gchar * target_filename = g_build_filename( path.c_str(), "system.db", NULL );
    Util::GFreeLater free_target_filename( target_filename );

    if ( g_rename( backup_filename, target_filename ) != 0 )
    {
        g_warning( "FAILED TO MOVE BACKUP SYSTEM DATABASE" );
        g_unlink( backup_filename );
        return false;
    }

    g_info( "SYSTEM DATABASE FLUSHED" );
    dirt = 0;
    return true;
}

//.............................................................................

bool SystemDatabase::was_restored() const
{
    return restored;
}

//.............................................................................

bool SystemDatabase::insert_initial_data()
{
    // Collect a list of existing profile ids

    std::set<int> ids;

    {
        SQLite::Statement select( db, "select id from profiles;" );

        while ( select.step_row() )
        {
            ids.insert( select.get_int( 0 ) );
        }

        if ( !select.ok() )
        {
            return false;
        }
    }

    // There are no profiles, we must create one

    if ( ids.size() == 0 )
    {
        int id = create_profile( TP_DB_FIRST_PROFILE_NAME, "" );

        if ( !id )
        {
            return false;
        }

        if ( !set( TP_DB_CURRENT_PROFILE_ID, id ) )
        {
            return false;
        }
    }

    // There are profiles, lets make sure the current profile id is set to one
    // of them

    else
    {
        int id = get_int( TP_DB_CURRENT_PROFILE_ID, -1 );

        // There is no current profile id set, or the one that is set is not
        // in the list of ids

        if ( id == -1 || ids.find( id ) == ids.end() )
        {
            if ( !set( TP_DB_CURRENT_PROFILE_ID, *( ids.begin() ) ) )
            {
                return false;
            }
        }
    }

    return true;
}

//.............................................................................

bool SystemDatabase::set( const char * key, int value )
{
    SQLite::Statement insert( db, "insert or replace into generic (key,value) values (?1,?2);" );
    insert.bind( 1, key );
    insert.bind( 2, value );
    insert.step();
    make_dirty();
    return insert.ok();
}

//.............................................................................

bool SystemDatabase::set( const char * key, const char * value )
{
    SQLite::Statement insert( db, "insert or replace into generic (key,value) values (?1,?2);" );
    insert.bind( 1, key );
    insert.bind( 2, value );
    insert.step();
    make_dirty();
    return insert.ok();
}

//.............................................................................

bool SystemDatabase::set( const char * key, const String & value )
{
    SQLite::Statement insert( db, "insert or replace into generic (key,value) values (?1,?2);" );
    insert.bind( 1, key );
    insert.bind( 2, value );
    insert.step();
    make_dirty();
    return insert.ok();
}

//.............................................................................

String SystemDatabase::get_string( const char * key, const char * def )
{
    SQLite::Statement select( db, "select value from generic where key=?1;" );
    select.bind( 1, key );
    if ( select.step_row() )
    {
        return select.get_string( 0 );
    }
    return String( def );
}

//.............................................................................

int SystemDatabase::get_int( const char * key, int def )
{
    SQLite::Statement select( db, "select value from generic where key=?1;" );
    select.bind( 1, key );
    if ( select.step_row() )
    {
        return select.get_int( 0 );
    }
    return def;
}

//.............................................................................

int SystemDatabase::create_profile( const String & name, const String & pin )
{
    SQLite::Statement insert( db, "insert into profiles (id,name,pin) values (NULL,?1,?2);" );
    insert.bind( 1, name );
    insert.bind( 2, pin );
    insert.step();
    make_dirty();
    return db.last_insert_rowid();
}

//.............................................................................

SystemDatabase::Profile SystemDatabase::get_current_profile()
{
    SystemDatabase::Profile result;

    SQLite::Statement select( db, "select p.id,p.name,p.pin from generic g,profiles p where g.key=?1 and g.value=p.id;" );
    select.bind( 1, TP_DB_CURRENT_PROFILE_ID );
    if ( select.step_row() )
    {
        result.id = select.get_int( 0 );
        result.name = select.get_string( 1 );
        result.pin = select.get_string( 2 );
    }
    return result;
}

//.............................................................................

SystemDatabase::Profile SystemDatabase::get_profile( int id )
{
    SystemDatabase::Profile result;

    SQLite::Statement select( db, "select name,pin from profiles where id=?1;" );
    select.bind( 1, id );
    if ( select.step_row() )
    {
        result.id = id;
        result.name = select.get_string( 0 );
        result.pin = select.get_string( 1 );
    }
    return result;
}

//.............................................................................

int SystemDatabase::get_app_count()
{
    SQLite::Statement select( db, "select count(*) from apps;" );
    if ( select.step_row() )
    {
        return select.get_int( 0 );
    }
    return 0;
}

//.............................................................................

bool SystemDatabase::delete_all_apps()
{
    make_dirty();
    SQLite::Statement select( db, "delete from apps;" );
    select.step();
    return select.ok();
}

//.............................................................................

bool SystemDatabase::insert_app( const App::Metadata & metadata, const StringSet & fingerprints )
{
    make_dirty();

    String fingerprint_list;

    for ( StringSet::const_iterator it = fingerprints.begin(); it != fingerprints.end(); ++it )
    {
        if ( ! fingerprint_list.empty() )
        {
            fingerprint_list += ",";
        }

        fingerprint_list += *it;
    }

    SQLite::Statement insert( db, "insert or replace into apps (id,path,name,release,version,fingerprints) values (?1,?2,?3,?4,?5,?6);" );
    insert.bind( 1, metadata.id );
    insert.bind( 2, metadata.path );
    insert.bind( 3, metadata.name );
    insert.bind( 4, metadata.release );
    insert.bind( 5, metadata.version );
    insert.bind( 6, fingerprint_list );

    insert.step();

    return insert.ok();
}

//.............................................................................

String SystemDatabase::get_app_path( const String & id )
{
    SQLite::Statement select( db, "select path from apps where id=?1;" );
    select.bind( 1, id );
    if ( select.step_row() )
    {
        return select.get_string( 0 );
    }
    return String();
}

//.............................................................................

SystemDatabase::AppInfo::List SystemDatabase::get_app_list( SQLite::Statement * select )
{
    g_assert( select );

    AppInfo::List result;

    while ( select->step_row() )
    {
        AppInfo app;

        app.id = select->get_string( 0 );
        app.path = select->get_string( 1 );
        app.name = select->get_string( 2 );
        app.release = select->get_int( 3 );
        app.version = select->get_string( 4 );

        gchar * * fingerprints = g_strsplit( select->get_string( 5 ).c_str(), ",", 0 );

        for ( gchar * * f = fingerprints; *f; ++f )
        {
            app.fingerprints.insert( String( *f ) );
        }

        g_strfreev( fingerprints );

        result.push_back( app );
    }

    return result;
}

//.............................................................................

SystemDatabase::AppInfo::List SystemDatabase::get_all_apps()
{
    SQLite::Statement select( db, "select id,path,name,release,version,fingerprints from apps;" );

    return get_app_list( &select );
}

//.............................................................................

void SystemDatabase::update_all_apps( const App::Metadata::List & apps )
{
    // First, gather a set of all existing app ids

    StringSet existing_ids;

    SQLite::Statement select_ids( db, "select id from apps" );

    while ( select_ids.step_row() )
    {
        existing_ids.insert( select_ids.get_string( 0 ) );
    }

    // Now, iterate over the apps passed in. Update each one and
    // take it out of the existing ids.

    for ( App::Metadata::List::const_iterator it = apps.begin(); it != apps.end(); ++it )
    {
        insert_app( *it );

        bool existed = existing_ids.erase( it->id );

        g_info( "%s %s (%s/%d) @ %s",
                existed ? "UPDATING" : "ADDING",
                it->id.c_str(),
                it->version.c_str(),
                it->release,
                it->path.c_str() );

        if ( ! existed )
        {
            add_app_to_all_profiles( it->id );
        }
    }

    // If there are any remaining, they should be deleted

    if ( ! existing_ids.empty() )
    {
        make_dirty();

        SQLite::Statement del( db, "delete from apps where id = ?1" );

        for ( StringSet::const_iterator it = existing_ids.begin(); it != existing_ids.end(); ++it )
        {
            del.bind( 1, *it );
            del.step();
            del.reset();
            del.clear();

            g_info( "DELETING %s", it->c_str() );
        }
    }
}

//.............................................................................

bool SystemDatabase::add_app_to_all_profiles( const String & app_id )
{
    make_dirty();

    SQLite::Statement insert( db, "insert or ignore into profile_apps ( profile_id , app_id ) select id , ?1 from profiles;" );

    insert.bind( 1, app_id );

    return insert.step_done();
}

//.............................................................................

bool SystemDatabase::add_app_to_current_profile( const String & app_id )
{
    Profile profile = get_current_profile();

    if ( ! profile.id )
    {
        return false;
    }

    make_dirty();

    SQLite::Statement insert( db, "insert or ignore into profile_apps ( profile_id , app_id ) values ( ?1 , ?2 );" );

    insert.bind( 1, profile.id );
    insert.bind( 2, app_id );

    return insert.step_done();
}

//.............................................................................

SystemDatabase::AppInfo::List SystemDatabase::get_apps_for_current_profile()
{
    Profile profile = get_current_profile();

    if ( ! profile.id )
    {
        return AppInfo::List();
    }

    SQLite::Statement select( db,
            "select a.id,a.path,a.name,a.release,a.version,a.fingerprints"
            " from apps a, profile_apps p where p.profile_id = ?1 and a.id = p.app_id;" );

    select.bind( 1, profile.id );

    return get_app_list( &select );
}

//.............................................................................

bool SystemDatabase::remove_app_from_all_profiles( const String & app_id )
{
    make_dirty();

    SQLite::Statement del( db, "delete from profile_apps where app_id = ?1;" );

    del.bind( 1, app_id );

    return del.step_done();
}

//.............................................................................

bool SystemDatabase::remove_app_from_current_profile( const String & app_id )
{
    Profile profile = get_current_profile();

    if ( ! profile.id )
    {
        return false;
    }

    make_dirty();

    SQLite::Statement del( db, "delete from profile_apps where app_id = ?1 and profile_id = ?2;" );

    del.bind( 1, app_id );
    del.bind( 2, profile.id );

    return del.step_done();
}

//.............................................................................

std::list<int> SystemDatabase::get_profiles_for_app( const String & app_id )
{
    std::list<int> result;

    SQLite::Statement select( db, "select profile_id from profile_apps where app_id = ?1;" );

    select.bind( 1, app_id );

    while( select.step_row() )
    {
        result.push_back( select.get_int( 0 ) );
    }

    return result;
}

//.............................................................................
