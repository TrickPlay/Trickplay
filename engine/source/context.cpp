#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <sstream>

#include "clutter/clutter.h"
#include "clutter/clutter-keysyms.h"
#include "curl/curl.h"
#include "fontconfig.h"

#include "trickplay/keys.h"
#include "lb.h"
#include "context.h"
#include "app.h"
#include "network.h"
#include "util.h"
#include "console.h"
#include "sysdb.h"
#include "controller_server.h"
#include "mediaplayers.h"
#include "profiler.h"
#include "images.h"
#include "downloads.h"
#include "installer.h"
#include "versions.h"
#include "controller_lirc.h"
#include "app_push_server.h"

//-----------------------------------------------------------------------------

static int * g_argc     = NULL;
static char *** g_argv  = NULL;

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
    :
    is_running( false ),
    sysdb( NULL ),
    controller_server( NULL ),
    controller_lirc( NULL ),
    app_push_server( NULL ),
    console( NULL ),
    downloads( NULL ),
    installer( NULL ),
    current_app( NULL ),
    is_first_app( true ),
    media_player_constructor( NULL ),
    media_player( NULL ),
    external_log_handler( NULL ),
    external_log_handler_data( NULL )
{
    g_log_set_default_handler( TPContext::log_handler, this );
}

//-----------------------------------------------------------------------------

TPContext::~TPContext()
{
}

//-----------------------------------------------------------------------------

void TPContext::set( const char * key, const char * value )
{
    g_assert( key );

    if ( ! value )
    {
        config.erase( String( key ) );
    }
    else
    {
        set( key, String( value ) );
    }
}

//-----------------------------------------------------------------------------

void TPContext::set( const char * key, int value )
{
    g_assert( key );

    std::stringstream str;
    str << value;
    set( key, str.str() );
}

//-----------------------------------------------------------------------------

void TPContext::set( const char * key, const String & value )
{
    g_assert( key );

    config[String( key )] = value;
}
//-----------------------------------------------------------------------------

const char * TPContext::get( const char * key, const char * def )
{
    g_assert( key );

    StringMap::const_iterator it = config.find( String( key ) );

    if ( it == config.end() )
    {
        return def;
    }
    return it->second.c_str();
}

//-----------------------------------------------------------------------------

bool TPContext::get_bool( const char * key, bool def )
{
    const char * value = get( key );

    if ( !value )
    {
        return def;
    }

    return ( !strcmp( value, "1" ) ||
             !strcmp( value, "TRUE" ) ||
             !strcmp( value, "true" ) ||
             !strcmp( value, "YES" ) ||
             !strcmp( value, "yes" ) ||
             !strcmp( value, "Y" ) ||
             !strcmp( value, "y" ) );
}

//-----------------------------------------------------------------------------

int TPContext::get_int( const char * key, int def )
{
    const char * value = get( key );

    if ( !value )
    {
        return def;
    }
    return atoi( value );
}

//-----------------------------------------------------------------------------

struct DumpInfo
{
    DumpInfo()
    :
        indent( 0 )
    {}

    guint indent;

    std::map< String, std::list<ClutterActor*> > actors_by_type;
};

static void dump_actors( ClutterActor * actor, gpointer dump_info )
{
    if ( !actor )
    {
        return;
    }

    DumpInfo * info = ( DumpInfo * )dump_info;

    ClutterGeometry g;

    clutter_actor_get_geometry( actor, & g );

    const gchar * name = clutter_actor_get_name( actor );
    const gchar * type = g_type_name( G_TYPE_FROM_INSTANCE( actor ) );

    if ( g_str_has_prefix( type, "Clutter" ) )
    {
        type += 7;
    }

    info->actors_by_type[type].push_back(actor);

    // Get extra info about the actor

    String extra;

    if ( CLUTTER_IS_TEXT( actor ) )
    {
        extra = String( "[text='" ) + clutter_text_get_text( CLUTTER_TEXT( actor ) ) + "'";

        ClutterColor color;

        clutter_text_get_color( CLUTTER_TEXT( actor ), &color );

        gchar * c = g_strdup_printf( "color=(%u,%u,%u,%u)", color.red, color.green, color.blue, color.alpha );

        extra = extra + "," + c + "]";

        g_free( c );

    }
    else if ( CLUTTER_IS_TEXTURE( actor ) )
    {
        const gchar * src = ( const gchar * )g_object_get_data( G_OBJECT( actor ) , "tp-src" );

        if ( src )
        {
            extra = String( "[src='" ) + src + "']";
        }
    }
    else if ( CLUTTER_IS_RECTANGLE( actor ) )
    {
        ClutterColor color;

        clutter_rectangle_get_color( CLUTTER_RECTANGLE( actor ), &color );

        gchar * c = g_strdup_printf( "[color=(%u,%u,%u,%u)]", color.red, color.green, color.blue, color.alpha );

        extra = c;

        g_free( c );
    }
    else if ( CLUTTER_IS_CLONE( actor ) )
    {
        ClutterActor * other = clutter_clone_get_source( CLUTTER_CLONE( actor ) );

        if ( other )
        {
            gchar * c = g_strdup_printf( "[source=%u]" , clutter_actor_get_gid( other ) );

            extra = c;

            g_free( c );
        }
    }

    String details;

    gdouble sx;
    gdouble sy;

    clutter_actor_get_scale( actor, &sx, &sy );

    if ( sx != 1 || sy != 1 )
    {
        gchar * c = g_strdup_printf( " scale(%1.2f,%1.2f)", sx, sy );

        details = c;

        g_free( c );
    }

    gfloat ax;
    gfloat ay;

    clutter_actor_get_anchor_point( actor, &ax, &ay );

    if ( ax != 0 || ay != 0 )
    {
        gchar * c = g_strdup_printf( " anchor(%1.0f,%1.0f)", ax, ay );

        details += c;

        g_free( c );
    }

    guint8 o = clutter_actor_get_opacity( actor );

    if ( o < 255 )
    {
        gchar * c = g_strdup_printf( "  opacity(%u)" , o );
        details += c;
        g_free( c );
    }

    if ( !extra.empty() )
    {
        extra = String( " : " ) + extra;
    }


    g_info( "%s%s%s:%s%u : (%d,%d %ux%u)%s%s",
            clutter_stage_get_key_focus( CLUTTER_STAGE( clutter_stage_get_default() ) ) == actor ? "> " : "  ",
            String( info->indent, ' ' ).c_str(),
            type,
            name ? String( " " + String( name ) + " : " ).c_str()  : " ",
            clutter_actor_get_gid( actor ),
            g.x,
            g.y,
            g.width,
            g.height,
            details.empty() ? "" : details.c_str(),
            extra.empty() ? "" : extra.c_str() );

    if ( CLUTTER_IS_CONTAINER( actor ) )
    {
        info->indent += 2;
        clutter_container_foreach( CLUTTER_CONTAINER( actor ), dump_actors, info );
        info->indent -= 2;
    }
}

//-----------------------------------------------------------------------------

