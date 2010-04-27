
#include "clutter/clutter.h"

#include "app.h"
#include "sysdb.h"
#include "util.h"
#include "context.h"
#include "network.h"
#include "lb.h"
#include "profiler.h"

//-----------------------------------------------------------------------------
#define APP_METADATA_FILENAME   "app"
#define APP_TABLE_NAME          "app"
#define APP_FIELD_ID            "id"
#define APP_FIELD_NAME          "name"
#define APP_FIELD_DESCRIPTION   "description"
#define APP_FIELD_AUTHOR        "author"
#define APP_FIELD_COPYRIGHT     "copyright"
#define APP_FIELD_RELEASE       "release"
#define APP_FIELD_VERSION       "version"

//-----------------------------------------------------------------------------
// Bindings
//-----------------------------------------------------------------------------

extern void luaopen_clutter_actor( lua_State * L );
extern void luaopen_clutter_container( lua_State * L );
extern void luaopen_clutter_screen( lua_State * L );
extern void luaopen_clutter_text( lua_State * L );
extern void luaopen_clutter_rectangle( lua_State * L );
extern void luaopen_clutter_clone( lua_State * L );
extern void luaopen_clutter_group( lua_State * L );
extern void luaopen_clutter_image( lua_State * L );
extern void luaopen_clutter_canvas( lua_State * L );

extern void luaopen_clutter_timeline( lua_State * L );
extern void luaopen_clutter_alpha( lua_State * L );
extern void luaopen_clutter_interval( lua_State * L );

extern void luaopen_idle( lua_State * L );
extern void luaopen_timer( lua_State * L );
extern void luaopen_url_request( lua_State * L );
extern void luaopen_storage( lua_State * L );
extern void luaopen_globals( lua_State * L );
extern void luaopen_app( lua_State * L );
extern void luaopen_system( lua_State * L );
extern void luaopen_settings( lua_State * L );
extern void luaopen_profile( lua_State * L );
extern void luaopen_xml( lua_State * L );
extern void luaopen_controllers_module( lua_State * L );
extern void luaopen_mediaplayer_module( lua_State * L );
extern void luaopen_stopwatch( lua_State * L );

extern void luaopen_restricted( lua_State * L );
extern void luaopen_apps( lua_State * L );

// This one comes from keys.cpp and is not generated by lb

extern void luaopen_keys( lua_State * L );

//=============================================================================

class EventGroup::IdleClosure
{
public:

    static guint add_idle( EventGroup * eg, gint priority, GSourceFunc f, gpointer d, GDestroyNotify dn )
    {
        return g_idle_add_full( priority, idle_callback, new IdleClosure( eg, f, d, dn ), destroy_callback );
    }

private:

    IdleClosure( EventGroup * eg, GSourceFunc f, gpointer d, GDestroyNotify dn )
        :
        event_group( eg ),
        function( f ),
        data( d ),
        destroy_notify( dn )
    {
        event_group->ref();
    }

    ~IdleClosure()
    {
        event_group->unref();
    }

    static gboolean idle_callback( gpointer ic )
    {
        IdleClosure * closure = ( IdleClosure * )ic;

        GSource * source = g_main_current_source();

        guint id = g_source_get_id( source );

        if ( !g_source_is_destroyed( source ) )
        {
            closure->function( closure->data );
        }
        else
        {
            g_debug( "NOT FIRING SOURCE %d", id );
        }

        closure->event_group->remove( id );

        return FALSE;
    }

    static void destroy_callback( gpointer ic )
    {
        IdleClosure * closure = ( IdleClosure * )ic;

        if ( closure->destroy_notify )
        {
            closure->destroy_notify( closure->data );
        }

        delete closure;
    }

private:

    EventGroup *	event_group;
    GSourceFunc		function;
    gpointer		data;
    GDestroyNotify	destroy_notify;
};

EventGroup::EventGroup()
    :
    mutex( g_mutex_new() )
{
}

EventGroup::~EventGroup()
{
    cancel_all();
    g_mutex_free( mutex );
}

