
#include <stack>

#include "uriparser/Uri.h"

#include "sandbox.h"
#include "util.h"
#include "context.h"

//.............................................................................

#define TP_LOG_DOMAIN   "SANDBOX"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//=============================================================================

class LuaLoader
{
public:

	virtual ~LuaLoader()
	{
	}

	int load( lua_State * L , const String & chunk_name )
	{
		return lua_load( L , LuaLoader::lua_Reader , this , chunk_name.c_str() );
	}

protected:

	virtual const char * lua_read( lua_State * L , size_t * size ) = 0;

private:

	static const char * lua_Reader( lua_State * L , void * data , size_t * size )
	{
		return ( ( LuaLoader * ) data )->lua_read( L , size );
	}
};

//=============================================================================

class LuaLoaderGFile : public LuaLoader
{
public:

	//.........................................................................
	// Ownership of the GFile is transferred to the reader. That is, this
	// constructor does not ref the file - it assumes ownership of the
	// current ref.

	LuaLoaderGFile( GFile * _file )
	:
		file( _file ),
		contents( 0 )
	{
		g_assert( file );
	}

	~LuaLoaderGFile()
	{
		g_object_unref( G_OBJECT( file ) );

		g_free( contents );
	}

protected:

	//.........................................................................
	// Lua will call us as many times as we return something. It also expects
	// the results to survive between calls. So, on the first call, we load
	// the contents of the file, keep them and return them. On the second call,
	// we return 0.

	virtual const char * lua_read( lua_State * , size_t * size )
	{
		g_assert( size );

		// If we have already read, we return 0

		if ( contents )
		{
			g_free( contents );

			contents = 0;

			* size = 0;

			return 0;
		}

		gsize length = 0;

		contents = Sandbox::get_contents( file , length );

		* size = length;

		// If we fail to read the contents, self->contents and length will be 0.
		// This is what Lua expects. get_contents will have printed out an error
		// message.
		//
		// If it succeeds, we now own the contents and Lua will call us again.

		return contents;
	}

private:

	GFile *	file;
	gchar * contents;
};

//=============================================================================

#define TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE	8192

class LuaLoaderResourceReader : public LuaLoader
{
public:

	LuaLoaderResourceReader( const TPResourceReader & _reader )
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

	virtual const char * lua_read( lua_State * , size_t * size )
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

	char * 				buffer;
	bool				finished;
	TPResourceReader 	reader;
};

#undef TP_LUA_LOADER_RESOURCE_READER_BUFFER_SIZE

//=============================================================================
// Sandbox

Sandbox::Sandbox()
:
	root( 0 ),
	context( 0 )
{
}

//.............................................................................

Sandbox::Sandbox( const gchar * _root )
:
	root( _root ? g_file_new_for_commandline_arg( _root ) : 0 ),
	context( 0 )
{
}

//.............................................................................

Sandbox::Sandbox( const String & _root )
:
    root( _root.empty() ? 0 : g_file_new_for_commandline_arg( _root.c_str() ) ),
    context( 0 )
{
}

//.............................................................................

Sandbox::Sandbox( const Sandbox & other )
:
    root( 0 ),
    context( 0 )
{
	* this = other;
}

//.............................................................................

const Sandbox & Sandbox::operator = ( const Sandbox & other )
{
	GFile * old_root = root;

	root = other.root;

	if ( root )
	{
		g_object_ref( G_OBJECT( root ) );
	}

	if ( old_root )
	{
		g_object_unref( G_OBJECT( old_root ) );
	}

	context = other.context;

	return *this;
}

//.............................................................................

Sandbox::~Sandbox()
{
	if ( root )
	{
		g_object_unref( G_OBJECT( root ) );
	}
}

//.............................................................................

void Sandbox::set_context( TPContext * _context )
{
	context = _context;
}

//.............................................................................

bool Sandbox::is_valid() const
{
	return root != 0;
}

//.............................................................................

