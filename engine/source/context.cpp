#include <cstdlib>
#include <sstream>
#include <stdlib.h>

#include <execinfo.h>
#include <cxxabi.h>

#include "tp-clutter.h"
#include "clutter/clutter-keysyms.h"
#include "curl/curl.h"
#include "fontconfig/fontconfig.h"

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
#include "controller_lirc.h"
#include "app_push_server.h"
#include "http_server.h"
#include "http_trickplay_api_support.h"
#include "clutter_util.h"
#include "console_commands.h"
#include "desktop_controller.h"
#include "ansi_color.h"

#ifdef TP_WITH_GAMESERVICE
#include "libgameservice.h"
#include "gameservice_support.h"
#endif

//-----------------------------------------------------------------------------
#ifndef TP_DEFAULT_RESOURCES_PATH
#define TP_DEFAULT_RESOURCES_PATH   "/usr/share/trickplay/resources"
#endif
//-----------------------------------------------------------------------------

static int g_argc     = 0;
static char** g_argv = 0;

#ifdef TP_UNLICENSED_TIMEOUT
static gboolean unlicensed_timeout_cb( gpointer _stage )
{
    static ClutterActor* texture = NULL;
    ClutterActor* stage = CLUTTER_ACTOR( _stage );

    if ( NULL == texture )
    {
        // Handle timeout here
        // We will just insert a big semi-opaque TrickPlay logo image, stick it on top of everything in Clutter

        texture = clutter_text_new_full( "LG Display bold 20px", "TrickPlay - DEBUG - " TP_GIT_VERSION, clutter_color_get_static( CLUTTER_COLOR_YELLOW ) );
        clutter_actor_set_name( texture, "Unlicensed Scrim" );

        g_object_ref_sink( texture );

        clutter_actor_set_position( texture, clutter_actor_get_width( stage ), clutter_actor_get_height( stage ) );
        clutter_actor_set_translation( texture, -clutter_actor_get_width( texture ), -clutter_actor_get_height( texture ), 0 );

        //    guchar * t = g_new0( guchar , 4 * width * height );

        //    clutter_texture_set_from_rgb_data( CLUTTER_TEXTURE( texture ) , t , TRUE , width , height , 4 * width , 4 , CLUTTER_TEXTURE_NONE , 0 );

        //    g_free( t );

        clutter_actor_add_child( stage, texture );
    }

    if ( CLUTTER_ACTOR_IS_VISIBLE( texture ) )
    {
        clutter_actor_hide( texture );
    }
    else
    {
        clutter_actor_show( texture );
        clutter_actor_set_child_above_sibling( stage, texture, NULL );
    }

    return TRUE;
}
#endif

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
    :
    is_running( false ),
    stage( NULL ),
    sysdb( NULL ),
    controller_server( NULL ),
    controller_lirc( NULL ),
    app_push_server( NULL ),
    http_server( NULL ),
    console( NULL ),
    downloads( NULL ),
    installer( NULL ),
    current_app( NULL ),
#ifdef TP_WITH_GAMESERVICE
    gameservice_support( NULL ),
#endif
    media_player_constructor( NULL ),
    //media_player( NULL ),
    http_trickplay_api_support( NULL ),
    external_log_handler( NULL ),
    external_log_handler_data( NULL ),
    user_data( NULL )
{
    g_log_set_default_handler( TPContext::log_handler, this );
}

//-----------------------------------------------------------------------------

TPContext::~TPContext()
{
    // Free all the internals by calling their destroy notify

    for ( InternalMap::iterator it = internals.begin(); it != internals.end(); ++ it )
    {
        if ( it->second.second )
        {
            it->second.second( it->second.first );
        }
    }
}

//-----------------------------------------------------------------------------

void TPContext::set( const char* key, const char* value )
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

void TPContext::set( const char* key, int value )
{
    g_assert( key );

    std::stringstream str;
    str << value;
    set( key, str.str() );
}

//-----------------------------------------------------------------------------

void TPContext::set( const char* key, const String& value )
{
    g_assert( key );

    config[String( key )] = value;
}
//-----------------------------------------------------------------------------

const char* TPContext::get( const char* key, const char* def , bool default_if_empty ) const
{
    g_assert( key );

    StringMap::const_iterator it = config.find( String( key ) );

    if ( it == config.end() )
    {
        return def;
    }

    if ( default_if_empty && it->second.empty() )
    {
        return def;
    }

    return it->second.c_str();
}

//-----------------------------------------------------------------------------

