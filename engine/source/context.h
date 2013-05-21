#ifndef _TICKPLAY_CONTEXT_H
#define _TICKPLAY_CONTEXT_H

//-----------------------------------------------------------------------------
#include "trickplay/audio-sampler.h"
#include "trickplay/resource.h"
#include "common.h"
#include "notify.h"
#include "mediaplayers.h"
#include "controller_list.h"
#include "tuner_list.h"
#include "app.h"

//-----------------------------------------------------------------------------
// Internal notifications

#define TP_NOTIFICATION_APP_LOADED                      "app-loaded"
#define TP_NOTIFICATION_APP_CLOSING                     "app-closing"

//-----------------------------------------------------------------------------
// Internal configuration keys

#define PROFILE_ID              "profile_id"
#define PROFILE_NAME            "profile_name"
//-----------------------------------------------------------------------------
// Default values

#define TP_SYSTEM_LANGUAGE_DEFAULT          "en"
#define TP_SYSTEM_COUNTRY_DEFAULT           "US"
#define TP_SYSTEM_NAME_DEFAULT              "Desktop"
#define TP_SYSTEM_VERSION_DEFAULT           "0.0.0"
#define TP_SYSTEM_SN_DEFAULT                "SN"
#define TP_SCAN_APP_SOURCES_DEFAULT         false
#define TP_CONFIG_FROM_ENV_DEFAULT          true
#define TP_CONFIG_FROM_FILE_DEFAULT         ".trickplay"
#define TP_CONSOLE_ENABLED_DEFAULT          true
#define TP_TELNET_CONSOLE_PORT_DEFAULT      7777
#define TP_CONTROLLERS_ENABLED_DEFAULT      false
#define TP_CONTROLLERS_PORT_DEFAULT         0
#define TP_SCREEN_WIDTH_DEFAULT             960
#define TP_SCREEN_HEIGHT_DEFAULT            540
#define TP_VIRTUAL_WIDTH_DEFAULT            1920
#define TP_VIRTUAL_HEIGHT_DEFAULT           1080
#define TP_SCREEN_ROTATION_DEFAULT          0
#define TP_CONTROLLERS_NAME_DEFAULT         "TrickPlay"
#define TP_LIRC_ENABLED_DEFAULT             true
#define TP_LIRC_UDS_DEFAULT                 "/var/run/lirc/lircd"
#define TP_LIRC_REPEAT_DEFAULT              150
#define TP_APP_PUSH_ENABLED_DEFAULT         true
#define TP_APP_PUSH_PORT_DEFAULT            8888
#define TP_TEXTURE_CACHE_LIMIT_DEFAULT      0
#define TP_MEDIAPLAYER_SCHEMES_DEFAULT      "rtsp"
#define TP_GAMESERVICE_ENABLED_DEFAULT      false
#define TP_GAMESERVICE_DOMAIN_DEFAULT       "gameservice.trickplay.com"
#define TP_GAMESERVICE_HOST_DEFAULT         "gameservice.gameservice.trickplay.com"
#define TP_GAMESERVICE_PORT_DEFAULT         5222

// TODO: Don't like hard-coding this app id here

#define TP_APP_ALLOWED_DEFAULT          "com.trickplay.launcher=apps:com.trickplay.store=apps:com.trickplay.editor=editor"

//-----------------------------------------------------------------------------
// Forward declarations

class SystemDatabase;
class ControllerServer;
class Console;
class Downloads;
class Installer;
class Image;
class ControllerLIRC;
class AppPushServer;
class HttpServer;
class HttpTrickplayApiSupport;

#ifdef TP_WITH_GAMESERVICE
class GameServiceSupport;
#endif


//-----------------------------------------------------------------------------

struct TPContext : public Notify
{
public:

    //.........................................................................
    // Getting context configuration variables

    const char* get( const char* key, const char* def = NULL , bool default_if_empty = false ) const;
    bool get_bool( const char* key, bool def = false ) const;
    int get_int( const char* key, int def = 0 ) const;

    //.........................................................................
    // Console command handlers

    void add_console_command_handler( const char* command, TPConsoleCommandHandler handler, void* data );

    void remove_console_command_handler( const char* command, TPConsoleCommandHandler handler, void* data );

    //.........................................................................
    // Output handlers. They get everything before it is printed - so we can
    // support multiple consoles

    typedef void ( *OutputHandler )( const gchar* output, gpointer data );

