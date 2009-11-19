#ifndef __CLUTTER_STAGE__
#define __CLUTTER_STAGE__


extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "clutter/clutter.h"
}


#define STAGE "Stage"

int clutter_stage_register(lua_State *L);

ClutterActor **pushstage(lua_State *L, ClutterActor *stage);
ClutterActor *tostage(lua_State *L, int index);
ClutterActor *checkstage(lua_State *L, int index);

#endif