bool TPContext::get_bool( const char* key, bool def ) const
{
    const char* value = get( key );

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

int TPContext::get_int( const char* key, int def ) const
{
    const char* value = get( key );

    if ( !value )
    {
        return def;
    }

    return atoi( value );
}

//-----------------------------------------------------------------------------

int TPContext::console_command_handler( const char* command, const char* parameters, void* self )
{
    TPContext* context = ( TPContext* ) self;

    std::pair<ConsoleCommandHandlerMultiMap::const_iterator, ConsoleCommandHandlerMultiMap::const_iterator>
    range = context->console_command_handlers.equal_range( String( command ) );

    for ( ConsoleCommandHandlerMultiMap::const_iterator it = range.first; it != range.second; ++it )
    {
        it->second.first( context , command, parameters, it->second.second );
    }

    return range.first != range.second;
}

//-----------------------------------------------------------------------------

void TPContext::setup_fonts()
{
    FreeLater free_later;

    // Get the a directory where fonts live

    String fonts_path;

    if ( const char* fp = get( TP_FONTS_PATH , 0 , true ) )
    {
        fonts_path = Util::canonical_external_path( fp );
    }
    else
    {
        gchar* s = g_build_filename( get( TP_RESOURCES_PATH ) , "fonts" , NULL );

        if ( g_file_test( s , G_FILE_TEST_EXISTS ) )
        {
            fonts_path = s;
            g_free( s );
        }
        else
        {
            g_free( s );
            g_warning( "USING SYSTEM FONTS" );
            return;
        }
    }

    // We create a directory called "fonts" in our data directory. There,
    // we will have a tiny configuration file and the fontconfig cache.

    gchar* font_cache_path = g_build_filename( get( TP_DATA_PATH ), "fonts", NULL );
    free_later( font_cache_path );

    if ( g_mkdir_with_parents( font_cache_path, 0700 ) != 0 )
    {
        g_error( "FAILED TO CREATE FONT CACHE DIRECTORY '%s'", font_cache_path );
    }

    // We write the configuration file that sets the cache directory

    gchar* font_conf_file_name = g_build_filename( font_cache_path, "fonts.conf", NULL );
    free_later( font_conf_file_name );

    if ( !g_file_test( font_conf_file_name, G_FILE_TEST_EXISTS ) )
    {
        gchar* conf = g_strdup_printf( "<fontconfig><cachedir>%s</cachedir></fontconfig>", font_cache_path );
        g_file_set_contents( font_conf_file_name, conf, -1, NULL );
        g_free( conf );
    }

#ifdef TP_FONT_DEBUG

    // This is here ONLY so that FC_DEBUG will work; so we can troubleshoot
    // font problems

    ( void ) FcInitLoadConfig();

#endif

    FcConfig* config = FcConfigCreate();

    g_assert( config );

    // Parse and load our tiny configuration file

    if ( FcConfigParseAndLoad( config, ( const FcChar8* )font_conf_file_name, FcTrue ) == FcFalse )
    {
        g_warning( "FAILED TO PARSE FONTCONFIG CONFIGURATION FILE" );
    }
    else
    {
        FcConfigAppFontClear( config );

        const char* ap = get( TP_APP_SOURCES );

        g_debug( "ADDING APP PATH '%s' TO FONT PATH", ap );

        int added = 0;

        if ( FcConfigAppFontAddDir( config, ( const FcChar8* ) ap ) == FcFalse )
        {
            g_warning( "FAILED TO ADD FONT PATH '%s'" , ap );
        }
        else
        {
            ++added;
        }

        g_debug( "FONT PATHS ARE '%s'", fonts_path.c_str() );

        // This adds all the fonts in the directory to the cache...it can take
        // a long time the first time around. Once the cache exists, it will
        // be very quick.

        gchar** paths = g_strsplit( fonts_path.c_str() , ";" , 0 );

        for ( gchar** p = paths; *p; ++p )
        {
            gchar* path = g_strstrip( *p );

            g_debug( "ADDING FONT PATH '%s'", path );

            if ( FcConfigAppFontAddDir( config, ( const FcChar8* ) path ) == FcFalse )
            {
                g_warning( "FAILED TO ADD FONT PATH '%s'" , path );
            }
            else
            {
                ++added;
            }
        }

        g_strfreev( paths );

        if ( added )
        {
            // This transfers ownership of the config object over to FC, so we
            // don't have to destroy it or unref it.

            FcConfigSetCurrent( config );

            config = NULL;

            g_debug( "FONT CONFIGURATION COMPLETE" );
        }
    }

    // If something went wrong, we destroy the config

    if ( config )
    {
        FcConfigDestroy( config );
    }
}

//-----------------------------------------------------------------------------
// This one deals with the ESCAPE and EXIT keys to exit the current app. If the current
// app is the first one, this will also exit from the call to tp_context_run.

gboolean TPContext::escape_handler( ClutterActor* actor, ClutterEvent* event, gpointer _context )
{
    if ( event && (
            ( event->any.type == CLUTTER_KEY_PRESS && ( event->key.keyval == CLUTTER_Escape || event->key.keyval == TP_KEY_EXIT ) ) ||
            event->any.type == CLUTTER_DELETE
            )
       )
    {
        // In production builds, the ESCAPE key is not used - it just passes through

#ifdef TP_PRODUCTION

        if ( event->key.keyval == CLUTTER_Escape )
        {
            return FALSE;
        }

#endif

        TPContext* context = ( TPContext* ) _context;

        if ( ! context->is_first_app() || context->get_bool( TP_FIRST_APP_EXITS , true ) )
        {
            context->close_app();
            return TRUE;
        }
    }

    return FALSE;
}

//-----------------------------------------------------------------------------


#ifndef TP_PRODUCTION

// This one deals with tilde to reload current app

gboolean TPContext::tilde_handler( ClutterActor* actor, ClutterEvent* event, gpointer context )
{
    if ( event && event->any.type == CLUTTER_KEY_PRESS && event->key.keyval == CLUTTER_asciitilde )
    {
        ( ( TPContext* )context )->reload_app();

        return TRUE;
    }

    return FALSE;
}

#endif

//-----------------------------------------------------------------------------
// When profiling is enabled, these signal handlers let us know when painting
// the stage begins and ends.

#ifdef TP_PROFILING

static gpointer paint_profiler = 0;

static void before_paint( ClutterActor* actor , gpointer )
{
    paint_profiler = PROFILE_START( "PAINT" , PROFILER_INTERNAL_CALLS );
}

static void after_paint( ClutterActor* actor , gpointer )
{
    PROFILE_STOP( paint_profiler );
}

#endif

//-----------------------------------------------------------------------------

class RunningAction : public Action
{
public:

    RunningAction( TPContext* _context )
        :
        context( _context )
    {}

private:

    virtual bool run()
    {
        context->notify( context , TP_NOTIFICATION_RUNNING );

        return false;
    }

    TPContext* context;
};

//-----------------------------------------------------------------------------
// Sometimes the stage goes un-fullscreen when it shouldn't. This corrects
// that.

void stage_unfullscreen( ClutterStage* stage , gpointer user_data )
{
    clutter_stage_set_fullscreen( stage , TRUE );
}

//-----------------------------------------------------------------------------

#ifdef TP_FORCE_VERIFICATION

static void do_handshake()
{
    static const gchar HANDSHAKE_PREFIX[4] = TP_VERIFICATION_CODE;

    gchar code[4];
    gchar suffix[4];

    for ( int i = 0; i < 3; i++ )
    {
        code[i] = g_random_int_range( 'A', 'Z' );
        signed int my_result = code[i] + HANDSHAKE_PREFIX[i] - 'A';

        if ( my_result > 'Z' )
        {
            my_result -= 26;
        }

        suffix[i] = my_result;
    }

    code[3] = '\0';
    suffix[3] = '\0';

    gchar response[7];

    memset( response , 0 , sizeof( response ) );

    gchar* url = g_strdup_printf( "http://trickplay.com/verify/?CODE=%s%s", HANDSHAKE_PREFIX , suffix );

    {
        Network::Request  rq;

        rq.url = url;
        rq.timeout_s = 10;
        rq.redirect = true;

        Network::Response r( Network().perform_request( rq , 0 ) );

        if ( ! r.failed && r.code == 200 && r.body && r.body->len >= 6 )
        {
            memmove( response , r.body->data , 6 );
        }
    }

    if ( 6 != strlen( response ) )
    {
        memset( response , 0 , sizeof( response ) );

        g_warning( "Network auto-verification failed.  Please use manual verification below." );

        g_info( "Visit the URL: %s" , url );

        g_info( "Now please type the code it gives back: " );

        fgets( response, 7, stdin );
    }

    g_free( url );

    for ( int i = 0; i < 3; i++ )
    {
        signed int result = response[3 + i] - response[i];

        if ( result < 0 )
        {
            result += 26;
        }

        if ( ( result + 'A' ) != code[i] )
        {
            g_critical( "YOUR CHECK CODE FAILED (%c,%c).  PLEASE CONTACT TRICKPLAY SUPPORT.", code[i], response[3 + i] );
            fflush( stdout );
            fflush( stderr );
            abort();
        }
    }
}
#endif

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

#ifdef TP_FORCE_VERIFICATION
    do_handshake();
#endif

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
        const char* app_sources = get( TP_APP_SOURCES );
        gchar* installed_root = g_build_filename( get( TP_DATA_PATH ), "apps", NULL );

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

    notify( this , TP_NOTIFICATION_PROFILE_CHANGED );

    //.........................................................................

    http_server = new HttpServer( get_int( TP_HTTP_PORT , 0 ) );

    set( TP_HTTP_PORT, http_server->get_port() );

    http_trickplay_api_support = new HttpTrickplayApiSupport( this );

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

        const char* new_name = get( TP_CONTROLLERS_NAME );

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

        ConsoleCommands::add_all( this );
    }

    //.........................................................................
    // Set default size and color for the stage

    g_info( "GRABBING CLUTTER LOCK..." );

    clutter_threads_enter();

    g_info( "INITIALIZING STAGE..." );

    stage = clutter_stage_new();

    g_assert( stage != NULL );

    int display_width = get_int( TP_SCREEN_WIDTH );
    int display_height = get_int( TP_SCREEN_HEIGHT );

    if ( display_width <= 0 || display_height <= 0 )
    {
        clutter_stage_set_fullscreen( CLUTTER_STAGE( stage ) , TRUE );

        g_signal_connect( stage , "unfullscreen" , ( GCallback ) stage_unfullscreen , 0 );
    }
    else
    {
        clutter_actor_set_size( stage , display_width , display_height );
    }

    clutter_actor_set_name( stage , "stage" );

