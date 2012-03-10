#include <jni.h>

#include <stdlib.h>

#include <android/log.h>
#include <android_native_app_glue.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <strings.h>
#include <sys/stat.h>
#include <sys/errno.h>

#include <pthread.h>

#include "unzip.h"

#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "TP-Engine", __VA_ARGS__)

typedef int (*main_type)(int, char**);
typedef void (*cogl_init_type)(ANativeWindow *window);


typedef struct
{
    ANativeActivity* activity;
    ANativeWindow* window;
    main_type main;
    cogl_init_type cogl_init;
} MyStateT;

static MyStateT my_state;

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
typedef void                (*GPrintFunc)                       (const char *string);
typedef GPrintFunc          (*g_set_print_handler_type)              (GPrintFunc func);

static void my_glog_func(const char *domain, GLogLevelFlags log_level, const char *message, void *user_data)
{
    LOG( "%s(%d): %s", domain, log_level, message);
}

static void my_gprint_func(const char *string)
{
    LOG("%s",string);
}

void *load_library(const char *path, const char *lib)
{
    char *full_path = new char[( strlen(path) + strlen("/../lib/") + strlen(lib) + 1 )];
    strcpy( full_path, path );
    strcat( full_path, "/../lib/" );
    strcat( full_path, lib );

    void *res = dlopen(full_path, RTLD_NOW);
    delete [] full_path;

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
    load_library(activity->internalDataPath, "libgnustl_shared.so");
    load_library(activity->internalDataPath, "libiconv.so");
    load_library(activity->internalDataPath, "libintl.so");
    load_library(activity->internalDataPath, "libexif-tp.so");
    load_library(activity->internalDataPath, "libexpat.so");
    load_library(activity->internalDataPath, "libxml2.so");
    load_library(activity->internalDataPath, "libffi.so");
    void *glib_impl = load_library(activity->internalDataPath, "libglib-2.0.so");
    g_log_set_handler_type glog_set_handler = (g_log_set_handler_type) load_sym( glib_impl, "g_log_set_default_handler" );

    g_set_print_handler_type gset_print_handler = (g_set_print_handler_type) load_sym( glib_impl, "g_set_print_handler" );

    load_library(activity->internalDataPath, "libgthread-2.0.so");
    load_library(activity->internalDataPath, "libgobject-2.0.so");
    load_library(activity->internalDataPath, "libgmodule-2.0.so");
    load_library(activity->internalDataPath, "libgio-2.0.so");

    glog_set_handler(my_glog_func, NULL);
    gset_print_handler(my_gprint_func);
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
    load_library(activity->internalDataPath, "libjpeg.8.so");
    load_library(activity->internalDataPath, "libtiff.so");
    load_library(activity->internalDataPath, "libtiffxx.so");
    load_library(activity->internalDataPath, "libgif.so");
    load_library(activity->internalDataPath, "libjson-glib-1.0.so");
    load_library(activity->internalDataPath, "libatk-1.0.so");
    void *cogl_impl = load_library(activity->internalDataPath, "libcogl.so");
    my_state.cogl_init = (cogl_init_type) load_sym(cogl_impl, "cogl_android_set_native_window_EXP");

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
    my_state.main = (main_type) load_sym(impl, "main");

    LOG( "DLL Loading success!");
}

