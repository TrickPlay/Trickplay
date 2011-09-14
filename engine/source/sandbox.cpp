
#include "sandbox.h"
#include "util.h"
#include "context.h"

//.............................................................................

#define TP_LOG_DOMAIN   "SANDBOX"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================
// Reader

Sandbox::Reader::Reader()
{
	g_assert( false );
}

//.............................................................................
// Ownership of the GFile is transferred to the reader. That is, this
// constructor does not ref the file - it assumes ownership of the
// current ref.

Sandbox::Reader::Reader( GFile * _file )
:
    file( _file ),
    contents( 0 )
{
	g_assert( file );
}

//.............................................................................

Sandbox::Reader::Reader( const Reader & )
{
	g_assert( false );
}

//.............................................................................

Sandbox::Reader::~Reader()
{
	g_object_unref( G_OBJECT( file ) );

	g_free( contents );
}

//.............................................................................
// Lua will call us as many times as we return something. It also expects the
// results to survive between calls. So, on the first call, we load the contents
// of the file, keep them and return them. On the second call, we return 0.

const char * Sandbox::Reader::lua_Reader( lua_State * , void * me , size_t * size )
{
	g_assert( me );
	g_assert( size );

	Reader * self = ( Reader * ) me;

	// If we have already read, we return 0

	if ( self->contents )
	{
		g_free( self->contents );

		self->contents = 0;

		* size = 0;

		return 0;
	}

	gsize length = 0;

	self->contents = Sandbox::get_contents( self->file , length );

	* size = length;

	// If we fail to read the contents, self->contents and length will be 0.
	// This is what Lua expects. get_contents will have printed out an error
	// message.
	//
	// If it succeeds, we now own the contents and Lua will call us again.

	return self->contents;
}

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

Sandbox::Reader * Sandbox::get_native_child_reader( const String & native_path ) const
{
	GFile * file = get_native_child( native_path );

	if ( file && ! g_file_query_exists( file , 0 ) )
	{
		g_object_unref( G_OBJECT( file ) );
		return 0;
	}

	return file ? new Reader( file ) : 0;
}

//.............................................................................

Sandbox::Reader * Sandbox::get_pi_child_reader( const String & pi_path ) const
{
	GFile * file = get_pi_child( pi_path );

	if ( file && ! g_file_query_exists( file , 0 ) )
	{
		g_object_unref( G_OBJECT( file ) );
		return 0;
	}

	return file ? new Reader( file ) : 0;
}

//.............................................................................

int Sandbox::lua_load_pi_child( lua_State * L , const String & pi_path ) const
{
	Reader * reader = get_pi_child_reader( pi_path );

	if ( ! reader )
	{
		lua_pushfstring( L , "FAILED TO OPEN '%s'" , pi_path.c_str() );

		return LUA_ERRFILE;
	}

	int result = lua_load( L , Reader::lua_Reader , reader , pi_path.c_str() );

	delete reader;

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