guint EventGroup::add_idle( gint priority, GSourceFunc function, gpointer data, GDestroyNotify notify )
{
    Util::GMutexLock lock( mutex );
    g_assert( function );

    guint id = IdleClosure::add_idle( this, priority, function, data, notify );

    source_ids.insert( id );

    return id;
}

void EventGroup::cancel( guint id )
{
    Util::GMutexLock lock( mutex );
    std::set<guint>::iterator it = source_ids.find( id );

    if ( it == source_ids.end() )
    {
        g_debug( "CANNOT CANCEL SOURCE %d", id );
    }
    else
    {
        g_debug( "CANCELLING SOURCE %d", id );

        source_ids.erase( it );

        g_source_remove( id );
    }
}

void EventGroup::cancel_all()
{
    Util::GMutexLock lock( mutex );

    if ( !source_ids.empty() )
    {
        g_debug( "CANCELLING %" G_GSIZE_FORMAT " SOURCE(S)", source_ids.size() );

        for ( std::set<guint>::iterator it = source_ids.begin(); it != source_ids.end(); ++it )
        {
            g_source_remove( ( *it ) );
        }

        source_ids.clear();
    }
}

void EventGroup::remove( guint id )
{
    Util::GMutexLock lock( mutex );
    source_ids.erase( id );
}

//=============================================================================

LuaStateProxy::LuaStateProxy( lua_State * l )
    :
    L( l )
{
    g_debug( "CREATED LSP %p", this );
}

LuaStateProxy::~LuaStateProxy()
{
    g_debug( "DESTROYED LSP %p", this );
}

void LuaStateProxy::invalidate()
{
    L = NULL;
    g_debug( "INVALIDATED LSP %p", this );
}

lua_State * LuaStateProxy::get_lua_state()
{
    return L;
}

bool LuaStateProxy::is_valid()
{
    return L != NULL;
}

//=============================================================================

bool App::load_metadata( const char * app_path, App::Metadata & md )
{
    g_assert( app_path );

    // To clear the one passed in

    md = Metadata();

    md.path = app_path;

    // Open a state with no libraries - not even the base one

    lua_State * L = lua_open();

    g_assert( L );

    try
    {
        // Build the path to the metadata file and test that it exists

        gchar * path = g_build_filename( app_path, APP_METADATA_FILENAME, NULL );

        Util::GFreeLater free_path( path );

        if ( !g_file_test( path, G_FILE_TEST_IS_REGULAR ) )
        {
            throw String( "App metadata file does not exist" );
        }

        // Now, run it with Lua

        int result = luaL_dofile( L, path );

        // Check that it ran OK

        if ( result )
        {
            throw String( "Failed to parse app metadata : " ) + lua_tostring( L, -1 );
        }

        // Look for the 'app' global

        lua_getglobal( L, APP_TABLE_NAME );
        if ( !lua_istable( L, -1 ) )
        {
            throw String( "Missing or invalid app table" );
        }

        // Look for the id
        lua_getfield( L, -1, APP_FIELD_ID );
        if ( lua_type( L, -1 ) != LUA_TSTRING )
        {
            throw String( "Missing or invalid app id" );
        }

        // Validate the id

        size_t len;
        const char * s = lua_tolstring( L, -1, &len );

        if ( len > 64 )
        {
            throw String( "App id is too long" );
        }

        static const char * valid_id_characters = "_-.";

        for ( const char * c = s; *c; ++c )
        {
            if ( !g_ascii_isalnum( *c ) )
            {
                if ( !strchr( valid_id_characters, *c ) )
                {
                    throw String( "App id contains invalid characters" );
                }
            }
        }

        if ( strstr( s, ".." ) )
        {
            throw String( "App id contains two dots" );
        }

        if ( strstr( s, "--" ) )
        {
            throw String( "App id contains two dashes" );
        }

        if ( strstr( s, "__" ) )
        {
            throw String( "App id contains two underscores" );
        }


        // Store it
        md.id = s;
        lua_pop( L, 1 );

        // Look for the other fields
        lua_getfield( L, -1, APP_FIELD_NAME );
        if ( lua_type( L, -1 ) != LUA_TSTRING )
        {
            throw String( "Missing or invalid app name" );
        }
        md.name = lua_tostring( L, -1 );
        lua_pop( L, 1 );

        lua_getfield( L, -1, APP_FIELD_RELEASE );
        if ( lua_tointeger( L, -1 ) <= 0 )
        {
            throw String( "Missing or invalid app release, it must be a number greater than 0" );
        }
        md.release = lua_tointeger( L, -1 );
        lua_pop( L, 1 );

        lua_getfield( L, -1, APP_FIELD_VERSION );
        if ( lua_type( L, -1 ) != LUA_TSTRING )
        {
            throw String( "Missing or invalid app version" );
        }
        md.version = lua_tostring( L, -1 );
        lua_pop( L, 1 );

        lua_getfield( L, -1, APP_FIELD_DESCRIPTION );
        if ( lua_isstring( L, -1 ) )
        {
            md.description = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );

        lua_getfield( L, -1, APP_FIELD_AUTHOR );
        if ( lua_isstring( L, -1 ) )
        {
            md.author = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );

        lua_getfield( L, -1, APP_FIELD_COPYRIGHT );
        if ( lua_isstring( L, -1 ) )
        {
            md.copyright = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );

        lua_close( L );
        return true;
    }
    catch ( const String & e )
    {
        lua_close( L );
        g_warning( "Failed to load app metadata from '%s' : %s" , app_path , e.c_str() );
        return false;
    }
}



