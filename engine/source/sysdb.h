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
            Profile() : id(0) {}
            
            int     id;
            String  name;
            String  pin;
        };
        
        static SystemDatabase * open(const char * path);
        
        ~SystemDatabase();
        
        bool flush();
        
        bool was_restored() const;
        
        //.....................................................................
        // Generic
        
        bool set(const char * key,int value);
        bool set(const char * key,const char * value);
        bool set(const char * key,const String & value);
        
        String get_string(const char * key,const char * def="");
        int get_int(const char * key,int def=0);
        
        //.....................................................................
        // Profile
        
        int create_profile(const String & name,const String & pin);
        Profile get_current_profile();
        Profile get_profile(int id);

        //.....................................................................
        // Apps
        
        int get_app_count();
        bool delete_all_apps();
        bool insert_app(const String & id,const String & path,int release,const String & version);
        String get_app_path(const String & id);

    private:
        
        bool insert_initial_data();
        
        SystemDatabase(SQLite::DB & d,const char * p,bool c);
        SystemDatabase(const SystemDatabase &) {}
        
        String      path;
        SQLite::DB  db;
        bool        dirty;
        bool        restored;
};


#endif