// Returns non-zero if the md5sum of the zipfile matches one already
// installed in activity->internalDataPath
int check_md5sum(ANativeActivity* activity, const char* zipfile_name)
{
    // Check if md5sum file exists in target
    char *md5sum_filename = new char[(
                                            strlen(zipfile_name) +
                                            strlen(".md5sum") + 1
                                )];
    strcpy(md5sum_filename, zipfile_name);
    strcat(md5sum_filename, ".md5sum");

    char *md5sum_target_filename = new char[(  strlen(activity->internalDataPath) +
                                            1 + // For the '/'
                                            strlen(md5sum_filename) + 1
                                        )];
    strcpy(md5sum_target_filename, activity->internalDataPath);
    strcat(md5sum_target_filename, "/");
    strcat(md5sum_target_filename, md5sum_filename);

    int fd = open(md5sum_target_filename, O_RDONLY);
    if(fd < 0)
    {
        LOG("Failed to open md5sum file %s: (%d) %s", md5sum_target_filename, errno, strerror(errno));
        delete [] md5sum_filename;
        delete [] md5sum_target_filename;
        return 0;
    }
    delete [] md5sum_target_filename;

    AAssetManager * mgr = activity->assetManager;
    AAsset * md5sum_asset = AAssetManager_open( mgr, md5sum_filename, AASSET_MODE_BUFFER );
    if(NULL == md5sum_asset)
    {
        LOG("Failed to open md5sum asset: %s", md5sum_filename);
        delete [] md5sum_filename;
        return 0;
    }
    delete [] md5sum_filename;

    const void* asset_contents = AAsset_getBuffer(md5sum_asset);
    char *md5sum_from_asset = new char[33];
    bzero(md5sum_from_asset, 33);
    memcpy(md5sum_from_asset, asset_contents, 32);
    LOG("Read asset as: \"%s\"", md5sum_from_asset);
    char* md5sum_from_fd = new char[33];
    bzero(md5sum_from_fd, 33);
    int read_len = read(fd, md5sum_from_fd, 32);
    LOG("Read file contents as \"%s\"", md5sum_from_fd);
    if(read_len < 32 || strcmp(md5sum_from_asset, md5sum_from_fd))
    {
        LOG("md5sum did not match for %s", zipfile_name);
        LOG("strcmp(\"%s\",\"%s\")",md5sum_from_asset,md5sum_from_fd);
        delete [] md5sum_from_fd;
        delete [] md5sum_from_asset;
        AAsset_close(md5sum_asset);
        close(fd);
        return 0;
    }

    LOG("md5sum matched for %s", zipfile_name);
    delete [] md5sum_from_fd;
    delete [] md5sum_from_asset;
    AAsset_close(md5sum_asset);
    close(fd);

    return -1;
}

void install_zipfile(ANativeActivity* activity, const char* zipfile_name)
{
    // Figure out where to install it to
    char *unzip_target_directory = new char[(  strlen(activity->internalDataPath) +
                                            1 + // For the '/'
                                            strlen(zipfile_name) + 1 // Will be shorter than this cos we're gonna chop off the filename and just keep directory bit
                                        )];
    strcpy(unzip_target_directory, activity->internalDataPath);
    strcat(unzip_target_directory, "/");
    strcat(unzip_target_directory, zipfile_name);
    // Now find the last '/' in there and nuke everything after it
    // We know there's at least one since we put it there, so no worries about NULL
    *(strrchr(unzip_target_directory, '/')) = '\0';
    LOG("Unzipping %s into %s...", zipfile_name, unzip_target_directory);

    AAssetManager * mgr = activity->assetManager;
    AAsset * asset = AAssetManager_open( mgr, zipfile_name, AASSET_MODE_BUFFER );
    if(asset)
    {
        void* asset_contents = (void *)AAsset_getBuffer(asset);

        HZIP zip = OpenZip( asset_contents, AAsset_getLength(asset), 0);
        SetUnzipBaseDir(zip, unzip_target_directory);

        ZIPENTRY ze;
        GetZipItem(zip, -1, &ze);
        int numitems=ze.index;
        for (int i=0; i<numitems; i++)
        {
            GetZipItem(zip,i,&ze);
            LOG("Unzipping %s...", ze.name);
            UnzipItem(zip,i,ze.name);
        }
        CloseZip(zip);
        AAsset_close(asset);
    }
    else
    {
        LOG("Failed to open zipfile asset %s", zipfile_name);
    }

    delete [] unzip_target_directory;
    LOG("Done unzipping %s", zipfile_name);
}