#ifndef TP_CLUTTER_BACKEND_EGL

    clutter_stage_set_title( CLUTTER_STAGE( stage ) , "TrickPlay" );

#endif

    ClutterColor color;
    color.red = 0;
    color.green = 0;
    color.blue = 0;
    color.alpha = 0;

    clutter_actor_set_background_color( stage, &color );

    clutter_stage_set_use_alpha( CLUTTER_STAGE( stage ) , true );

#ifdef TP_PROFILING

    g_signal_connect( stage , "paint" , ( GCallback ) before_paint , 0 );
    g_signal_connect_after( stage , "paint" , ( GCallback ) after_paint , 0 );

#endif

    g_signal_connect( stage, "captured-event", ( GCallback ) escape_handler, this );
    g_signal_connect( stage, "delete-event", ( GCallback ) escape_handler, this );

#ifndef TP_PRODUCTION

    g_signal_connect( stage, "captured-event", ( GCallback )tilde_handler, this );

#endif

    install_desktop_controller( this );

    clutter_stage_set_throttle_motion_events( CLUTTER_STAGE( stage ) , FALSE );

    //.........................................................................
    // Create the default media player. This may come back NULL.

    if ( get_bool( TP_MEDIAPLAYER_ENABLED , true ) )
    {
        g_info( "CREATING MEDIA PLAYER..." );

        media_player.push_back( MediaPlayer::make( this , media_player_constructor ) );
    }
    else
    {
        g_info( "MEDIA PLAYER IS DISABLED..." );
    }

    //.........................................................................
    // connect to gameservice server
#ifdef TP_WITH_GAMESERVICE

    if ( get_bool( TP_GAMESERVICE_ENABLED ) )
    {
        libgameservice::setGameServiceXmppDomain( get( TP_GAMESERVICE_DOMAIN ) );
        gameservice_support = new GameServiceSupport( this );
    }

#endif
    //.........................................................................

    load_background();

    //.........................................................................
    // Load the app

    bool run_app = ! get_bool( TP_DONT_RUN_APP , false );

    g_info( "LOADING APP..." );

    App* app = 0;

    result = load_app( & app );

    if ( app )
    {

#ifndef TP_PRODUCTION

        // Output a machine-readable JSON string with all
        // the "control" ports.

        g_info( "<<CONTROL>>:%s" , get_control_message( app ).c_str() );

#endif

        //.....................................................................
        // Execute the app's script

        first_app_id = app->get_id();

        if ( run_app )
        {
            app->run( app_allowed[ first_app_id ] , app_run_callback );
        }

        app->unref();

        app = 0;

        //.................................................................

        Action::post( new RunningAction( this ) );

        //.................................................................
        // Schedule unlicensed timeout if called for
#ifdef TP_UNLICENSED_TIMEOUT
        unsigned long unlicensed_timeout = ::strtoul( TP_UNLICENSED_TIMEOUT, NULL, 0 );
        g_warning( "SETTING UNLICENSED TIMEOUT FOR %lu SECONDS", unlicensed_timeout );

        g_timeout_add_seconds( unlicensed_timeout, unlicensed_timeout_cb, ( gpointer )stage );
#endif

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
                if ( is_first_app() )
                {
                    g_warning( "CAUGHT EXCEPTION IN RUN LOOP, EXITING" );

                    result = TP_RUN_APP_ERROR;

                    break;
                }
                else
                {
                    g_warning( "CAUGHT EXCEPTION IN RUN LOOP, CLOSING APP" );

                    close_current_app();

                    reload_app();
                }
            }
        }

    }

    //.....................................................................

    notify( this , TP_NOTIFICATION_EXITING );

    //.....................................................................
    // Keep further events from being processed.

    controller_list.stop_events();

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

    if ( media_player.size() )
    {
        std::list<MediaPlayer*>::iterator itr = media_player.begin();
        (*itr)->reset();
    }

    //.....................................................................
    // Clean up the stage

    clutter_actor_remove_all_children( stage );

    //.....................................................................
    // Shutdown the app

    if ( current_app )
    {
        current_app->unref();
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

    if ( media_player.size() )
    {
        for (std::list<MediaPlayer*>::iterator itr = media_player.begin(); itr != media_player.end(); itr++)
            delete (MediaPlayer *) (*itr);
        media_player.clear();
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

    if ( http_trickplay_api_support )
    {
        delete http_trickplay_api_support;
        http_trickplay_api_support = NULL;
    }

    //.........................................................................

    if ( http_server )
    {
        delete http_server;
        http_server = NULL;
    }

    //.........................................................................
    // Get rid of the system database

    delete sysdb;
    sysdb = NULL;

    //.........................................................................

    Images::shutdown();

    //.........................................................................
    // Not running any more


    g_debug( "DESTROYING STAGE..." );
    clutter_actor_destroy( stage );


    g_debug( "RELEASING CLUTTER LOCK..." );
    clutter_threads_leave();

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

        gchar* app_path = g_build_filename( data_directory.c_str(), "source", NULL );

        free_later( app_path );

        if ( 0 == g_mkdir_with_parents( app_path, 0700 ) )
        {
            gchar* app = g_build_filename( app_path, "app", NULL );

            free_later( app );

            if ( ! g_file_test( app , G_FILE_TEST_EXISTS ) )
            {
                g_file_set_contents( app, "app={id='com.trickplay.empty',name='Empty',version='1.0',release=1,attributes={'nolauncher'}}", -1, NULL );
            }

            gchar* main = g_build_filename( app_path, "main.lua", NULL );

            free_later( main );

            if ( ! g_file_test( main , G_FILE_TEST_EXISTS ) )
            {
                g_file_set_contents( main, "--Automatically Created", -1, NULL );
            }

            result = app_path;
        }
    }

    g_info( "CREATED EMPTY APP" );

#endif

    return result;
}

//-----------------------------------------------------------------------------

