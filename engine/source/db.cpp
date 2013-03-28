
#include <algorithm>

#include "db.h"
#include "common.h"
#include "util.h"

//.............................................................................

#define TP_LOG_DOMAIN   "DB"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//.............................................................................

#ifndef TP_PRODUCTION

// Comment in to enable tracing
//#define TP_SQLITE_TRACE   1

#endif

//.............................................................................

namespace SQLite
{
Error::Error()
    :
    db( NULL ),
    error( SQLITE_ERROR ),
    msg( "Database is not open" )
{
}

Error::Error( sqlite3* d )
{
    reset_db( d );
}

Error::Error( const Error& other )
{
    db = other.db;
    error = other.error;
    msg = other.msg;
}

void Error::exception( const char* message ) const
{
    if ( error == SQLITE_OK )
    {
        return;
    }

    String e;

    if ( message )
    {
        e = String( message ) + " : ";
    }

    e += msg;
    throw e;
}

int Error::check( int new_error )
{
    if ( error != SQLITE_OK )
    {
        return error;
    }

    if ( new_error == SQLITE_OK || new_error == SQLITE_DONE || new_error == SQLITE_ROW )
    {
        return new_error;
    }

    error = new_error;
    msg = sqlite3_errmsg( db );
    tpwarn( "SQLITE : %s", msg.c_str() );
    return error;
}

int Error::check()
{
    return check( sqlite3_errcode( db ) );
}

int Error::check( const Error& other )
{
    if ( error != SQLITE_OK )
    {
        return error;
    }

    if ( other.ok() )
    {
        return SQLITE_OK;
    }

    error = other.error;
    msg = other.msg;
    tpwarn( "SQLITE : %s", msg.c_str() );
    return error;
}

#ifdef TP_SQLITE_TRACE

static void trace( void* , const char* s )
{
    g_debug( "[SQLITE] %s" , s );
}

#endif

void Error::reset_db( sqlite3* d )
{
    db = d;

    if ( !db )
    {
        msg = "Database is not open";
        error = SQLITE_ERROR;
    }
    else
    {
        error = SQLITE_OK;
        msg = "";
        check();

#ifdef TP_SQLITE_TRACE

        sqlite3_trace( db , trace , 0 );
#endif
    }
}

//-------------------------------------------------------------------------

DB::DB()
{
}

DB::DB( const char* path )
{
    sqlite3* db = NULL;
    sqlite3_open( path, &db );
    reset_db( db );
}

DB::DB( const char* path, int flags )
{
    sqlite3* db = NULL;
    sqlite3_open_v2( path, &db, flags, NULL );
    reset_db( db );
}

DB::DB( DB& other )
{
    reset_db( other.steal_db() );
}

DB& DB::operator = ( DB& other )
{
    if ( sqlite3* db = get_db() )
    {
        sqlite3_close( db );
    }

    reset_db( other.steal_db() );

    return *this;
}

DB::~DB()
{
    if ( sqlite3* db = get_db() )
    {
        sqlite3_close( db );
    }
}

int DB::exec( const char* sql )
{
    return !ok() ? get_error() : check( sqlite3_exec( get_db(), sql, NULL, NULL, NULL ) );
}

int DB::last_insert_rowid() const
{
    return !ok() ? 0 : sqlite3_last_insert_rowid( get_db() );
}


sqlite3* DB::steal_db()
{
    sqlite3* db = get_db();
    reset_db( NULL );
    return db;
}

bool DB::set_schema_version( const char* schema , const char* hash )
{
    String schema_hash( hash ? hash : "" );

    if ( schema_hash.empty() )
    {
        // Calculate the hash for the new schema

        gchar* h = g_compute_checksum_for_string( G_CHECKSUM_MD5, schema, -1 );

        schema_hash = h;

        g_free( h );
    }

    try
    {
        exec( "create table if not exists schema_version (name TEXT NOT NULL PRIMARY KEY, value TEXT);" );

        exception( "FAILED TO CREATE SCHEMA VERSION TABLE IN DESTINATION DB" );

        Statement insert_hash( * this , "insert into schema_version (name,value) values ('hash',?1);" );

        insert_hash.bind( 1, schema_hash );

        insert_hash.step();

        insert_hash.exception( "FAILED TO INSERT SCHEMA HASH IN DESTINATION DB" );

        return true;
    }
    catch ( const String& e )
    {
        tpwarn( "FAILED TO SET SCHEMA VERSION : %s", e.c_str() );
    }

    return false;

}

bool DB::migrate_schema( const char* schema )
{
    FreeLater free_later;

    // Calculate the hash for the new schema

    gchar* schema_hash = g_compute_checksum_for_string( G_CHECKSUM_MD5, schema, -1 );

    free_later( schema_hash );

    try
    {
        // Get the old schema hash

        Statement select_hash( *this, "select value from schema_version where name='hash';" );

        if ( select_hash.step_row() && ( select_hash.get_string( 0 ) == schema_hash ) )
        {
            // They have the same schema hash, we are done

            tplog( "SCHEMA HASH MATCHES, NO MIGRATION NEEDED" );

            return false;
        }

        // It is possible that this database does not have a schema version table - which is OK

        if ( ! select_hash.ok() )
        {
            tplog( "UNABLE TO FETCH OLD SCHEMA VERSION, MIGRATING" );
        }
        else
        {
            tplog( "SCHEMA VERSION DOES NOT MATCH, MIGRATING" );
        }

        // OK, the schema hash is not the same, we need to migrate

        // Create the new database

        DB new_db( ":memory:" );

        new_db.exec( schema );

        new_db.exception( "FAILED TO CREATE NEW DATABASE SCHEMA" );


        // Get a list of tables from the 'old' database

        StringList tables;

        Statement select_tables( *this, "select name from sqlite_master where type='table' and name not like 'sqlite%' and name != 'schema_version';" );

        while ( select_tables.step_row() )
        {
            tables.push_back( select_tables.get_string( 0 ) );
        }

        select_tables.exception( "FAILED TO LOAD LIST OF TABLES FOR MIGRATION" );


        // Now, migrate each table

        for ( StringList::const_iterator it = tables.begin(); it != tables.end(); ++it )
        {
            String table_name( *it );

            tplog( "MIGRATING TABLE '%s'", table_name.c_str() );

            // Get the columns for this table in the source database

            Statement get_source_columns( *this, Util::format( "pragma table_info(%s);", table_name.c_str() ) );

            StringSet source_columns;

            while ( get_source_columns.step_row() )
            {
                source_columns.insert( get_source_columns.get_string( 1 ) );
            }

            get_source_columns.exception( "FAILED TO GET SOURCE TABLE COLUMNS" );

            // Get the columns in the dest database

            Statement get_dest_columns( new_db, Util::format( "pragma table_info(%s);", table_name.c_str() ) );

            StringSet dest_columns;

            while ( get_dest_columns.step_row() )
            {
                dest_columns.insert( get_dest_columns.get_string( 1 ) );
            }

            get_dest_columns.exception( "FAILED TO GET DESTINATION TABLE COLUMNS" );

            // If this is empty, the table does not exist in the destination database

            if ( dest_columns.empty() )
            {
                tplog( "  DOES NOT EXIST IN DESTINATION DB, SKIPPING" );

                continue;
            }

            // Now, figure out which columns we will migrate - only those that exist in
            // both tables.

            StringList columns;

            std::set_intersection(
                    source_columns.begin(),
                    source_columns.end(),
                    dest_columns.begin(),
                    dest_columns.end(),
                    std::inserter( columns, columns.begin() ) );

            if ( columns.empty() )
            {
                tplog( "  NO COLUMNS IN COMMON, SKIPPING" );

                continue;
            }

            // Create a comma separated list of columns and bind values

            String column_list;
            String value_list;

            int i = 1;

            for ( StringList::const_iterator cit = columns.begin(); cit != columns.end(); ++cit, ++i )
            {
                if ( ! column_list.empty() )
                {
                    column_list += ",";
                }

                column_list += *cit;

                if ( ! value_list.empty() )
                {
                    value_list += ",";
                }

                value_list += Util::format( "?%d", i );
            }

            // Create the select statement

            Statement select_source( *this, Util::format( "select %s from %s;", column_list.c_str(), table_name.c_str() ) );

            Statement insert_dest( new_db, Util::format( "insert into %s (%s) values (%s);", table_name.c_str(), column_list.c_str(), value_list.c_str() ) );

            int rows = 0;

            while ( select_source.step_row() )
            {
                insert_dest.reset();
                insert_dest.clear();

                int i = 1;

                for ( StringList::const_iterator cit = columns.begin(); cit != columns.end(); ++cit, ++i )
                {
                    insert_dest.bind( i, select_source.get_string( i - 1 ) );
                }

                insert_dest.step();

                insert_dest.exception( "FAILED TO INSERT DESTINATION ROW" );

                ++rows;
            }

            tplog( "  MIGRATED %d ROW(S)", rows );
        }

        // Now create the schema version in the new database

        if ( ! new_db.set_schema_version( schema , schema_hash ) )
        {
            return false;
        }

        // Close the source database and replace it with the new database

        sqlite3_close( get_db() );

        reset_db( new_db.steal_db() );

        return true;
    }
    catch ( const String& e )
    {
        tpwarn( "DATABASE MIGRATION FAILED : %s", e.c_str() );
    }

    return false;
}

int DB::changes()
{
    return ! ok() ? 0 : sqlite3_changes( get_db() );
}

//-------------------------------------------------------------------------

Statement::Statement( const DB& db, const char* sql )
    :
    Error( db ),
    s( NULL )
{
    if ( ok() )
    {
        check( sqlite3_prepare( get_db(), sql, -1, &s, NULL ) );
    }
}

Statement::Statement( const DB& db, const String& sql )
    :
    Error( db ),
    s( NULL )
{
    if ( ok() )
    {
        check( sqlite3_prepare( get_db(), sql.c_str(), -1, &s, NULL ) );
    }
}

Statement::~Statement()
{
    if ( s )
    {
        sqlite3_finalize( s );
    }
}

int Statement::step()
{
    return !ok() ? get_error() : check( sqlite3_step( s ) );
}

bool Statement::step_row()
{
    return step() == SQLITE_ROW;
}

bool Statement::step_done()
{
    return step() == SQLITE_DONE;
}

int Statement::reset()
{
    return !ok() ? get_error() : check( sqlite3_reset( s ) );
}

int Statement::clear()
{
    return !ok() ? get_error() : check( sqlite3_clear_bindings( s ) );
}

int Statement::get_int( int col )
{
    return !ok() ? 0 : sqlite3_column_int( s, col );
}

String Statement::get_string( int col )
{
    if ( !ok() || is_null( col ) )
    {
        return String();
    }

    const char* value = ( const char* ) sqlite3_column_text( s, col );

    return ! value ? String() : String( value , sqlite3_column_bytes( s , col ) );
}

bool Statement::is_null( int col )
{
    return !ok() ? true : sqlite3_column_type( s, col ) == SQLITE_NULL;
}

int Statement::bind( int pos )
{
    return !ok() ? get_error() : check( sqlite3_bind_null( s, pos ) );
}

int Statement::bind( int pos, int value )
{
    return !ok() ? get_error() : check( sqlite3_bind_int( s, pos, value ) );
}

int Statement::bind( int pos, const char* value )
{
    return !ok() ? get_error() : check( sqlite3_bind_text( s, pos, value, -1, SQLITE_TRANSIENT ) );
}

int Statement::bind( int pos, const String& value )
{
    return !ok() ? get_error() : check( sqlite3_bind_text( s, pos, value.data(), value.length(), SQLITE_TRANSIENT ) );
}

//-------------------------------------------------------------------------

Backup::Backup( const DB& to, const DB& from )
    :
    Error( to )
{
    // If from has errors, they are transfered to us and ok() will return false

    check( from );

    if ( ok() )
    {
        sqlite3_backup* backup = sqlite3_backup_init( get_db(), "main", from.get_db(), "main" );

        if ( !backup )
        {
            // Checks the destination database for errors
            check();
        }
        else
        {
            check( sqlite3_backup_step( backup, -1 ) );
            check( sqlite3_backup_finish( backup ) );
        }
    }
}

} // namespace SQLite
