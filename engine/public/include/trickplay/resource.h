#ifndef _TRICKPLAY_RESOURCE_H
#define _TRICKPLAY_RESOURCE_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------------
    File: Resource Loading
*/

/*-----------------------------------------------------------------------------
    Struct: TPResourceReader

    Holds a function to read chunks of a resource as well as user data specific
    to the resource.
*/

	typedef struct TPResourceReader TPResourceReader;

    struct TPResourceReader
    {
		/*
		    Field: read

		    This is a pointer to a function that will be called repeatedly by
		    TrickPlay to read chunks of this resource. The function should put
		    at most 'bytes' into the memory pointed to by 'buffer' and return
		    the number of bytes read. In case of an error, it should return 0.

		    If the function returns less than 'bytes' (or 0), it will not be
		    called again for this resource, so you are free to dispose of
		    'user_data' and/or close the underlying file.

		    'buffer' will never be NULL and 'bytes' will never be zero.
		*/

        unsigned long int	(*read)(void * 				buffer ,
        							unsigned long int	bytes ,
        							void * 				user_data );

        /*
            Field: user_data

            An opaque pointer that is passed to the <read> function.
        */

        void *				user_data;
    };

/*-----------------------------------------------------------------------------
	Constants: Resource Types

	TP_RESOURCE_TYPE_LUA_SOURCE - Lua source code files.
*/

#define TP_RESOURCE_TYPE_LUA_SOURCE	1

/*-----------------------------------------------------------------------------
	Function: TPResourceLoader

	Function prototype used in calls to <tp_context_set_resource_loader>. This
	function should attempt to open the given file and fill the 'reader'
	structure with a function that will be used to read chunks from the file.

	TrickPlay does not verify that the file exists before calling this function.

	Arguments:

		context -   	The TrickPlay context.

		resource_type -	The type of resource that is being loaded.

		filename -  	The filename of the resource to load.

		reader -  		A pointer to a <TPResourceReader> structure to fill.
						This will never be NULL.

		user_data -    	Opaque user data that was passed to <tp_context_set_resource_loader>.

    Returns:

        0 -				If the 'reader' structure was filled in and TrickPlay
         	 	 	    can begin calling the 'read' function.

        Non-zero - 		If there was a problem.
*/

	typedef
	int
	(*TPResourceLoader)(

		TPContext * 		context,
		unsigned int		resource_type,
		const char * 		filename,
		TPResourceReader * 	reader,
		void * 				user_data);

/*-----------------------------------------------------------------------------
	Function: tp_context_set_resource_loader

	Specify the function used to load resources of a given type.

	Arguments:

		context - 		A valid TPContext.

		resource_type - An indicator of what type of resource this loader should
						be used for.  See <Resource Types>.

		loader -	 	A pointer to a <TPResourceLoader> function.

		user_data -		Opaque user data that is passed to the loader.

    Below is a sample implementation using 'fread'.

    (code)

    static unsigned long int my_read(
    	void * buffer,
    	unsigned long int bytes,
    	void * user_data )
   	{
   		FILE * file = ( FILE * ) user_data;

   		size_t result = fread( buffer , 1 , bytes , file );

   		if ( result < bytes )
   		{
   			fclose( file );
   		}

   		return result;
   	}

    static int my_loader(
    	TPContext * context ,
    	unsigned int resource_type,
    	const char * filename,
    	TPResourceReader * reader,
    	void * user_data )
    {
    	FILE * file = fopen( filename , "rb" );

    	if ( 0 == file )
    	{
    		return 1;
    	}

    	reader->read = my_read;
    	reader->user_data = file;

    	return 0;
    }

    ...
    tp_context_set_resource_loader( context , TP_RESOURCE_TYPE_LUA_SOURCE , my_loader , 0 );
    ...

    (end)
*/

	TP_API_EXPORT
	void
	tp_context_set_resource_loader(

		TPContext * 		context,
		unsigned int 		resource_type,
		TPResourceLoader 	loader,
		void * 				user_data);

/*---------------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif

#endif /* _TRICKPLAY_RESOURCE_H */