int TPContext::load_app( App** app )
{
    PROFILER( "TPContext::load_app" , PROFILER_INTERNAL_CALLS );

    String app_path;

    // If an app id was specified, we will try to find the app by id, in the
    // system database

    const char* app_id = get( TP_APP_ID );

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

        const char* ap = get( TP_APP_PATH );

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

int TPContext::launch_app( const char* app_id, const App::LaunchInfo& launch , bool id_is_path )
{
    String app_path = id_is_path ? app_id : get_db()->get_app_path( app_id );

    if ( app_path.empty() )
    {
        return TP_RUN_APP_NOT_FOUND;
    }

    App::Metadata md;

    if ( !App::load_metadata( app_path.c_str(), md ) )
    {
        return TP_RUN_APP_CORRUPT;
    }

    App* new_app = App::load( this, md, launch );

    if ( !new_app )
    {
        return TP_RUN_APP_PREPARE_FAILED;
    }

    new_app->run( app_allowed[ new_app->get_id() ] , app_run_callback );
    new_app->unref();

    return 0;
}

//-----------------------------------------------------------------------------

void TPContext::app_run_callback( App* app , int result )
{
    TPContext* context = app->get_context();

    String id( app->get_id() );

    if ( result != TP_RUN_OK )
    {
        if ( context->first_app_id == id )
        {
            context->quit();
        }
    }
    else
    {
        context->close_current_app();

        if ( context->console )
        {
            context->console->attach_to_lua( app->get_lua_state() );
        }

        context->current_app = app;

        context->current_app->ref();

        if ( context->first_app_id != id )
        {
            context->get_db()->app_launched( id );
        }

        app->animate_in();
    }
}

//-----------------------------------------------------------------------------

void TPContext::close_app()
{
    if ( is_first_app() )
    {
        quit();
    }
    else
    {
        App* new_app = NULL;

        load_app( &new_app );

        if ( new_app )
        {
            new_app->run( app_allowed[ new_app->get_id() ] , app_run_callback );
            new_app->unref();
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

        current_app->unref();

        current_app = NULL;
    }
}

//-----------------------------------------------------------------------------

void TPContext::reload_app()
{
    close_current_app();

    App* new_app = NULL;

    load_app( &new_app );

    if ( !new_app )
    {
        g_warning( "FAILED TO RELOAD APP" );
    }
    else
    {
        new_app->run( app_allowed[ new_app->get_id() ] , app_run_callback );
        new_app->unref();
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
        g_idle_add_full( TRICKPLAY_PRIORITY , delayed_quit, 0 , 0 );
    }
}

//-----------------------------------------------------------------------------

void TPContext::add_console_command_handler( const char* command, TPConsoleCommandHandler handler, void* data )
{
    console_command_handlers.insert( std::make_pair( String( command ), ConsoleCommandHandlerClosure( handler, data ) ) );
}

void TPContext::remove_console_command_handler( const char* command, TPConsoleCommandHandler handler, void* data )
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

class LogHandlerAction : public Action
{
public:

    LogHandlerAction( gchar* _line , const TPContext::OutputHandlerSet& _handlers )
        :
        line( _line ),
        handlers( _handlers )
    {}

    virtual ~LogHandlerAction()
    {
        g_free( line );
    }

protected:

    virtual bool run()
    {
        for ( TPContext::OutputHandlerSet::const_iterator it = handlers.begin(); it != handlers.end(); ++it )
        {
            it->first( line, it->second );
        }

        return false;
    }

private:

    gchar*                      line;
    TPContext::OutputHandlerSet handlers;
};

//-----------------------------------------------------------------------------

void TPContext::log_handler( const gchar* log_domain, GLogLevelFlags log_level, const gchar* message, gpointer self )
{
    static enum { CHECK , NORMAL , ENGINE , APP , APP_RAW , SILENT , BARE } verbose = CHECK;

    if ( verbose == CHECK )
    {
        verbose = NORMAL;

        if ( const gchar* e = g_getenv( "TP_LOG" ) )
        {
            if ( ! strcmp( e , "engine" ) )
            {
                verbose = ENGINE;
            }
            else if ( ! strcmp( e , "app" ) )
            {
                verbose = APP;
            }
            else if ( ! strcmp( e , "raw" ) )
            {
                verbose = APP_RAW;
            }
            else if ( ! strcmp( e , "silent" ) )
            {
                verbose = SILENT;
            }
            else if ( ! strcmp( e , "bare" ) )
            {
                verbose = BARE;
            }
        }
    }

    switch ( verbose )
    {
        case NORMAL:
            break;

        case SILENT:
            return;

        case ENGINE:
            if ( log_level == G_LOG_LEVEL_MESSAGE )
            {
                return;
            }

            break;

        case APP:
            if ( log_level != G_LOG_LEVEL_MESSAGE )
            {
                return;
            }

            break;

        case APP_RAW:
            if ( log_level == G_LOG_LEVEL_MESSAGE )
            {
                fprintf( stderr, "%s\n", message );
                fflush( stderr );
            }

            return;

        case BARE:
            fprintf( stderr , "%s\n" , message );
            fflush( stderr );
            return;

        default:
            break;
    }

    gchar* line = 0;

    // This is before a context is created, so we just print out the message

    if ( !self )
    {
        line = format_log_line( log_domain, log_level, message );
        fprintf( stderr, "%s", line );
        fflush( stderr );
    }

    // Otherwise, we have a context and more choices as to what we can do with
    // the log messages

    else
    {
        TPContext* context = ( TPContext* )self;

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
                context->external_log_handler( context , log_level, log_domain, message, context->external_log_handler_data );
            }
            else
            {
                line = format_log_line( log_domain, log_level, message );
                fprintf( stderr, "%s", line );
                fflush( stderr );
            }

            if ( !context->output_handlers.empty() )
            {
                if ( ! line )
                {
                    line = format_log_line( log_domain, log_level, message );
                }

                // Because we are already being called by g_logv and it is not
                // recursive/re-entrant, we defer logging to other handlers by posting an
                // action.

                Action::post( new LogHandlerAction( line , context->output_handlers ) );

                // The action will free the original line when it is finished with it,
                // so we clear it here

                line = 0;
            }
        }
    }

    g_free( line );
}

//-----------------------------------------------------------------------------

void TPContext::set_log_handler( TPLogHandler handler, void* data )
{
    g_assert( !running() );

    external_log_handler = handler;
    external_log_handler_data = data;
}

//-----------------------------------------------------------------------------

void TPContext::set_resource_loader( unsigned int type , TPResourceLoader loader , void* data )
{
    g_assert( !running() );
    g_assert( loader );

    resource_loaders[ type ] = ResourceLoaderClosure( loader , data );
}

//-----------------------------------------------------------------------------

bool TPContext::get_resource_loader( unsigned int resource_type , TPResourceLoader* loader , void * * user_data ) const
{
    if ( ! get_bool( TP_RESOURCE_LOADER_ENABLED , true ) )
    {
        return false;
    }

    ResourceLoaderMap::const_iterator it = resource_loaders.find( resource_type );

    if ( it == resource_loaders.end() )
    {
        return false;
    }

    * loader = it->second.first;
    * user_data = it->second.second;

    return true;
}

//-----------------------------------------------------------------------------

void TPContext::set_request_handler( const char* subject, TPRequestHandler handler, void* data )
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

int TPContext::request( const char* subject )
{
    RequestHandlerMap::const_iterator it = request_handlers.find( String( subject ) );

    return it == request_handlers.end() ? 1 : it->second.first( this , subject , it->second.second );
}

//-----------------------------------------------------------------------------
// Load configuration variables from the environment or a file

