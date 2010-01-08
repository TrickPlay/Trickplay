#ifndef SYSDB_H
#define SYSDB_H

#include <string>

#include "db.h"

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
        
        bool set(const char * key,int value);
        bool set(const char * key,const char * value);
        bool set(const char * key,const String & value);
        
        String get_string(const char * key,const char * def="");
        int get_int(const char * key,int def=0);

    private:
        
        bool insert_initial_data();
        
        SystemDatabase(SQLite::DB & d,const char * p);
        SystemDatabase(const SystemDatabase &) {}
        
        String      path;
        SQLite::DB  db;
        bool        dirty;
};


#endif