//-----------------------------------------------------------------------------

void App::scan_app_sources( SystemDatabase * sysdb, const char * app_sources, const char * installed_apps_root, bool force )
{
    // If the scan is not forced and we already have apps in the database, bail

    if ( !force && sysdb->get_app_count() > 0 )
    {
        return;
    }

    // Otherwise, let's do the scan

    if ( !app_sources )
    {
        g_warning( "NO APP SOURCES TO SCAN" );
        return;
    }

    std::map< String, std::list<Metadata> > apps;

    //.........................................................................
    // First scan app sources

    gchar ** paths = g_strsplit( app_sources, ";", 0 );

    for ( gchar ** p = paths; *p; ++p )
    {
        gchar * path = g_strstrip( *p );

        GDir * dir = g_dir_open( path, 0, NULL );

        if ( !dir )
        {
            g_warning( "FAILED TO SCAN APP SOURCE %s", path );
        }
        else
        {
            while ( const gchar * base = g_dir_read_name( dir ) )
            {
                gchar * md_file_name = g_build_filename( path, base, "app", NULL );
                Util::GFreeLater free_md_file_name( md_file_name );

                if ( !g_file_test( md_file_name, G_FILE_TEST_IS_REGULAR ) )
                {
                    continue;
                }

                gchar * app_path = g_build_filename( path, base, NULL );
                Util::GFreeLater free_app_path( app_path );

                Metadata md;

                if ( load_metadata( app_path, md ) )
                {
                    g_info( "SCAN FOUND %s (%s/%d) @ %s",
                            md.id.c_str(),
                            md.version.c_str(),
                            md.release,
                            app_path );

                    apps[md.id].push_back( md );
                }
            }

            g_dir_close( dir );
        }
    }

    g_strfreev( paths );

    //.........................................................................
    // Now scan the data directory - where apps may be installed

    if ( g_file_test( installed_apps_root, G_FILE_TEST_EXISTS ) )
    {
        GDir * dir = g_dir_open( installed_apps_root, 0, NULL );

        if ( !dir )
        {
            g_warning( "FAILED TO SCAN APP SOURCE %s", installed_apps_root );
        }
        else
        {
            while ( const gchar * base = g_dir_read_name( dir ) )
            {
                gchar * app_path = g_build_filename( installed_apps_root, base, "source", NULL );
                Util::GFreeLater free_app_path( app_path );

                gchar * md_file_name = g_build_filename( app_path, "app", NULL );
                Util::GFreeLater free_md_file_name( md_file_name );

                if ( !g_file_test( md_file_name, G_FILE_TEST_IS_REGULAR ) )
                {
                    continue;
                }

                Metadata md;

                if ( load_metadata( app_path, md ) )
                {
                    g_info( "SCAN FOUND %s (%s/%d) @ %s",
                            md.id.c_str(),
                            md.version.c_str(),
                            md.release,
                            app_path );

                    apps[md.id].push_back( md );
                }
            }

            g_dir_close( dir );
        }
    }

    if ( !apps.empty() )
    {
        //.........................................................................
        // Now we have a map of app ids - each entry has a list of versions found

        // We delete all the apps from the database

        sysdb->delete_all_apps();

        std::map< String, std::list<Metadata> >::iterator it = apps.begin();

        for ( ; it != apps.end(); ++it )
        {
            if ( it->second.size() > 1 )
            {
                // We move the list to a new list and clear the original

                const std::list<Metadata> versions( it->second );

                it->second.clear();

                // Now, we point an iterator to the first one in the list. If one of the
                // others has a greater release number, we point the iterator at it.
                //
                // When we are done, this iterator will point to the app metadata
                // with the greatest release number.

                std::list<Metadata>::const_iterator latest = versions.begin();

                for ( std::list<Metadata>::const_iterator vit = ++( versions.begin() ); vit != versions.end(); ++vit )
                {
                    if ( vit->release > latest->release )
                    {
                        latest = vit;
                    }
                }

                // Finally, we put the one pointed to by the iterator back in the map's list

                it->second.push_back( *latest );
            }

            const Metadata & md = it->second.front();

            sysdb->insert_app( md.id, md.path, md.release, md.version );

            g_info( "ADDING %s (%s/%d) @ %s",
                    md.id.c_str(),
                    md.version.c_str(),
                    md.release,
                    md.path.c_str() );
        }
    }
}


