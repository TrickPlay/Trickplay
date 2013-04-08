#ifndef _TRICKPLAY_DEBUGGER_H
#define _TRICKPLAY_DEBUGGER_H

#include "common.h"
#include "json.h"

class App;

class Debugger
{
public:

    Debugger( App* app );

    ~Debugger();

    void install( bool break_next_line = false );

    void uninstall();

    void break_next_line();

    bool is_in_break() const
    {
        return in_break;
    }

    guint16 get_server_port() const;

    class Server;

    class Command;

private:

    static void lua_hook( lua_State* L, lua_Debug* ar );

    void debug_break( lua_State* L, lua_Debug* ar );

    JSON::Object get_location( lua_State* L , lua_Debug* ar );
    JSON::Array get_back_trace( lua_State* L , lua_Debug* ar );
    JSON::Array get_locals( lua_State* L , lua_Debug* ar );
    JSON::Array get_breakpoints( lua_State* L , lua_Debug* ar );
    JSON::Object get_app_info();
    JSON::Array get_globals( lua_State* L );

    StringVector* get_source( const String& pi_path );

    bool handle_command( lua_State* L , lua_Debug* ar , Command* command , bool with_location );

    App*    app;
    bool    installed;
    bool    break_next;
    int     returns;
    bool    in_break;

    struct Breakpoint
    {
        Breakpoint( const String& _file , int _line , bool _enabled = true )
            :
            file( _file ),
            line( _line ),
            enabled( _enabled )
        {}

        String  file;
        int     line;
        bool    enabled;
    };

    typedef std::vector< Breakpoint > BreakpointList;

    BreakpointList      breakpoints;

    typedef std::map< String , StringVector > SourceMap;

    SourceMap           source;

    static Server*      server;
};

#endif // _TRICKPLAY_DEBUGGER_H
