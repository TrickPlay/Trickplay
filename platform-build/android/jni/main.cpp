#include <jni.h>

#include <android/log.h>

#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <sys/errno.h>

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
    // Set up debug environment variables
    if(setenv("COGL_DEBUG", "all", 0))
    {
        LOG("setenv failed: (%d): %s", errno, strerror(errno));
    }
    if(setenv("CLUTTER_DEBUG", "all", 0))
    {
        LOG("setenv failed: (%d): %s", errno, strerror(errno));
    }

    // Initialize TP

    LOG("tp_init");

	tp_init( & argc, & argv );

    // Create a TP context

    LOG("tp_context_new");

    TPContext * context = tp_context_new();

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

