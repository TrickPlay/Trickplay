#include <jni.h>

#include <stdlib.h>

#include <android/log.h>
#include <android_native_app_glue.h>
#include <dlfcn.h>

#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "TP-Engine", __VA_ARGS__)

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

void window_created(ANativeActivity* activity, ANativeWindow* window)
{
    cogl_init( window );

    // Hand off to main()
    char *argv[] = { "TP-Engine", NULL };
    int argc = 1;

    main( argc, argv );

    // When main() returns, we're all done, so exit
    ANativeActivity_finish(activity);
}

void *load_library(const char *path, const char *lib)
{
    char *full_path = malloc( strlen(path) + strlen("/../lib/") + strlen(lib) + 1 );
    strcpy( full_path, path );
    strcat( full_path, "/../lib/" );
    strcat( full_path, lib );

    void *res = dlopen(full_path, RTLD_NOW);
    free(full_path);

    if(NULL == res)
    {
        LOG( "Failed to load library %s", lib);
        LOG( "Error is: %s", dlerror());

        abort();
    }
    else
    {
        LOG( "%s loaded at %p", lib, res);

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

void preload_shared_libraries(ANativeActivity *activity)
{
    LOG( "About to load all DLLs from %s", activity->internalDataPath);
    load_library(activity->internalDataPath, "libiconv.so");
    load_library(activity->internalDataPath, "libintl.so");
    load_library(activity->internalDataPath, "libexif-tp.so");
    load_library(activity->internalDataPath, "libexpat.so");
    load_library(activity->internalDataPath, "libxml2.so");
    load_library(activity->internalDataPath, "libffi.so");
    void *glib_impl = load_library(activity->internalDataPath, "libglib-2.0.so");
    g_log_set_handler_type glog_set_handler = (g_log_set_handler_type) load_sym( glib_impl, "g_log_set_default_handler" );

    load_library(activity->internalDataPath, "libgthread-2.0.so");
    load_library(activity->internalDataPath, "libgobject-2.0.so");
    load_library(activity->internalDataPath, "libgmodule-2.0.so");
    load_library(activity->internalDataPath, "libgio-2.0.so");

    glog_set_handler(my_glog_func, NULL);
    LOG( "Glue Log handler for Glib installed");

    load_library(activity->internalDataPath, "libsqlite3.so");
    load_library(activity->internalDataPath, "libcares.so");
    load_library(activity->internalDataPath, "libcurl.so");
    load_library(activity->internalDataPath, "libfreetype.so");
    load_library(activity->internalDataPath, "libfontconfig.so");
    load_library(activity->internalDataPath, "libpixman-1.so");
    load_library(activity->internalDataPath, "libpng15.so");
    load_library(activity->internalDataPath, "libcairo.so");
    load_library(activity->internalDataPath, "libcairo-gobject.so");
    load_library(activity->internalDataPath, "libpango-1.0.so");
    load_library(activity->internalDataPath, "libpangoft2-1.0.so");
    load_library(activity->internalDataPath, "libpangocairo-1.0.so");
    load_library(activity->internalDataPath, "libjpeg.so");
    load_library(activity->internalDataPath, "libtiff.so");
    load_library(activity->internalDataPath, "libtiffxx.so");
    load_library(activity->internalDataPath, "libgif.so");
    load_library(activity->internalDataPath, "libjson-glib-1.0.so");
    load_library(activity->internalDataPath, "libatk-1.0.so");
    void *cogl_impl = load_library(activity->internalDataPath, "libcogl.so");
    cogl_init = (cogl_init_type) load_sym(cogl_impl, "cogl_android_set_native_window_EXP");

    load_library(activity->internalDataPath, "libcogl-pango.so");
    load_library(activity->internalDataPath, "libclutter-eglnative-1.0.so");
    load_library(activity->internalDataPath, "libavahi-common.so");
    load_library(activity->internalDataPath, "libavahi-core.so");
    load_library(activity->internalDataPath, "libavahi-glib.so");
    load_library(activity->internalDataPath, "libixml.so");
    load_library(activity->internalDataPath, "libthreadutil.so");
    load_library(activity->internalDataPath, "libupnp.so");
    load_library(activity->internalDataPath, "liburiparser.so");
    load_library(activity->internalDataPath, "libuuid.so");
    load_library(activity->internalDataPath, "libsndfile.so");
    load_library(activity->internalDataPath, "libsoup-2.4.so");
    load_library(activity->internalDataPath, "libclutteralphamode.so");
    load_library(activity->internalDataPath, "libtplua.so");

    void *impl = load_library(activity->internalDataPath, "libtp-implementation.so");
    main = (main_type) load_sym(impl, "main");

    LOG( "DLL Loading success!");
}

/**
 * This is the main entry point of a native application that is using
 * android_native_app_glue.  It runs in its own thread, with its own
 * event loop for receiving input events and doing other things.
 */
void android_main(struct android_app* state) {
    // Make sure glue isn't stripped.
    app_dummy();

    preload_shared_libraries(state->activity);

    state->activity->callbacks->onNativeWindowCreated = window_created;


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
