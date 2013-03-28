
#include <stack>

#include "uriparser/Uri.h"
#include "libsoup/soup.h"

#include "app_resource.h"
#include "network.h"
#include "context.h"

//.............................................................................

#define TP_LOG_DOMAIN   "APP"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................
// Construct an empty, bad resource

AppResource::AppResource()
{}

//.............................................................................

AppResource::AppResource( lua_State* L , const char* app_path , int flags , const StringSet& schemes )
{
    g_assert( L );

    make( this , Args( L , app_path , flags , schemes ) );
}

//.............................................................................

AppResource::AppResource( App* app , const String& app_path , int flags , const StringSet& schemes )
{
    g_assert( app );

    make( this , Args( app , app_path.c_str() , flags , schemes ) );
}

//.............................................................................

AppResource::AppResource( lua_State* L , const String& app_path , int flags , const StringSet& schemes )
{
    g_assert( L );

    make( this , Args( L , app_path.c_str() , flags , schemes ) );
}

//.............................................................................

AppResource::AppResource( App* app , const char* app_path , int flags , const StringSet& schemes )
{
    g_assert( app );

    make( this , Args( app , app_path , flags , schemes ) );
}

//.............................................................................

AppResource::AppResource( const char* root_uri , const char* app_path , int flags , const StringSet& schemes )
{
    g_assert( root_uri );

    make( this , Args( root_uri , app_path , flags , schemes ) );
}

//.............................................................................

AppResource::AppResource( const char* root_uri , const String& app_path , int flags , const StringSet& schemes )
{
    g_assert( root_uri );

    make( this , Args( root_uri , app_path.c_str() , flags , schemes ) );
}

//.............................................................................
// This is the workhorse of AppResource path validation.

