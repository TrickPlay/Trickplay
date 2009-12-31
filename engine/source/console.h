#ifndef CONSOLE_H
#define CONSOLE_H

#include "glib.h"

#include "lb.h"

class Console
{
public:
    
    Console(lua_State*);
    ~Console();
    
protected:
    
    gboolean read_data();
    
    static gboolean channel_watch(GIOChannel * source,GIOCondition condition,gpointer data);
    
private:
    
    Console() {}
    Console(const Console &) {}
    
    lua_State *     L;
    GIOChannel *    channel;
    GString *       line;
};


#endif