//-----------------------------------------------------------------------------

String App::get_data_directory( TPContext * context, const String & app_id )
{
    g_assert( context );

    String result;

    // Get the data directory ready

    gchar * id_hash = g_compute_checksum_for_string( G_CHECKSUM_SHA1, app_id.c_str(), -1 );

    Util::GFreeLater free_id_hash( id_hash );

    gchar * app_data_path = g_build_filename( context->get( TP_DATA_PATH ), "apps", id_hash, NULL );

    Util::GFreeLater free_app_data_path( app_data_path );

    if ( !g_file_test( app_data_path, G_FILE_TEST_EXISTS ) )
    {
        if ( g_mkdir_with_parents( app_data_path, 0700 ) != 0 )
        {
            g_warning( "FAILED TO CREATE APP DATA PATH '%s'", app_data_path );
        }
        else
        {
            result = app_data_path;
        }
    }

    return result;
}


//-----------------------------------------------------------------------------

App * App::load( TPContext * context, const App::Metadata & md )
{
    String app_data_path = get_data_directory( context, md.id );

    if ( app_data_path.empty() )
    {
        return NULL;
    }

    return new App( context, md, app_data_path );
}

//-----------------------------------------------------------------------------

int App::lua_panic_handler( lua_State * L )
{
    g_critical( "%s", String( 60, '=' ).c_str() );
    g_critical( "LUA PANIC : %s", lua_tostring( L, -1 ) );
    g_critical( "%s", String( 60, '=' ).c_str() );

    throw LUA_ERRRUN;
}

//-----------------------------------------------------------------------------

