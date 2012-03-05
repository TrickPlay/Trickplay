#include <jni.h>

#include <stdlib.h>

#include <android/sensor.h>
#include <android/log.h>
#include <android_native_app_glue.h>
#include <dlfcn.h>

#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "TP-Engine", __VA_ARGS__)

#define LIBRARY_PATH_PREFIX "/data/data/com.trickplay.Engine/lib/"

typedef int (*main_type)(int, char**);
static main_type main;

typedef void (*cogl_init_type)(ANativeWindow *window);
static cogl_init_type cogl_init;

// Copy some defs from glib for logging stuff
typedef enum {
  /* log flags */
  G_LOG_FLAG_RECURSION          = 1 << 0,
  G_LOG_FLAG_FATAL              = 1 << 1,

  /* GLib log levels */
  G_LOG_LEVEL_ERROR             = 1 << 2,       /* always fatal */
  G_LOG_LEVEL_CRITICAL          = 1 << 3,
  G_LOG_LEVEL_WARNING           = 1 << 4,
  G_LOG_LEVEL_MESSAGE           = 1 << 5,
  G_LOG_LEVEL_INFO              = 1 << 6,
  G_LOG_LEVEL_DEBUG             = 1 << 7,

  G_LOG_LEVEL_MASK              = ~(G_LOG_FLAG_RECURSION | G_LOG_FLAG_FATAL)
} GLogLevelFlags;

typedef void                (*GLogFunc)                         (const char *log_domain,
                                                         GLogLevelFlags log_level,
                                                         const char *message,
                                                         void* user_data);
typedef unsigned (*g_log_set_handler_type)(GLogFunc log_func,
                                                         void* user_data);


static void my_glog_func(const char *domain, GLogLevelFlags log_level, const char *message, void *user_data)
{
    LOG( "%s(%d): %s", domain, log_level, message);
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

                cogl_init( app->window );

                // Hand off to main()
                char *argv[] = { "TP-Engine", NULL };
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


void *load_library(const char *path, int mode)
{
    LOG( "About to load: %s", path);
    void *res = dlopen(path, mode);
    if(NULL == res)
    {
        LOG( "Failed to load library %s", path);
        LOG( "Error is: %s", dlerror());

        abort();
    }
    else
    {
        LOG( "%s loaded at %p", path, res);
        return res;
    }
}

void *load_sym( void* lib, const char *symbol)
{
    void *res = dlsym(lib, symbol);
    if(NULL == res)
    {
        LOG( "Failed to locate symbol %s", symbol);
        LOG( "Error is: %s", dlerror());

        abort();
    }
    else
    {
        LOG( "Located %s at %p", symbol, res);
        return res;
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

    LOG( "About to load all DLLs");
     load_library(LIBRARY_PATH_PREFIX "libiconv.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libintl.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libexif-tp.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libexpat.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libxml2.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libffi.so", RTLD_NOW);
     void *glib_impl = load_library(LIBRARY_PATH_PREFIX "libglib-2.0.so", RTLD_NOW);
     g_log_set_handler_type glog_set_handler = (g_log_set_handler_type) load_sym( glib_impl, "g_log_set_default_handler" );

     load_library(LIBRARY_PATH_PREFIX "libgthread-2.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libgobject-2.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libgmodule-2.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libgio-2.0.so", RTLD_NOW);

     glog_set_handler(my_glog_func, NULL);
     LOG( "Glue Log handler for Glib installed");

     load_library(LIBRARY_PATH_PREFIX "libsqlite3.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libcares.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libcurl.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libfreetype.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libfontconfig.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libpixman-1.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libpng15.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libcairo.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libcairo-gobject.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libpango-1.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libpangoft2-1.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libpangocairo-1.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libjpeg.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libtiff.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libtiffxx.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libgif.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libjson-glib-1.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libatk-1.0.so", RTLD_NOW);
     void *cogl_impl = load_library(LIBRARY_PATH_PREFIX "libcogl.so", RTLD_NOW);
     cogl_init = (cogl_init_type) load_sym(cogl_impl, "cogl_android_set_native_window_EXP");

     load_library(LIBRARY_PATH_PREFIX "libcogl-pango.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libclutter-eglnative-1.0.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libavahi-common.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libavahi-core.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libavahi-glib.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libixml.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libthreadutil.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libupnp.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "liburiparser.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libuuid.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libsndfile.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libsoup-2.4.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libclutteralphamode.so", RTLD_NOW);
     load_library(LIBRARY_PATH_PREFIX "libtplua.so", RTLD_NOW);

     void *impl = load_library(LIBRARY_PATH_PREFIX "libtp-implementation.so", RTLD_NOW);
     main = (main_type) load_sym(impl, "main");

    LOG( "DLL Loading success!");

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
