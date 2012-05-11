TrickPlay OpenGL-ES Reference Test App
======================================

The purpose of this test app is to ensure OpenGL-ES compatibility, and to establish how to initalize OpenGL-ES on the target platform.

HOW TO PROCEED
--------------

The OEM should modify only the file tp_opengles_oem.c to provide implementations for the two functions

int tp_pre_egl_initialize( EGLNativeDisplayType * display , EGLNativeWindowType * window );

and

void tp_post_egl_terminate( void );

The first function is called from main() in tp_opengles.c and should initialize OpenGL-ES on the target device.  It should provide values back to the calling function for display and window; these values are passed in initially as EGL_DEFAULT_DISPLAY and 0 respectively.  If these values are OK for the device, they need not be modified.

The second function can be used to clean up when the test app ends, if that is necessary on the target device.



WHAT YOU SHOULD SEE
-------------------

If the program is correctly implemented, then a partially-transparent black and white checkerboard pattern should be displayed on the screen, and the program will output details of the OpenGL-ES enviroment to stdout.  If there are any errors in initializing OpenGL-ES, then details will be printed on stderr.