App::App( TPContext * c, const App::Metadata & md, const String & dp )
    :
    context( c ),
    metadata( md ),
    data_path( dp ),
    L( NULL ),
    lua_state_proxy( NULL ),
    network( NULL ),
    event_group( new EventGroup() ),
    cookie_jar( NULL ),
    screen_gid( 0 )
{

    // Create the user agent

    user_agent = Network::format_user_agent(
                     context->get( TP_SYSTEM_LANGUAGE ),
                     context->get( TP_SYSTEM_COUNTRY ),
                     md.id.c_str(),
                     md.release,
                     context->get( TP_SYSTEM_NAME ),
                     context->get( TP_SYSTEM_VERSION ) );

    // Create the network

    network = new Network( event_group );

    // Register to get all notifications

    context->add_notification_handler( "*", forward_notification_handler, this );

    // Register for profile switch

    context->add_notification_handler( TP_NOTIFICATION_PROFILE_CHANGE, profile_notification_handler, this );

    // Create the Lua state

    L = lua_open();
    g_assert( L );

    // Install panic handler that throws an exception

    lua_atpanic( L, lua_panic_handler );

    // Create the lua state proxy

    lua_state_proxy = new LuaStateProxy( L );

    // Put a pointer to us in Lua so bindings can get to it

    lua_pushstring( L, "tp_app" );
    lua_pushlightuserdata( L, this );
    lua_rawset( L, LUA_REGISTRYINDEX );
}

#if 0
void debug_hook( lua_State * L, lua_Debug * ar )
{
    printf( "DEBUG: %d\n", ar->event );

    switch ( ar->event )
    {
        case LUA_HOOKCALL:
        {
            lua_getstack( L, 0, ar );
            lua_getinfo( L, "nsl", ar );
            printf( "  CALL\n" );
            break;
        }
    }

    if ( ar->event == LUA_HOOKLINE )
    {
        lua_getinfo( L, "nsl", ar );
        printf( "  LINE: %d : %s : %s\n", ar->currentline, ar->short_src, ar->source );
    }
}
#endif

//-----------------------------------------------------------------------------

int App::run( const StringSet & allowed_names )
{
    PROFILER( "App::run" );

    int result = TP_RUN_OK;

    // Get the screen ready for the app

    ClutterActor * stage = clutter_stage_get_default();
    g_assert( stage );

    ClutterActor * screen = clutter_group_new();
    g_assert( screen );

    gfloat width;
    gfloat height;

    clutter_actor_get_size( stage, &width, &height );

    clutter_actor_set_position( screen, 0, 0 );
    clutter_actor_set_size( screen, width, height );

    screen_gid = clutter_actor_get_gid( screen );

    secure_lua_state( allowed_names );

    // Open our stuff
    luaopen_clutter_actor( L );
    luaopen_clutter_container( L );
    luaopen_clutter_screen( L );
    luaopen_clutter_text( L );
    luaopen_clutter_rectangle( L );
    luaopen_clutter_clone( L );
    luaopen_clutter_group( L );
    luaopen_clutter_image( L );
    luaopen_clutter_canvas( L );

    luaopen_clutter_timeline( L );
    luaopen_clutter_alpha( L );
    luaopen_clutter_interval( L );

    luaopen_idle( L );
    luaopen_timer( L );
    luaopen_url_request( L );
    luaopen_storage( L );
    luaopen_globals( L );
    luaopen_app( L );
    luaopen_system( L );
    luaopen_settings( L );
    luaopen_profile( L );
    luaopen_xml( L );
    luaopen_controllers_module( L );
    luaopen_keys( L );
    luaopen_stopwatch( L );

    luaopen_mediaplayer_module( L );

    // TODO
    // This should not be opened for all apps - only trusted ones. Since we
    // don't have a mechanism for determining trustworthiness yet...

    luaopen_restricted( L );

    // TODO
    // This one should only be opened for the launcher and the store apps

    luaopen_apps( L );

    // TODO
    // DEBUG HOOK
//    lua_sethook(L,debug_hook,LUA_MASKCALL|LUA_MASKRET|LUA_MASKLINE|LUA_MASKCOUNT,1);

    // Run the script
    gchar * main_path = g_build_filename( metadata.path.c_str(), "main.lua", NULL );
    Util::GFreeLater free_main_path( main_path );

    if ( luaL_dofile( L, main_path ) )
    {
        g_critical( "%s", String( 60, '=' ).c_str() );
        g_critical( "LUA ERROR : %s", lua_tostring( L, -1 ) );
        g_critical( "%s", String( 60, '=' ).c_str() );

        result = TP_RUN_APP_ERROR;

        g_object_unref( G_OBJECT( screen ) );

        screen_gid = 0;
    }
    else
    {
        // Make it small

        clutter_actor_set_scale( screen, 0, 0 );

        // By adding it to the stage, the ref is sunk, so we don't need
        // to unref it here.

        clutter_container_add_actor( CLUTTER_CONTAINER( stage ), screen );
    }

    return result;
}

