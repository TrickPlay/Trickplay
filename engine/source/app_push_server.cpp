
#include <cstdlib>

#include "app_push_server.h"
#include "context.h"
#include "app.h"
#include "util.h"

//.............................................................................

static Debug_ON log( "APP-PUSH" );

//.............................................................................

AppPushServer * AppPushServer::make( TPContext * context )
{
#ifdef TP_PRODUCTION
    return 0;
#else
    g_assert( context );

    if ( ! context->get_bool( TP_APP_PUSH_ENABLED , TP_APP_PUSH_ENABLED_DEFAULT ) )
    {
        return 0;
    }

    return new AppPushServer( context );
#endif
}

//.............................................................................

AppPushServer::AppPushServer( TPContext * _context )
:
    context( _context ),
    current_push_path( 0 )
{
    context->get_http_server()->register_handler( "/push" , this );

    log( "READY" );
}

//.............................................................................

AppPushServer::~AppPushServer()
{
    context->get_http_server()->unregister_handler( "/push" );

    g_free( current_push_path );
}

//.............................................................................

void AppPushServer::handle_http_post( const HttpServer::Request & request , HttpServer::Response & response )
{
    response.set_status( SOUP_STATUS_BAD_REQUEST );

    //.........................................................................
    // If the path is /push, they are initiating a push. Otherwise, they are
    // pushing a file.

    String path = request.get_path();

    if ( path != "/push" )
    {
        if ( ! current_push_path )
        {
            return;
        }

        if ( path != String( current_push_path ) )
        {
            return;
        }

        handle_push_file( request , response );

        return;
    }


    //.........................................................................
    // Check the content type

    if ( request.get_content_type() != "application/json" )
    {
        return;
    }

    //.........................................................................
    // Get the body of the request

    const HttpServer::Request::Body & body( request.get_body() );

    if ( 0 == body.get_length() || 0 == body.get_data() )
    {
        return;
    }

    FreeLater free_later;

    //.........................................................................
    // Parse the body

    JsonParser * parser = json_parser_new();

    if ( ! parser )
    {
        return;
    }

    free_later( parser , g_object_unref );

    if ( ! json_parser_load_from_data( parser , body.get_data() , body.get_length() , 0 ) )
    {
        return;
    }

    JsonNode * root = json_parser_get_root( parser );

    if ( ! root )
    {
        return;
    }

    if ( JSON_NODE_TYPE( root ) != JSON_NODE_OBJECT )
    {
        return;
    }

    JsonObject * object = json_node_get_object( root );

    if ( ! object )
    {
        return;
    }

    // The root node should be an object that has a member called 'app'
    // which is a string and has the contents of the app file.
    // It should also have an array member called 'files'. This is an
    // array of 3 element arrays. Each one has the file name, the md5
    // hash of the file and the size of the file.

    JsonNode * app = json_object_get_member( object , "app" );
    JsonNode * files = json_object_get_member( object , "files" );

    if ( ! app || ! files )
    {
        return;
    }

    if ( JSON_NODE_TYPE( app ) != JSON_NODE_VALUE || JSON_NODE_TYPE( files ) != JSON_NODE_ARRAY )
    {
        return;
    }

    String app_contents( json_node_get_string( app ) );

    FileInfo::List file_list;

    JsonArray * files_array = json_node_get_array( files );

    if ( ! files_array )
    {
        return;
    }

    for( guint i = 0; i < json_array_get_length( files_array ); ++i )
    {
        JsonNode * element = json_array_get_element( files_array , i );

        if ( element && JSON_NODE_TYPE( element ) == JSON_NODE_ARRAY )
        {
            if ( JsonArray * file_parts = json_node_get_array( element ) )
            {
                if ( json_array_get_length( file_parts ) >= 3 )
                {
                    JsonNode * file_name_node = json_array_get_element( file_parts , 0 );
                    JsonNode * hash_node = json_array_get_element( file_parts , 1 );
                    JsonNode * size_node = json_array_get_element( file_parts , 2 );

                    if ( JSON_NODE_TYPE( file_name_node ) == JSON_NODE_VALUE &&
                            JSON_NODE_TYPE( hash_node ) == JSON_NODE_VALUE &&
                            JSON_NODE_TYPE( size_node ) == JSON_NODE_VALUE )
                    {
                        FileInfo info;

                        info.name = json_node_get_string( file_name_node );
                        info.md5 = json_node_get_string( hash_node );
                        info.size = json_node_get_int( size_node );

                        file_list.push_back( info );
                    }
                }
            }
        }
    }

    //.........................................................................
    // Now we have app_contents and file_list

    try
    {
        PushInfo push_info = compare_files( app_contents , file_list );

        // Stop any other push that is going on

        if ( current_push_path )
        {
            g_free( current_push_path );

            current_push_path = 0;
        }

        if ( push_info.target_files.empty() )
        {
            // The app is up to date, we can just launch it

            set_response( response , true , "Nothing changed." );

            current_push_info = push_info;

            launch_it();
        }
        else
        {
            // Make a new push path

            GTimeVal t;

            g_get_current_time( & t );

            String s = Util::format( "%ld:%ld:%s" , t.tv_sec , t.tv_usec , push_info.metadata.id.c_str() );

            GChecksum * ck = g_checksum_new( G_CHECKSUM_MD5 );

            g_checksum_update( ck , ( const guchar * ) s.c_str() , s.length() );

            current_push_path = g_strdup_printf( "/push/%s" , g_checksum_get_string( ck ) );

            g_checksum_free( ck );

            current_push_info = push_info;

            set_response( response , false , "" , push_info.target_files.front().source.name , current_push_path );
        }
    }
    catch( const String & e )
    {
        set_response( response , true , e );
    }
}