void AppResource::make( AppResource* me , const Args& args )
{
    g_assert( me );

    me->original.clear();
    me->native_path.clear();
    me->uri.clear();

    try
    {
        size_t length = args.app_path.length();

        failif( 0 == length , "INVALID EMPTY PATH OR URI" );

        FreeLater free_later;

        //.........................................................................
        // Save the original passed in - for debugging.

        me->original = args.app_path;

        //.........................................................................
        // We start by looking at the scheme. This function does not look at the
        // rest of the app_path, so it is not too picky about escaping and such

        char* scheme = g_uri_parse_scheme( args.app_path.c_str() );

        // NULL is OK here.

        free_later( scheme );

        //.........................................................................
        // There is no scheme, or the scheme is poorly formatted, so this must be
        // a plain old UNIX path. We use UriParser to get a URI from a UNIX file
        // name.

        if ( 0 == scheme )
        {
            // We allow absolute paths...since all paths are really just
            // relative to the app's root. So, we ignore any leading slashes.

            const char* relative_path = args.app_path.c_str();

            while ( '/' == * relative_path )
            {
                ++relative_path;
            }

            // There is nothing left - bad path

            failif( 0 == * relative_path , "INVALID EMPTY PATH" );

            // Convert the relative path to a relative URI. This will
            // already be escaped. We're using the length of the original
            // path passed in, which should be greater and therefore OK.

            char* relative_child_uri_string = g_new0( char , 7 + 3 * length + 1 );

            free_later( relative_child_uri_string );

            failif( URI_SUCCESS != uriUnixFilenameToUriStringA( relative_path , relative_child_uri_string ) , "INVALID PATH" );

            // Get the URI for the app's root

            String root_uri_string = args.root_uri;

            failif( root_uri_string.empty() , "APP ROOT IS INVALID" );

            // Add a trailing slash to the root URI if it is missing

            if ( root_uri_string[ root_uri_string.length() - 1 ] != '/' )
            {
                root_uri_string += "/";
            }

            tplog2( "APP PATH IS             [%s]" , args.app_path.c_str() );
            tplog2( "  ROOT URI IS           [%s]" , root_uri_string.c_str() );
            tplog2( "  RELATIVE CHILD URI IS [%s]" , relative_child_uri_string );

            // The root URI should be an absolute URI

            // Now, we have to parse both, so we can create a final URI

            UriParserStateA state;

            UriUriA root_uri;
            state.uri = & root_uri;

            if ( URI_SUCCESS != uriParseUriA( & state , root_uri_string.c_str() ) )
            {
                uriFreeUriMembersA( & root_uri );
                failif( true , "APP ROOT URI COULD NOT BE PARSED '%s'" , root_uri_string.c_str() );
            }

            UriUriA relative_child_uri;
            state.uri = & relative_child_uri;

            if ( URI_SUCCESS != uriParseUriA( & state , relative_child_uri_string ) )
            {
                uriFreeUriMembersA( & root_uri );
                uriFreeUriMembersA( & relative_child_uri );
                failif( true , "PATH URI COULD NOT BE PARSED" );
            }

            UriUriA absolute_uri;

            if ( URI_SUCCESS != uriAddBaseUriA( & absolute_uri , & relative_child_uri , & root_uri ) )
            {
                uriFreeUriMembersA( & root_uri );
                uriFreeUriMembersA( & relative_child_uri );
                failif( true , "FAILED TO CREATE ABSOLUTE URI FOR PATH" );
            }

            //.....................................................................
            // Clean these up

            uriFreeUriMembersA( & root_uri );
            uriFreeUriMembersA( & relative_child_uri );

            //.....................................................................

            int chars_required = 0;

            uriToStringCharsRequiredA( & absolute_uri , & chars_required );

            ++chars_required;

            char* absolute_uri_string = g_new0( char , chars_required );

            free_later( absolute_uri_string );

            if ( URI_SUCCESS != uriToStringA( absolute_uri_string , & absolute_uri , chars_required , 0 ) )
            {
                uriFreeUriMembersA( & absolute_uri );
                failif( true , "FAILED TO STRINGIFY FINAL URI" );
            }

            //.....................................................................

            uriFreeUriMembersA( & absolute_uri );

            tplog2( "  ABSOLUTE CHILD URI IS [%s]" , absolute_uri_string );

            //.....................................................................
            // Now we have the final absolute URI, we need to make sure it is
            // within the root.

            failif( ! is_child( root_uri_string , absolute_uri_string ) , "PATH OUTSIDE APP ROOT" );

            //.....................................................................
            // If the final URI points to a file system path, we get the native
            // path and store it in native_path. This is a native path! It will
            // be different on windows and Unix.

            GFile* file = g_file_new_for_uri( absolute_uri_string );

            free_later( file , g_object_unref );

            if ( g_file_is_native( file ) )
            {
                if ( char* path = g_file_get_path( file ) )
                {
                    me->native_path = path;
                    g_free( path );
                }
            }

            // All is well, we store the uri here to mark this object as 'good'.

            me->uri = absolute_uri_string;
        }

        //.........................................................................
        // The app_path has a scheme. It could be a real URI or a local path
        // prefixed with one of our schemes, such as "localized".

        else
        {
            // Empty scheme, WTF?

            failif( 0 == strlen( scheme ) , "INVALID EMPTY SCHEME" );

            // The 'file' scheme is NEVER allowed as an input.

            failif( ! strcmp( scheme , "file" ) , "SCHEME 'file:' NOT ALLOWED" );

            // localized: scheme. We have to handle in a special way
            // What follows the scheme is a plain UNIX path that we have to
            // append to other directories and check for existence in order.

            if ( ! strcmp( scheme , "localized" ) )
            {
                failif( 0 != ( args.flags & AppResource::LOCALIZED_NOT_ALLOWED ) , "SCHEME 'localized:' NOT ALLOWED" );

                const char* relative_path = args.app_path.c_str();

                // Skip to the first : or the end of the string

                while ( * relative_path != 0 && * relative_path != ':' )
                {
                    ++relative_path;
                }

                // If we are not at the : something is wrong

                failif( ':' != * relative_path , "INVALID LOCALIZED PATH" );

                // Skip the :

                ++relative_path;

                // Now skip any leading slashes

                while ( '/' == * relative_path )
                {
                    ++relative_path;
                }

                // If there is nothing left, bail

                failif( 0 == * relative_path , "EMPTY LOCALIZED PATH" );

                // We need to have an app pointer to do the rest, so we fail
                // if we don't. This is a programmer error.

                g_assert( args.app );

                // Now, prepare a list of prefixes to try

                String language( args.app->get_context()->get( TP_SYSTEM_LANGUAGE ) );
                String country( args.app->get_context()->get( TP_SYSTEM_COUNTRY ) );

                StringList prefixes;

                prefixes.push_back( String( "localized/" ) + language + "/" + country );
                prefixes.push_back( String( "localized/" ) + language );
                prefixes.push_back( String( "localized" ) );

                for ( StringList::const_iterator it = prefixes.begin(); it != prefixes.end(); ++it )
                {
                    String try_path( * it + "/" + relative_path );

                    AppResource path( args.app , try_path.c_str() , AppResource::URI_NOT_ALLOWED | AppResource::LOCALIZED_NOT_ALLOWED );

                    if ( path.exists( args.app ) )
                    {
                        * me = path;
                        return;
                    }
                }

                // If none of those exist, we create a new path with just the relative path,
                // and assign it to this one. If the path is bad, it will have failed
                // and reported the issue.

                make( me , Args( args.app , relative_path , AppResource::URI_NOT_ALLOWED | AppResource::LOCALIZED_NOT_ALLOWED ) );

                return;
            }

            // It is some other kind of scheme. We now check to see
            // if URI_NOT_ALLOWED is in the flags.

            failif( 0 != ( args.flags & AppResource::URI_NOT_ALLOWED ) , "URI NOT ALLOWED" );

            // Make a copy of the schemes passed in and add http and https
            // which are always allowed schemes.

            StringSet all_schemes( args.schemes );

            all_schemes.insert( "http" );
            all_schemes.insert( "https" );

            // If the scheme is not one of the ones allowed, bail

            failif( all_schemes.find( scheme ) == all_schemes.end() , "SCHEME '%s:' NOT ALLOWED" , scheme );

            // This helps us troubleshoot the URI and also escapes it.

            SoupURI* uri_uri = soup_uri_new( args.app_path.c_str() );

            failif( 0 == uri_uri , "INVALID URI" );

            free_later( uri_uri , ( GDestroyNotify ) soup_uri_free );

            char* uri_s = soup_uri_to_string( uri_uri , false );

            // This should never happen, but let's guard against it
            // anyway. This is sensitive code.

            failif( 0 == uri_s , "INVALID URI" );

            free_later( uri_s );

            // Everything is fine. We make this object 'good' by
            // populating its URI.

            me->uri = uri_s;
        }
    }
    catch ( const String& e )
    {
        tpwarn( "%s : '%s'" , e.c_str() , args.app_path.c_str() );
        me->uri.clear();
    }
}

