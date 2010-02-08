
#include "db.h"

namespace SQLite
{
    Error::Error()
    :
        db(NULL),
        error(SQLITE_ERROR),
        msg("Database is not open")
    {
    }
    
    Error::Error(sqlite3 * d)
    {
        reset_db(d);
    }
    
    Error::Error(const Error & other)
    {
        db=other.db;
        error=other.error;
        msg=other.msg;
    }
    
    void Error::exception(const char * message) const
    {
        if (error==SQLITE_OK)
            return;
        
        String e;
        if (message)
            e = String(message) + " : ";
        e+=msg;
        throw e;
    }

    int Error::check(int new_error)
    {
        if (error!=SQLITE_OK)
            return error;
        
        if (new_error==SQLITE_OK || new_error==SQLITE_DONE || new_error==SQLITE_ROW)
            return new_error;
        
        error=new_error;
        msg=sqlite3_errmsg(db);
        g_warning("SQLITE : %s",msg.c_str());
        return error;
    }
    
    int Error::check()
    {
        return check(sqlite3_errcode(db));
    }
    
    int Error::check(const Error & other)
    {
        if (error!=SQLITE_OK)
            return error;
        
        if (other.ok())
            return SQLITE_OK;
        
        error=other.error;
        msg=other.msg;
        g_warning("SQLITE : %s",msg.c_str());
        return error;        
    }
    
    void Error::reset_db(sqlite3 * d)
    {
        db=d;
        if(!db)
        {
            msg="Database is not open";
            error=SQLITE_ERROR;            
        }
        else
        {
            error=SQLITE_OK;
            msg="";            
            check();
        }
    }
    
    //-------------------------------------------------------------------------
    
    DB::DB()
    {
    }
    
    DB::DB(const char * path)
    {
        sqlite3 * db=NULL;
        sqlite3_open(path,&db);
        reset_db(db);        
    }
    
    DB::DB(const char * path,int flags)
    {
        sqlite3 * db=NULL;
        sqlite3_open_v2(path,&db,flags,NULL);
        reset_db(db);
    }
    
    DB::DB(DB & other)
    {
        reset_db(other.steal_db());
    }
        
    DB::~DB()
    {
        if (sqlite3 * db=get_db())
            sqlite3_close(db);
    }
    
    int DB::exec(const char * sql)
    {
        return !ok()?get_error():check(sqlite3_exec(get_db(),sql,NULL,NULL,NULL));
    }

    int DB::last_insert_rowid() const
    {
        return !ok()?0:sqlite3_last_insert_rowid(get_db());
    }

    
    sqlite3 * DB::steal_db()
    {
        sqlite3 * db=get_db();
        reset_db(NULL);
        return db;
    }
    
    //-------------------------------------------------------------------------
    
    Statement::Statement(const DB & db,const char * sql)
    :
        Error(db),
        s(NULL)
    {
        if (ok())
            check(sqlite3_prepare(get_db(),sql,-1,&s,NULL));
    }
    
    Statement::~Statement()
    {
        if(s)
            sqlite3_finalize(s);
    }
    
    int Statement::step()
    {
        return !ok()?get_error():check(sqlite3_step(s));
    }
    
    bool Statement::step_row()
    {
        return step()==SQLITE_ROW;
    }
    
    int Statement::reset()
    {
        return !ok()?get_error():check(sqlite3_reset(s));
    }
    
    int Statement::clear()
    {
        return !ok()?get_error():check(sqlite3_clear_bindings(s));
    }
    
    int Statement::get_int(int col)
    {
        return !ok()?0:sqlite3_column_int(s,col);
    }
    
    String Statement::get_string(int col)
    {
        return !ok()?String():String((const char *)sqlite3_column_text(s,col));
    }
    
    bool Statement::is_null(int col)
    {
        return !ok()?true:sqlite3_column_type(s,col)==SQLITE_NULL;
    }
    
    int Statement::bind(int pos)
    {
        return !ok()?get_error():check(sqlite3_bind_null(s,pos));
    }

    int Statement::bind(int pos,int value)
    {
        return !ok()?get_error():check(sqlite3_bind_int(s,pos,value));
    }
    
    int Statement::bind(int pos,const char * value)
    {
        return !ok()?get_error():check(sqlite3_bind_text(s,pos,value,-1,SQLITE_TRANSIENT));
    }
        
    int Statement::bind(int pos,const String & value)
    {
        return !ok()?get_error():check(sqlite3_bind_text(s,pos,value.data(),value.length(),SQLITE_TRANSIENT));
    }
    
    //-------------------------------------------------------------------------
    
    Backup::Backup(const DB & to,const DB & from)
    :
        Error(to)
    {
        // If from has errors, they are transfered to us and ok() will return false
        
        check(from);
        
        if (ok())
        {
            sqlite3_backup * backup=sqlite3_backup_init(get_db(),"main",from.get_db(),"main");
            
            if(!backup)
            {
                // Checks the destination database for errors
                check();
            }
            else
            {
                check(sqlite3_backup_step(backup,-1));
                check(sqlite3_backup_finish(backup));
            }
        }
    }

} // namespace SQLite
