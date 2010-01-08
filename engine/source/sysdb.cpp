
#include <set>

#include "glib.h"
#include "glib/gstdio.h"

#include "sysdb.h"
#include "util.h"


//-----------------------------------------------------------------------------

static const char * schema_create=
    
    "create table generic( key TEXT PRIMARY KEY NOT NULL , value TEXT );"
    "create table profiles( id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "                       name TEXT,pin TEXT);"
;

//-----------------------------------------------------------------------------

inline int se(int c,const char * m)
{
    if (!(c==SQLITE_OK||c==SQLITE_DONE||c==SQLITE_ROW))
        throw String(m);
    return c;
}

SystemDatabase * SystemDatabase::open(const char * path)
{
    sqlite3 * db=NULL;

    try
    {
        // Create the in-memory database
        
        se(sqlite3_open(":memory:",&db),"Failed to create in-memory database");
        
        // Construct the filename for the on-disk db
        
        gchar * filename=g_build_filename(path,"system.db",NULL);
        Util::GFreeLater free_filename(filename);
        
        bool create=false;
        
        // See if the on-disk db exists
        
        if (!g_file_test(filename,G_FILE_TEST_EXISTS))
        {
            g_debug("System database does not exist on disk, will be created");
            create=true;
        }
        else
        {
            sqlite3 * sdb=NULL;
            
            // Try to open the on-disk db in read only mode
            
            if (sqlite3_open_v2(filename,&sdb,SQLITE_OPEN_READONLY,NULL)!=SQLITE_OK)
            {
                g_debug("System database exists on disk but could not be opened : %s",sqlite3_errmsg(sdb));
                create=true;
            }
            else
            {
                // Now do an integrity check by executing the "pragma integrity_check;" statement
                
                sqlite3_stmt * stmt=NULL;
                
                try
                {
                    se(sqlite3_prepare(sdb,"pragma integrity_check;",-1,&stmt,NULL),"Failed to prepare integrity check statement for system database");
                    
                    se(sqlite3_step(stmt),"Failed to get integrity check results for system database");
                        
                    if (strcmp((const char *)sqlite3_column_text(stmt,0),"ok"))
                        throw String("System database on disk is corrupt");
                }
                catch(const String & e)
                {
                    g_warning("%s : %s",e.c_str(),sqlite3_errmsg(sdb));
                    create=true;
                }
                
                if (stmt)
                    sqlite3_finalize(stmt);
                
                // If the integrity check succeeded, continue
                
                if (!create)
                {
                    sqlite3_backup * backup=sqlite3_backup_init(db,"main",sdb,"main");
                    
                    if (!backup)
                    {
                        g_debug("Failed to initialize backup from system database : %s",sqlite3_errmsg(db));
                        create=true;
                    }
                    else
                    {
                        if (sqlite3_backup_step(backup,-1)!=SQLITE_DONE)
                        {
                            g_debug("Failed to perform backup from system database : %s",sqlite3_errmsg(db));
                            create=true;
                        }
                        
                        if (sqlite3_backup_finish(backup)!=SQLITE_OK)
                        {
                            g_debug("Failed to finish backup from system database : %s",sqlite3_errmsg(db));
                            create=true;
                        }
                        
                        if (!create)
                        {
                            g_debug("SYSTEM DATABASE RESTORED");
                        }
                    }
                }
            }
            
            if (sdb)
                sqlite3_close(sdb);
        }
        
        if (create)
        {
            se(sqlite3_exec(db,schema_create,NULL,NULL,NULL),"Failed to initialize system database schema");
            g_debug("SYSTEM DATABASE CREATED");
        }

        // May throw String exceptions
        
        insert_initial_data(db);
        
        return new SystemDatabase(db,path);        
    }
    catch( const String & e)
    {
        g_warning("%s : %s",e.c_str(),sqlite3_errmsg(db));
        
        if(db)
        {
            sqlite3_close(db);
            db = NULL;
        }
        return NULL;        
    }
}