int TPContext::console_command_handler( const char * command, const char * parameters, void * self )
{
    TPContext * context = ( TPContext * )self;

    if ( !strcmp( command, "exit" ) || !strcmp( command, "quit" ) )
    {
        context->quit();
        return TRUE;
    }
    else if ( !strcmp( command, "config" ) )
    {
        for ( StringMap::const_iterator it = context->config.begin(); it != context->config.end(); ++it )
        {
            g_info( "%-15.15s %s", it->first.c_str(), it->second.c_str() );
        }
    }
    else if ( !strcmp( command, "profile" ) )
    {
        if ( !parameters )
        {
            SystemDatabase::Profile p = context->get_db()->get_current_profile();
            g_info( "%d '%s' '%s'", p.id, p.name.c_str(), p.pin.c_str() );
        }
        else
        {
            gchar ** parts = g_strsplit( parameters, " ", 2 );
            guint count = g_strv_length( parts );
            if ( count == 2 && !strcmp( parts[0], "new" ) )
            {
                int id = context->get_db()->create_profile( parts[1], "" );
                g_info( "Created profile %d", id );
            }
            else if ( count == 2 && !strcmp( parts[0], "switch" ) )
            {
                int id = atoi( parts[1] );
                if ( context->profile_switch( id ) )
                {
                    g_info( "Switched to profile %d", id );
                }
                else
                {
                    g_info( "No such profile" );
                }
            }
            else
            {
                g_info( "Usage: '/profile new <name>' or '/profile switch <id>'" );
            }
            g_strfreev( parts );
        }
    }
    else if ( !strcmp( command, "reload" ) )
    {
        context->reload_app();
    }
    else if ( !strcmp( command, "close" ) )
    {
        if ( !context->current_app )
        {
            g_info( "No app loaded" );
        }
        else
        {
            context->close_current_app();
        }
    }
    else if ( !strcmp( command, "ui" ) )
    {
        DumpInfo info;

        dump_actors( clutter_stage_get_default(), &info );

        g_info( "" );
        g_info( "SUMMARY" );

        std::map< String, std::list< ClutterActor * > >::const_iterator it;

        for ( it = info.actors_by_type.begin(); it != info.actors_by_type.end(); ++it )
        {
            g_info( "%15s %5u", it->first.c_str(), it->second.size() );
        }
    }
    else if ( !strcmp( command, "prof" ) )
    {
        if ( parameters && !strcmp( parameters, "reset" ) )
        {
            PROFILER_RESET;
        }
        else
        {
            PROFILER_DUMP;
        }
    }
    else if ( !strcmp( command, "obj" ) )
    {
        PROFILER_OBJECTS;
    }
    else if ( !strcmp( command, "ver" ) )
    {
        dump_versions();
    }
    else if ( !strcmp( command , "images" ) )
    {
        Images::dump();
    }
    else if ( !strcmp( command, "cache" ) )
    {
        Images::dump_cache();
    }
    else if ( !strcmp( command , "gc" ) )
    {
        if ( context->current_app )
        {
            if ( lua_State * L = context->current_app->get_lua_state() )
            {
                int old_kb = lua_gc( L , LUA_GCCOUNT , 0 );
                lua_gc( L , LUA_GCCOLLECT , 0 );
                int new_kb = lua_gc( L , LUA_GCCOUNT , 0 );
                g_info( "GC : %d KB - %d KB = %d KB" , new_kb , old_kb , new_kb - old_kb );
            }
        }
    }

    std::pair<ConsoleCommandHandlerMultiMap::const_iterator, ConsoleCommandHandlerMultiMap::const_iterator>
    range = context->console_command_handlers.equal_range( String( command ) );

    for ( ConsoleCommandHandlerMultiMap::const_iterator it = range.first; it != range.second; ++it )
    {
        it->second.first( command, parameters, it->second.second );
    }

    return range.first != range.second;
}

//-----------------------------------------------------------------------------

void TPContext::setup_fonts()
{
    FreeLater free_later;

    // Get the a directory where fonts live

    const char * fonts_path = get( TP_FONTS_PATH );

    if ( !fonts_path )
    {
        g_warning( "USING SYSTEM FONTS" );
        return;
    }

    // We create a directory called "fonts" in our data directory. There,
    // we will have a tiny configuration file and the fontconfig cache.

    gchar * font_cache_path = g_build_filename( get( TP_DATA_PATH ), "fonts", NULL );
    free_later( font_cache_path );

    if ( g_mkdir_with_parents( font_cache_path, 0700 ) != 0 )
    {
        g_error( "FAILED TO CREATE FONT CACHE DIRECTORY '%s'", font_cache_path );
    }

    // We write the configuration file that sets the cache directory

    gchar * font_conf_file_name = g_build_filename( font_cache_path, "fonts.conf", NULL );
    free_later( font_conf_file_name );

    if ( !g_file_test( font_conf_file_name, G_FILE_TEST_EXISTS ) )
    {
        gchar * conf = g_strdup_printf( "<fontconfig><cachedir>%s</cachedir></fontconfig>", font_cache_path );
        g_file_set_contents( font_conf_file_name, conf, -1, NULL );
        g_free( conf );
    }

    // Create a new configuration

    FcConfig * config = FcConfigCreate();

    g_assert( config );

    // Parse and load our tiny configuration file

    if ( FcConfigParseAndLoad( config, ( const FcChar8 * )font_conf_file_name, FcTrue ) == FcFalse )
    {
        g_warning( "FAILED TO PARSE FONTCONFIG CONFIGURATION FILE" );
    }
    else
    {
        FcConfigAppFontClear( config );

        g_debug( "READING FONTS FROM '%s'", fonts_path );

        // This adds all the fonts in the directory to the cache...it can take
        // a long time the first time around. Once the cache exists, it will
        // be very quick.

		gchar ** paths = g_strsplit( fonts_path, ";", 0 );
		for ( gchar ** p = paths; *p; ++p )
		{
			gchar * path = g_strstrip( *p );

			if ( FcConfigAppFontAddDir( config, ( const FcChar8 * )path ) == FcFalse )
			{
				g_warning( "FAILED TO READ FONTS" );
			}
			else
			{
				// This transfers ownership of the config object over to FC, so we
				// don't have to destroy it or unref it.
	
				FcConfigSetCurrent( config );
	
				config = NULL;
	
				g_debug( "FONT CONFIGURATION COMPLETE" );
			}
		}
    }

    // If something went wrong, we destroy the config

    if ( config )
    {
        FcConfigDestroy( config );
    }
}

//-----------------------------------------------------------------------------

#ifndef TP_CLUTTER_BACKEND_EGL

static void map_key( ClutterEvent * event , guint * keyval , gunichar * unicode )
{
    * keyval = event->key.keyval;
    * unicode = event->key.unicode_value;

    switch ( * keyval )
    {
        case CLUTTER_F5:
            * keyval = TP_KEY_RED;
            * unicode = 0;
            break;

        case CLUTTER_F6:
            * keyval = TP_KEY_GREEN;
            * unicode = 0;
            break;

        case CLUTTER_F7:
            * keyval = TP_KEY_YELLOW;
            * unicode = 0;
            break;

        case CLUTTER_F8:
            * keyval = TP_KEY_BLUE;
            * unicode = 0;
            break;
    }
}

