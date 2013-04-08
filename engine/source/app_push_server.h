#ifndef _TRICKPLAY_APP_PUSH_SERVER_H
#define _TRICKPLAY_APP_PUSH_SERVER_H

#include "common.h"
#include "app.h"
#include "http_server.h"

class AppPushServer : public HttpServer::RequestHandler
{
public:

    static AppPushServer* make( TPContext* context );

    ~AppPushServer();

    virtual void handle_http_post( const HttpServer::Request& request , HttpServer::Response& response );

private:

    struct FileInfo
    {
        typedef std::list<FileInfo> List;

        String  name;
        String  md5;
        gint64  size;
    };

    struct TargetInfo
    {
        typedef std::list<TargetInfo> List;

        FileInfo    source;
        String      path;
    };

    struct PushInfo
    {
        PushInfo() : debug( false ) {}

        App::Metadata       metadata;
        TargetInfo::List    target_files;
        bool                debug;
    };

    AppPushServer() { g_assert( 0 ); }

    AppPushServer( TPContext* context );

    void handle_push_file( const HttpServer::Request& request , HttpServer::Response& response );

    PushInfo compare_files( const String& app_contents , const FileInfo::List& source_files );

    void set_response( HttpServer::Response& response , bool done , bool failed , const String& msg , const String& file = String() , const String& url = String() );

    void write_file( const TargetInfo& target_info , const HttpServer::Request::Body& body );

    bool launch_it();

    TPContext*          context;

    gchar*              current_push_path;

    PushInfo            current_push_info;
};



#endif // _TRICKPLAY_APP_PUSH_SERVER_H