SystemDatabase::SystemDatabase(sqlite3 * d,const char * p)
:
    path(p),
    db(d)
{
    g_assert(db);
}

SystemDatabase::~SystemDatabase()
{
    flush();
    sqlite3_close(db);
}

bool SystemDatabase::flush()
{
    bool result=false;
    
    gchar * backup_filename=g_build_filename(path.c_str(),"system.db.XXXXXX",NULL);
    Util::GFreeLater free_backup_filename(backup_filename);
    
    sqlite3 * ddb=NULL;
    
    try
    {
        gint fd=g_mkstemp(backup_filename);
    
        if (fd==-1)
            throw String("Failed to create temporary file");
            
        close(fd);
        
        // Open the destination database
        
        se(sqlite3_open(backup_filename,&ddb),"Failed to open destination");

        // Backup into it
        
        sqlite3_backup * backup=sqlite3_backup_init(ddb,"main",db,"main");
        
        if (!backup)
            throw String("Failed to initialize backup");
            
        sqlite3_backup_step(backup,-1);
        
        se(sqlite3_backup_finish(backup),"Failed to finish backup");
        
        // Move the backup file name
        
        sqlite3_close(ddb);
        ddb=NULL;
        
        gchar * target_filename=g_build_filename(path.c_str(),"system.db",NULL);
        Util::GFreeLater free_target_filename(target_filename);
        
        if (g_rename(backup_filename,target_filename)!=0)
            throw String("Failed to rename backup file");
        
        g_debug("SYSTEM DATABASE FLUSHED");
        
        result=true;
    }
    catch(const String & e)
    {
        g_warning("Failed to flush system database : %s",e.c_str());
    }
    
    if (ddb)
        sqlite3_close(ddb);
        
    g_unlink(backup_filename);
    
    return result;
}

class SQLiteStatement
{
    public:
        
        SQLiteStatement() : stmt(NULL) {}
        
        ~SQLiteStatement()
        {
            if (stmt)
                sqlite3_finalize(stmt);
        }
        
        static int prepare(sqlite3 * db,const char * sql,SQLiteStatement & statement)
        {
            sqlite3_stmt * s=NULL;
            int result=sqlite3_prepare(db,sql,-1,&s,NULL);
            statement.set_stmt(s);
            return result;
        }
        
        int step() { return sqlite3_step(stmt);}
        
        int get_int(int col) { return sqlite3_column_int(stmt,col); }
        String get_string(int col) { return String((const char *)sqlite3_column_text(stmt,col));}
        
        int bind(int pos) { return sqlite3_bind_null(stmt,pos);}
        int bind(int pos,int value) { return sqlite3_bind_int(stmt,pos,value);}
        int bind(int pos,const char * value) { return sqlite3_bind_text(stmt,pos,value,-1,SQLITE_TRANSIENT);}
        int bind(int pos,const String & value) { return sqlite3_bind_text(stmt,pos,value.data(),value.length(),SQLITE_TRANSIENT);}
        
    private:
        
        void set_stmt(sqlite3_stmt * s)
        {
            if (stmt)
                sqlite3_finalize(stmt);
            stmt=s;
        }
        
        sqlite3_stmt * stmt;
};

