#ifndef _TRICKPLAY_DB_H
#define _TRICKPLAY_DB_H

#include "sqlite3.h"

#include "common.h"

namespace SQLite
{
class Error
{
public:

    // If the error is not ok, will throw a String exception

    void exception( const char* message = NULL ) const;

    // Checks that there is no error

    inline bool ok() const
    {
        return error == SQLITE_OK;
    }

    // Returns the sqlite error code

    inline int get_error() const
    {
        return error;
    }

    // Returns the sqlite error message

    inline String get_msg() const
    {
        return msg;
    }

    inline sqlite3* get_db() const
    {
        return db;
    }

protected:

    Error();
    Error( sqlite3* d );
    Error( const Error& other );

    int check();
    int check( int new_error );
    int check( const Error& other );

    void reset_db( sqlite3* d );

private:

    sqlite3*    db;
    int         error;
    String      msg;
};

//-------------------------------------------------------------------------

class DB : public Error
{
public:

    DB();
    DB( const char* path );
    DB( const char* path, int flags );
    DB( DB& other );
    ~DB();

    DB& operator = ( DB& other );

    int exec( const char* sql );

    int last_insert_rowid() const;

    sqlite3* steal_db();

    // If the migration happens, this database will be replaced
    // with a new in-memory database.

    bool migrate_schema( const char* schema );

    bool set_schema_version( const char* schema , const char* hash = 0 );

    int changes();
};

//-------------------------------------------------------------------------

class Statement : public Error
{
public:

    Statement( const DB& db, const char* sql );
    Statement( const DB& db, const String& sql );
    ~Statement();

    int step();
    bool step_row();
    bool step_done();

    int reset();

    int clear();

    int get_int( int col );

    String get_string( int col );

    bool is_null( int col );

    int bind( int pos );
    int bind( int pos, int value );
    int bind( int pos, const char* value );
    int bind( int pos, const String& value );

private:

    Statement( const Statement& ) {}

    sqlite3_stmt* s;
};

//-------------------------------------------------------------------------

class Backup : public Error
{
public:

    Backup( const DB& to, const DB& from );

private:

    Backup( const Backup& ) {}
};

} // namespace DB


#endif // _TRICKPLAY_DB_H