//.............................................................................

void AppPushServer::set_response( HttpServer::Response & response , bool done , const String & msg , const String & file , const String & url )
{
    JsonObject * o = json_object_new();

    json_object_set_boolean_member( o , "done" , done );
    json_object_set_string_member( o , "msg" , msg.c_str() );

    if ( ! file.empty() )
    {
        json_object_set_string_member( o , "file" , file.c_str() );
    }

    if ( ! url.empty() )
    {
        json_object_set_string_member( o , "url" , url.c_str() );
    }

    JsonNode * node = json_node_new( JSON_NODE_OBJECT );

    json_node_take_object( node , o );

    JsonGenerator * g = json_generator_new();

    json_generator_set_root( g , node );

    json_node_free( node );

    gsize length = 0;

    gchar * json = json_generator_to_data( g , & length );

    if ( json && length )
    {
        response.set_response( "application/json" , json , length );

        response.set_status( SOUP_STATUS_OK );
    }
    else
    {
        g_free( json );
    }

    g_object_unref( g );
}

//.............................................................................

AppPushServer::PushInfo AppPushServer::compare_files( const String & app_contents , const FileInfo::List & source_files )
{
    FreeLater free_later;

    PushInfo push_info;

    //.........................................................................
    // Load and check the metadata for the app

    if ( app_contents.empty() )
    {
        throw String( "App file is empty." );
    }

    if ( ! App::load_metadata_from_data( app_contents.c_str() , push_info.metadata ) )
    {
        throw String( "Invalid app file." );
    }

    //.........................................................................
    // Create the root destination path

    gchar * app_path = g_build_filename( context->get( TP_DATA_PATH ) , "pushed" , push_info.metadata.id.c_str() , NULL );

    push_info.metadata.path = app_path;

    free_later( app_path );

    if ( g_mkdir_with_parents( app_path , 0700 ) != 0 )
    {
        throw String( "Failed to create destination directory" );
    }

    for ( FileInfo::List::const_iterator it = source_files.begin(); it != source_files.end(); ++it )
    {
        FreeLater free_later;

        gchar * target_path = Util::rebase_path( app_path , it->name.c_str() , false );

        if ( ! target_path )
        {
            throw Util::format( "Invalid file path '%s'" , it->name.c_str() );
        }

        TargetInfo target_info;

        target_info.source = * it;
        target_info.path = target_path;

        free_later( target_path );

        //.....................................................................
        // If the target file does not exist, mark it as such and add it to the
        // list of changed files.

        if ( ! g_file_test( target_path , G_FILE_TEST_EXISTS ) )
        {
            push_info.target_files.push_back( target_info );

            continue;
        }

        //.....................................................................
        // It exists. Lets get a GFile for it.

        GFile * file = g_file_new_for_path( target_path );

        free_later( file , g_object_unref );

        bool hash_it = true;

        //.....................................................................
        // Try to get the file's current size. If it is different than the size
        // of the source file, we don't have to hash it to know that it changed.

        GFileInfo * file_info = g_file_query_info( file , G_FILE_ATTRIBUTE_STANDARD_SIZE , G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS , 0 , 0 );

        if ( file_info )
        {
            goffset size = g_file_info_get_size( file_info );

            g_object_unref( file_info );

            if ( size == 0 || size != target_info.source.size )
            {
                hash_it = false;
            }
        }

        //.....................................................................
        // If we know that it changed, we add it to the list and continue

        if ( ! hash_it )
        {
            push_info.target_files.push_back( target_info );

            continue;
        }

        //.....................................................................
        // Otherwise, we have to get the target file's MD5 hash.

        if ( GFileInputStream * input = g_file_read( file , NULL , NULL ) )
        {
            free_later( input , g_object_unref );

            if ( GChecksum * ck = g_checksum_new( G_CHECKSUM_MD5 ) )
            {
                static guint BUFFER_SIZE = 1024;

                guchar buffer[ BUFFER_SIZE ];

                String target_hash;

                while ( true )
                {
                    gssize read = g_input_stream_read( G_INPUT_STREAM( input ) , buffer , BUFFER_SIZE , NULL , NULL );

                    if ( read == 0 )
                    {
                        // Done, populate the hash
                        target_hash = g_checksum_get_string( ck );
                        break;
                    }
                    else if ( read == -1 )
                    {
                        // Break with an empty hash signals a problem
                        break;
                    }
                    else
                    {
                        g_checksum_update( ck , buffer , read );
                    }
                }

                g_checksum_free( ck );

                // The hash matches, we can move on to the next file.

                if ( target_hash == target_info.source.md5 )
                {
                    continue;
                }
            }
        }

        //.....................................................................
        // If we get here, for whatever reason, we assume the file is different

        push_info.target_files.push_back( target_info );
    }

    return push_info;
}