//-----------------------------------------------------------------------------

App::~App()
{
    context->remove_notification_handler( "*", forward_notification_handler, this );
    context->remove_notification_handler( TP_NOTIFICATION_PROFILE_CHANGE, profile_notification_handler, this );

    // Stops the network thread and waits

    delete network;

    // Cancels all outstanding idle callbacks

    event_group->cancel_all();

    // Release the cookie jar

    release_cookie_jar();

    // Close Lua

    lua_close( L );

    // Invalidate and release the lua state proxy

    lua_state_proxy->invalidate();

    lua_state_proxy->unref();

    // Release the event group

    event_group->unref();
}

//-----------------------------------------------------------------------------

void App::secure_lua_state( const StringSet & allowed_names )
{
    //.........................................................................
    // Open standard libs

    // We do NOT open these, as they pose security risks

    //      {LUA_IOLIBNAME, luaopen_io},
    //      {LUA_DBLIBNAME, luaopen_debug},

    const luaL_Reg lualibs[] =
    {
        { "", luaopen_base },
        { LUA_TABLIBNAME, luaopen_table },
        { LUA_STRLIBNAME, luaopen_string },
        { LUA_MATHLIBNAME, luaopen_math },
        { LUA_OSLIBNAME, luaopen_os },
        { LUA_LOADLIBNAME, luaopen_package },
        { NULL, NULL }
    };

    for ( const luaL_Reg * lib = lualibs; lib->func; ++lib )
    {
        lua_pushcfunction( L, lib->func );
        lua_pushstring( L, lib->name );
        lua_call( L, 1, 0 );
    }

    //.........................................................................
    // Now, we have to nuke some 'os' functions

    lua_getglobal( L, "os" );

    const char * os_nuke[] =
    {
        "execute",
        "exit",
        "getenv",
        "remove",
        "rename",
        "setlocale",
        "tmpname",
        NULL
    };

    for( const char * * name = os_nuke; * name; ++name )
    {
        lua_pushstring( L, * name );
        lua_pushnil( L );
        lua_rawset( L, -3 );
    }

    lua_pop( L, 1 );

    //.........................................................................
    // Nuke package stuff

    lua_getglobal( L, "package" );

    const char * package_nuke[] =
    {
        "cpath",
        "loaders",
        "loadlib",
        "path",
        "preload",
        NULL
    };

    for( const char * * name = package_nuke; * name; ++name )
    {
        lua_pushstring( L, * name );
        lua_pushnil( L );
        lua_rawset( L, -3 );
    }

#if 0
    // Set "loaders" to an empty table
    // We have to do this if we want 'require' to work

    lua_pushstring( L, "loaders" );
    lua_newtable( L );
    lua_rawset( L, -3 );

#endif

    lua_pop( L, 1 );

    //.........................................................................
    // Nuke globals

    const char * global_nuke[] =
    {
        "require",
        NULL
    };

    for( const char * * name = global_nuke; * name; ++name )
    {
        lua_pushnil( L );
        lua_setglobal( L, * name );
    }

    //.........................................................................

    for ( StringSet::const_iterator it = allowed_names.begin(); it != allowed_names.end(); ++it )
    {
        lb_allow( L, it->c_str() );
    }

}

//-----------------------------------------------------------------------------

App * App::get( lua_State * L )
{
    g_assert( L );
    lua_pushstring( L, "tp_app" );
    lua_rawget( L, LUA_REGISTRYINDEX );
    App * result = ( App * )lua_touserdata( L, -1 );
    lua_pop( L, 1 );
    g_assert( result );
    return result;
}

//-----------------------------------------------------------------------------

TPContext * App::get_context()
{
    return context;
}

//-----------------------------------------------------------------------------


String App::get_data_path() const
{
    return data_path;
}

//-----------------------------------------------------------------------------