void install_md5sum(ANativeActivity* activity, const char* zipfile_name)
{
    char *md5sum_filename = new char[(
                                            strlen(zipfile_name) +
                                            strlen(".md5sum") + 1
                                )];
    strcpy(md5sum_filename, zipfile_name);
    strcat(md5sum_filename, ".md5sum");

    char *md5sum_target_filename = new char[(  strlen(activity->internalDataPath) +
                                            1 + // For the '/'
                                            strlen(md5sum_filename) + 1
                                        )];
    strcpy(md5sum_target_filename, activity->internalDataPath);
    strcat(md5sum_target_filename, "/");
    strcat(md5sum_target_filename, md5sum_filename);

    int fd = open(md5sum_target_filename, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);
    if(fd != -1)
    {
        AAssetManager * mgr = activity->assetManager;
        AAsset * md5sum_asset = AAssetManager_open( mgr, md5sum_filename, AASSET_MODE_BUFFER );
        if(md5sum_asset)
        {
            const char* md5sum_from_asset = (const char *)AAsset_getBuffer(md5sum_asset);
            int write_len = 32;
            int wrote_so_far = 0;
            while(write_len > 0)
            {
                int wrote = write(fd, &(md5sum_from_asset[wrote_so_far]), write_len);
                if(-1 == wrote)
                {
                    LOG("Error while writing %s: (%d) %s", md5sum_target_filename, errno, strerror(errno) );
                    break;
                }
                write_len -= wrote;
            }

            AAsset_close(md5sum_asset);
        }
        else
        {
            LOG("Failed to open md5sum asset %s", md5sum_filename);
        }
        close(fd);
    }
    else
    {
        LOG("Failed to open file %s: (%d) %s", md5sum_target_filename, errno, strerror(errno));
    }

    delete [] md5sum_target_filename;
    delete [] md5sum_filename;
}

void check_install_zipfile(ANativeActivity* activity, const char* zipfile_name)
{
    LOG("Checking if we need to install %s", zipfile_name);
    if(!check_md5sum(activity, zipfile_name))
    {
        LOG("MD5SUM for %s did not match: installing it...",zipfile_name);
        install_zipfile(activity, zipfile_name);
        install_md5sum(activity, zipfile_name);
    }
}

void install_resources(ANativeActivity* activity)
{
    check_install_zipfile(activity, "resources.zip");
}

void install_apps(ANativeActivity* activity)
{
    AAssetManager * mgr = activity->assetManager;

    AAssetDir* apps_dir = AAssetManager_openDir(mgr, "apps");

    const char *app_name;
    while(app_name = AAssetDir_getNextFileName(apps_dir))
    {
        // Check if it's a ZIP file
        if( strlen(app_name) > 4 )
        {
            LOG("Examining %s shows %s", app_name, &(app_name[strlen(app_name)-4]));
            if( !strcmp( ".zip", &(app_name[strlen(app_name)-4]) ) )
            {
                LOG("Will check install for: %s", app_name);
                char *full_app_path = new char[(    strlen("apps/") +
                                                    strlen(app_name) + 1
                                                )];
                strcpy(full_app_path, "apps/");
                strcat(full_app_path, app_name);

                check_install_zipfile(activity, full_app_path);

                delete [] full_app_path;
            }
            else
            {
                LOG("Skipping non-zipfile: %s", app_name);
            }
        }
        else
        {
            LOG("Short filename: \"%s\"", app_name);
        }
    }

    AAssetDir_close(apps_dir);
}

void *start_trickplay(void *state)
{
    MyStateT *my_state = (MyStateT *) state;

    LOG("TrickPlay engine thread running");

    preload_shared_libraries(my_state->activity);

    install_resources(my_state->activity);
    install_apps(my_state->activity);

    my_state->cogl_init( my_state->window );

    // Hand off to main()
    char *argv[] = { (char *)"TP-Engine", NULL };
    int argc = 1;

    my_state->main( argc, argv );

    // When main() returns, we're all done, so exit
    ANativeActivity_finish(my_state->activity);

    pthread_exit(NULL);
}

void window_created(ANativeActivity* activity, ANativeWindow* window)
{
    my_state.activity = activity;
    my_state.window = window;

    pthread_t trickplay_thread;

    LOG("Starting new thread for Trickplay engine to run on...");
    pthread_create(&trickplay_thread, NULL, &start_trickplay, &my_state);
}

/**
 * This is the main entry point of a native application that is using
 * android_native_app_glue.  It runs in its own thread, with its own
 * event loop for receiving input events and doing other things.
 */
extern "C" void android_main(struct android_app* state) {
    // Make sure glue isn't stripped.
    app_dummy();

    state->activity->callbacks->onNativeWindowCreated = window_created;

    while (1) {
        // Read all pending events.
        int ident;
        int events;
        struct android_poll_source* source;

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