void TPContext::load_external_configuration()
{
    if ( get_bool( TP_CONFIG_FROM_ENV, TP_CONFIG_FROM_ENV_DEFAULT ) )
    {
        gchar** env = g_listenv();

        for ( gchar** e = env; *e; ++e )
        {
            if ( g_str_has_prefix( *e, "TP_" ) )
            {
                if ( const gchar* v = g_getenv( *e ) )
                {
                    gchar* k = g_strstrip( ( *e ) + 3 );

                    g_info( "ENV:%s=%s", k, v );
                    set( k, v );
                }
            }
        }

        g_strfreev( env );
    }

    FreeLater free_later;

    const char* file_name = get( TP_CONFIG_FROM_FILE );

    // Giving an empty file name for the config file disables
    // processing of all config files.

    if ( file_name && ( 0 == strlen( file_name ) ) )
    {
        g_warning( "CONFIG FILE DISABLED" );
        return;
    }

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

            const gchar* home = g_getenv( "HOME" );

            if ( ! home )
            {
                home = g_get_home_dir();

                if ( ! home )
                {
                    return;
                }
            }

            gchar* path = g_build_filename( home , TP_CONFIG_FROM_FILE_DEFAULT , NULL );

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

    lua_State* L = luaL_newstate();

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

    for ( const luaL_Reg* lib = lualibs; lib->func; ++lib )
    {
        luaL_requiref( L, lib->name, lib->func, 1 );
        lua_pop( L, 1 ); /* remove lib */
    }

    //.....................................................................
    // Create a new table to hold command line options

    lua_newtable( L );

    if ( g_argc && g_argv )
    {
        for ( int i = 1; i < g_argc; ++i )
        {
            lua_pushstring( L , g_argv[ i ] );
            lua_rawseti( L , -2 , i );
        }
    }

    gchar* d = g_path_get_dirname( file_name );

    if ( ! strcmp( d , "." ) )
    {
        g_free( d );

        d = g_get_current_dir();
    }

    lua_pushstring( L , d );
    lua_rawseti( L , -2 , 0 );

    g_free( d );

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

    const char* names[] =
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
        TP_VIRTUAL_WIDTH,
        TP_VIRTUAL_HEIGHT,
        TP_SCREEN_ROTATION,
        TP_CONFIG_FROM_ENV,
        TP_CONFIG_FROM_FILE,
        TP_CONSOLE_ENABLED,
        TP_TELNET_CONSOLE_PORT,
        TP_CONTROLLERS_ENABLED,
        TP_CONTROLLERS_PORT,
        TP_CONTROLLERS_NAME,
        TP_CONTROLLERS_MDNS_ENABLED,
        TP_CONTROLLERS_UPNP_ENABLED,
        TP_LOG_DEBUG,
        TP_LOG_APP_ONLY,
        TP_FONTS_PATH,
        TP_DOWNLOADS_PATH,
        TP_NETWORK_DEBUG,
        TP_SSL_VERIFYPEER,
        TP_SSL_CA_CERT_FILE,
        TP_LIRC_ENABLED,
        TP_LIRC_UDS,
        TP_LIRC_REPEAT,
        TP_APP_PUSH_ENABLED,
        TP_MEDIAPLAYER_ENABLED,
        TP_MEDIAPLAYER_SCHEMES,
        TP_IMAGE_DECODER_ENABLED,
        TP_RANDOM_SEED,
        TP_PLUGINS_PATH,
        TP_AUDIO_SAMPLER_ENABLED,
        TP_AUDIO_SAMPLER_MAX_INTERVAL,
        TP_AUDIO_SAMPLER_MAX_BUFFER_KB,
        TP_TOAST_JSON_PATH,
        TP_FIRST_APP_EXITS,
        TP_HTTP_PORT,
        TP_RESOURCES_PATH,
        TP_TEXTURE_CACHE_LIMIT,
        TP_RESOURCE_LOADER_ENABLED,
        TP_APP_ARGS,
        TP_APP_ANIMATIONS_ENABLED,
        TP_DEBUGGER_PORT,
        TP_START_DEBUGGER,
        TP_GAMESERVICE_ENABLED,
        TP_GAMESERVICE_DOMAIN,
        TP_GAMESERVICE_HOST,
        TP_GAMESERVICE_PORT,

        NULL
    };

    for ( const char * * name = names; *name; ++name )
    {
        lua_getglobal( L, * name );

        if ( ! lua_isnil( L, -1 ) )
        {
            const char* value = lua_tostring( L, -1 );

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

    String app_sources = Util::canonical_external_path( get( TP_APP_SOURCES , "apps" , true ) );

    set( TP_APP_SOURCES, app_sources );


    // TP_APP_PATH

    const char* app_path = get( TP_APP_PATH );

    if ( app_path )
    {
        String app_path_s = Util::canonical_external_path( app_path , false );

        if ( ! app_path_s.empty() )
        {
            set( TP_APP_PATH , app_path_s );
        }
    }

    // TP_SYSTEM_LANGUAGE

    const char* language = get( TP_SYSTEM_LANGUAGE );

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

    const char* country = get( TP_SYSTEM_COUNTRY );

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

    String data_path = Util::canonical_external_path( get( TP_DATA_PATH , g_get_tmp_dir() , true ) );

    gchar* full_data_path = g_build_filename( data_path.c_str() , "trickplay" , NULL );

    if ( g_mkdir_with_parents( full_data_path , 0700 ) != 0 )
    {
        g_error( "DATA PATH '%s' DOES NOT EXIST AND COULD NOT BE CREATED" , full_data_path );
    }

    set( TP_DATA_PATH, full_data_path );

    g_debug( "USING DATA PATH: '%s'", full_data_path );

    g_free( full_data_path );

    // DOWNLOADS PATH

    gchar* default_downloads_path = g_build_filename( get( TP_DATA_PATH ) , "downloads" , NULL );

    String downloads_path = Util::canonical_external_path( get( TP_DOWNLOADS_PATH , default_downloads_path , true ) );

    set( TP_DOWNLOADS_PATH , downloads_path );

    g_free( default_downloads_path );

    if ( g_mkdir_with_parents( downloads_path.c_str() , 0700 ) != 0 )
    {
        g_error( "DOWNLOADS PATH '%s' DOES NOT EXIST AND COULD NOT BE CREATED", downloads_path.c_str() );
    }

    // PLUGINS PATH

    String plugins_path = Util::canonical_external_path( get( TP_PLUGINS_PATH , "plugins" , true ) );

    set( TP_PLUGINS_PATH , plugins_path );

    // SCREEN WIDTH AND HEIGHT

    if ( !get( TP_SCREEN_WIDTH ) )
    {
        set( TP_SCREEN_WIDTH, TP_SCREEN_WIDTH_DEFAULT );
    }

    if ( !get( TP_SCREEN_HEIGHT ) )
    {
        set( TP_SCREEN_HEIGHT, TP_SCREEN_HEIGHT_DEFAULT );
    }

    if ( !get( TP_VIRTUAL_WIDTH ) )
    {
        set( TP_VIRTUAL_WIDTH, TP_VIRTUAL_WIDTH_DEFAULT );
    }

    if ( !get( TP_VIRTUAL_HEIGHT ) )
    {
        set( TP_VIRTUAL_HEIGHT, TP_VIRTUAL_HEIGHT_DEFAULT );
    }

    if ( !get( TP_SCREEN_ROTATION ) )
    {
        set( TP_SCREEN_ROTATION, TP_SCREEN_ROTATION_DEFAULT );
    }

    // RESOURCES PATH

    const char* resources_path = get( TP_RESOURCES_PATH , 0 , true );

    if ( ! resources_path )
    {
        if ( g_file_test( TP_DEFAULT_RESOURCES_PATH , G_FILE_TEST_IS_DIR ) )
        {
            resources_path = TP_DEFAULT_RESOURCES_PATH;
        }
        else
        {
            resources_path = "resources";
        }
    }

    String resources_path_s = Util::canonical_external_path( resources_path );

    set( TP_RESOURCES_PATH , resources_path_s );

    // gameservice configuration variable validation
    if ( !get( TP_GAMESERVICE_ENABLED ) )
    {
        set( TP_GAMESERVICE_ENABLED,  TP_GAMESERVICE_ENABLED_DEFAULT );
    }

    g_debug( "USING TP_GAMESERVICE_ENABLED: '%s'", get( TP_GAMESERVICE_ENABLED ) );

    if ( get( TP_GAMESERVICE_ENABLED ) )
    {
        if ( !get( TP_GAMESERVICE_DOMAIN ) )
        {
            set( TP_GAMESERVICE_DOMAIN,  TP_GAMESERVICE_DOMAIN_DEFAULT );
        }

        g_debug( "USING TP_GAMESERVICE_DOMAIN: '%s'", get( TP_GAMESERVICE_DOMAIN ) );

        if ( !get( TP_GAMESERVICE_HOST ) )
        {
            set( TP_GAMESERVICE_HOST,  TP_GAMESERVICE_HOST_DEFAULT );
        }

        g_debug( "USING TP_GAMESERVICE_HOST: '%s'", get( TP_GAMESERVICE_HOST ) );

        if ( !get( TP_GAMESERVICE_PORT, 0 ) )
        {
            set( TP_GAMESERVICE_PORT,  TP_GAMESERVICE_PORT_DEFAULT );
        }

        g_debug( "USING TP_GAMESERVICE_PORT: '%s'", get( TP_GAMESERVICE_PORT ) );
    }


    // Allowed secure objects

    const gchar* allowed_config = get( TP_APP_ALLOWED, TP_APP_ALLOWED_DEFAULT );

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

gchar* TPContext::format_log_line( const gchar* log_domain, GLogLevelFlags log_level, const gchar* message )
{
    gulong ms = timestamp();

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

    const char* level = "OTHER";

    const char* color_start = "";
    const char* color_end = SAFE_ANSI_COLOR_RESET;

    gboolean dump_stack = false;

    if ( log_level & G_LOG_LEVEL_ERROR )
    {
        color_start = SAFE_ANSI_COLOR_FG_RED;
        level = "ERROR";
        dump_stack = true;
    }
    else if ( log_level & G_LOG_LEVEL_CRITICAL )
    {
        color_start = SAFE_ANSI_COLOR_FG_RED;
        level = "CRITICAL";
        dump_stack = true;
    }
    else if ( log_level & G_LOG_LEVEL_WARNING )
    {
        color_start = SAFE_ANSI_COLOR_FG_YELLOW;
        level = "WARNING";
    }
    else if ( log_level & G_LOG_LEVEL_MESSAGE )
    {
        color_start = SAFE_ANSI_COLOR_FG_CYAN;
        level = "MESSAGE";
    }
    else if ( log_level & G_LOG_LEVEL_INFO )
    {
        color_start = SAFE_ANSI_COLOR_FG_GREEN;
        level = "INFO";
    }
    else if ( log_level & G_LOG_LEVEL_DEBUG )
    {
        color_start = SAFE_ANSI_COLOR_FG_WHITE;
        level = "DEBUG";
    }

#ifndef TP_PRODUCTION

    if ( dump_stack )
    {
        void* callstack[128];
        int i, frames = backtrace( callstack, 128 );
        char** strs = backtrace_symbols( callstack, frames );

        // Skip frames which are the logging functions
        for ( i = 4; i < frames; ++i )
        {
            char* begin_name = 0, *end_name = 0, *begin_offset = 0, *end_offset = 0;

#if !defined(CLUTTER_WINDOWING_OSX)

            // find parentheses and +address offset surrounding the mangled name:
            // ./module(function+0x15c) [0x8048a6d]
            for ( char* p = strs[i]; *p; ++p )
            {
                if ( *p == '(' )
                {
                    begin_name = p + 1;
                }
                else if ( *p == '+' )
                {
                    end_name = p - 1;
                    begin_offset = p + 1;
                    *p = '\0';
                }
                else if ( *p == ')' && begin_offset )
                {
                    end_offset = p - 1;
                    *p = '\0';
                    break;
                }
            }

#else
            // find "+ offset" at end of the line and mangled name just before it
            // x   module                           0x000000010bec0d1f _function + 751
            end_offset = strrchr( strs[i], '\0' );
            char* plus = strrchr( strs[i], '+' );
            begin_offset = plus + 2;
            end_name  = plus - 1;
            *end_name = '\0';
            begin_name = strrchr( strs[i], ' ' );
            begin_name++;
#endif

            if ( begin_name && begin_offset && end_offset
                    && begin_name < begin_offset )
            {
                int status;
                char* funcname = abi::__cxa_demangle( begin_name,
                        NULL, NULL, &status );

                if ( status == 0 )
                {
                    fprintf( stderr, "[%s] %p %2.2d:%2.2d:%2.2d:%3.3lu %s%-8s-%s %s+%s\n",
                            log_domain, g_thread_self(), hour, min, sec, ms, color_start, "C++", color_end, funcname, begin_offset );
                }
                else
                {
                    // demangling failed. Output function name as a C function with
                    // no arguments.
                    fprintf( stderr, "[%s] %p %2.2d:%2.2d:%2.2d:%3.3lu %s%-8s-%s %s()+%s\n",
                            log_domain, g_thread_self(), hour, min, sec, ms, color_start, "C", color_end, begin_name, begin_offset );
                }

                free( funcname );
            }
            else
            {
                // couldn't parse the line? print the whole line.
                fprintf( stderr, "[%s] %p %2.2d:%2.2d:%2.2d:%3.3lu %s%-8s-%s %s\n", log_domain, g_thread_self(), hour, min, sec, ms, color_start, "STACK", color_end, strs[i] );
            }
        }

        free( strs );
    }

#endif

    return g_strdup_printf( "[%s] %p %2.2d:%2.2d:%2.2d:%3.3lu %s%-8s-%s %s\n" ,
            log_domain,
            g_thread_self() ,
            hour , min , sec , ms ,
            color_start , level , color_end ,
            message );
}

//-----------------------------------------------------------------------------

ClutterActor* TPContext::get_stage() const
{
    g_assert( stage );
    return stage;
}

//-----------------------------------------------------------------------------

SystemDatabase* TPContext::get_db() const
{
    g_assert( sysdb );
    return sysdb;
}

//-----------------------------------------------------------------------------

Downloads* TPContext::get_downloads() const
{
    g_assert( downloads );
    return downloads;
}

//-----------------------------------------------------------------------------

Installer* TPContext::get_installer() const
{
    g_assert( installer );
    return installer;
}

//-----------------------------------------------------------------------------

HttpServer* TPContext::get_http_server() const
{
    g_assert( http_server );
    return http_server;
}

//-----------------------------------------------------------------------------

Console* TPContext::get_console() const
{
    return console;
}

//-----------------------------------------------------------------------------

#ifdef TP_WITH_GAMESERVICE
GameServiceSupport* TPContext::get_gameservice() const
{
    return gameservice_support;
}
#endif

//-----------------------------------------------------------------------------

bool TPContext::profile_switch( int id )
{
    SystemDatabase::Profile profile = get_db()->get_profile( id );

    if ( profile.id == 0 )
    {
        return false;
    }

    notify( this , TP_NOTIFICATION_PROFILE_CHANGING );

    get_db()->set( TP_DB_CURRENT_PROFILE_ID, id );
    set( PROFILE_ID, id );
    set( PROFILE_NAME, profile.name );

    notify( this , TP_NOTIFICATION_PROFILE_CHANGE );

    notify( this , TP_NOTIFICATION_PROFILE_CHANGED );

    return true;
}

//-----------------------------------------------------------------------------

MediaPlayer* TPContext::get_default_media_player()
{
    g_assert(media_player.size());
    std::list< MediaPlayer* >::iterator itr = media_player.begin();
    return (*itr);
}

//-----------------------------------------------------------------------------

MediaPlayer* TPContext::create_new_media_player( MediaPlayer::Delegate* delegate )
{
    if ( get_bool( TP_MEDIAPLAYER_ENABLED , true ) )
    {
        MediaPlayer *instance = MediaPlayer::make( this , media_player_constructor, delegate );

        media_player.push_back(instance);

        return instance;
    }
    else
    {
        return 0;
    }
}

bool TPContext::remove_media_player( MediaPlayer *instance  )
{
    if ( !instance ) return false;

    media_player.remove( instance );

    delete instance;

    return true;
}

//-----------------------------------------------------------------------------

ControllerList* TPContext::get_controller_list()
{
    return &controller_list;
}

//-----------------------------------------------------------------------------

TunerList* TPContext::get_tuner_list()
{
    return &tuner_list;
}

//-----------------------------------------------------------------------------

Image* TPContext::load_icon( const gchar* path )
{
    PROFILER( "TPContext::load_icon" , PROFILER_INTERNAL_CALLS );

    FreeLater free_later;

    static GChecksumType hash_type = G_CHECKSUM_MD5;

    //.........................................................................
    // First, we read the contents of the original file

    gchar* contents = NULL;
    gsize content_length = 0;

    GFile* file = g_file_new_for_commandline_arg( path );

    if ( ! g_file_load_contents( file , 0 , & contents , & content_length , 0 , 0 ) )
    {
        g_object_unref( G_OBJECT( file ) );

        return 0;
    }

    g_object_unref( G_OBJECT( file ) );

    free_later( contents );


    //.........................................................................
    // Now, we compute an md5 hash of the contents

    gchar* data_hash = g_compute_checksum_for_string( hash_type, contents, content_length );

    free_later( data_hash );

    //.........................................................................
    // Compute a hash for the full path to the file

    gchar* path_hash = g_compute_checksum_for_string( hash_type, path, -1 );

    free_later( path_hash );

    //.........................................................................
    // See if we have an entry in the icon cache for this path

    gchar* icon_cache_path = g_build_filename( get( TP_DATA_PATH ), "icons", NULL );

    free_later( icon_cache_path );

    //.........................................................................
    // This is the file name for the raw file

    gchar* icon_file_path = g_build_filename( icon_cache_path, path_hash, NULL );

    free_later( icon_file_path );

    //.........................................................................
    // We also have an info file that has the data hash, width, height, pitch
    // and depth for the image.

    gchar* info_file_name = g_strdup_printf( "%s.info", icon_file_path );

    free_later( info_file_name );


    gchar* info_contents = NULL;

    gsize info_length = 0;

    if ( g_file_get_contents( info_file_name, &info_contents, &info_length, NULL ) )
    {
        free_later( info_contents );


        gchar* actual_data_hash = g_new0( gchar , info_length + 1 );

        free_later( actual_data_hash );

        TPImage result;
        memset( &result, 0, sizeof( TPImage ) );


        if ( sscanf( info_contents, "%s %u %u %u %u %u %u", actual_data_hash, &result.width, &result.height, &result.pitch, &result.depth, &result.bgr , &result.pm_alpha ) >= 6 )
        {
            if ( !strcmp( actual_data_hash, data_hash ) )
            {
                PROFILER( "TPContext::load_icon(load raw)" , PROFILER_INTERNAL_CALLS );

                gchar* raw_contents = NULL;

                gsize length = 0;

                if ( g_file_get_contents( icon_file_path, &raw_contents, &length, NULL ) )
                {
                    result.pixels = raw_contents;
                    result.free_image = Image::free_image_with_g_free;

                    return Image::make( result );
                }
            }
        }
    }


    //.........................................................................
    // If we got here, we need to create the icon file because it doesn't exist,
    // doesn't match or we had a problem reading the information.

    Image* image = Image::decode( contents, content_length, path );

    if ( image )
    {
        // The length of the raw image

        gsize length = image->size();

        // If the conversion succeeded, we need to write the info file and the
        // raw icon file. Any failure below this point is simply a failure to cache,
        // and even though it will affect performance, it is not considered critical.

        PROFILER( "TPContext::load_icon(cache)" , PROFILER_INTERNAL_CALLS );

        // Make sure the icon cache directory exists

        if ( g_mkdir_with_parents( icon_cache_path, 0700 ) == 0 )
        {
            gchar* info = g_strdup_printf( "%s %u %u %u %u %u %u", data_hash, image->width(), image->height(), image->pitch(), image->depth(), image->bgr() , image->pm_alpha() );

            free_later( info );

            if ( g_file_set_contents( info_file_name, info, -1, NULL ) )
            {
                // Now we save the raw icon

                g_file_set_contents( icon_file_path, ( const gchar* )image->pixels(), length, NULL );
            }
        }

    }

    return image;
}

//-----------------------------------------------------------------------------

StringMap TPContext::get_config() const
{
    return config;
}

//-----------------------------------------------------------------------------

void TPContext::add_internal( gpointer key , gpointer value , GDestroyNotify destroy )
{
    g_assert( key );

    InternalMap::iterator it( internals.find( key ) );

    // If it already exists, call its destroy notify

    if ( it != internals.end() )
    {
        // If it has a destroy notify, call it with the value

        if ( it->second.second != 0 )
        {
            it->second.second( it->second.first );
        }

        it->second = InternalPair( value , destroy );
    }
    else
    {
        internals[ key ] = InternalPair( value , destroy );
    }
}

//-----------------------------------------------------------------------------

gpointer TPContext::get_internal( gpointer key )
{
    InternalMap::const_iterator it( internals.find( key ) );

    if ( it != internals.end() )
    {
        return it->second.first;
    }

    return 0;
}

//-----------------------------------------------------------------------------

void TPContext::set_first_app_exits( bool value )
{
    set( TP_FIRST_APP_EXITS , value ? 1 : 0 );
}

//-----------------------------------------------------------------------------

bool TPContext::is_first_app() const
{
    if ( ! current_app )
    {
        return true;
    }

    return current_app->get_id() == first_app_id;
}

//-----------------------------------------------------------------------------
// Called by other threads...

class AudioMatchAction : public Action
{
public:

    AudioMatchAction( TPContext* _context , const gchar* _json )
        :
        context( _context ),
        json( _json )
    {}

    virtual bool run()
    {
        if ( App* app = context->get_current_app() )
        {
            app->audio_match( json );
        }

        return false;
    }

private:

    TPContext* context;
    String      json;
};

void TPContext::audio_detection_match( const gchar* json )
{
    JsonParser* parser = json_parser_new();

    GError* error = 0;

    bool valid = json_parser_load_from_data( parser , json , -1 , & error );

    g_object_unref( parser );

    if ( ! valid )
    {
        g_warning( "INVALID JSON AUDIO DETECTION RESULT '%s' : %s" , json , error->message );

        g_clear_error( & error );
    }
    else
    {
        g_info( "VALID JSON AUDIO DETECTION RESULT : '%s'" , json );

        Action::post( new AudioMatchAction( this , json ) );
    }
}

void TPContext::load_background()
{
#ifndef TP_PRODUCTION

    if ( const gchar* resources_path = get( TP_RESOURCES_PATH , 0 , true ) )
    {
        gchar* path = g_build_filename( resources_path , "background.jpg" , NULL );

        FreeLater free_later( path );

        if ( ! g_file_test( path , G_FILE_TEST_EXISTS ) )
        {
            return;
        }

        if ( Image* image = Image::decode( path , false ) )
        {
            ClutterActor* bg = clutter_texture_new();

            clutter_actor_set_name( bg , "background" );

            Images::load_texture( CLUTTER_TEXTURE( bg ) , image );

            delete image;

            gint iw;
            gint ih;

            clutter_texture_get_base_size( CLUTTER_TEXTURE( bg ) , & iw , & ih );

            gfloat width;
            gfloat height;

            clutter_actor_get_size( stage , & width , & height );

            clutter_actor_set_scale( bg , width / iw , height / ih );

            clutter_actor_add_child( stage, bg );

            g_object_set_data_full( G_OBJECT( bg ) , "tp-src", g_strdup( "[background]" ) , g_free );
        }
    }

#endif
}

String TPContext::get_control_message( App* app ) const
{
    app = app ? app : current_app;

    JSON::Object control;

    guint16 port;

    if ( ( port = http_server->get_port() ) )
    {
        control[ "http" ] = port;
    }

    if ( ( port = console ? console->get_port() : 0 ) )
    {
        control[ "console" ] = port;
    }

    if ( app )
    {
        if ( Debugger* debugger = app->get_debugger() )
        {
            if ( ( port = debugger->get_server_port() ) )
            {
                control[ "debugger" ] = port;
            }
        }
    }

    if ( controller_server )
    {
        if ( ( port = controller_server->get_port() ) )
        {
            control[ "controllers" ] = port;
        }
    }

    return control.stringify();
}

//=============================================================================
// External-facing functions
//=============================================================================

void tp_init_version( int* argc, char** * argv, int major_version, int minor_version, int patch_version )
{
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

    if ( argc && argv )
    {
        g_argc = * argc;
        g_argv = * argv;
    }

    g_info( "%d.%d.%d [%s]", TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION , TP_GIT_VERSION );
}

//-----------------------------------------------------------------------------

TPContext* tp_context_new()
{
    return new TPContext();
}

//-----------------------------------------------------------------------------

void tp_context_free( TPContext* context )
{
    g_assert( context );
    g_assert( !context->running() );

    delete context;
}

//-----------------------------------------------------------------------------

void tp_context_set( TPContext* context, const char* key, const char* value )
{
    g_assert( context );

    context->set( key, value );
}

//-----------------------------------------------------------------------------

void tp_context_set_int( TPContext* context, const char* key, int value )
{
    g_assert( context );

    context->set( key, value );
}

//-----------------------------------------------------------------------------

const char* tp_context_get( TPContext* context, const char* key )
{
    g_assert( context );

    if ( !strcmp( key, "sekrit-stage" ) ) { return ( const char* )context->get_stage(); }

    return context->get( key );
}

//-----------------------------------------------------------------------------

void tp_context_set_user_data( TPContext* context , void* user_data )
{
    g_assert( context );

    context->user_data = user_data;
}

//-----------------------------------------------------------------------------

void* tp_context_get_user_data( TPContext* context )
{
    g_assert( context );

    return context->user_data;
}

//-----------------------------------------------------------------------------

void tp_context_add_notification_handler( TPContext* context, const char* subject, TPNotificationHandler handler, void* data )
{
    g_assert( context );

    context->add_notification_handler( subject, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_set_request_handler( TPContext* context, const char* subject, TPRequestHandler handler, void* data )
{
    g_assert( context );

    context->set_request_handler( subject, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_add_console_command_handler( TPContext* context, const char* command, TPConsoleCommandHandler handler, void* data )
{
    g_assert( context );

    context->add_console_command_handler( command, handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_set_log_handler( TPContext* context, TPLogHandler handler, void* data )
{
    g_assert( context );

    context->set_log_handler( handler, data );
}

//-----------------------------------------------------------------------------

void tp_context_set_resource_loader( TPContext* context , unsigned int type , TPResourceLoader loader, void* data )
{
    g_assert( context );

    context->set_resource_loader( type , loader , data );
}

//-----------------------------------------------------------------------------

int tp_context_run( TPContext* context )
{
    g_assert( context );

    return context->run();
}

//-----------------------------------------------------------------------------

void tp_context_quit( TPContext* context )
{
    g_assert( context );

    context->quit();
}

//-----------------------------------------------------------------------------
// Media player
//-----------------------------------------------------------------------------

void tp_context_set_media_player_constructor( TPContext* context, TPMediaPlayerConstructor constructor )
{
    g_assert( context );

    context->media_player_constructor = constructor;
}

//-----------------------------------------------------------------------------
// Tuners
//-----------------------------------------------------------------------------

TPTuner* tp_context_add_tuner( TPContext* context, const char* name, TPChannelChangeCallback tune_channel_cb, TPTunerSetViewportGeometry set_viewport_cb, void* data )
{
    g_assert( context );

    return context->tuner_list.add_tuner( context, name, tune_channel_cb, set_viewport_cb, data );
}

void tp_context_remove_tuner( TPContext* context, TPTuner* tuner )
{
    g_assert( context );
    g_assert( tuner );

    context->tuner_list.remove_tuner( tuner );
}

//-----------------------------------------------------------------------------
// Controllers
//-----------------------------------------------------------------------------

TPController* tp_context_add_controller( TPContext* context, const char* name, const TPControllerSpec* spec, void* data )
{
    g_assert( context );

    return context->controller_list.add_controller( context , name, spec, data );
}

//-----------------------------------------------------------------------------

void tp_context_remove_controller( TPContext* context, TPController* controller )
{
    g_assert( context );

    context->controller_list.remove_controller( controller );
}

//-----------------------------------------------------------------------------
// Image Decoder
//-----------------------------------------------------------------------------

void tp_context_set_image_decoder( TPContext* context, TPImageDecoder decoder, void* user )
{
    g_assert( context );
    g_assert( decoder );

    Images::set_external_decoder( context , decoder, user );
}

//-----------------------------------------------------------------------------

