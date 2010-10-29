#ifndef _TRICKPLAY_APP_H
#define _TRICKPLAY_APP_H

#include "common.h"
#include "notify.h"
#include "network.h"
#include "util.h"
#include "event_group.h"
#include "debugger.h"

#define APP_METADATA_FILENAME   "app"

//-----------------------------------------------------------------------------
// Forward declarations

class SystemDatabase;

//-----------------------------------------------------------------------------
// A LuaStateProxy wraps around a lua state and gets invalidated when the state
// is closed - so that we can close the state and anyone that depends on it
// can be aware.

class LuaStateProxy : public RefCounted
{
public:

    lua_State * get_lua_state();

    bool is_valid();

    friend class App;

private:

    LuaStateProxy( lua_State * l );

    virtual ~LuaStateProxy();

    void invalidate();

    lua_State * L;
};

//-----------------------------------------------------------------------------

class App : public Notify
{
public:

    //.........................................................................
    // Structure to hold app actions

    struct Action
    {
        typedef std::map< String, Action > Map;

        Action()
        {}

        Action( const String & _description, const String & _uri, const String & _type )
        :
            description( _description ),
            uri( _uri ),
            type( _type )
        {}

        String description;
        String uri;
        String type;
    };

    //.........................................................................
    // Structure to hold app metadata

    struct Metadata
    {
        typedef std::list< Metadata > List;

        Metadata() : release( 0 ) {}

        String      path;
        String      id;
        String      name;
        int         release;
        String      version;
        String      description;
        String      author;
        String      copyright;

        Action::Map actions;
    };

    //.........................................................................
    // Launch information

    struct LaunchInfo
    {
        LaunchInfo()
        {}

        LaunchInfo( const String & _caller,
                const String & _action = String(),
                const char * _uri = NULL,
                const char * _type = NULL,
                const char * _parameters = NULL )
        :
            caller( _caller ),
            action( _action ),
            uri( _uri ? _uri : "" ),
            type( _type ? _type : "" ),
            parameters( _parameters ? _parameters : "" )
        {}

        String  caller;
        String  action;
        String  uri;
        String  type;
        String  parameters; // serialized Lua
    };

    //.........................................................................
    // Loads metadata for an app

    static bool load_metadata( const char * app_path, Metadata & metadata );

    static bool load_metadata_from_data( const gchar * data, Metadata & metadata );

    //.........................................................................
    // Scans application source directories for apps and adds them to the
    // database.

    static void scan_app_sources( SystemDatabase * sysdb,
                                  const char * app_sources,
                                  const char * installed_apps_root,
                                  bool force );

    //.........................................................................

    static String get_data_directory( TPContext * context, const String & app_id );

    //.........................................................................
    // Loads an app

    static App * load( TPContext * context, const Metadata & metadata, const LaunchInfo & launch );

    //.........................................................................
    // Get the app from the Lua state

    static App * get( lua_State * L );

    //.........................................................................

    ~App();

    //.........................................................................
    // Runs the app

    int run( const StringSet & allowed_names );

    //.........................................................................
    // Get the metadata

    const Metadata & get_metadata() const;

    //.........................................................................

    const String & get_id() const;

    //.........................................................................

    const LaunchInfo & get_launch_info() const;

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
    // Get the network for this app

    Network * get_network();

    //.........................................................................
    // Get the user agent

    String get_user_agent() const;

    //.........................................................................
    // Get the Lua state

    lua_State * get_lua_state();

    //.........................................................................

    LuaStateProxy * ref_lua_state_proxy();

    //.........................................................................
    // Get the event group for the app

    EventGroup * get_event_group();

    //.........................................................................
    // Processes paths to ensure they are either URIs or valid paths within the
    // app bundle. Also checks for links and handles custom schemes such as
    // 'localized:'
    //
    // May return NULL if the path is invalid.
    //
    // CALLER HAS TO FREE RESULT

    char * normalize_path( const gchar * path_or_uri, bool * is_uri = NULL, const StringSet & additional_uri_schemes = StringSet() );

    //.........................................................................
    // ONLY FOR THE EDITOR - apps should not do this

    bool change_app_path( const char * path );

    //.........................................................................
    // This returns the clutter actor GID for this app's screen

    guint32 get_screen_gid() const;

    //.........................................................................
    // This shows the app

    void animate_in();

    // This one hides it away. It does not depend on the app object after it
    // returns, so the app can be deleted

    void animate_out();

    //.........................................................................

    Debugger * get_debugger();


private:

    App( TPContext * context, const Metadata & metadata, const String & data_path, const LaunchInfo & launch );

    //.........................................................................
    // Drop the cookie jar

    void release_cookie_jar();

    //.........................................................................
    // Notification handler for profile switches

    static void profile_notification_handler( const char * subject, void * data );

    void profile_switch();

    //.........................................................................

    void secure_lua_state( const StringSet & allowed_names );

    //.........................................................................
    // Notification handler to forward everything to our listeners

    static void forward_notification_handler( const char * subject, void * data );

    //.........................................................................
    // Gets called in an idle source to animate the screen out

    static gboolean animate_out_callback( gpointer screen );

    //.........................................................................
    // The panic handler for Lua, it just prints the message and throws

    static int lua_panic_handler( lua_State * L );

    //.........................................................................

    TPContext       *       context;
    Metadata                metadata;
    String                  data_path;
    lua_State       *       L;
    LuaStateProxy     *     lua_state_proxy;
    String                  user_agent;
    Network        *        network;
    EventGroup       *      event_group;
    Network::CookieJar   *  cookie_jar;
    guint32                 screen_gid;
    LaunchInfo              launch;

#ifndef TP_PRODUCTION

    Debugger                debugger;

#endif
};



#endif // _TRICKPLAY_APP_H