bool Sandbox::is_native() const
{
	return root ? g_file_is_native( root ) : false;
}

//.............................................................................

String Sandbox::get_root_native_path() const
{
	String result;

	if ( gchar * path = root ? g_file_get_path( root ) : 0 )
	{
		result = path;
		g_free( path );
	}

	return result;
}

//.............................................................................

String Sandbox::get_root_uri() const
{
	String result;

	if ( gchar * uri = root ? g_file_get_uri( root ) : 0 )
	{
		result = uri;
		g_free( uri );
	}

	return result;
}

//.............................................................................

GFile * Sandbox::get_pi_child( const String & pi_path ) const
{
	if ( ! root )
	{
		tpwarn( "CANNOT GET PATH FOR '%s' : SANDBOX IS INVALID" , pi_path.c_str() );

		return 0;
	}

	if ( pi_path.empty() )
	{
		tpwarn( "INVALID EMPTY PATH" );

		return 0;
	}


	gchar * path = g_strdup( pi_path.c_str() );

	FreeLater free_later( path );

	// See if it has a scheme

	Scheme scheme = NO_SCHEME;

	if ( g_str_has_prefix( path , "localized:" ) )
	{
		path += 10;

		scheme = LOCALIZED;
	}

	// Convert it to a native path, by replacing all the directory separators.
	// This is not perfect, but we will do some other checks later to make
	// sure we end up with something sane.

    if ( G_DIR_SEPARATOR != '/' )
    {
        path = g_strdelimit( path , "/", G_DIR_SEPARATOR );
    }

    return get_native_child( path , scheme );
}

//.............................................................................

GFile * Sandbox::resolve_relative_native_child( const String & native_path , Scheme scheme ) const
{
	switch( scheme )
	{
	case NO_SCHEME:
		return g_file_resolve_relative_path( root , native_path.c_str() );

	case LOCALIZED:
	{
		if ( ! context )
		{
			return 0;
		}

		String language( context->get( TP_SYSTEM_LANGUAGE ) );
		String country( context->get( TP_SYSTEM_COUNTRY ) );

		StringList pi_paths;

		pi_paths.push_back( String( "localized/" ) + language + "/" + country );
		pi_paths.push_back( String( "localized/" ) + language );
		pi_paths.push_back( String( "localized" ) );

		for ( StringList::const_iterator it = pi_paths.begin(); it != pi_paths.end(); ++it )
		{
			if ( GFile * base = get_pi_child( * it ) )
			{
				if ( GFile * file = g_file_resolve_relative_path( base , native_path.c_str() ) )
				{
					if ( g_file_query_exists( file , 0 ) )
					{
						g_object_unref( G_OBJECT( base ) );

						return file;
					}

					g_object_unref( G_OBJECT( file ) );
				}

				g_object_unref( G_OBJECT( base ) );
			}
		}

		return g_file_resolve_relative_path( root , native_path.c_str() );
	}
	}

	return 0;
}

//.............................................................................

GFile * Sandbox::get_native_child( const String & native_path , Scheme scheme ) const
{
	if ( ! root )
	{
		tpwarn( "CANNOT GET PATH FOR '%s' : SANDBOX IS INVALID" , native_path.c_str() );

		return 0;
	}

	if ( native_path.empty() )
	{
		tpwarn( "INVALID EMPTY PATH" );

		return 0;
	}

	const gchar * path = native_path.c_str();

	// Now see if it is an absolute path

    if ( g_path_is_absolute( path ) )
    {
    	path = g_path_skip_root( path );
    }

    // Get a file pointing to the child

    GFile * child = resolve_relative_native_child( path , scheme );

    if ( ! child )
    {
    	tpwarn( "INVALID PATH '%s'" , path );

    	return 0;
    }

    // Now ensure that the child has the sandbox as its ancestor

    if ( ! is_in_sandbox( child ) )
    {
    	g_object_unref( child );

    	tpwarn( "PATH OUTSIDE OF SANDBOX '%s'" , path );

    	return 0;
    }

#if 0

    gchar * p = g_file_get_parse_name( child );

    tplog( "%s" , p );

    g_free( p );

#endif

    // Everything is in order

    return child;
}

