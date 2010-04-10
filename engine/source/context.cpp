#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <sstream>

#include "clutter/clutter.h"
#include "curl/curl.h"
#include "fontconfig.h"

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

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
    :
    is_running( false ),
    sysdb( NULL ),
    controller_server( NULL ),
    console( NULL ),
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
    set( key, String( value ) );
}

//-----------------------------------------------------------------------------

void TPContext::set( const char * key, int value )
{
    std::stringstream str;
    str << value;
    set( key, str.str() );
}

//-----------------------------------------------------------------------------

void TPContext::set( const char * key, const String & value )
{
    config[String( key )] = value;
}
//-----------------------------------------------------------------------------

const char * TPContext::get( const char * key, const char * def )
{
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
        extra = String( "[text='" ) + clutter_text_get_text( CLUTTER_TEXT( actor ) ) + "']";
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

    if ( !extra.empty() )
    {
        extra = String( " : " ) + extra;
    }


    g_info( "%s%s: '%s' : %u : (%d,%d %ux%u)%s",
            String( info->indent, ' ' ).c_str(),
            type,
            name ? name : "",
            clutter_actor_get_gid( actor ),
            g.x,
            g.y,
            g.width,
            g.height,
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
    else if ( ! strcmp( command , "prof" ) )
    {
        Profiler::dump();
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
    Util::GFreeLater free_font_cache_path( font_cache_path );

    if ( g_mkdir_with_parents( font_cache_path, 0700 ) != 0 )
    {
        g_error( "FAILED TO CREATE FONT CACHE DIRECTORY '%s'", font_cache_path );
    }

    // We write the configuration file that sets the cache directory

    gchar * font_conf_file_name = g_build_filename( font_cache_path, "fonts.conf", NULL );
    Util::GFreeLater free_font_conf_file_name( font_conf_file_name );

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

        g_info( "READING FONTS FROM '%s'", fonts_path );

        // This adds all the fonts in the directory to the cache...it can take
        // a long time the first time around. Once the cache exists, it will
        // be very quick.

        if ( FcConfigAppFontAddDir( config, ( const FcChar8 * )fonts_path ) == FcFalse )
        {
            g_warning( "FAILED TO READ FONTS" );
        }
        else
        {
            // This transfers ownership of the config object over to FC, so we
            // don't have to destroy it or unref it.

            FcConfigSetCurrent( config );

            config = NULL;

            g_info( "FONT CONFIGURATION COMPLETE" );
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

                    tp_controller_key_down( ( TPController * )controller, event->key.keyval, event->key.unicode_value );
                    return TRUE;
                }

                break;
            }

            case CLUTTER_KEY_RELEASE:
            {
                if ( !( event->key.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    tp_controller_key_up( ( TPController * )controller, event->key.keyval, event->key.unicode_value );
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

#ifndef TP_PRODUCTION

// This one deals with escape to exit current app

gboolean escape_handler( ClutterActor * actor, ClutterEvent * event, gpointer context )
{
    if ( event && event->any.type == CLUTTER_KEY_PRESS && event->key.keyval == CLUTTER_Escape )
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
    // Start the console

#ifndef TP_PRODUCTION

    g_info( "STARTING CONSOLE..." );

    console = new Console( this,
                           get_bool( TP_CONSOLE_ENABLED, TP_CONSOLE_ENABLED_DEFAULT ),
                           get_int( TP_TELNET_CONSOLE_PORT, TP_TELNET_CONSOLE_PORT_DEFAULT ) );
    console->add_command_handler( console_command_handler, this );

#endif

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

#ifndef TP_CLUTTER_BACKEND_EGL

#ifndef TP_PRODUCTION

    g_signal_connect( stage, "captured-event", ( GCallback )escape_handler, this );
    g_signal_connect( stage, "captured-event", ( GCallback )tilde_handler, this );

#endif

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

        result = current_app->run();

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

            clutter_main();

            notify( TP_NOTIFICATION_APP_CLOSING );

            notify( TP_NOTIFICATION_APP_CLOSED );
        }
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
    // Not running any more

    is_running = false;

    return result;
}

//-----------------------------------------------------------------------------

int TPContext::load_app( App ** app )
{
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
        app_path = get( TP_APP_PATH );
    }

    // Load metadata

    App::Metadata md;

    if ( !App::load_metadata( app_path.c_str(), md ) )
    {
        return TP_RUN_APP_CORRUPT;
    }

    // Load the app

    *app = App::load( this, md );

    if ( !*app )
    {
        return TP_RUN_APP_PREPARE_FAILED;
    }

    controller_list.reset_all();

    return TP_RUN_OK;
}

//-----------------------------------------------------------------------------

int TPContext::launch_app( const char * app_id )
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

    App * new_app = App::load( this, md );

    if ( !new_app )
    {
        return TP_RUN_APP_PREPARE_FAILED;
    }

    int result = new_app->run();

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
            if ( new_app->run() == TP_RUN_OK )
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
        if ( new_app->run() == TP_RUN_OK )
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

void TPContext::quit()
{
    if ( !is_running )
    {
        return;
    }

    clutter_main_quit();
}

//-----------------------------------------------------------------------------

void TPContext::add_console_command_handler( const char * command, TPConsoleCommandHandler handler, void * data )
{
    console_command_handlers.insert( std::make_pair( String( command ), ConsoleCommandHandlerClosure( handler, data ) ) );
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
                    gchar * k = g_strstrip( g_strdelimit( ( *e ) + 3, "_", '.' ) );

                    g_info( "ENV:%s=%s", k, v );
                    set( k, v );
                }
            }
        }

        g_strfreev( env );
    }

    const char * file_name = get( TP_CONFIG_FROM_FILE, TP_CONFIG_FROM_FILE_DEFAULT );

    gchar * contents = NULL;

    if ( g_file_get_contents( file_name, &contents, NULL, NULL ) )
    {
        gchar ** lines = g_strsplit( contents, "\n", 0 );

        for ( gchar ** l = lines; *l; ++l )
        {
            gchar * line = g_strstrip( *l );

            if ( g_str_has_prefix( line, "#" ) )
            {
                continue;
            }

            gchar ** parts = g_strsplit( line, "=", 2 );

            if ( g_strv_length( parts ) == 2 )
            {
                gchar * k = g_strstrip( parts[0] );
                gchar * v = g_strstrip( parts[1] );

                g_info( "FILE:%s:%s=%s", file_name, k, v );
                set( k, v );
            }

            g_strfreev( parts );
        }

        g_strfreev( lines );
        g_free( contents );
    }
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

    if ( !app_path && !get( TP_APP_ID ) )
    {
        gchar * c = g_get_current_dir();
        set( TP_APP_PATH, c );
        g_warning( "DEFAULT:%s=%s", TP_APP_PATH, c );
        g_free( c );
    }

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

    // SCREEN WIDTH AND HEIGHT

    if ( !get( TP_SCREEN_WIDTH ) )
    {
        set( TP_SCREEN_WIDTH, TP_SCREEN_WIDTH_DEFAULT );
    }

    if ( !get( TP_SCREEN_HEIGHT ) )
    {
        set( TP_SCREEN_HEIGHT, TP_SCREEN_HEIGHT_DEFAULT );
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

    if ( log_level & G_LOG_LEVEL_ERROR )
    {
        level = "ERROR";
    }
    else if ( log_level & G_LOG_LEVEL_CRITICAL )
    {
        level = "CRITICAL";
    }
    else if ( log_level & G_LOG_LEVEL_WARNING )
    {
        level = "WARNING";
    }
    else if ( log_level & G_LOG_LEVEL_MESSAGE )
    {
        level = "MESSAGE";
    }
    else if ( log_level & G_LOG_LEVEL_INFO )
    {
        level = "INFO";
    }
    else if ( log_level & G_LOG_LEVEL_DEBUG )
    {
        level = "DEBUG";
    }

    return g_strdup_printf( "%p %2.2d:%2.2d:%2.2d:%3.3lu %s %s %s\n" ,
                            g_thread_self() ,
                            hour , min , sec , ms , level , log_domain , message );
}

//-----------------------------------------------------------------------------

SystemDatabase * TPContext::get_db() const
{
    g_assert( sysdb );
    return sysdb;
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

//=============================================================================
// External-facing functions
//=============================================================================

void tp_init_version( int * argc, char ** * argv, int major_version, int minor_version, int patch_version )
{
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