    void add_output_handler( OutputHandler handler, gpointer data );
    void remove_output_handler( OutputHandler handler, gpointer data );

    //.........................................................................
    // Media player

    MediaPlayer* get_default_media_player();

    MediaPlayer* create_new_media_player( MediaPlayer::Delegate* delegate );

    //.........................................................................
    // Sends a request to the outside world

    int request( const char* subject );

    //.........................................................................

    inline bool running() const
    {
        return is_running;
    }

    //.........................................................................
    // The clutter stage

    ClutterActor* get_stage() const;

    //.........................................................................
    // The system database

    SystemDatabase* get_db() const;

    //.........................................................................
    // Switches profiles and handles all the associated notifications

    bool profile_switch( int id );

    //.........................................................................
    // Launches one app from another, and kills the first.

    int launch_app( const char* app_id, const App::LaunchInfo& launch , bool id_is_path = false );

    //.........................................................................
    // Kills the current app and either goes back to the previous one, or
    // quits altogether.

    void close_app();

    //.........................................................................

    void reload_app();


    void close_current_app();

    //.........................................................................

    inline App* get_current_app()
    {
        return current_app;
    }

    //.........................................................................

    ControllerList* get_controller_list();

    //.........................................................................

    TunerList* get_tuner_list();

    //.........................................................................

    Downloads* get_downloads() const;

    //.........................................................................

    Installer* get_installer() const;

    //.........................................................................

    HttpServer* get_http_server() const;

    //.........................................................................

    Console* get_console() const;

    //.........................................................................

#ifdef TP_WITH_GAMESERVICE
    GameServiceSupport* get_gameservice() const;
#endif

    //.........................................................................

    Image* load_icon( const gchar* path );

    //.........................................................................

    StringMap get_config() const;

    //.........................................................................

    void add_internal( gpointer key , gpointer value , GDestroyNotify destroy );

    gpointer get_internal( gpointer key );

    //.........................................................................

    void set_first_app_exits( bool value );

    bool is_first_app() const;

    //.........................................................................
    // This one is thread-safe, it receives a snippet of JSON that came from
    // an audio detection plugin. In the future, we could make it more generic,
    // and just let the outside world give us contextual information. It could
    // come via TCP/IP from a set-top box, for example.

    void audio_detection_match( const gchar* json );

    //.........................................................................
    // Get a resource loader

    bool get_resource_loader( unsigned int resource_type , TPResourceLoader* loader , void * * user_data ) const;

    typedef std::pair<OutputHandler, void*>                    OutputHandlerClosure;
    typedef std::set<OutputHandlerClosure>                      OutputHandlerSet;

    String get_control_message( App* app = 0 ) const;

private:

    TPContext();
    ~TPContext();

    //.........................................................................
    // Setting configuration variables

    void set( const char* key, const char* value );
    void set( const char* key, int value );
    void set( const char* key, const String& value );

    //.........................................................................
    // Loads configuration variables from the environment or a file

    void load_external_configuration();

    //.........................................................................
    // Ensures that all the required config variables are set and sets defaults
    // if they are not.

    void validate_configuration();

    //.........................................................................
    // Gets fontconfig working

    void setup_fonts();

    //.........................................................................

    String make_fake_app();

    //.........................................................................
    // Load the app

    int load_app( App** app );

    //.........................................................................
    // A command handler to handle basic commands

    static int console_command_handler( const char* command, const char* parameters, void* self );

    //.........................................................................
    // Formats a log line

    static gchar* format_log_line( const gchar* log_domain, GLogLevelFlags log_level, const gchar* message );

    //.........................................................................
    // Running and quitting the context

    int run();
    void quit();

    //.........................................................................
    // This launches a new app in an idle source

    static void app_run_callback( App* app , int result );

    static gboolean launch_app_callback( gpointer new_app );

    //.........................................................................
    // Log handler. This is what prints the messages in the outside world.

    void set_log_handler( TPLogHandler handler, void* data );

    // Our standard log handler if the one above is not set

    static void log_handler( const gchar* log_domain, GLogLevelFlags log_level, const gchar* message, gpointer self );

    //.........................................................................
    // Resource readers
    void set_resource_loader( unsigned int resource_type , TPResourceLoader loader , void* user_data );

    //.........................................................................
    // Request handlers

    void set_request_handler( const char* subject, TPRequestHandler handler, void* data );