//.............................................................................

gchar * Sandbox::get_native_child_contents( const String & native_path , gsize & length ) const
{
	GFile * file = get_native_child( native_path );

	if ( ! file )
	{
		return 0;
	}

	FreeLater free_later( file , g_object_unref );

	return get_contents( file , length );
}

//.............................................................................

gchar * Sandbox::get_pi_child_contents( const String & pi_path , gsize & length ) const
{
	GFile * file = get_pi_child( pi_path );

	if ( ! file )
	{
		return 0;
	}

	FreeLater free_later( file , g_object_unref );

	return get_contents( file , length );
}

//.............................................................................

gchar * Sandbox::get_contents( GFile * file , gsize & length )
{
	g_assert( file );

	gchar * contents = 0;
	GError * error = 0;

	// TODO: The ETag returned by this function could be useful if we start
	// caching stuff.

	g_file_load_contents( file , 0 , & contents , & length , 0 , & error );

	if ( error )
	{
		gchar * name = g_file_get_parse_name( file );

		tpwarn( "FAILED TO READ CONTENTS OF '%s' : %s" , name , error->message );

		g_free( name );
		g_free( contents );
		g_clear_error( & error );

		length = 0;

		return 0;
	}

	return contents;
}

//.............................................................................

int Sandbox::lua_load_pi_child( lua_State * L , const String & pi_path ) const
{
	// Get GFile for a PI child path

	GFile * file = get_pi_child( pi_path );

	// Could not get the GFile for it

	if ( ! file )
	{
		lua_pushfstring( L , "FAILED TO OPEN '%s'" , pi_path.c_str() );

		return LUA_ERRFILE;
	}

	// It doesn't exist

	if ( ! g_file_query_exists( file , 0 ) )
	{
		g_object_unref( file );

		lua_pushfstring( L , "FAILED TO OPEN '%s'" , pi_path.c_str() );

		return LUA_ERRFILE;
	}

	LuaLoader * lua_loader = 0;

	// If we have a context and this is a native file (not a URL), we check to
	// see if the context has an external resource loader for Lua files.

	if ( context && g_file_is_native( file ) )
	{
		TPResourceLoader 	loader = 0;
		void * 				user_data = 0;

		if ( context->get_resource_loader( TP_RESOURCE_TYPE_LUA_SOURCE , & loader , & user_data ) )
		{
			g_assert( loader );

			// There is an external resource loader, so we have to get the
			// native path of the file.

			char * native_path = g_file_get_path( file );

			if ( ! native_path )
			{
				g_object_unref( file );

				lua_pushfstring( L , "FAILED TO OPEN '%s'" , pi_path.c_str() );

				return LUA_ERRFILE;
			}

			// We call the external loader to give us a reader. If it does not,
			// we assume it could not open the file.

			TPResourceReader resource_reader;

			memset( & resource_reader , 0 , sizeof( resource_reader ) );

			int load_result = loader( context , TP_RESOURCE_TYPE_LUA_SOURCE , native_path , & resource_reader , user_data );

			if ( 0 != load_result )
			{
				// The loader failed

				tpwarn( "EXTERNAL LOADER FAILED WITH %d FOR '%s'" , load_result , native_path );

				g_object_unref( file );

				g_free( native_path );

				lua_pushfstring( L , "FAILED TO OPEN '%s'" , pi_path.c_str() );

				return LUA_ERRFILE;
			}

			tplog2( "USING EXTERNAL RESOURCE LOADER FOR '%s'" , native_path );

			// We no longer need the GFile or the native path

			g_object_unref( file );

			g_free( native_path );

			// Create a LuaLoader to do the rest

			lua_loader = new LuaLoaderResourceReader( resource_reader );
		}
	}

	if ( 0 == lua_loader )
	{
		lua_loader = new LuaLoaderGFile( file );
	}

	int result = lua_loader->load( L , pi_path );

	delete lua_loader;

	return result;
}

