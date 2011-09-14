#ifndef _TRICKPLAY_SANDBOX_H
#define _TRICKPLAY_SANDBOX_H

#include "gio/gio.h"
#include "common.h"

class Sandbox
{
public:

	Sandbox();

	Sandbox( const gchar * root );

	Sandbox( const String & root );

	Sandbox( const Sandbox & other );

	const Sandbox & operator = ( const Sandbox & other );

	virtual ~Sandbox();

	enum Scheme { NO_SCHEME , LOCALIZED };

	// Some platform independent paths let you specify a scheme
	// that needs a context to be resolved. "localized:", for example.

	void set_context( TPContext * context );

	// Whether the sandbox has a root. If it has a root
	// that, for example, doesn't exist it may still be bad, but this
	// will return true. This returns root != 0.

	bool is_valid() const;

	// Whether the sandbox is a native file system path. If it is a remote
	// URI or something else, it will return false.

	bool is_native() const;

	// Returns the native file system path for the root. If it is bad,
	// or a remote sandbox, it will return an empty string.

	String get_root_native_path() const;

	// Returns a URI to the root of the sandbox. If it is bad, it will
	// return an empty string.

	String get_root_uri() const;

	// Returns the contents of a native child, or 0 if something is
	// wrong. The result has to be deallocated with g_free.

	gchar * get_native_child_contents( const String & native_path , gsize & length ) const;

	// Same as above, but for a platform independent child path.

	gchar * get_pi_child_contents( const String & pi_path , gsize & length ) const;

	// Just like lua_loadfile. Returns 0 if its OK, LUA_ERRFILE or the
	// result of lua_load. It pushes either an error message, or the
	// compiled chunk as a function.

	int lua_load_pi_child( lua_State * L , const String & pi_path ) const;

	// Returns a URI to a platform independent child path. It also populates
	// is_native if the URI points to a native file. If something goes
	// wrong, it returns an empty string.

	String get_pi_child_uri( const String & pi_path , bool & is_native ) const;

	// Returns a native path to a platform independent child path.
	// If the root of the sandbox is not native, it will return an
	// empty string.

	String get_pi_child_native_path( const String & pi_path ) const;

	// Returns true if a child with the given native path exists

	bool native_child_exists( const String & native_path ) const;

private:

	// Get a child GFile with a platform-independent path. Returns 0 if
	// something is wrong. It does not check whether the child exists.
	// The returned GFile has to be unrefed.

	GFile * get_pi_child( const String & pi_path ) const;

	// Get a child GFile with a native path. Returns 0 if something
	// is wrong. It does not check whether the child exists.
	// The returned GFile has to be unrefed.

	GFile * get_native_child( const String & native_path , Scheme scheme = NO_SCHEME ) const;

	// Takes a native path that is relative to the root and has the scheme
	// stripped out. Uses the path and the scheme (if any) to return
	// a pointer to the final file.

	GFile * resolve_relative_native_child( const String & native_path , Scheme scheme ) const;

	// Returns the contents of the file or 0 if something went wrong.
	// The result has to be deallocated with g_free.

	static gchar * get_contents( GFile * file , gsize & length );

	// Climbs up the parents of file to ensure one is our root.

	bool is_in_sandbox( GFile * file ) const;

	// Internal reader class. Haven't decided whether to expose it to
	// the outside world.

	class Reader
	{
	public:

		virtual ~Reader();

		static const char * lua_Reader( lua_State * L , void * data , size_t * size );

	private:

		friend class Sandbox;

		Reader();
		Reader( GFile * file );
		Reader( const Reader & other );

		GFile * file;
		gchar * contents;
	};

	friend class Reader;

	// Returns a reader to a native child path. If it goes wrong, returns
	// 0. Caller must delete the result.

	Reader * get_native_child_reader( const String & native_path ) const;

	// Returns a reader to a platform independent child path.
	// If it goes wrong, returns 0. Caller must delete the result.

	Reader * get_pi_child_reader( const String & pi_path ) const;

	// The GFile pointing to the sandbox's root. It can be 0.

	GFile * root;

	TPContext * context;
};


#endif // _TRICKPLAY_SANDBOX_H
