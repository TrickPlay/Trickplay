#ifndef NETWORK_H
#define NETWORK_H

#include "glib.h"
#include <string>
#include <map>

namespace Network
{   
    typedef std::string String;
    typedef std::map<std::string,std::string> StringMap;
    typedef std::multimap<std::string,std::string> StringMultiMap;
    
    class Request
    {
    public:
        
        Request();
            
        String      url;
        String      method;
        StringMap   headers;
        double      timeout_s;
        String      client_certificate_pem;
        String      client_private_key_pem;
        String      body;
        bool        redirect;
        String      user_agent;
    };
    
    class Response
    {
    public:
        
        Response();
        ~Response();
        Response(const Response & other);
        
        int             code;
        StringMultiMap  headers;
        String          status;
        GByteArray *    body;
        bool            failed;
    };
    
    typedef void (*ResponseCallback)(const Response & response,gpointer data);

    void shutdown();
        
    void perform_request_async(const Request & request,ResponseCallback callback,gpointer data);
    
    Response perform_request(const Request & request);
};

#endif