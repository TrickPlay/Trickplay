#ifndef _TRICKPLAY_APP_RESOURCE_H
#define _TRICKPLAY_APP_RESOURCE_H

#include "common.h"
#include "app.h"
#include "util.h"

//.........................................................................

class AppResource
{
public:

    enum Flags
    {
        URI_NOT_ALLOWED         = 0x01,
        LOCALIZED_NOT_ALLOWED   = 0x02
    };

    AppResource();

    //.....................................................................
    // Construct an app resource given a path. If something goes wrong,
    // you can use the bool operator below to test it. Error messages
    // are printed by this function, so you don't need to do it yourself.

    AppResource( App* app , const char* app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    AppResource( lua_State* L , const char* app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    AppResource( App* app , const String& app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    AppResource( lua_State* L , const String& app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    AppResource( const char* root_uri_or_native_path , const char* app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    AppResource( const char* root_uri_or_native_path , const String& app_path , int flags = 0 , const StringSet& schemes = StringSet() );

    //.....................................................................
    // This lets you test the resource to make sure it is good.

    bool good() const
    {
        return ! uri.empty();
    }

    operator bool () const
    {
        return good();
    }

    //.....................................................................

    bool is_native() const
    {
        return ! native_path.empty();
    }

    String get_original() const
    {
        return original;
    }

    String get_native_path() const
    {
        return native_path;
    }

    String get_uri() const
    {
        return uri;
    }

    //.....................................................................
    // Returns true if the resource is valid and is either HTTP or HTTPS.

    bool is_http() const;

    //.....................................................................
    // If this object is valid and the underlying resource exists,
    // this will return true. Note that in the case of a remote
    // resource, this will require a round trip to the server. In the case
    // of HTTP(S), a HEAD request will be made.

    bool exists( App* app ) const;

    //.....................................................................
    // If it is a valid resource and the contents can be loaded, returns
    // a buffer with the contents which will always be zero terminated.
    // If there is a problem, the buffer will be bad - you can test it with
    // the bool operator. If the resource is HTTP(S), then it will make a
    // network request.

    Util::Buffer load_contents( App* app ) const;

    //.....................................................................
    // Just like lua_loadfile. Returns 0 if its OK, LUA_ERRFILE or the
    // result of lua_load. It pushes either an error message, or the
    // compiled chunk as a function.

    int lua_load( lua_State* L ) const;

    //.....................................................................

    static StringPairList get_native_children( const String& uri_or_native_path );

    static StringList get_pi_children( const String& uri_or_native_path );

private:

    struct Args
    {
        Args()
            :
            app( 0 ),
            flags( 0 )
        {}

        Args( lua_State* L , const char* _app_path , int _flags , const StringSet& _schemes = StringSet() )
            :
            app( App::get( L ) ),
            root_uri( app->get_metadata().get_root_uri() ),
            app_path( _app_path ? _app_path : "" ),
            flags( _flags ),
            schemes( _schemes )
        {}

        Args( App* _app , const char* _app_path , int _flags , const StringSet& _schemes = StringSet() )
            :
            app( _app ),
            root_uri( app->get_metadata().get_root_uri() ),
            app_path( _app_path ? _app_path : "" ),
            flags( _flags ),
            schemes( _schemes )
        {}

        Args( const char* _root_uri , const char* _app_path , int _flags , const StringSet& _schemes = StringSet() )
            :
            app( 0 ),
            root_uri( _root_uri ? _root_uri : "" ),
            app_path( _app_path ? _app_path : "" ),
            flags( _flags ),
            schemes( _schemes )
        {
            // We use GFile to make sure the root is a valid URI. You
            // can pass in a native path, or a URI.

            if ( ! root_uri.empty() )
            {
                GFile* file = g_file_new_for_commandline_arg( root_uri.c_str() );
                char* uri = g_file_get_uri( file );
                g_object_unref( file );
                root_uri = uri ? uri : "";
                g_free( uri );
            }
        }

        App*       app;
        String      root_uri;
        String      app_path;
        int         flags;
        StringSet   schemes;
    };

    static void make( AppResource* me , const Args& args );

    static bool is_child( const String& root_uri , const String& child_uri );

    String  original;
    String  native_path;
    String  uri;
};


#endif // _TRICKPLAY_APP_RESOURCE_H
