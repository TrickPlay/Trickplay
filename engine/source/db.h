#ifndef DB_H
#define DB_H

#include <string>
#include "sqlite3.h"

namespace SQLite
{
    typedef std::string String;
    
    class Error
    {
    public:
        
        // If the error is not ok, will throw a String exception
        
        void exception(const char * message=NULL) const;

        // Checks that there is no error
        
        inline bool ok() const { return error==SQLITE_OK; }
        
        // Returns the sqlite error code
        
        inline int get_error() const { return error; }
        
        // Returns the sqlite error message
        
        inline String get_msg() const { return msg; }
        
        inline sqlite3 * get_db() const { return db; }
            
    protected:
        
        Error();
        Error(sqlite3 * d);
        Error(const Error & other);
            
        int check();
        int check(int new_error);        
        int check(const Error & other);

        void reset_db(sqlite3 * d);
    
    private:
        
        sqlite3 *   db;
        int         error;
        String      msg;
    };
    
    //-------------------------------------------------------------------------
    
    class DB : public Error
    {
    public:
        
        DB();
        DB(const char * path);
        DB(const char * path,int flags);
        DB(DB & other);
        ~DB();
        
        int exec(const char * sql);
        
        int last_insert_rowid() const;

        sqlite3 * steal_db();        
    };
    
    //-------------------------------------------------------------------------

    class Statement : public Error
    {
    public:
        
        Statement(const DB & db,const char * sql);
        ~Statement();
        
        int step();
        bool step_row();
        
        int reset();
        
        int clear();
        
        int get_int(int col);
        
        String get_string(int col);
        
        bool is_null(int col);

        int bind(int pos);
        int bind(int pos,int value);
        int bind(int pos,const char * value);
        int bind(int pos,const String & value);
        
    private:
        
        Statement(const Statement&) {}
    
        sqlite3_stmt * s;
    };
    
    //-------------------------------------------------------------------------

    class Backup : public Error
    {
    public:
        
        Backup(const DB & to,const DB & from);
    
    private:
        
        Backup(const Backup&) {}
    };

} // namespace DB


#endif // DB_H