void SystemDatabase::insert_initial_data(sqlite3 * db)
{
    // Collect a list of existing profile ids
    
    std::set<int> ids;

    {
        SQLiteStatement s;
    
        se(SQLiteStatement::prepare(db,"select id from profiles;",s),"Failed to get list of profile IDs");
        
        while(s.step()==SQLITE_ROW)
            ids.insert(s.get_int(0));
    }

    // There are no profiles, we must create one
    
    if (ids.size()==0)
    {
        {
            SQLiteStatement s;
            se(SQLiteStatement::prepare(db,"insert into profiles (id,name,pin) values (NULL,?1,?2);",s),"Failed to create profile");
            se(s.bind(1,TP_DB_FIRST_PROFILE_NAME),"Failed to bind profile name");
            se(s.bind(2,""),"Failed to bind profile pin");
            se(s.step(),"Failed to insert profile");
        }
        {        
            int id=sqlite3_last_insert_rowid(db);
            SQLiteStatement s;
            se(SQLiteStatement::prepare(db,"insert or replace into generic (key,value) values (?1,?2);",s),"Failed to set generic value");
            se(s.bind(1,TP_DB_CURRENT_PROFILE_ID),"Failed to bind generic key");
            se(s.bind(2,id),"Failed to bind generic value");
            se(s.step(),"Failed to insert generic value");
        }
    }
    
    // There are profiles, lets make sure the current profile id is set to one
    // of them
    
    else
    {
        int id=-1;
        {
            SQLiteStatement s;
            se(SQLiteStatement::prepare(db,"select value from generic where key=?1;",s),"Failed to get generic value");
            se(s.bind(1,TP_DB_CURRENT_PROFILE_ID),"Failed to bind generic key");
            if (se(s.step(),"Failed to step generic value")==SQLITE_ROW)
                id=s.get_int(0);
        }
        
        // There is no current profile id set, or the one that is set is not
        // in the list of ids
        
        if (id==-1 || ids.find(id)==ids.end())
        {
            SQLiteStatement s;
            se(SQLiteStatement::prepare(db,"insert or replace into generic (key,value) values (?1,?2);",s),"Failed to set generic value");
            se(s.bind(1,TP_DB_CURRENT_PROFILE_ID),"Failed to bind generic key");
            se(s.bind(2,*(ids.begin())),"Failed to bind generic value");
            se(s.step(),"Failed to insert generic value");            
        }
    }
}

void SystemDatabase::set(const char * key,int value)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"insert or replace into generic (key,value) values (?1,?2);",s),"Failed to set generic value");
    se(s.bind(1,key),"Failed to bind generic key");
    se(s.bind(2,value),"Failed to bind generic value");
    se(s.step(),"Failed to insert generic value");
}

void SystemDatabase::set(const char * key,const char * value)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"insert or replace into generic (key,value) values (?1,?2);",s),"Failed to set generic value");
    se(s.bind(1,key),"Failed to bind generic key");
    se(s.bind(2,value),"Failed to bind generic value");
    se(s.step(),"Failed to insert generic value");    
}

void SystemDatabase::set(const char * key,const String & value)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"insert or replace into generic (key,value) values (?1,?2);",s),"Failed to set generic value");
    se(s.bind(1,key),"Failed to bind generic key");
    se(s.bind(2,value),"Failed to bind generic value");
    se(s.step(),"Failed to insert generic value");    
}

String SystemDatabase::get_string(const char * key,const char * def)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"select value from generic where key=?1;",s),"Failed to get generic value");
    se(s.bind(1,key),"Failed to bind generic key");
    if (se(s.step(),"Failed to step generic value")==SQLITE_ROW)
        return s.get_string(0);
    return String(def);
}

int SystemDatabase::get_int(const char * key,int def)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"select value from generic where key=?1;",s),"Failed to get generic value");
    se(s.bind(1,key),"Failed to bind generic key");
    if (se(s.step(),"Failed to step generic value")==SQLITE_ROW)
        return s.get_int(0);
    return def;    
}


int SystemDatabase::create_profile(const String & name,const String & pin)
{
    SQLiteStatement s;
    se(SQLiteStatement::prepare(db,"insert into profiles (id,name,pin) values (NULL,?1,?2);",s),"Failed to create profile");
    se(s.bind(1,name),"Failed to bind profile name");
    se(s.bind(2,pin),"Failed to bind profile pin");
    se(s.step(),"Failed to insert profile");
    return sqlite3_last_insert_rowid(db);
}
