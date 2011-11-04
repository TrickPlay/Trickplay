#ifndef _TRICKPLAY_DEBUGGER_H
#define _TRICKPLAY_DEBUGGER_H

#include "common.h"
#include "json.h"

class App;

class Debugger
{
public:

    Debugger( App * app );

    ~Debugger();

    void install();

    void uninstall();

    void break_next_line();

private:

    static void command_handler( TPContext * context , const char * command, const char * parameters, void * me );

    void handle_command( const char * parameters );

    static void lua_hook( lua_State * L, lua_Debug * ar );

    void debug_break( lua_State * L, lua_Debug * ar );

    StringVector * load_source_file( const char * file_name );

    JSON::Array get_back_trace( lua_State * L , lua_Debug * ar );

    JSON::Array get_locals( lua_State * L , lua_Debug * ar );

    App *           app;
    bool            installed;

    bool            break_next;

    bool 			tracing;

    typedef std::pair< String, int > Breakpoint;

    typedef std::list< Breakpoint > BreakpointList;

    BreakpointList  breakpoints;

    typedef std::map< String , StringVector > SourceMap;

    SourceMap		source;

    class Server;

    static Server *		server;
};

#endif // _TRICKPLAY_DEBUGGER_H
