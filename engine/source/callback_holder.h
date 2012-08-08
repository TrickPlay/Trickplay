#ifndef _TRICKPLAY_CALLBACK_HOLDER_H
#define _TRICKPLAY_CALLBACK_HOLDER_H

#include "glib.h"
#include "glib-object.h"

#include "lua.h"
#include "lauxlib.h"

struct CallbackHolder
{

public:
	
	CallbackHolder();
	~CallbackHolder();

	int add_callback(lua_State *L);
	void remove_callback(lua_State *L);
        void invoke_callbacks(lua_State *L, int nargs);

private:

	GSList *callback_refs;
	void clean(lua_State *L);
	void print_num_callbacks(char* title);

};

#endif