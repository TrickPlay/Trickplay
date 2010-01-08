#ifndef SYSDB_H
#define SYSDB_H

#include <string>

#include "sqlite3.h"

typedef std::string String;

#define TP_DB_FIRST_PROFILE_NAME    "TrickPlay User"

#define TP_DB_CURRENT_PROFILE_ID    "profile.current"

class SystemDatabase
{
    public:
        
        struct Profile
        {
            int     id;
            String  name;
            String  pin;
        };
        
        static SystemDatabase * open(const char * path);
        
        ~SystemDatabase();
        
        bool flush();
        
        int create_profile(const String & name,const String & pin);
        
        void set(const char * key,int value);
        void set(const char * key,const char * value);
        void set(const char * key,const String & value);
        
        String get_string(const char * key,const char * def="");
        int get_int(const char * key,int def=0);

    private:
        
        static void insert_initial_data(sqlite3 * db);
        
        SystemDatabase(sqlite3 * d,const char * p);
        SystemDatabase() {}
        SystemDatabase(const SystemDatabase &) {}
        
        String      path;
        sqlite3 *   db; 
};


#endif