//.............................................................................

bool AppResource::is_child( const String& root_uri , const String& child_uri )
{
    g_assert( root_uri.length() > 0 );

    bool result = false;

    // In order for the parent checking to work correctly for
    // URIs, we have to get rid of the trailing slash from the
    // root URI.

    String slashless_root_uri( root_uri );

    if ( root_uri[ root_uri.length() - 1 ] == '/' )
    {
        slashless_root_uri = root_uri.substr( 0 , root_uri.length() - 1 );
    }

    GFile* root = g_file_new_for_uri( slashless_root_uri.c_str() );

    if ( 0 == root )
    {
        return false;
    }

    GFile* child = g_file_new_for_uri( child_uri.c_str() );

    if ( 0 == child )
    {
        g_object_unref( root );
        return false;
    }

    while ( ! result )
    {
        if ( g_file_has_parent( child , root ) )
        {
            g_object_unref( G_OBJECT( child ) );
            result = true;
        }
        else
        {
            GFile* parent = g_file_get_parent( child );

            g_object_unref( G_OBJECT( child ) );

            if ( ! parent )
            {
                break;
            }

            child = parent;
        }
    }

    g_object_unref( root );

    return result;
}

//.....................................................................
// Returns true if the path is valid and is either HTTP or HTTPS.

