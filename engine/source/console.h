#ifndef _TRICKPLAY_CONSOLE_H
#define _TRICKPLAY_CONSOLE_H

#include "common.h"
#include "server.h"

class Console : private Server::Delegate
{
public:
    
    Console(TPContext * context,int port);
    ~Console();
    
    typedef int (*CommandHandler)(const char * command,const char * parameters,void * data);

    void add_command_handler(CommandHandler handler,void * data);
    
    void attach_to_lua(lua_State * l);
    
protected:
    
    gboolean read_data();
    
    void process_line(gchar * line);
    
    static gboolean channel_watch(GIOChannel * source,GIOCondition condition,gpointer data);
    
private:
    
    Console() {}
    Console(const Console &) {}

    // Server delegate methods
    
    virtual void connection_accepted(gpointer connection,const char * remote_address);
    virtual void connection_data_received(gpointer connection,const char * data);
    
    static void output_handler(const gchar * line,gpointer data);
    
    typedef std::pair<CommandHandler,void*>     CommandHandlerClosure;
    typedef std::list<CommandHandlerClosure>    CommandHandlerList;

    TPContext *             context;    
    lua_State *             L;
    GIOChannel *            channel;
    GString *               stdin_buffer;
    CommandHandlerList      handlers;
    std::auto_ptr<Server>   server;
};


#endif // _TRICKPLAY_CONSOLE_H
