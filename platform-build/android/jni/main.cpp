#include <jni.h>

#include <android/log.h>

#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <sys/errno.h>
#include <sys/stat.h>

#include "trickplay/trickplay.h"
#include "trickplay/controller.h"
#include "trickplay/keys.h"

#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "TP-Engine", __VA_ARGS__)

static TPController * remote = NULL;

static void android_log_handler( TPContext * context, unsigned int level, const char * domain, const char * message, void * data)
{
    LOG("(%s - %d) %s", domain, level, message);
}

extern "C" int main( int argc , char ** argv )
{
    // Initialize TP

    setenv("CLUTTER_SHOW_FPS","1",1);

    LOG("tp_init");

	tp_init( & argc, & argv );

    // Create a TP context

    LOG("tp_context_new");

    TPContext * context = tp_context_new();

    // Set TP Context variables

    tp_context_set( context, TP_LIRC_ENABLED, "FALSE");

    mkdir("/data/data/com.trickplay.Engine/files", 0770);
    mkdir("/data/data/com.trickplay.Engine/files/data", 0770);
    tp_context_set( context, TP_DATA_PATH, "/data/data/com.trickplay.Engine/files/data");

    mkdir("/data/data/com.trickplay.Engine/cache", 0770);
    mkdir("/data/data/com.trickplay.Engine/cache/downloads", 0770);
    tp_context_set( context, TP_DOWNLOADS_PATH, "/data/data/com.trickplay.Engine/cache/downloads");

    tp_context_set( context, TP_APP_SOURCES, "/data/data/com.trickplay.Engine/files/apps");
    tp_context_set( context, TP_APP_ID, "com.trickplay.tests.benchmark");


    tp_context_set( context, TP_RESOURCES_PATH, "/data/data/com.trickplay.Engine/files/resources");
    tp_context_set( context, TP_FONTS_PATH, "/data/data/com.trickplay.Engine/files/resources/fonts");
    tp_context_set( context, TP_PLUGINS_PATH, "/data/data/com.trickplay.Engine/files/plugins");

    tp_context_set( context, TP_SCAN_APP_SOURCES, "TRUE");

    tp_context_set( context, TP_APP_ALLOWED,    "com.trickplay.kt-menu=apps:"
                                                "com.trickplay.kt-menu=editor:"
                                                "trickplay.launcher=apps:"
                                                "com.trickplay.editor=editor");

    tp_context_set( context, TP_CONTROLLERS_ENABLED,    "TRUE" );
    tp_context_set( context, TP_CONTROLLERS_NAME, "Android");
    tp_context_set( context, TP_CONTROLLERS_MDNS_ENABLED, "TRUE");
    tp_context_set( context, TP_CONTROLLERS_UPNP_ENABLED, "TRUE");

    tp_context_set( context, TP_CONSOLE_ENABLED, "FALSE" );
    tp_context_set( context, TP_TELNET_CONSOLE_PORT, "7778" ); // 7777 is bound on 127.0.0.1 at least on galaxy tab

    tp_context_set( context, TP_MEDIAPLAYER_ENABLED, "FALSE");
    tp_context_set( context, TP_IMAGE_DECODER_ENABLED, "FALSE");
    tp_context_set( context, TP_AUDIO_SAMPLER_ENABLED, "FALSE");

    // Initialize a key map for the remote

	TPControllerKeyMap key_map[] =
	{
        { 0 , 0 }
	};

	// Add the remote as a TP controller

    TPControllerSpec remote_spec;
    memset( & remote_spec, 0, sizeof(TPControllerSpec) );
    remote_spec.capabilities = TP_CONTROLLER_HAS_KEYS;
    remote_spec.key_map = key_map;

    LOG("tp_context_add_controller");

    remote = tp_context_add_controller( context, "RemoteControl", & remote_spec, NULL );

    LOG("tp_context_set_log_handler");

    tp_context_set_log_handler(	context, &android_log_handler, NULL);

    // Run TP - will not return until you exit TP

    LOG("tp_context_run");

    int result = tp_context_run( context );

    // Detroy the TP context

    LOG("tp_context_free");

    tp_context_free( context );

	// Clear

    remote = 0;

	return result;
}

// Callback for remote control events

void remote_control_callback( unsigned char key )
{
	if ( remote )
	{
        tp_controller_key_down( remote, key, 0 , 0 );
        tp_controller_key_up( remote, key, 0 , 0 );
	}
}