bool AppResource::is_http() const
{
    if ( ! good() )
    {
        return false;
    }

    bool result = false;

    if ( SoupURI* suri = soup_uri_new( uri.c_str() ) )
    {
        const char* scheme = soup_uri_get_scheme( suri );

        result = ( scheme == SOUP_URI_SCHEME_HTTP || scheme == SOUP_URI_SCHEME_HTTPS );

        soup_uri_free( suri );
    }

    return result;
}

//.............................................................................

bool AppResource::exists( App* app ) const
{
    g_assert( app );

    if ( ! good() )
    {
        // This path ain't no good.

        return false;
    }

    bool result = false;

    if ( is_native() )
    {
        GFile* file = g_file_new_for_path( native_path.c_str() );

        result = g_file_query_exists( file , 0 );

        g_object_unref( file );
    }
    else if ( is_http() )
    {
        if ( Network* network = app->get_network() )
        {
            Network::Request request( app->get_user_agent() , uri );

            request.method = "HEAD";

            Network::Response response = network->perform_request( request , app->get_cookie_jar() );

            result = ( response.code == 200 );
        }
    }

    return result;
}

//.............................................................................

Util::Buffer AppResource::load_contents( App* app ) const
{
    Util::Buffer result;

    if ( ! good() )
    {
        return result;
    }

    if ( is_native() )
    {
        GFile* file = g_file_new_for_path( native_path.c_str() );

        gchar* contents = 0;
        gsize length = 0;
        GError* error = 0;

        // TODO: The ETag returned by this function could be useful if we start
        // caching stuff.

        g_file_load_contents( file , 0 , & contents , & length , 0 , & error );

        g_object_unref( file );

        if ( error )
        {
            tpwarn( "FAILED TO READ CONTENTS OF '%s' : %s" , original.c_str() , error->message );

            g_free( contents );
            g_clear_error( & error );
        }
        else
        {
            // g_file_load_contents always adds a null to the end, but
            // does not count that zero in the length.

            result = Util::Buffer( Util::Buffer::MEMORY_USE_TAKE , contents , length );
        }

    }
    else if ( is_http() )
    {
        Network::Response response;

        if ( 0 != app )
        {
            if ( Network* network = app->get_network() )
            {
                Network::Request request( app->get_user_agent() , uri );

                response = network->perform_request( request , app->get_cookie_jar() );
            }
        }
        else
        {
            Network* network = new Network();

            Network::Request request( String() , uri );

            response = network->perform_request( request , 0 );

            delete network;
        }

        if ( ! response.failed )
        {
            // Zero terminator
            guint8 terminator = 0;
            g_byte_array_append( response.body , & terminator , 1 );

            result = Util::Buffer( g_byte_array_set_size( response.body , response.body->len - 1 ) );
        }
    }

    return result;
}

//=============================================================================

class LuaLoader
{
public:

    virtual ~LuaLoader()
    {}

    int load( lua_State* L , const String& chunk_name )
    {
        return lua_load( L , LuaLoader::lua_Reader , this , chunk_name.c_str() , 0 );
    }

protected:

    virtual const char* lua_read( lua_State* L , size_t* size ) = 0;

private:

    static const char* lua_Reader( lua_State* L , void* data , size_t* size )
    {
        return ( ( LuaLoader* ) data )->lua_read( L , size );
    }
};

//=============================================================================

class LuaLoaderAppResource : public LuaLoader
{
public:

    LuaLoaderAppResource( const AppResource& _resource )
        :
        resource( _resource )
    {}


protected:

    //.........................................................................
    // Lua will call us as many times as we return something. It also expects
    // the results to survive between calls. So, on the first call, we load
    // the contents of the file, keep them and return them. On the second call,
    // we return 0.

