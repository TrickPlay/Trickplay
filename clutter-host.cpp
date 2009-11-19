#include <stdio.h>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "clutter-timeline.h"
#include "clutter-stage.h"

int clutter_register(lua_State *L)
{
	clutter_stage_register(L);
	clutter_timeline_register(L);
	return 1;
}

void report_errors(lua_State *L, int status)
{
  if ( status!=0 ) {
    printf("-- %s\n", lua_tostring(L, -1));
    lua_pop(L, 1); // remove error message
  }
}

int main(int argc, char** argv)
{
  clutter_init (&argc, &argv);

  for ( int n=1; n<argc; ++n ) {
    const char* file = argv[n];

    lua_State *L = lua_open();

    luaL_openlibs(L);
    clutter_register(L);

    printf("-- Loading file: %s\n", file);

    int s = luaL_loadfile(L, file);

    if ( s==0 ) {
      // execute Lua program
      s = lua_pcall(L, 0, LUA_MULTRET, 0);
    }

    report_errors(L, s);
    lua_close(L);
  }
}
