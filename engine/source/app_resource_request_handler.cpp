/*
 * resource_request_handler.cpp
 *
 *  Created on: Apr 5, 2011
 */
#include "app.h"
#include "app_resource_request_handler.h"
#include "util.h"
#include "sysdb.h"

AppResourceRequestHandler::AppResourceRequestHandler( TPContext * ctx )
    :
    context( ctx )
{
	context->get_http_server()->register_handler( "/app" , this );
}

AppResourceRequestHandler::~AppResourceRequestHandler( )
{
	context->get_http_server()->unregister_handler( "/app" );
}
//-----------------------------------------------------------------------------

void AppResourceRequestHandler::do_get( const HttpServer::Request& request, HttpServer::Response& response )
{
	String result;
	String path = request.get_request_uri( );

    g_debug( "PROCESSING GET '%s'", path.c_str() );
    bool found = false;
    String resource_id = request.get_parameter("resource_id");

    if ( resource_id.size() > 0 )
    {
		WebServerPathMap::const_iterator it = path_map.find( resource_id );

		if ( it != path_map.end() )
		{
			String filepath( it->second.first );

			found = write_file( filepath, response );

			if ( found )
			{
				g_debug( "  SERVED '%s'", filepath.c_str() );
			}
			else
			{
				g_debug( " Failed to serve '%s", filepath.c_str( ) );
			}
		}
	}

	if ( !found )
	{
		response.set_content_length( 0 );
		response.set_status( HttpServer::HTTP_STATUS_NOT_FOUND );
	}
}

class AppResourceStreamWriter : public HttpServer::Response::StreamWriter {
public:

	AppResourceStreamWriter( const String& _filename )
	: filename( _filename ), file ( NULL ), size( -1 ), input_stream ( NULL ), total_bytes_read( 0 )
	{
		g_assert( filename.size() );

		file = g_file_new_for_path( filename.c_str( ) );

		if ( !file )
		{
			return;
		}
		GError * error = NULL;

		GFileInfo * info = g_file_query_info( file,
											  G_FILE_ATTRIBUTE_STANDARD_SIZE,
											  G_FILE_QUERY_INFO_NONE,
											  NULL,
											  &error );

		if ( !info )
		{
			if (error) {
				String msg( "g_file_query_info failed for filepath " );
				msg += filename;
				msg += ". Got error: ";
				msg += error->message;
				g_debug( msg.c_str() );
			}
			return;
		}

		size = g_file_info_get_size( info );

		g_object_unref( info );

		input_stream = g_file_read( file, NULL, NULL );

		if ( !input_stream )
		{
			return;
		}

	}

	~AppResourceStreamWriter( )
	{
		if ( input_stream )
		{
			g_object_unref( input_stream );
			input_stream = NULL;
		}
		if ( file )
		{
			g_object_unref( file );
			file = NULL;
		}
	}

	bool is_valid( )
	{
		return input_stream && file;
	}
	/*
	 * @return the size of the file in bytes
	 */
	int get_file_size ( )
	{
		return size;
	}

	void write(HttpServer::Response::StreamBody& stream)
	{
		g_assert( is_valid() );

		if (total_bytes_read < size )
		{
			gsize bytes_remaining = size - total_bytes_read;
			gsize bytes_to_read =  bytes_remaining < BLOCK_SIZE ? bytes_remaining : BLOCK_SIZE;
			char buffer[ bytes_to_read ];
			gsize bytes_read = g_input_stream_read ((GInputStream *) input_stream, &buffer, bytes_to_read, NULL, NULL );
			stream.append( buffer, bytes_read );
			total_bytes_read += bytes_read;
		}
		else
		{
			stream.complete ( );
		}

	}

	static void destroy( AppResourceStreamWriter * me )
	{
		delete me;
	}

private:
	String filename;
    GFile * file;
    gsize size;
    GFileInputStream * input_stream;
    gsize total_bytes_read;
    static const guint BLOCK_SIZE = 1024;
};

bool AppResourceRequestHandler::write_file( const String& filepath, HttpServer::Response& response )
{
	AppResourceStreamWriter * stream_writer = new AppResourceStreamWriter( filepath );
	if ( !stream_writer )
	{
		return false;
	}
	else if ( !stream_writer->is_valid() )
	{
		delete stream_writer;
		return false;
	}

	response.set_content_length( stream_writer->get_file_size() );

    // Get the input stream
	response.set_status(HttpServer::HTTP_STATUS_OK);

	//, ( GDestroyNotify ) AppResourceStreamWriter::destroy
    response.set_stream_writer( stream_writer );

    return true;
}

String get_file_extension( const String & path, bool include_dot = true )
{
    String result;

    if ( !path.empty() )
    {
        // See if the last character is a separator. If it is,
        // we bail. Otherwise, g_path_get_basename would give us
        // the element before the separator and not the last element.

        if ( !g_str_has_suffix( path.c_str(), G_DIR_SEPARATOR_S ) )
        {
            gchar * basename = g_path_get_basename( path.c_str() );

            if ( basename )
            {
                gchar * * parts = g_strsplit( basename, ".", 0 );

                guint count = g_strv_length( parts );

                if ( count > 1 )
                {
                    result = parts[count - 1];

                    if ( !result.empty() && include_dot )
                    {
                        result = "." + result;
                    }
                }

                g_strfreev( parts );

                g_free( basename );
            }
        }
    }

    return result;
}

//-----------------------------------------------------------------------------

String AppResourceRequestHandler::serve_path( const String & group, const String & path )
{
    String s = group + ":" + path;

    gchar * id = g_compute_checksum_for_string( G_CHECKSUM_SHA1, s.c_str(), -1 );
    String result( id );
    g_free( id );

    result += get_file_extension( path );

    if ( path_map.find( result ) == path_map.end() )
    {
        g_debug( "SERVING %s : %s", result.c_str(), path.c_str() );

        path_map[result] = StringPair( path, group );
    }

    return result;
}

//-----------------------------------------------------------------------------

void AppResourceRequestHandler::drop_web_server_group( const String & group )
{
    for ( WebServerPathMap::iterator it = path_map.begin(); it != path_map.end(); )
    {
        if ( it->second.second == group )
        {
            g_debug( "DROPPING %s : %s", it->first.c_str(), it->second.first.c_str() );

            path_map.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------