int App::get_profile_id() const
{
    return context->get_int( PROFILE_ID );
}

//-----------------------------------------------------------------------------

const App::Metadata & App::get_metadata() const
{
    return metadata;
}

//-----------------------------------------------------------------------------

const String & App::get_id() const
{
    return metadata.id;
}

//-----------------------------------------------------------------------------

void App::release_cookie_jar()
{
    // Will unref it and set it to NULL
    cookie_jar = Network::cookie_jar_unref( cookie_jar );
}

//-----------------------------------------------------------------------------

Network::CookieJar * App::get_cookie_jar()
{
    if ( !cookie_jar )
    {
        gchar * name = g_strdup_printf( "cookies-%d.txt", get_profile_id() );
        Util::GFreeLater free_name( name );

        gchar * file_name = g_build_filename( data_path.c_str(), name, NULL );
        Util::GFreeLater free_file_name( file_name );

        cookie_jar = Network::cookie_jar_new( file_name );
    }

    return cookie_jar;
}

//-----------------------------------------------------------------------------

Network * App::get_network()
{
    return network;
}

//-----------------------------------------------------------------------------

String App::get_user_agent() const
{
    return user_agent;
}

//-----------------------------------------------------------------------------
// This one forwards all notifications from the context to our listeners

void App::forward_notification_handler( const char * subject, void * data )
{
    ( ( App * )data )->notify( subject );
}

//-----------------------------------------------------------------------------
// Notification handler for profile switches

void App::profile_notification_handler( const char * subject, void * data )
{
    ( ( App * )data )->profile_switch();
}

//-----------------------------------------------------------------------------

void App::profile_switch()
{
    release_cookie_jar();
}

//-----------------------------------------------------------------------------

lua_State * App::get_lua_state()
{
    return L;
}

//-----------------------------------------------------------------------------

LuaStateProxy * App::ref_lua_state_proxy()
{
    lua_state_proxy->ref();

    return lua_state_proxy;
}

//-----------------------------------------------------------------------------

EventGroup * App::get_event_group()
{
    return event_group;
}

//-----------------------------------------------------------------------------

char * App::normalize_path( const gchar * path_or_uri, bool * is_uri, const StringSet & additional_uri_schemes )
{
    bool it_is_a_uri = false;

    const char * app_path = metadata.path.c_str();

    char * result = NULL;

    // First, see if there is a scheme

    gchar ** parts = g_strsplit( path_or_uri, ":", 2 );

    guint count = g_strv_length( parts );

    if ( count == 0 )
    {
        // What do we do? This is clearly not a good path

        g_critical( "INVALID EMPTY PATH OR URI" );
    }

    else if ( count == 1 )
    {
        // There is no scheme, so this is a simple path

        result = Util::rebase_path( app_path, path_or_uri );
    }
    else
    {
        // There is a scheme

        gchar * scheme = parts[0];
        gchar * uri = parts[1];

        // The scheme is only one character long - assume it
        // is a windows drive letter

        if ( strlen( scheme ) == 1 )
        {
            result = Util::rebase_path( app_path, path_or_uri );
        }
        else
        {
            // If it is HTTP or HTTPS, we just return the whole thing passed in

            if ( !strcmp( scheme, "http" ) || !strcmp( scheme, "https" ) )
            {
                it_is_a_uri = true;

                result = g_strdup( path_or_uri );
            }

            // If it is one of the additional schemes passed in, do the same

            else if ( additional_uri_schemes.find( scheme ) != additional_uri_schemes.end() )
            {
                it_is_a_uri = true;

                result = g_strdup( path_or_uri );
            }

            // Localized file

            else if ( !strcmp( scheme, "localized" ) )
            {
                const char * language = context->get( TP_SYSTEM_LANGUAGE, TP_SYSTEM_LANGUAGE_DEFAULT );
                const char * country = context->get( TP_SYSTEM_COUNTRY, TP_SYSTEM_COUNTRY_DEFAULT );

                gchar * try_path = NULL;

                // Try <app>/localized/en/US/<path>

                try_path = g_build_filename( app_path, "localized", language, country, NULL );

                result = Util::rebase_path( try_path, uri );

                g_free( try_path );

                if ( !g_file_test( result, G_FILE_TEST_EXISTS ) )
                {
                    // Try <app>/localized/en/<path>

                    g_free( result );

                    try_path = g_build_filename( app_path, "localized", language, NULL );

                    result = Util::rebase_path( try_path, uri );

                    g_free( try_path );

                    if ( !g_file_test( result, G_FILE_TEST_EXISTS ) )
                    {
                        // Try <app>/localized/<path>

                        g_free( result );

                        try_path = g_build_filename( app_path, "localized", NULL );

                        result = Util::rebase_path( try_path, uri );

                        g_free( try_path );

                        if ( !g_file_test( result, G_FILE_TEST_EXISTS ) )
                        {
                            // End up with <app>/<path>

                            g_free( result );

                            result = Util::rebase_path( app_path, uri );
                        }
                    }
                }
            }
            else
            {
                g_critical( "INVALID SCHEME IN '%s'", path_or_uri );
            }
        }
    }

    g_strfreev( parts );

    if ( result && is_uri )
    {
        *is_uri = it_is_a_uri;
    }

#ifdef TP_PRODUCTION

    // Check for links

    if ( result && !it_is_a_uri && g_file_test( result, G_FILE_TEST_IS_SYMLINK ) )
    {
        g_critical( "SYMBOLIC LINKS NOT ALLOWED : %s", result );
        g_free( result );
        result = NULL;
    }

#endif

    return result;
}

