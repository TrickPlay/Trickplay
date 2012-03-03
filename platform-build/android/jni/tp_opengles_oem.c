#include <jni.h>
#include <errno.h>

#include <android/sensor.h>
#include <android/log.h>
#include <android_native_app_glue.h>

#include "tp_opengles.h"

static struct android_app* me;

int tp_pre_egl_initialize( EGLNativeDisplayType * display , EGLNativeWindowType * window )
{
    *display = EGL_DEFAULT_DISPLAY;
    *window = me->window;

    return 0;
}

void tp_post_egl_terminate( void )
{
}

/**
 * Process the next input event.
 */
static int32_t engine_handle_input(struct android_app* app, AInputEvent* event) {

    return 0;
}

/**
 * Process the next main command.
 */
static void engine_handle_cmd(struct android_app* app, int32_t cmd) {

    switch (cmd) {
        case APP_CMD_SAVE_STATE:
            break;
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (app->window != NULL) {
                me = app;

                // Hand off to main()
                char *argv[] = { "TP-OpenGL-Reference", NULL };
                int argc = 1;

                main( argc, argv );
            }
            break;
        case APP_CMD_TERM_WINDOW:
            break;
        case APP_CMD_GAINED_FOCUS:
            break;
        case APP_CMD_LOST_FOCUS:
            break;
    }
}

/**
 * This is the main entry point of a native application that is using
 * android_native_app_glue.  It runs in its own thread, with its own
 * event loop for receiving input events and doing other things.
 */
void android_main(struct android_app* state) {
    // Make sure glue isn't stripped.
    app_dummy();

    __android_log_print(ANDROID_LOG_INFO, "TrickPlay-OpenGL-ES-Reference",  "About to load all DLLs");
     dlopen("libiconv.so");
     dlopen("libintl.so");
     dlopen("libexif-tp.so");
     dlopen("libexpat.so");
     dlopen("libxml2.so");
     dlopen("libffi.so");
     dlopen("libglib-2.0.so");
     dlopen("libgthread-2.0.so");
     dlopen("libgobject-2.0.so");
     dlopen("libgmodule-2.0.so");
     dlopen("libgio-2.0.so");
     dlopen("libsqlite3.so");
     dlopen("libcares.so");
     dlopen("libcurl.so");
     dlopen("libfreetype.so");
     dlopen("libfontconfig.so");
     dlopen("libpixman-1.so");
     dlopen("libpng15.so");
     dlopen("libcairo.so");
     dlopen("libcairo-gobject.so");
     dlopen("libpango-1.0.so");
     dlopen("libpangoft2-1.0.so");
     dlopen("libpangocairo-1.0.so");
     dlopen("libjpeg.so");
     dlopen("libtiff.so");
     dlopen("libtiffxx.so");
     dlopen("libgif.so");
     dlopen("libjson-glib-1.0.so");
     dlopen("libatk-1.0.so");
     dlopen("libcogl.so");
     dlopen("libcogl-pango.so");
     dlopen("libclutter-eglnative-1.0.so");
     dlopen("libavahi-common.so");
     dlopen("libavahi-core.so");
     dlopen("libavahi-glib.so");
     dlopen("libixml.so");
     dlopen("libthreadutil.so");
     dlopen("libupnp.so");
     dlopen("liburiparser.so");
     dlopen("libuuid.so");
     dlopen("libsndfile.so");
     dlopen("libsoup-2.4.so");
     dlopen("libclutteralphamode.so");
     dlopen("libtplua.so");
    __android_log_print(ANDROID_LOG_INFO, "TrickPlay-OpenGL-ES-Reference",  "DLL Loading success!");

    state->onAppCmd = engine_handle_cmd;
    state->onInputEvent = engine_handle_input;

    while (1) {
        // Read all pending events.
        int ident;
        int events;
        struct android_poll_source* source;

        // If not animating, we will block forever waiting for events.
        // If animating, we loop until all events are read, then continue
        // to draw the next frame of animation.
        while ((ident=ALooper_pollAll(0, NULL, &events,
                (void**)&source)) >= 0) {

            // Process this event.
            if (source != NULL) {
                source->process(state, source);
            }

            // Check if we are exiting.
            if (state->destroyRequested != 0) {
                return;
            }
        }
    }
}