    virtual const char* lua_read( lua_State* L , size_t* size )
    {
        g_assert( size );

        // If we have already read, we return 0

        if ( contents )
        {
            contents = Util::Buffer();

            * size = 0;

            return 0;
        }

        contents = resource.load_contents( App::get( L ) );

        if ( contents )
        {
            * size = contents.length();
            return  contents.data();
        }

        * size = 0;
        return 0;
    }

private:

    AppResource     resource;
    Util::Buffer    contents;
};

//=============================================================================
// This one loads from an external resource reader

#define TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE   8192

class LuaLoaderResourceReader : public LuaLoader
{
public:

    LuaLoaderResourceReader( const TPResourceReader& _reader )
        :
        finished( false ),
        reader( _reader )
    {
        g_assert( reader.read );

        buffer = g_new( char , TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE );
    }

    ~LuaLoaderResourceReader()
    {
        g_free( buffer );
    }

    virtual const char* lua_read( lua_State* , size_t* size )
    {
        if ( finished )
        {
            * size = 0;

            return 0;
        }

        unsigned long int bytes_read = reader.read(
                buffer ,
                TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE ,
                reader.user_data );

        g_assert( bytes_read <= TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE );

        * size = bytes_read;

        if ( bytes_read < TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE )
        {
            finished = true;
        }

        return buffer;
    }


private:

    char*              buffer;
    bool                finished;
    TPResourceReader    reader;
};

#undef TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE

//=============================================================================

int AppResource::lua_load( lua_State* L ) const
{
    if ( ! good() )
    {
        lua_pushfstring( L , "INVALID PATH '%s'" , original.c_str() );
        return LUA_ERRFILE;
    }

    App* app = App::get( L );

    g_assert( app );

    if ( ! exists( app ) )
    {
        lua_pushfstring( L , "FAILED TO OPEN '%s'" , original.c_str() );
        return LUA_ERRFILE;
    }

    LuaLoader* lua_loader = 0;

    // If we have a context and this is a native file (not a URL), we check to
    // see if the context has an external resource loader for Lua files.

    if ( is_native() )
    {
        TPContext*         context = app->get_context();
        TPResourceLoader    loader = 0;
        void*              user_data = 0;

        if ( context->get_resource_loader( TP_RESOURCE_TYPE_LUA_SOURCE , & loader , & user_data ) )
        {
            g_assert( loader );

            // We call the external loader to give us a reader. If it does not,
            // we assume it could not open the file.

            TPResourceReader resource_reader;

            memset( & resource_reader , 0 , sizeof( resource_reader ) );

            int load_result = loader( context , TP_RESOURCE_TYPE_LUA_SOURCE , native_path.c_str() , & resource_reader , user_data );

            if ( 0 != load_result )
            {
                // The loader failed

                tpwarn( "EXTERNAL LOADER FAILED WITH %d FOR '%s'" , load_result , native_path.c_str() );

                lua_pushfstring( L , "FAILED TO OPEN '%s'" , original.c_str() );

                return LUA_ERRFILE;
            }

            tplog2( "USING EXTERNAL RESOURCE LOADER FOR '%s'" , native_path.c_str() );

            // Create a LuaLoader to do the rest

            lua_loader = new LuaLoaderResourceReader( resource_reader );
        }
    }

    if ( 0 == lua_loader )
    {
        lua_loader = new LuaLoaderAppResource( * this );
    }

    int result = lua_loader->load( L , original );

    delete lua_loader;

    return result;
}

//.............................................................................