// In desktop builds, we catch all key events that are not synthetic and pass
// them through a keyboard controller. That will generate an event for the
// controller and re-inject the event into clutter as a synthetic event.

gboolean controller_keys( ClutterActor * actor, ClutterEvent * event, gpointer controller )
{
    if ( event )
    {
        switch ( event->any.type )
        {
            case CLUTTER_KEY_PRESS:
            {
                if ( !( event->key.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    guint keyval;
                    gunichar unicode;

                    map_key( event , & keyval , & unicode );

                    tp_controller_key_down( ( TPController * )controller, keyval, unicode );
                    return TRUE;
                }

                break;
            }

            case CLUTTER_KEY_RELEASE:
            {
                if ( !( event->key.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    guint keyval;
                    gunichar unicode;

                    map_key( event , & keyval , & unicode );

                    tp_controller_key_up( ( TPController * )controller, keyval, unicode );
                    return TRUE;
                }
                break;
            }

            default:
            {
                break;
            }
        }
    }
    return FALSE;
}

#endif

#ifndef TP_PRODUCTION

// This one deals with escape to exit current app

gboolean escape_handler( ClutterActor * actor, ClutterEvent * event, gpointer context )
{
    if ( event && event->any.type == CLUTTER_KEY_PRESS && ( event->key.keyval == CLUTTER_Escape || event->key.keyval == TP_KEY_EXIT ) )
    {
        ( ( TPContext * )context )->close_app();

        return TRUE;
    }

    return FALSE;
}


// This one deals with tilde to reload current app

gboolean tilde_handler ( ClutterActor * actor, ClutterEvent * event, gpointer context )
{
    if ( event && event->any.type == CLUTTER_KEY_PRESS && event->key.keyval == CLUTTER_asciitilde )
    {
        ( ( TPContext * )context )->reload_app();

        return TRUE;
    }

    return FALSE;
}

#endif

//-----------------------------------------------------------------------------

int TPContext::run()
{
    //.........................................................................
    // So that run cannot be called while we are running

    if ( is_running )
    {
        return TP_RUN_ALREADY_RUNNING;
    }

    is_running = true;

    int result = TP_RUN_OK;

    //.........................................................................
    // Load external configuration variables (from the environment or a file)

    load_external_configuration();

    //.........................................................................
    // Validate our configuration
    // Any problem here will just abort - these are likely programming errors.

    validate_configuration();

    //.........................................................................
    // Setup fonts

    setup_fonts();

    //.........................................................................
    // Open the system database

    sysdb = SystemDatabase::open( get( TP_DATA_PATH ) );

    if ( !sysdb )
    {
        is_running = false;
        return TP_RUN_SYSTEM_DATABASE_CORRUPT;
    }

    //.........................................................................
    // Scan for apps

    g_info( "SCANNING FOR APPS..." );

    {
        bool force = get_bool( TP_SCAN_APP_SOURCES, TP_SCAN_APP_SOURCES_DEFAULT );
        const char * app_sources = get( TP_APP_SOURCES );
        gchar * installed_root = g_build_filename( get( TP_DATA_PATH ), "apps", NULL );

        if ( force || get( TP_APP_ID ) )
        {
            App::scan_app_sources( sysdb, app_sources, installed_root, force );
        }

        g_free( installed_root );
    }

    //.........................................................................
    // Get the current profile from the database and set it into our
    // configuration

    g_info( "GETTING CURRENT PROFILE..." );

    SystemDatabase::Profile profile = sysdb->get_current_profile();
    set( PROFILE_ID, profile.id );
    set( PROFILE_NAME, profile.name );

    //.........................................................................
    // Let the world know that the profile has changed

    notify( TP_NOTIFICATION_PROFILE_CHANGED );

    //.........................................................................
    // Create the controller server

    if ( get_bool( TP_CONTROLLERS_ENABLED, TP_CONTROLLERS_ENABLED_DEFAULT ) )
    {
        g_info( "STARTING CONTROLLER SERVER..." );

        // Figure out the name for the controllers service. If one is passed
        // in to the context, we use it. Otherwise, we look in the database.
        // If the name is new, we store it in the database.

        String name;
        String stored_name = sysdb->get_string( TP_CONTROLLERS_NAME );

        const char * new_name = get( TP_CONTROLLERS_NAME );

        if ( new_name )
        {
            name = new_name;
        }
        else
        {
            if ( !stored_name.empty() )
            {
                name = stored_name;
            }
            else
            {
                name = TP_CONTROLLERS_NAME_DEFAULT;
            }
        }

        if ( name != stored_name )
        {
            sysdb->set( TP_CONTROLLERS_NAME, name );
        }

        controller_server = new ControllerServer( this, name, get_int( TP_CONTROLLERS_PORT, TP_CONTROLLERS_PORT_DEFAULT ) );
    }

    //.........................................................................
    // LIRC controller

    controller_lirc = ControllerLIRC::make( this );

    //.........................................................................

    app_push_server = AppPushServer::make( this );

    //.........................................................................
    // Create the downloads

    downloads = new Downloads( this );

    //.........................................................................

    installer = new Installer( this );

    //.........................................................................
    // Start the console

    console = Console::make( this );

    if ( console )
    {
        console->add_command_handler( console_command_handler, this );
    }

    //.........................................................................
    // Set default size and color for the stage

    g_info( "INITIALIZING STAGE..." );

    ClutterActor * stage = clutter_stage_get_default();

    clutter_actor_set_size( stage, get_int( TP_SCREEN_WIDTH ), get_int( TP_SCREEN_HEIGHT ) );
    clutter_stage_set_title( (ClutterStage *)stage, "TrickPlay" );

    ClutterColor color;
    color.red = 0;
    color.green = 0;
    color.blue = 0;
    color.alpha = 0;

    clutter_stage_set_color( CLUTTER_STAGE( stage ), &color );

#ifndef TP_PRODUCTION

    g_signal_connect( stage, "captured-event", ( GCallback )escape_handler, this );
    g_signal_connect( stage, "captured-event", ( GCallback )tilde_handler, this );

#endif

#ifndef TP_CLUTTER_BACKEND_EGL

    // We add a controller for the keyboard in non-egl builds

    TPControllerSpec spec;

    memset( &spec, 0, sizeof( spec ) );

    spec.capabilities = TP_CONTROLLER_HAS_KEYS;

    // This controller won't leak because the controller list will free it

    TPController * keyboard = tp_context_add_controller( this, "Keyboard", &spec, NULL );

    g_signal_connect( stage, "captured-event", ( GCallback )controller_keys, keyboard );

#endif

    //.........................................................................
    // Create the default media player. This may come back NULL.

    g_info( "CREATING MEDIA PLAYER..." );

    media_player = MediaPlayer::make( media_player_constructor );

    //.........................................................................
    // Load the app

    g_info( "LOADING APP..." );

    notify( TP_NOTIFICATION_APP_LOADING );

    result = load_app( &current_app );

    if ( !current_app )
    {
        notify( TP_NOTIFICATION_APP_LOAD_FAILED );
    }
    else
    {
        //.....................................................................
        // Execute the app's script

        result = current_app->run( app_allowed[ current_app->get_id() ] );

        if ( result != TP_RUN_OK )
        {
            notify( TP_NOTIFICATION_APP_LOAD_FAILED );
        }
        else
        {
            current_app->animate_in();

            notify( TP_NOTIFICATION_APP_LOADED );

            //.................................................................
            // Attach the console to the app

            if ( console )
            {
                console->attach_to_lua( current_app->get_lua_state() );
            }

            //.................................................................
            // Dip into the loop

            g_info( "ENTERING MAIN LOOP..." );

            while ( true )
            {
                try
                {
                    clutter_main();

                    // This means the run loop ended nicely, so we break

                    break;
                }
                catch ( ... )
                {
                    if ( is_first_app )
                    {
                        g_warning( "CAUGHT EXCEPTION IN RUN LOOP, EXITING" );

                        result = TP_RUN_APP_ERROR;

                        break;
                    }
                    else
                    {
                        g_warning( "CAUGHT EXCEPTION IN RUN LOOP, CLOSING APP" );

                        close_app();
                    }
                }
            }

            notify( TP_NOTIFICATION_APP_CLOSING );

            notify( TP_NOTIFICATION_APP_CLOSED );
        }
    }

    //.....................................................................

    if ( app_push_server )
    {
        delete app_push_server;

        app_push_server = 0;
    }

    //.....................................................................
    // Kill the LIRC connection

    if ( controller_lirc )
    {
        delete controller_lirc;

        controller_lirc = 0;
    }

    //.....................................................................
    // Detach the console

    if ( console )
    {
        console->attach_to_lua( NULL );
    }

    //.....................................................................
    // Reset the media player, just in case

    if ( media_player )
    {
        media_player->reset();
    }

    //.....................................................................
    // Clean up the stage

    clutter_group_remove_all( CLUTTER_GROUP( clutter_stage_get_default() ) );

    //.....................................................................
    // Shutdown the app

    if ( current_app )
    {
        delete current_app;
        current_app = NULL;
    }

    //.....................................................................

    if ( installer )
    {
        delete installer;
        installer = NULL;
    }

    //.....................................................................
    // Clean up the downloads

    if ( downloads )
    {
        delete downloads;
        downloads = NULL;
    }

    //.....................................................................
    // Kill the media player

    if ( media_player )
    {
        delete media_player;
        media_player = NULL;
    }

    //........................................................................
    // Delete the console

    if ( console )
    {
        delete console;
        console = NULL;
    }

    //.........................................................................
    // Get rid of the controller server

    if ( controller_server )
    {
        delete controller_server;
        controller_server = NULL;
    }

    //.........................................................................
    // Get rid of the system database

    delete sysdb;
    sysdb = NULL;

    //.........................................................................

    Images::shutdown();

    //.........................................................................
    // Not running any more

    is_running = false;

    return result;
}

//-----------------------------------------------------------------------------

String TPContext::make_fake_app()
{
    String result;

#ifndef TP_PRODUCTION

    String data_directory = App::get_data_directory( this, "com.trickplay.empty" );

    if ( ! data_directory.empty() )
    {
        FreeLater free_later;

        gchar * app_path = g_build_filename( data_directory.c_str(), "source", NULL );

        free_later( app_path );

        if ( 0 == g_mkdir_with_parents( app_path, 0700 ) )
        {
            gchar * app = g_build_filename( app_path, "app", NULL );

            free_later( app );

            g_file_set_contents( app, "app={id='com.trickplay.empty',name='Empty',version='1.0',release=1}", -1, NULL );

            gchar * main = g_build_filename( app_path, "main.lua", NULL );

            free_later( main );

            g_file_set_contents( main, "--Automatically Created", -1, NULL );

            result = app_path;
        }
    }

#endif

    return result;
}

//-----------------------------------------------------------------------------

int TPContext::load_app( App ** app )
{
    PROFILER( "TPContext::load_app" );

    String app_path;

    // If an app id was specified, we will try to find the app by id, in the
    // system database

    const char * app_id = get( TP_APP_ID );

    if ( app_id )
    {
        app_path = sysdb->get_app_path( app_id );
        if ( app_path.empty() )
        {
            g_warning( "FAILED TO FIND %s IN THE SYSTEM DATABASE", app_id );
            return TP_RUN_APP_NOT_FOUND;
        }
        set( TP_APP_PATH, app_path );
    }
    else
    {
        // Get the base path for the app

        const char * ap = get( TP_APP_PATH );

        if ( ! ap )
        {
            app_path = make_fake_app();

            if ( app_path.empty() )
            {
                g_warning( "NO APP WAS GIVEN - FAILED TO CREATE TEST APP" );

                return TP_RUN_APP_PREPARE_FAILED;
            }
        }
        else
        {
            app_path = ap;
        }
    }

    // Load metadata

    App::Metadata md;

    if ( !App::load_metadata( app_path.c_str(), md ) )
    {
        return TP_RUN_APP_CORRUPT;
    }

    // Load the app

    *app = App::load( this, md , App::LaunchInfo() );

    if ( !*app )
    {
        return TP_RUN_APP_PREPARE_FAILED;
    }

    controller_list.reset_all();

    return TP_RUN_OK;
}

//-----------------------------------------------------------------------------

int TPContext::launch_app( const char * app_id, const App::LaunchInfo & launch )
{
    String app_path = get_db()->get_app_path( app_id );

    if ( app_path.empty() )
    {
        return TP_RUN_APP_NOT_FOUND;
    }

    App::Metadata md;

    if ( !App::load_metadata( app_path.c_str(), md ) )
    {
        return TP_RUN_APP_CORRUPT;
    }

    App * new_app = App::load( this, md, launch );

    if ( !new_app )
    {
        return TP_RUN_APP_PREPARE_FAILED;
    }

    int result = new_app->run( app_allowed[ new_app->get_id() ] );

    if ( result != TP_RUN_OK )
    {
        delete new_app;
        return result;
    }

    g_idle_add_full( G_PRIORITY_HIGH, launch_app_callback, new_app, NULL );

    // TODO: Not right to set this before the idle source fires

    is_first_app = false;

    return 0;
}

//-----------------------------------------------------------------------------

gboolean TPContext::launch_app_callback( gpointer app )
{
    App * new_app = ( App * )app;

    TPContext * context = new_app->get_context();

    context->close_current_app();

    if ( context->console )
    {
        context->console->attach_to_lua( new_app->get_lua_state() );
    }

    context->current_app = new_app;

    new_app->animate_in();

    context->notify( TP_NOTIFICATION_APP_LOADED );

    return FALSE;
}

//-----------------------------------------------------------------------------

void TPContext::close_app()
{
    if ( is_first_app )
    {
        quit();
    }
    else
    {
        App * new_app = NULL;

        load_app( &new_app );

        if ( new_app )
        {
            if ( new_app->run( app_allowed[ new_app->get_id() ] ) == TP_RUN_OK )
            {
                g_idle_add_full( G_PRIORITY_HIGH, launch_app_callback, new_app, NULL );

                // TODO Not right to set here

                is_first_app = true;
            }
            else
            {
                delete new_app;
            }
        }
    }
}

//-----------------------------------------------------------------------------

void TPContext::close_current_app()
{
    if ( console )
    {
        console->attach_to_lua( NULL );
    }

    if ( current_app )
    {
        current_app->animate_out();

        notify( TP_NOTIFICATION_APP_CLOSING );

        delete current_app;

        current_app = NULL;
    }
}

//-----------------------------------------------------------------------------

void TPContext::reload_app()
{
    App * new_app = NULL;

    load_app( &new_app );

    if ( !new_app )
    {
        g_warning( "FAILED TO RELOAD APP" );
    }
    else
    {
        if ( new_app->run( app_allowed[ new_app->get_id() ] ) == TP_RUN_OK )
        {
            g_idle_add_full( G_PRIORITY_HIGH, launch_app_callback, new_app, NULL );
        }
        else
        {
            delete new_app;
        }
    }
}


//-----------------------------------------------------------------------------

gboolean delayed_quit( gpointer )
{
    clutter_main_quit();

    return FALSE;
}

void TPContext::quit()
{
    if ( !is_running )
    {
        return;
    }

    if ( g_main_depth() > 0 )
    {
        clutter_main_quit();
    }
    else
    {
        g_idle_add( delayed_quit, NULL );
    }
}

//-----------------------------------------------------------------------------

void TPContext::add_console_command_handler( const char * command, TPConsoleCommandHandler handler, void * data )
{
    console_command_handlers.insert( std::make_pair( String( command ), ConsoleCommandHandlerClosure( handler, data ) ) );
}

void TPContext::remove_console_command_handler( const char * command, TPConsoleCommandHandler handler, void * data )
{
    std::pair<ConsoleCommandHandlerMultiMap::iterator, ConsoleCommandHandlerMultiMap::iterator>

    range = console_command_handlers.equal_range( String( command ) );

    for ( ConsoleCommandHandlerMultiMap::iterator it = range.first; it != range.second; ++it )
    {
        if ( it->second.first == handler && it->second.second == data )
        {
            console_command_handlers.erase( it );

            break;
        }
    }
}

//-----------------------------------------------------------------------------

void TPContext::log_handler( const gchar * log_domain, GLogLevelFlags log_level, const gchar * message, gpointer self )
{
    gchar * line = NULL;

    // This is before a context is created, so we just print out the message

    if ( !self )
    {
        line = format_log_line( log_domain, log_level, message );
        fprintf( stderr, "%s", line );
    }

    // Otherwise, we have a context and more choices as to what we can do with
    // the log messages

    else
    {
        TPContext * context = ( TPContext * )self;

        bool output = true;

        if ( log_level == G_LOG_LEVEL_DEBUG && !context->get_bool( TP_LOG_DEBUG, true ) )
        {
            output = false;
        }

        if ( context->get_bool( TP_LOG_APP_ONLY , false ) )
        {
            output = log_level == G_LOG_LEVEL_MESSAGE;
        }

        if ( output )
        {
            if ( context->external_log_handler )
            {
                context->external_log_handler( log_level, log_domain, message, context->external_log_handler_data );
            }
            else
            {
                line = format_log_line( log_domain, log_level, message );
                fprintf( stderr, "%s", line );
            }

            if ( !context->output_handlers.empty() )
            {
                if ( !line )
                {
                    line = format_log_line( log_domain, log_level, message );
                }

                for ( OutputHandlerSet::const_iterator it = context->output_handlers.begin();
                        it != context->output_handlers.end(); ++it )
                {
                    it->first( line, it->second );
                }
            }
        }
    }

    g_free( line );
}

//-----------------------------------------------------------------------------

void TPContext::set_log_handler( TPLogHandler handler, void * data )
{
    g_assert( !running() );

    external_log_handler = handler;
    external_log_handler_data = data;
}

//-----------------------------------------------------------------------------

void TPContext::set_request_handler( const char * subject, TPRequestHandler handler, void * data )
{
    request_handlers[String( subject )] = RequestHandlerClosure( handler, data );
}

//-----------------------------------------------------------------------------

void TPContext::add_output_handler( OutputHandler handler, gpointer data )
{
    output_handlers.insert( OutputHandlerClosure( handler, data ) );
}

//-----------------------------------------------------------------------------

void TPContext::remove_output_handler( OutputHandler handler, gpointer data )
{
    output_handlers.erase( OutputHandlerClosure( handler, data ) );
}

//-----------------------------------------------------------------------------

int TPContext::request( const char * subject )
{
    RequestHandlerMap::const_iterator it = request_handlers.find( String( subject ) );

    return it == request_handlers.end() ? 1 : it->second.first( subject, it->second.second );
}

//-----------------------------------------------------------------------------
// Load configuration variables from the environment or a file

void TPContext::load_external_configuration()
{
    if ( get_bool( TP_CONFIG_FROM_ENV, TP_CONFIG_FROM_ENV_DEFAULT ) )
    {
        gchar ** env = g_listenv();

        for ( gchar ** e = env; *e; ++e )
        {
            if ( g_str_has_prefix( *e, "TP_" ) )
            {
                if ( const gchar * v = g_getenv( *e ) )
                {
                    gchar * k = g_strstrip( ( *e ) + 3 );

                    g_info( "ENV:%s=%s", k, v );
                    set( k, v );
                }
            }
        }

        g_strfreev( env );
    }

    FreeLater free_later;

    const char * file_name = get( TP_CONFIG_FROM_FILE );

    // If a specific file name was given and it does not exist, we
    // bail with an error. If no file name was given and the default one
    // does not exist, we just skip processing it.

    if ( file_name && ! g_file_test( file_name , G_FILE_TEST_EXISTS ) )
    {
        g_error( "CONFIG FILE %s DOES NOT EXIST", file_name );
    }

    if ( ! file_name )
    {
        file_name = TP_CONFIG_FROM_FILE_DEFAULT;

        if ( ! g_file_test( file_name , G_FILE_TEST_EXISTS ) )
        {
            // See if there is one in the user's home directory

            const gchar * home = g_getenv( "HOME" );

            if ( ! home )
            {
                home = g_get_home_dir();

                if ( ! home )
                {
                    return;
                }
            }

            gchar * path = g_build_filename( home , TP_CONFIG_FROM_FILE_DEFAULT , NULL );

            free_later( path );

            if ( ! g_file_test( path , G_FILE_TEST_EXISTS ) )
            {
                return;
            }

            file_name = path;

            g_info( "%s=%s" , TP_CONFIG_FROM_FILE , file_name );
        }
    }

    // Now open the Lua state

    lua_State * L = lua_open();

    const luaL_Reg lualibs[] =
    {

// TODO: Not sure if these should be enabled all the time - they would give us
// some interesting capabilities.

#if 1

        { "", luaopen_base },
        { LUA_IOLIBNAME, luaopen_io},
        { LUA_OSLIBNAME, luaopen_os },
        { LUA_LOADLIBNAME, luaopen_package },

#endif

        { LUA_TABLIBNAME, luaopen_table },
        { LUA_STRLIBNAME, luaopen_string },
        { LUA_MATHLIBNAME, luaopen_math },
        { NULL, NULL }
    };

    for ( const luaL_Reg * lib = lualibs; lib->func; ++lib )
    {
        lua_pushcfunction( L, lib->func );
        lua_pushstring( L, lib->name );
        lua_call( L, 1, 0 );
    }

    //.....................................................................
    // Create a new table to hold command line options

    lua_newtable( L );

    if ( g_argc && g_argv )
    {
        for( int i = 1; i < * g_argc; ++i )
        {
            lua_pushstring( L , ( * g_argv )[ i ] );
            lua_rawseti( L , -2 , i );
        }
    }

    lua_setglobal( L, "args" );

    //.....................................................................
    // Push a global holding the trickplay version

    lua_pushstring( L, Util::format( "%d.%d.%d", TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION ).c_str() );
    lua_setglobal( L, "_TRICKPLAY_VERSION" );

    //.....................................................................
    // Run the config file

    if ( luaL_dofile( L, file_name ) )
    {
        g_error( "FAILED TO PARSE CONFIGURATION FILE : %s", lua_tostring( L , -1 ) );

        lua_close( L );
    }

    // Pull these names from the globals

    const char * names[] =
    {
        TP_APP_SOURCES,
        TP_SCAN_APP_SOURCES,
        TP_APP_ID,
        TP_APP_PATH,
        TP_APP_ALLOWED,
        TP_SYSTEM_LANGUAGE,
        TP_SYSTEM_COUNTRY,
        TP_SYSTEM_NAME,
        TP_SYSTEM_VERSION,
        TP_SYSTEM_SN,
        TP_DATA_PATH,
        TP_SCREEN_WIDTH,
        TP_SCREEN_HEIGHT,
        TP_CONFIG_FROM_ENV,
        TP_CONFIG_FROM_FILE,
        TP_CONSOLE_ENABLED,
        TP_TELNET_CONSOLE_PORT,
        TP_CONTROLLERS_ENABLED,
        TP_CONTROLLERS_PORT,
        TP_CONTROLLERS_NAME,
        TP_LOG_DEBUG,
        TP_LOG_APP_ONLY,
        TP_FONTS_PATH,
        TP_DOWNLOADS_PATH,
        TP_NETWORK_DEBUG,
        TP_SSL_VERIFY_PEER,
        TP_SSL_CA_CERT_FILE,
        TP_LIRC_ENABLED,
        TP_LIRC_UDS,
        TP_LIRC_REPEAT,
        TP_APP_PUSH_ENABLED,
        TP_APP_PUSH_PORT,

        NULL
    };

    for ( const char * * name = names; *name; ++name )
    {
        lua_getglobal( L, * name );

        if ( ! lua_isnil( L, -1 ) )
        {
            const char * value = lua_tostring( L, -1 );

            if ( ! value && lua_isboolean( L , -1 ) )
            {
                value = lua_toboolean( L , -1 ) ? "true" : "false";
            }

            if ( value )
            {
                g_info( "FILE:%s:%s=%s", file_name, * name, value );

                set( * name, value );
            }
        }
        lua_pop( L, 1 );
    }

    lua_close( L );
}


//-----------------------------------------------------------------------------

void TPContext::validate_configuration()
{
    // TP_APP_SOURCES

    const char * app_sources = get( TP_APP_SOURCES );

    if ( !app_sources )
    {
        gchar * s = g_build_filename( g_get_current_dir(), "apps", NULL );
        set( TP_APP_SOURCES, s );
        g_warning( "DEFAULT:%s=%s", TP_APP_SOURCES, s );
        g_free( s );
    }

    // TP_APP_PATH

    const char * app_path = get( TP_APP_PATH );
#if 0
    if ( !app_path && !get( TP_APP_ID ) )
    {
        gchar * c = g_get_current_dir();
        set( TP_APP_PATH, c );
        g_warning( "DEFAULT:%s=%s", TP_APP_PATH, c );
        g_free( c );
    }
#endif
    if ( app_path && !g_path_is_absolute( app_path ) )
    {
        gchar * new_app_path = g_build_filename( g_get_current_dir(), app_path, NULL );
        set( TP_APP_PATH, new_app_path );
        g_free( new_app_path );
    }

    // TP_SYSTEM_LANGUAGE

    const char * language = get( TP_SYSTEM_LANGUAGE );

    if ( !language )
    {
        set( TP_SYSTEM_LANGUAGE, TP_SYSTEM_LANGUAGE_DEFAULT );
        g_warning( "DEFAULT:%s=%s", TP_SYSTEM_LANGUAGE, TP_SYSTEM_LANGUAGE_DEFAULT );
    }
    else if ( strlen( language ) != 2 )
    {
        g_error( "Language must be a 2 character, lower case, ISO-639-1 code : '%s' is too long", language );
    }
    else if ( !g_ascii_islower( language[0] ) || !g_ascii_islower( language[1] ) )
    {
        g_error( "Language must be a 2 character, lower case, ISO-639-1 code : '%s' is invalid", language );
    }

    // SYSTEM COUNTRY

    const char * country = get( TP_SYSTEM_COUNTRY );

    if ( !country )
    {
        set( TP_SYSTEM_COUNTRY, TP_SYSTEM_COUNTRY_DEFAULT );
        g_warning( "DEFAULT:%s=%s", TP_SYSTEM_COUNTRY, TP_SYSTEM_COUNTRY_DEFAULT );
    }
    else if ( strlen( country ) != 2 )
    {
        g_error( "Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is too long", country );
    }
    else if ( !g_ascii_isupper( country[0] ) || !g_ascii_isupper( country[1] ) )
    {
        g_error( "Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is invalid", country );
    }

    // SYSTEM NAME

    if ( !get( TP_SYSTEM_NAME ) )
    {
        set( TP_SYSTEM_NAME, TP_SYSTEM_NAME_DEFAULT );
        g_warning( "DEFAULT:%s=%s", TP_SYSTEM_NAME, TP_SYSTEM_NAME_DEFAULT );
    }

    // SYSTEM VERSION

    if ( !get( TP_SYSTEM_VERSION ) )
    {
        set( TP_SYSTEM_VERSION, TP_SYSTEM_VERSION_DEFAULT );
        g_warning( "DEFAULT:%s=%s", TP_SYSTEM_VERSION, TP_SYSTEM_VERSION_DEFAULT );
    }

    // SYSTEM SN

    if ( !get( TP_SYSTEM_SN ) )
    {
        set( TP_SYSTEM_SN, TP_SYSTEM_SN_DEFAULT );
        g_warning( "DEFAULT:%s=%s", TP_SYSTEM_SN, TP_SYSTEM_SN_DEFAULT );
    }

    // DATA PATH

    const char * data_path = get( TP_DATA_PATH );

    if ( !data_path )
    {
        data_path = g_get_tmp_dir();
        g_assert( data_path );
        g_warning( "DEFAULT:%s=%s", TP_DATA_PATH, data_path );
    }

    gchar * full_data_path = g_build_filename( data_path, "trickplay", NULL );

    if ( g_mkdir_with_parents( full_data_path, 0700 ) != 0 )
    {
        g_error( "Data path '%s' does not exist and could not be created", full_data_path );
    }

    set( TP_DATA_PATH, full_data_path );

    g_free( full_data_path );

    // DOWNLOADS PATH

    const char * downloads_path = get( TP_DOWNLOADS_PATH );

    if ( !downloads_path )
    {
        gchar * path = g_build_filename( get( TP_DATA_PATH ), "downloads", NULL );

        g_warning( "DEFAULT:%s=%s", TP_DOWNLOADS_PATH, path );

        set( TP_DOWNLOADS_PATH, path );

        g_free( path );

        downloads_path = get( TP_DOWNLOADS_PATH );
    }

    if ( g_mkdir_with_parents( downloads_path, 0700 ) != 0 )
    {
        g_error( "DOWNLOADS PATH '%s' DOES NOT EXIST AND COULD NOT BE CREATED", downloads_path );
    }

    // SCREEN WIDTH AND HEIGHT

    if ( !get( TP_SCREEN_WIDTH ) )
    {
        set( TP_SCREEN_WIDTH, TP_SCREEN_WIDTH_DEFAULT );
    }

    if ( !get( TP_SCREEN_HEIGHT ) )
    {
        set( TP_SCREEN_HEIGHT, TP_SCREEN_HEIGHT_DEFAULT );
    }

    // Allowed secure objects

    const gchar * allowed_config = get( TP_APP_ALLOWED, TP_APP_ALLOWED_DEFAULT );

    if ( allowed_config )
    {
        gchar * * entries = g_strsplit( allowed_config, ":", 0 );

        for ( gchar * * entry = entries; * entry; ++entry )
        {
            gchar * * parts = g_strsplit_set( g_strstrip( * entry ), "=,", 0 );

            guint count = g_strv_length( parts );

            if ( count < 2 )
            {
                g_warning( "BAD ALLOWED ENTRY '%s'", * entry );
            }
            else
            {
                StringSet names;

                for ( guint i = 1; i < count; ++i )
                {
                    names.insert( g_strstrip( parts[i] ) );
                }

                app_allowed[ g_strstrip( parts[0] ) ] = names;
            }

            g_strfreev( parts );
        }

        g_strfreev( entries );
    }
}

//-----------------------------------------------------------------------------

gchar * TPContext::format_log_line( const gchar * log_domain, GLogLevelFlags log_level, const gchar * message )
{
    gulong ms = clutter_get_timestamp() / 1000;

    int sec = 0;
    int min = 0;
    int hour = 0;

    if ( ms >= 1000 )
    {
        sec = ms / 1000;
        ms %= 1000;

        if ( sec >= 60 )
        {
            min = sec / 60;
            sec %= 60;

            if ( min >= 60 )
            {
                hour = min / 60;
                min %= 60;
            }
        }
    }

    const char * level = "OTHER";

    const char * color_start = "";
    const char * color_end = "\033[0m";

    if ( log_level & G_LOG_LEVEL_ERROR )
    {
        color_start = "\033[31m";
        level = "ERROR";
    }
    else if ( log_level & G_LOG_LEVEL_CRITICAL )
    {
        color_start = "\033[31m";
        level = "CRITICAL";
    }
    else if ( log_level & G_LOG_LEVEL_WARNING )
    {
        color_start = "\033[33m";
        level = "WARNING";
    }
    else if ( log_level & G_LOG_LEVEL_MESSAGE )
    {
        color_start = "\033[36m";
        level = "MESSAGE";
    }
    else if ( log_level & G_LOG_LEVEL_INFO )
    {
        color_start = "\33[32m";
        level = "INFO";
    }
    else if ( log_level & G_LOG_LEVEL_DEBUG )
    {
        color_start = "\33[37m";
        level = "DEBUG";
    }

#if 0 // Set to 1 to disable colors
    color_start = "";
    color_end = "";
#endif

    return g_strdup_printf( "[%s] %p %2.2d:%2.2d:%2.2d:%3.3lu %s%-8s-%s %s\n" ,
                            log_domain,
                            g_thread_self() ,
                            hour , min , sec , ms ,
                            color_start , level , color_end ,
                            message );
}

//-----------------------------------------------------------------------------

SystemDatabase * TPContext::get_db() const
{
    g_assert( sysdb );
    return sysdb;
}

//-----------------------------------------------------------------------------

Downloads * TPContext::get_downloads() const
{
    g_assert( downloads );
    return downloads;
}

//-----------------------------------------------------------------------------

Installer * TPContext::get_installer() const
{
    g_assert( installer );
    return installer;
}

//-----------------------------------------------------------------------------

bool TPContext::profile_switch( int id )
{
    SystemDatabase::Profile profile = get_db()->get_profile( id );

    if ( profile.id == 0 )
    {
        return false;
    }

    notify( TP_NOTIFICATION_PROFILE_CHANGING );

    get_db()->set( TP_DB_CURRENT_PROFILE_ID, id );
    set( PROFILE_ID, id );
    set( PROFILE_NAME, profile.name );

    notify( TP_NOTIFICATION_PROFILE_CHANGE );

    notify( TP_NOTIFICATION_PROFILE_CHANGED );

    return true;
}

//-----------------------------------------------------------------------------

MediaPlayer * TPContext::get_default_media_player()
{
    return media_player;
}

//-----------------------------------------------------------------------------

MediaPlayer * TPContext::create_new_media_player( MediaPlayer::Delegate * delegate )
{
    return MediaPlayer::make( media_player_constructor, delegate );
}


//-----------------------------------------------------------------------------

ControllerList * TPContext::get_controller_list()
{
    return &controller_list;
}

//-----------------------------------------------------------------------------

Image * TPContext::load_icon( const gchar * path )
{
    PROFILER( "TPContext::load_icon" );

    FreeLater free_later;

    static GChecksumType hash_type = G_CHECKSUM_MD5;

    //.........................................................................
    // First, we read the contents of the original file

    gchar * contents = NULL;
    gsize content_length = 0;

    if ( !g_file_get_contents( path, &contents, &content_length, NULL ) )
    {
        return NULL;
    }

    free_later( contents );

    //.........................................................................
    // Now, we compute an md5 hash of the contents

    gchar * data_hash = g_compute_checksum_for_string( hash_type, contents, content_length );

    free_later( data_hash );

    //.........................................................................
    // Compute a hash for the full path to the file

    gchar * path_hash = g_compute_checksum_for_string( hash_type, path, -1 );

    free_later( path_hash );

    //.........................................................................
    // See if we have an entry in the icon cache for this path

    gchar * icon_cache_path = g_build_filename( get( TP_DATA_PATH ), "icons", NULL );

    free_later( icon_cache_path );

    //.........................................................................
    // This is the file name for the raw file

    gchar * icon_file_path = g_build_filename( icon_cache_path, path_hash, NULL );

    free_later( icon_file_path );

    //.........................................................................
    // We also have an info file that has the data hash, width, height, pitch
    // and depth for the image.

    gchar * info_file_name = g_strdup_printf( "%s.info", icon_file_path );

    free_later( info_file_name );


    gchar * info_contents = NULL;

    gsize info_length = 0;

    if ( g_file_get_contents( info_file_name, &info_contents, &info_length, NULL ) )
    {
        free_later( info_contents );


        gchar * actual_data_hash = g_new0( gchar , info_length + 1 );

        free_later( actual_data_hash );

        TPImage result;
        memset( &result, 0, sizeof( TPImage ) );


        if ( sscanf( info_contents, "%s %u %u %u %u %u", actual_data_hash, &result.width, &result.height, &result.pitch, &result.depth, &result.bgr ) == 6 )
        {
            if ( !strcmp( actual_data_hash, data_hash ) )
            {
                PROFILER( "TPContext::load_icon(load raw)" );

                gchar * raw_contents = NULL;

                gsize length = 0;

                if ( g_file_get_contents( icon_file_path, &raw_contents, &length, NULL ) )
                {
                    result.pixels = raw_contents;
                    result.free_pixels = g_free;

                    return Image::make( result );
                }
            }
        }
    }


    //.........................................................................
    // If we got here, we need to create the icon file because it doesn't exist,
    // doesn't match or we had a problem reading the information.

    Image * image = Image::decode( contents, content_length, path );

    if ( image )
    {
        // The length of the raw image

        gsize length = image->size();

        // If the conversion succeeded, we need to write the info file and the
        // raw icon file. Any failure below this point is simply a failure to cache,
        // and even though it will affect performance, it is not considered critical.

        PROFILER( "TPContext::load_icon(cache)" );

        // Make sure the icon cache directory exists

        if ( g_mkdir_with_parents( icon_cache_path, 0700 ) == 0 )
        {
            gchar * info = g_strdup_printf( "%s %u %u %u %u %u", data_hash, image->width(), image->height(), image->pitch(), image->depth(), image->bgr() );

            free_later( info );

            if ( g_file_set_contents( info_file_name, info, -1, NULL ) )
            {
                // Now we save the raw icon

                g_file_set_contents( icon_file_path, ( const gchar * )image->pixels(), length, NULL );
            }
        }

    }

    return image;
}


//=============================================================================
// External-facing functions
//=============================================================================

void tp_init_version( int * argc, char ** * argv, int major_version, int minor_version, int patch_version )
{
    g_argc = argc;
    g_argv = argv;

    if ( !g_thread_supported() )
    {
        g_thread_init( NULL );
    }

    if ( !( major_version == TP_MAJOR_VERSION &&
            minor_version == TP_MINOR_VERSION &&
            patch_version == TP_PATCH_VERSION ) )
    {
        g_warning( "TRICKPLAY VERSION MISMATCH : HOST (%d.%d.%d) : LIBRARY (%d.%d.%d)",
                   major_version, minor_version, patch_version,
                   TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION );
    }


    ClutterInitError ce = clutter_init( argc, argv );

    if ( ce != CLUTTER_INIT_SUCCESS )
    {
        g_error( "Failed to initialize Clutter : %d", ce );
    }

    CURLcode co = curl_global_init( CURL_GLOBAL_ALL );

    if ( co != CURLE_OK )
    {
        g_error( "Failed to initialize cURL : %s", curl_easy_strerror( co ) );
    }

    g_log_set_default_handler( TPContext::log_handler, NULL );

    g_info( "%d.%d.%d", TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION );
}

//-----------------------------------------------------------------------------

TPContext * tp_context_new()
{
    return new TPContext();
}

//-----------------------------------------------------------------------------

void tp_context_free( TPContext * context )
{
    g_assert( context );
    g_assert( !context->running() );

    delete context;
}

//-----------------------------------------------------------------------------

void tp_context_set( TPContext * context, const char * key, const char * value )
{
    g_assert( context );

    context->set( key, value );
}

//-----------------------------------------------------------------------------

void tp_context_set_int( TPContext * context, const char * key, int value )
{
    g_assert( context );

    context->set( key, value );
}

//-----------------------------------------------------------------------------

const char * tp_context_get( TPContext * context, const char * key )
{
    g_assert( context );

    return context->get( key );
}

//-----------------------------------------------------------------------------

void tp_context_add_notification_handler( TPContext * context, const char * subject, TPNotificationHandler handler, void * data )
{
    g_assert( context );

    context->add_notification_handler( subject, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_set_request_handler( TPContext * context, const char * subject, TPRequestHandler handler, void * data )
{
    g_assert( context );

    context->set_request_handler( subject, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_add_console_command_handler( TPContext * context, const char * command, TPConsoleCommandHandler handler, void * data )
{
    g_assert( context );

    context->add_console_command_handler( command, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_set_log_handler( TPContext * context, TPLogHandler handler, void * data )
{
    g_assert( context );

    context->set_log_handler( handler, data );
}

//-----------------------------------------------------------------------------

int tp_context_run( TPContext * context )
{
    g_assert( context );

    return context->run();
}

//-----------------------------------------------------------------------------

void tp_context_quit( TPContext * context )
{
    g_assert( context );

    context->quit();
}

//-----------------------------------------------------------------------------
// Media player
//-----------------------------------------------------------------------------

void tp_context_set_media_player_constructor( TPContext * context, TPMediaPlayerConstructor constructor )
{
    g_assert( context );

    context->media_player_constructor = constructor;
}

//-----------------------------------------------------------------------------
// Controllers
//-----------------------------------------------------------------------------

TPController * tp_context_add_controller( TPContext * context, const char * name, const TPControllerSpec * spec, void * data )
{
    g_assert( context );

    return context->controller_list.add_controller( name, spec, data );
}

//-----------------------------------------------------------------------------

void tp_context_remove_controller( TPContext * context, TPController * controller )
{
    g_assert( context );

    context->controller_list.remove_controller( controller );
}

//-----------------------------------------------------------------------------
// Image Decoder
//-----------------------------------------------------------------------------

void tp_context_set_image_decoder( TPContext * context, TPImageDecoder decoder, void * user)
{
    g_assert( context );
    g_assert( decoder );

    Images::set_external_decoder( decoder, user );
}

//-----------------------------------------------------------------------------