//.............................................................................

struct CancelPush
{
    CancelPush( gchar * * _path ) : path( _path ) {}
    ~CancelPush( ) { if ( path ) { g_free( * path ); * path = 0; } }
    void reset() { path = 0; }

private:

    gchar * * path;
};

void AppPushServer::handle_push_file( const HttpServer::Request & request , HttpServer::Response & response )
{
    response.set_status( SOUP_STATUS_BAD_REQUEST );

    if ( ! current_push_path )
    {
        return;
    }

    // If we bail early, this thing will get destroyed and will free and
    // clear current_push_path. This is a simple way to abort the current
    // push.

    CancelPush cancel_push( & current_push_path );

    //.........................................................................
    // Check the content type

    if ( request.get_content_type() != "application/octet-stream" )
    {
        return;
    }

    //.........................................................................
    // Get the body of the request

    const HttpServer::Request::Body & body( request.get_body() );

    if ( 0 == body.get_length() || 0 == body.get_data() )
    {
        return;
    }

    FreeLater free_later;


    if ( current_push_info.target_files.empty() )
    {
        return;
    }

    TargetInfo & target_info = current_push_info.target_files.front();

    // The file that they sent us doesn't match the original size they
    // told us. Bail.

    if ( target_info.source.size != gint64( body.get_length() ) )
    {
        return;
    }

    // The md5 hash for what they sent us does not match what they told
    // us when they started the push.

    gchar * ck = g_compute_checksum_for_data( G_CHECKSUM_MD5 , ( const guchar * ) body.get_data() , body.get_length() );

    bool match = ! strcmp( ck , target_info.source.md5.c_str() );

    g_free( ck );

    if ( ! match )
    {
        return;
    }

    // Everything matches.

    try
    {
        write_file( target_info , body );
    }
    catch ( const String & e )
    {
        set_response( response , true , e );

        return;
    }

    // Pop this file from the list

    current_push_info.target_files.pop_front();

    // If the list is empty, we are done, and we can launch the app

    if ( current_push_info.target_files.empty() )
    {
        set_response( response , true , "Finished." );

        launch_it();
    }
    else
    {
        // Otherwise, we move on to the next file.

        set_response( response , false , "" , current_push_info.target_files.front().source.name , current_push_path );

        // Keep it from canceling

        cancel_push.reset();
    }
}


//.............................................................................

void AppPushServer::write_file( const TargetInfo & target_info , const HttpServer::Request::Body & body )
{
    g_assert( body.get_data() );
    g_assert( body.get_length() );

    if ( ! g_file_test( target_info.path.c_str() , G_FILE_TEST_EXISTS ) )
    {
        FreeLater free_later;

        gchar * d = g_path_get_dirname( target_info.path.c_str() );

        if ( ! d )
        {
            throw String( "Invalid path." );
        }

        free_later( d );

        if ( ! strcmp( d , "." ) )
        {
            throw String( "Invalid path." );
        }

        if ( g_mkdir_with_parents( d , 0700 ) != 0 )
        {
            throw String( "Failed to create destination directory." );
        }
    }

    if ( ! g_file_set_contents( target_info.path.c_str() , body.get_data() , body.get_length() , 0 ) )
    {
        throw String( "Failed to write file." );
    }
}

//.............................................................................
// When the push is complete, we launch the app.

void AppPushServer::launch_it( )
{
    log( "LAUNCHING FROM %s" , current_push_info.metadata.path.c_str() );

    context->close_current_app();

    context->launch_app( current_push_info.metadata.path.c_str() , App::LaunchInfo() , true );
}

//.............................................................................