StringPairList AppResource::get_native_children( const String& uri_or_native_path )
{
    StringPairList result;

    GFile* root = g_file_new_for_commandline_arg( uri_or_native_path.c_str() );

    if ( ! g_file_is_native( root ) )
    {
        g_object_unref( root );
        return result;
    }

    typedef std::stack< GFile* > FileStack;

    FileStack stack;

    stack.push( root );

    g_object_ref( root );

    while ( ! stack.empty() )
    {
        GFile* r = stack.top();

        stack.pop();

        GFileEnumerator* e = g_file_enumerate_children( r , "standard::*" , G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS , 0 , 0 );

        if ( e )
        {
            while ( GFileInfo* info = g_file_enumerator_next_file( e , 0 , 0 ) )
            {
                if ( const char* name = g_file_info_get_name( info ) )
                {
                    if ( GFile* child = g_file_get_child( r , name ) )
                    {
                        if ( g_file_info_get_file_type( info ) == G_FILE_TYPE_DIRECTORY )
                        {
                            stack.push( child );
                        }
                        else
                        {
                            FreeLater free_later;

                            char* absolute_path = g_file_get_path( child );
                            char* relative_path = g_file_get_relative_path( root , child );

                            free_later( absolute_path );
                            free_later( relative_path );

                            if ( relative_path && absolute_path )
                            {
                                result.push_back( StringPair( absolute_path , relative_path ) );
                            }

                            g_object_unref( child );
                        }
                    }
                }

                g_object_unref( info );
            }

            g_file_enumerator_close( e , 0 , 0 );

            g_object_unref( e );
        }

        g_object_unref( r );
    }

    g_object_unref( root );

    return result;
}

//.............................................................................

static String build_unescaped_path( const UriUriA& uri )
{
    String result;

    for ( UriPathSegmentA* ps = uri.pathHead; ps; ps = ps->next )
    {
        if ( ps->text.first && ps->text.afterLast && ( ps->text.afterLast > ps->text.first ) )
        {
            // Allocates memory for the given size + 1, copies size characters
            // from the source and adds a 0 at the end.

            gchar* part = g_strndup( ps->text.first , ps->text.afterLast - ps->text.first );

            // Does it in place and moves the terminating 0.

            ( void ) uriUnescapeInPlaceA( part );

            if ( ! result.empty() )
            {
                // Always / because this is a pi path.

                result += "/";
            }

            result += part;

            g_free( part );
        }
    }

    return result;
}

//.............................................................................

StringList AppResource::get_pi_children( const String& uri_or_native_path )
{
    FreeLater free_later;

    StringList result;

    StringPairList native_list( get_native_children( uri_or_native_path ) );

    if ( native_list.empty() )
    {
        return result;
    }

    GFile* root = g_file_new_for_commandline_arg( uri_or_native_path.c_str() );

    free_later( root , g_object_unref );

    if ( ! g_file_is_native( root ) )
    {
        return result;
    }

    char* root_uri_string = g_file_get_uri( root );

    if ( ! root_uri_string )
    {
        return result;
    }

    free_later( root_uri_string );

    UriParserStateA state;
    UriUriA root_uri;

    state.uri = & root_uri;

    if ( URI_SUCCESS != uriParseUriA( & state , root_uri_string ) )
    {
        uriFreeUriMembersA( & root_uri );
        return result;
    }

    for ( StringPairList::const_iterator it = native_list.begin(); it != native_list.end(); ++it )
    {
        GFile* file = g_file_new_for_path( it->first.c_str() );

        char* uri_string = g_file_get_uri( file );

        g_object_unref( file );

        if ( ! uri_string )
        {
            continue;
        }

        UriUriA absolute_child_uri;
        state.uri = & absolute_child_uri;

        if ( URI_SUCCESS == uriParseUriA( & state , uri_string ) )
        {
            UriUriA relative_child_uri;

            if ( URI_SUCCESS == uriRemoveBaseUriA( & relative_child_uri , & absolute_child_uri , & root_uri , URI_FALSE ) )
            {
                String path = build_unescaped_path( relative_child_uri );

                if ( ! path.empty() )
                {
                    result.push_back( path );
                }
            }

            uriFreeUriMembersA( & relative_child_uri );
        }

        uriFreeUriMembersA( & absolute_child_uri );

        g_free( uri_string );
    }

    uriFreeUriMembersA( & root_uri );

    return result;
}