    //.........................................................................

    void load_background();

    //.........................................................................
    // External functions are our friends

    friend void tp_init_version( int* argc, char** * argv, int major_version, int minor_version, int patch_version );
    friend TPContext* tp_context_new();
    friend void tp_context_free( TPContext* context );
    friend void tp_context_set( TPContext* context, const char* key, const char* value );
    friend void tp_context_set_int( TPContext* context, const char* key, int value );
    friend const char* tp_context_get( TPContext* context, const char* key );
    friend void tp_context_set_user_data( TPContext* context , void* user_data );
    friend void* tp_context_get_user_data( TPContext* context );
    friend void tp_context_add_notification_handler( TPContext* context, const char* subject, TPNotificationHandler handler, void* data );
    friend void tp_context_set_request_handler( TPContext* context, const char* subject, TPRequestHandler handler, void* data );
    friend void tp_context_add_console_command_handler( TPContext* context, const char* command, TPConsoleCommandHandler handler, void* data );
    friend void tp_context_set_log_handler( TPContext* context, TPLogHandler handler, void* data );
    friend void tp_context_set_resource_loader( TPContext* context, unsigned int type, TPResourceLoader loader, void* data );
    friend void tp_context_key_event( TPContext* context, const char* key );
    friend int tp_context_run( TPContext* context );
    friend void tp_context_quit( TPContext* context );

    friend void tp_context_set_media_player_constructor( TPContext* context, TPMediaPlayerConstructor constructor );

    friend TPController* tp_context_add_controller( TPContext* context, const char* name, const TPControllerSpec* spec, void* data );
    friend void tp_context_remove_controller( TPContext* context, TPController* controller );

    friend TPTuner* tp_context_add_tuner( TPContext* context, const char* name, TPChannelChangeCallback tune_channel_cb, TPTunerSetViewportGeometry set_viewport_cb, void* data );
    friend void tp_context_remove_tuner( TPContext* context, TPTuner* tuner );

    friend TPAudioSampler* tp_context_get_audio_sampler( TPContext* context );

    static gboolean escape_handler( ClutterActor* actor, ClutterEvent* event, gpointer _context );

#ifndef TP_PRODUCTION

    static gboolean tilde_handler( ClutterActor* actor, ClutterEvent* event, gpointer context );

#endif

private:

    TPContext( const TPContext& );

    bool                        is_running;

    ClutterActor*               stage;

    StringMap                   config;

    SystemDatabase*             sysdb;

    ControllerServer*           controller_server;

    ControllerList              controller_list;

    TunerList                   tuner_list;

    ControllerLIRC*             controller_lirc;

    AppPushServer*              app_push_server;

    HttpServer*                 http_server;

    Console*                    console;

    Downloads*                  downloads;

    Installer*                  installer;

    App*                        current_app;

#ifdef TP_WITH_GAMESERVICE
    GameServiceSupport* gameservice_support;
#endif

    String                      first_app_id;

    TPMediaPlayerConstructor    media_player_constructor;
    MediaPlayer*                media_player;

    HttpTrickplayApiSupport*   http_trickplay_api_support;

    TPLogHandler                external_log_handler;
    void*                       external_log_handler_data;

    void*                       user_data;

    typedef std::pair<TPConsoleCommandHandler, void*>          ConsoleCommandHandlerClosure;
    typedef std::multimap<String, ConsoleCommandHandlerClosure> ConsoleCommandHandlerMultiMap;

    ConsoleCommandHandlerMultiMap                               console_command_handlers;

    typedef std::pair<TPRequestHandler, void*>                 RequestHandlerClosure;
    typedef std::map<String, RequestHandlerClosure>             RequestHandlerMap;

    RequestHandlerMap                                           request_handlers;

    OutputHandlerSet                                            output_handlers;

    typedef std::map<String, StringSet>                          AppAllowedMap;

    AppAllowedMap                                               app_allowed;

    typedef std::pair<gpointer, GDestroyNotify>                  InternalPair;
    typedef std::map<gpointer, InternalPair>                     InternalMap;

    InternalMap                                                 internals;

    typedef std::pair<TPResourceLoader, void*>                  ResourceLoaderClosure;
    typedef std::map<unsigned int, ResourceLoaderClosure>       ResourceLoaderMap;

    ResourceLoaderMap                                           resource_loaders;
};

#endif // _TICKPLAY_CONTEXT_H
