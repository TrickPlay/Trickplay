#ifndef _TRICKPLAY_APP_RESOURCE_H
#define _TRICKPLAY_APP_RESOURCE_H

#include "common.h"
#include "app.h"

//.........................................................................

class AppResource
{
public:

	enum Flags
	{
		URI_NOT_ALLOWED 		= 0x01,
		LOCALIZED_NOT_ALLOWED 	= 0x02
	};

	AppResource();

	//.....................................................................
	// Construct an app resource given a path. If something goes wrong,
	// you can use the bool operator below to test it. Error messages
	// are printed by this function, so you don't need to do it yourself.

	AppResource( App * app , const char * app_path , int flags = 0 , const StringSet & schemes = StringSet() );

	AppResource( lua_State * L , const char * app_path , int flags = 0 , const StringSet & schemes = StringSet() );

	AppResource( App * app , const String & app_path , int flags = 0 , const StringSet & schemes = StringSet() );

	AppResource( lua_State * L , const String & app_path , int flags = 0 , const StringSet & schemes = StringSet() );

	AppResource( const char * root_uri , const char * app_path , int flags = 0 , const StringSet & schemes = StringSet() );

	AppResource( const char * root_uri , const String & app_path , int flags = 0 , const StringSet & schemes = StringSet() );

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

	bool exists( App * app ) const;

	//.....................................................................
	// If it is a valid resource and the contents can be loaded, returns
	// a byte array with the contents. Otherwise, prints an error message
	// and returns 0. If the resource is HTTP(S), then it make a network
	// request.

	GByteArray * load_contents( App * app ) const;

	//.....................................................................
	// Just like lua_loadfile. Returns 0 if its OK, LUA_ERRFILE or the
	// result of lua_load. It pushes either an error message, or the
	// compiled chunk as a function.

	int lua_load( lua_State * L ) const;


private:

	struct Args
	{
		Args()
		:
			app( 0 ),
			flags( 0 )
		{}

		Args( lua_State * L , const char * _app_path , int _flags , const StringSet & _schemes = StringSet() )
		:
			app( App::get( L ) ),
			root_uri( app->get_metadata().sandbox.get_root_uri() ),
			app_path( _app_path ? _app_path : "" ),
			flags( _flags ),
			schemes( _schemes )
		{}

		Args( App * _app , const char * _app_path , int _flags , const StringSet & _schemes = StringSet() )
		:
			app( _app ),
			root_uri( app->get_metadata().sandbox.get_root_uri() ),
			app_path( _app_path ? _app_path : "" ),
			flags( _flags ),
			schemes( _schemes )
		{}

		Args( const char * _root_uri , const char * _app_path , int _flags , const StringSet & _schemes = StringSet() )
		:
			app( 0 ),
			root_uri( _root_uri ? _root_uri : "" ),
			app_path( _app_path ? _app_path : "" ),
			flags( _flags ),
			schemes( _schemes )
		{}

		App * 		app;
		String		root_uri;
		String		app_path;
		int			flags;
		StringSet	schemes;
	};

	static void make( AppResource * me , const Args & args );

	static bool is_child( const String & root_uri , const String & child_uri );

	String	original;
	String 	native_path;
	String	uri;
};


#endif // _TRICKPLAY_APP_RESOURCE_H
