#include <cstring>

#include "trickplay/trickplay.h"
#include "trickplay/controller.h"
#include "trickplay/keys.h"

#include "EGL/egl.h"

extern "C" NativeWindowType tp_egl_get_native_window()
{
  return 0;
}

extern "C" NativeDisplayType tp_egl_get_native_display()
{
  return EGL_DEFAULT_DISPLAY;
}

static TPController * remote = NULL;

int main( int argc , char * argv[] )
{
    // Initialize TP
    
	tp_init( & argc, & argv );

    // Create a TP context
    
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

    remote = tp_context_add_controller( context, "RemoteControl", & remote_spec, NULL );

    // Run TP - will not return until you exit TP
    
    int result = tp_context_run( context );
    
    // Detroy the TP context
    
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