//-----------------------------------------------------------------------------

guint32 App::get_screen_gid() const
{
    return screen_gid;
}

//-----------------------------------------------------------------------------

void App::animate_in()
{
    if ( !screen_gid )
    {
        return;
    }

    ClutterActor * screen = clutter_get_actor_by_gid( screen_gid );

    if ( !screen )
    {
        return;
    }

    // TODO
    // Here, we should ref the screen, create a timeline that animates the
    // screen and unref it when the timeline completes.

    clutter_actor_raise_top( screen );

    clutter_actor_set_scale( screen, 1, 1 );

    clutter_actor_grab_key_focus( screen );
}

//-----------------------------------------------------------------------------

void App::animate_out()
{
    if ( !screen_gid )
    {
        return;
    }

    ClutterActor * screen = clutter_get_actor_by_gid( screen_gid );

    if ( !screen )
    {
        return;
    }

    // So we can hold on to it until we are done

    g_object_ref( G_OBJECT( screen ) );

    g_idle_add_full( G_PRIORITY_HIGH, animate_out_callback, screen, NULL );
}

//-----------------------------------------------------------------------------

static void animate_out_completed( ClutterAnimation * animation, ClutterActor * actor )
{
    ClutterActor * parent = clutter_actor_get_parent( actor );

    if ( parent )
    {
        clutter_container_remove_actor( CLUTTER_CONTAINER( parent ), actor );
    }
}


gboolean App::animate_out_callback( gpointer s )
{
    ClutterActor * screen = CLUTTER_ACTOR( s );

    ClutterActor * parent = clutter_actor_get_parent( screen );

    if ( parent )
    {
        // TODO
        // What we would actually do here is to animate the screen out
        // and in the completed callback for that, remove it from its
        // parent and unref it

        //clutter_container_remove_actor( CLUTTER_CONTAINER( parent ), screen );

        gfloat width;
        gfloat height;

        clutter_actor_get_size( screen, &width, &height );

        clutter_actor_move_anchor_point( screen, width / 2 , height / 2 );

        clutter_actor_set_clip( screen, 0, 0, width, height );

        clutter_actor_animate( screen, CLUTTER_EASE_IN_CUBIC, 250,
                               "opacity", 0,
                               "scale-x", ( gdouble ) 0,
                               "scale-y", ( gdouble ) 0,
                               "signal::completed", animate_out_completed, screen,
                               NULL );
    }

    g_object_unref( G_OBJECT( screen ) );

    return FALSE;
}

//-----------------------------------------------------------------------------
