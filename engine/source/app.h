#ifndef _TRICKPLAY_APP_H
#define _TRICKPLAY_APP_H

#include "common.h"
#include "notify.h"
#include "network.h"
#include "util.h"
//-----------------------------------------------------------------------------
// Forward declarations

class SystemDatabase;

//-----------------------------------------------------------------------------
// An event group lets us track idle sources, so we can neuter them when the
// app is closed (so that they won't fire once the lua state is gone).

class EventGroup : public RefCounted
{
public:

    EventGroup();

    guint add_idle( gint priority, GSourceFunc function, gpointer data, GDestroyNotify notify );

    void cancel( guint id );

    void cancel_all();

    void remove( guint id );

protected:

    ~EventGroup();

private:

    class IdleClosure;

    GMutex     *    mutex;
    std::set<guint> source_ids;
};

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
    // Structure to hold app metadata

    struct Metadata
    {
        Metadata() : release( 0 ) {}

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

    static bool load_metadata( const char * app_path, Metadata & metadata );

    //.........................................................................
    // Scans application source directories for apps and adds them to the
    // database.

    static void scan_app_sources( SystemDatabase * sysdb,
                                  const char * app_sources,
                                  const char * installed_apps_root,
                                  bool force );

    //.........................................................................
    // Loads an app

    static App * load( TPContext * context, const Metadata & metadata );

    //.........................................................................
    // Get the app from the Lua state

    static App * get( lua_State * L );

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
    // This returns the clutter actor GID for this app's screen

    guint32 get_screen_gid() const;

    //.........................................................................
    // This shows the app

    void animate_in();

    // This one hides it away. It does not depend on the app object after it
    // returns, so the app can be deleted

    void animate_out();

private:

    App( TPContext * context, const Metadata & metadata, const char * data_path );

    App()
    {}

    App( const App & )
    {}

    //.........................................................................
    // Drop the cookie jar

    void release_cookie_jar();

    //.........................................................................
    // Notification handler for profile switches

    static void profile_notification_handler( const char * subject, void * data );

    void profile_switch();

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
};



#endif // _TRICKPLAY_APP_H
