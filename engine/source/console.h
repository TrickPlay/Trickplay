#ifndef CONSOLE_H
#define CONSOLE_H

#include <list>

#include "glib.h"

#include "lb.h"

typedef int (*ConsoleCommandHandler)(const char * command,const char * parameters,void * data);

class Console
{
public:
    
    Console(lua_State*);
    ~Console();
    
    void add_command_handler(ConsoleCommandHandler handler,void * data);
    
protected:
    
    gboolean read_data();
    
    static gboolean channel_watch(GIOChannel * source,GIOCondition condition,gpointer data);
    
private:
    
    Console() {}
    Console(const Console &) {}
    
    typedef std::pair<ConsoleCommandHandler,void*> CommandHandlerClosure;
    typedef std::list<CommandHandlerClosure> CommandHandlerList;
    
    lua_State *         L;
    GIOChannel *        channel;
    GString *           line;
    CommandHandlerList  handlers;
};


#endif