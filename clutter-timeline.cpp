#include "clutter-timeline.h"

ClutterTimeline **pushtimeline(lua_State *L, ClutterTimeline *timeline)
{
	ClutterTimeline **ptimeline = (ClutterTimeline **)lua_newuserdata(L, sizeof(ClutterTimeline *));
	*ptimeline = timeline;
	luaL_getmetatable(L, TIMELINE);
	lua_setmetatable(L, -2);

	return ptimeline;
}

ClutterTimeline *totimeline(lua_State *L, int index)
{
	ClutterTimeline **ptimeline = (ClutterTimeline **)lua_touserdata(L, index);
	if (NULL == ptimeline) luaL_typerror(L, index, TIMELINE);

	return *ptimeline;
}

ClutterTimeline *checktimeline(lua_State *L, int index)
{
	ClutterTimeline **ptimeline;
	luaL_checktype(L, index, LUA_TUSERDATA);
	ptimeline = (ClutterTimeline **)luaL_checkudata(L, index, TIMELINE);
	if (NULL == ptimeline) luaL_typerror(L, index, TIMELINE);
	if (NULL == *ptimeline) luaL_error(L, "null timeline");

	return *ptimeline;
}

static int Timeline_new(lua_State *L)
{
	int t = luaL_checkint(L, 1);

	ClutterTimeline *timeline;
	timeline = clutter_timeline_new(t);
	clutter_timeline_set_loop(timeline, TRUE);

	// Push the timeline pointer as a userdata
	pushtimeline(L, timeline);

	return 1;
}

static int Timeline_gc(lua_State *L)
{
	printf("goodbye Timeline (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int Timeline_tostring(lua_State *L)
{
	lua_pushfstring(L, "Timeline: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg Timeline_meta[] =
{
	{"__gc",       Timeline_gc},
	{"__tostring", Timeline_tostring},
	{0, 0}
};

const luaL_reg Timeline_methods[] =
{
	{"new",         Timeline_new},
	{0, 0}
};

int clutter_timeline_register(lua_State *L)
{
	luaL_openlib(L, TIMELINE, Timeline_methods, 0);
	luaL_newmetatable(L, TIMELINE);
	luaL_openlib(L, 0, Timeline_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