//.............................................................................

String Sandbox::get_pi_child_uri( const String & pi_path , bool & is_native ) const
{
	String result;

	if ( GFile * file = get_pi_child( pi_path ) )
	{
		is_native = g_file_is_native( file );

		gchar * uri = g_file_get_uri( file );

		result = uri;

		g_free( uri );
		g_object_unref( G_OBJECT( file ) );
	}

	return result;
}

//.............................................................................

String Sandbox::get_pi_child_native_path( const String & pi_path ) const
{
	String result;

	if ( GFile * file = get_pi_child( pi_path ) )
	{
		if ( gchar * path = g_file_get_path( file ) )
		{
			result = path;
			g_free( path );
		}
		g_object_unref( G_OBJECT( file ) );
	}

	return result;
}

//.............................................................................

bool Sandbox::is_in_sandbox( GFile * file ) const
{
	if ( ! root || ! file )
	{
		return false;
	}

	GFile * child = file;

	g_object_ref( G_OBJECT( child ) );

	while ( true )
	{
		if ( g_file_has_parent( child , root ) )
		{
			g_object_unref( G_OBJECT( child ) );
			return true;
		}

		GFile * parent = g_file_get_parent( child );

		g_object_unref( G_OBJECT( child ) );

		if ( ! parent )
		{
			break;
		}

		child = parent;
	}

	return false;
}

//.............................................................................

bool Sandbox::native_child_exists( const String & native_path ) const
{
	bool result = false;

	if ( GFile * file = get_native_child( native_path ) )
	{
		result = g_file_query_exists( file , 0 );

		g_object_unref( G_OBJECT( file ) );
	}

	return result;
}

//.............................................................................

StringPairList Sandbox::get_native_children() const
{
	StringPairList result;

	if ( 0 == root )
	{
		return result;
	}

	typedef std::stack< GFile * > FileStack;

	FileStack stack;

	g_object_ref( root );

	stack.push( root );

	while ( ! stack.empty() )
	{
		GFile * r = stack.top();

		stack.pop();

		GFileEnumerator * e = g_file_enumerate_children( r , "standard::*" , G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS , 0 , 0 );

		if ( e )
		{
			while ( GFileInfo * info = g_file_enumerator_next_file( e , 0 , 0 ) )
			{
				if ( const char * name = g_file_info_get_name( info ) )
				{
					if ( GFile * child = g_file_get_child( r , name ) )
					{
						if ( g_file_info_get_file_type( info ) == G_FILE_TYPE_DIRECTORY )
						{
							stack.push( child );
						}
						else
						{
							FreeLater free_later;

							char * absolute_path = g_file_get_path( child );
							char * relative_path = g_file_get_relative_path( root , child );

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

	return result;
}

//.............................................................................

static String build_unescaped_path( const UriUriA & uri )
{
	String result;

	for ( UriPathSegmentA * ps = uri.pathHead; ps; ps = ps->next )
	{
		if ( ps->text.first && ps->text.afterLast && ( ps->text.afterLast > ps->text.first ) )
		{
			// Allocates memory for the given size + 1, copies size characters
			// from the source and adds a 0 at the end.

			gchar * part = g_strndup( ps->text.first , ps->text.afterLast - ps->text.first );

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

StringList Sandbox::get_pi_children() const
{
	StringList result;

	StringPairList native_list( get_native_children() );

	if ( native_list.empty() )
	{
		return result;
	}

	FreeLater free_later;

	char * root_uri_string = g_file_get_uri( root );

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
		GFile * file = g_file_new_for_path( it->first.c_str() );

		char * uri_string = g_file_get_uri( file );

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

