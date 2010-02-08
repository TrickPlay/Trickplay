#ifndef _TRICKPLAY_APP_H
#define _TRICKPLAY_APP_H

#include <string>
#include <set>

#include "lua.hpp"

#include "trickplay/trickplay.h"

#include "notify.h"
#include "network.h"

//-----------------------------------------------------------------------------
// Forward declarations

class SystemDatabase;

//-----------------------------------------------------------------------------

typedef std::string String;
typedef std::set<String> StringSet;

//-----------------------------------------------------------------------------

class App : public Notify
{
public:
    
    //.........................................................................
    // Structure to hold app metadata
    
    struct Metadata
    {
        Metadata() : release(0) {}
        
        String path;
        String id;
        String name;
        int release;
        String version;
        String description;
        String author;
        String copyright;
    };
    
    //.........................................................................
    // Loads metadata for an app
    
    static bool load_metadata(const char * app_path,Metadata & metadata);
    
    //.........................................................................
    // Scans application source directories for apps and adds them to the
    // database.
    
    static void scan_app_sources(SystemDatabase * sysdb,
                                 const char * app_sources,
                                 const char * installed_apps_root,
                                 bool force);
    
    //.........................................................................
    // Loads an app
    
    static App * load(TPContext * context,const Metadata & metadata);
    
    //.........................................................................
    // Get the app from the Lua state
    
    static App * get(lua_State * L);
    
    //.........................................................................
    
    ~App();
    
    //.........................................................................
    // Runs the app
    
    int run();

    //.........................................................................
    // Get the metadata
    
    const Metadata & get_metadata() const;
    
    //.........................................................................
    // Get the context
    
    TPContext * get_context();

    //.........................................................................
    // Get the app's data path
    
    String get_data_path() const;

    //.........................................................................
    // Get the current profile id (from the context)
    
    int get_profile_id() const;
    
    //.........................................................................
    // Get the cookie jar.
    
    Network::CookieJar * get_cookie_jar();

    //.........................................................................
    // Get the user agent
    
    const String & get_user_agent() const;
    
    //.........................................................................
    // Get the Lua state
    
    lua_State * get_lua_state();
    
    //.........................................................................
    // Processes paths to ensure they are either URIs or valid paths within the
    // app bundle. Also checks for links and handles custom schemes such as
    // 'localized:'
    //
    // May return NULL if the path is invalid.
    //
    // CALLER HAS TO FREE RESULT
 
    char * normalize_path(const gchar * path_or_uri,bool * is_uri=NULL,const StringSet & additional_uri_schemes=StringSet());

private:
    
    App(TPContext * context,const Metadata & metadata,const char * data_path);
    
    App()
    {}
    
    App(const App &)
    {}

    //.........................................................................
    // Drop the cookie jar
    
    void release_cookie_jar();
    
    //.........................................................................
    // Notification handler for profile switches

    static void profile_notification_handler(const char * subject,void * data);
    
    void profile_switch();
    
    //.........................................................................
    // Notification handler to forward everything to our listeners
    
    static void forward_notification_handler(const char * subject,void * data);
    
    
    //.........................................................................

    TPContext *             context;
    Metadata                metadata;
    String                  data_path;
    lua_State *             L;
    Network::CookieJar *    cookie_jar;
    String                  user_agent;
};



#endif // _TRICKPLAY_APP_H