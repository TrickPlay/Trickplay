#ifndef __CLUTTER_TIMELINE__
#define __CLUTTER_TIMELINE__

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "clutter/clutter.h"
}


#define TIMELINE "Timeline"

int clutter_timeline_register(lua_State *L);

ClutterTimeline **pushtimeline(lua_State *L, ClutterTimeline *timeline);
ClutterTimeline *totimeline(lua_State *L, int index);
ClutterTimeline *checktimeline(lua_State *L, int index);

#endif
