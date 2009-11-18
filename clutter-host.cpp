#include <math.h>
#include <stdio.h>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "clutter/clutter.h"
}

#define N_CIRCLES 3     /* number of circles */
#define CIRCLE_W 128    /* width */
#define CIRCLE_G 32     /* gap */
#define CIRCLE_S 3      /* segments */
#define SCREEN_W 640
#define SCREEN_H 480

#ifndef CLUTTER_ANGLE_FROM_RAD
#define CLUTTER_ANGLE_FROM_RAD(x) ((x) * 180.0 / M_PI)
#endif

static void
circle_paint_cb (ClutterActor *actor)
{
  const CoglColor fill_color = { 0xff, 0xff, 0xff, 0x80 };
  gint i;
  gdouble angle;
  guint radius = clutter_actor_get_width (actor)/2;

  cogl_set_source_color (&fill_color);

  angle = *((gdouble *)g_object_get_data (G_OBJECT (actor), "angle"));
  for (i = 0; i < CIRCLE_S; i++, angle += (2.0*M_PI)/(gdouble)CIRCLE_S)
    {
      gdouble angle2 = angle + ((2.0*M_PI)/(gdouble)CIRCLE_S)/2.0;
      cogl_path_move_to (((radius - CIRCLE_W) * cos (angle)) + radius,
                         ((radius - CIRCLE_W) * sin (angle)) + radius);
      cogl_path_arc (radius, radius, radius, radius,
                     CLUTTER_ANGLE_FROM_RAD (angle),
                     CLUTTER_ANGLE_FROM_RAD (angle2));
      cogl_path_line_to (((radius - CIRCLE_W) * cos (angle2)) + radius,
                         ((radius - CIRCLE_W) * sin (angle2)) + radius);
      cogl_path_arc (radius, radius, radius - CIRCLE_W, radius - CIRCLE_W,
                     CLUTTER_ANGLE_FROM_RAD (angle2),
                     CLUTTER_ANGLE_FROM_RAD (angle));
      cogl_path_close ();
      cogl_path_fill ();
    }
}

#define STAGE "Stage"
#define TIMELINE "Timeline"

static ClutterActor **pushstage(lua_State *L, ClutterActor *stage)
{
	ClutterActor **pstage = (ClutterActor **)lua_newuserdata(L, sizeof(ClutterActor *));
	*pstage = stage;
	luaL_getmetatable(L, STAGE);
	lua_setmetatable(L, -2);

	return pstage;
}

static ClutterActor *tostage(lua_State *L, int index)
{
	ClutterActor **pstage = (ClutterActor **)lua_touserdata(L, index);
	if(NULL == pstage) luaL_typerror(L, index, STAGE);

	return *pstage;
}

static ClutterActor *checkstage(lua_State *L, int index)
{
	ClutterActor **pstage;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pstage = (ClutterActor **)luaL_checkudata(L, index, STAGE);
	if(NULL == pstage) luaL_typerror(L, index, STAGE);
	if(NULL == *pstage) luaL_error(L, "null stage");
	
	return *pstage;
}

static int Stage_new(lua_State *L)
{
  int x = luaL_checkint(L, 1);
  int y = luaL_checkint(L, 2);

  const ClutterColor bg_color = { 0xe0, 0xf2, 0xfc, 0xff };

	ClutterActor *stage = clutter_stage_get_default();
	clutter_actor_set_size(stage, x, y);
	clutter_stage_set_color(CLUTTER_STAGE(stage), &bg_color);

   pushstage(L, stage);
   return 1;
}

static ClutterTimeline **pushtimeline(lua_State *L, ClutterTimeline *timeline)
{
	ClutterTimeline **ptimeline = (ClutterTimeline **)lua_newuserdata(L, sizeof(ClutterTimeline *));
	*ptimeline = timeline;
	luaL_getmetatable(L, TIMELINE);
	lua_setmetatable(L, -2);

	return ptimeline;
}

static ClutterTimeline *totimeline(lua_State *L, int index)
{
	ClutterTimeline **ptimeline = (ClutterTimeline **)lua_touserdata(L, index);
	if(NULL == ptimeline) luaL_typerror(L, index, TIMELINE);

	return *ptimeline;
}

static ClutterTimeline *checktimeline(lua_State *L, int index)
{
	ClutterTimeline **ptimeline;
	luaL_checktype(L, index, LUA_TUSERDATA);
	ptimeline = (ClutterTimeline **)luaL_checkudata(L, index, TIMELINE);
	if(NULL == ptimeline) luaL_typerror(L, index, TIMELINE);
	if(NULL == *ptimeline) luaL_error(L, "null timeline");
	
	return *ptimeline;
}

static int Timeline_new(lua_State *L)
{
  int t = luaL_checkint(L, 1);

  ClutterTimeline *timeline;
  timeline = clutter_timeline_new (t);
  clutter_timeline_set_loop (timeline, TRUE);

  // Push the timeline pointer as a userdata
  pushtimeline(L, timeline);
  
  return 1;
}

int Stage_circles(lua_State *L)
{
  ClutterTimeline *timeline;
  ClutterActor *stage;

  const ClutterColor transp = { 0xe0, 0xf2, 0xfc, 0x00 };

  
  stage = checkstage(L, 1);
  timeline = checktimeline(L, 2);

  gint i;
  
  for (i = 0; i < N_CIRCLES; i++)
    {
      gint size;
      gdouble *angle;
      ClutterActor *actor;
      ClutterAlpha *alpha;
      ClutterBehaviour *behaviour;
      
      actor = clutter_rectangle_new_with_color (&transp);
      
      size = (i+1) * (CIRCLE_W + CIRCLE_G) * 2;
      clutter_actor_set_size (actor, size, size);
      clutter_actor_set_position (actor, SCREEN_W - size/2,
                                  SCREEN_H - size/2);
      
      clutter_container_add_actor (CLUTTER_CONTAINER (stage), actor);
      
      angle = g_slice_new (gdouble);
      *angle = g_random_double_range (0.0, 90.0);
      g_object_set_data (G_OBJECT (actor), "angle", angle);
      g_signal_connect (actor, "paint", G_CALLBACK (circle_paint_cb), NULL);
      
      /* Animate */
      alpha = clutter_alpha_new_full (timeline, CLUTTER_LINEAR);
      behaviour = clutter_behaviour_rotate_new (alpha, CLUTTER_Z_AXIS,
                                                (i % 2) ? CLUTTER_ROTATE_CW
                                                        : CLUTTER_ROTATE_CCW,
                                                0.0, 0.0);
      clutter_behaviour_rotate_set_center (CLUTTER_BEHAVIOUR_ROTATE (behaviour),
                                           size/2, size/2, 0);
      clutter_behaviour_apply (behaviour, actor);
    }
  
  clutter_actor_show_all (stage);
  
  clutter_timeline_start (timeline);
  
  clutter_main();

  return 0;
}

static int Timeline_gc (lua_State *L)
{
  printf("goodbye Timeline (%p)\n", lua_touserdata(L, 1));
  return 0;
}

static int Timeline_tostring (lua_State *L)
{
  lua_pushfstring(L, "Timeline: %p", lua_touserdata(L, 1));
  return 1;
}

static const luaL_reg Timeline_meta[] = {
  {"__gc",       Timeline_gc},
  {"__tostring", Timeline_tostring},
  {0, 0}
};

static int Stage_gc (lua_State *L)
{
  printf("goodbye Stage (%p)\n", lua_touserdata(L, 1));
  return 0;
}

static int Stage_tostring (lua_State *L)
{
  lua_pushfstring(L, "Stage: %p", lua_touserdata(L, 1));
  return 1;
}

static const luaL_reg Stage_meta[] = {
  {"__gc",       Stage_gc},
  {"__tostring", Stage_tostring},
  {0, 0}
};

static const luaL_reg Timeline_methods[] = {
  {"new",			Timeline_new},
  {0, 0}
};

static const luaL_reg Stage_methods[] = {
  {"new",		Stage_new},
  {"circles",  Stage_circles},
  {0,0}
};

int clutter_register(lua_State *L)
{
	luaL_openlib(L, STAGE, Stage_methods, 0);
	luaL_newmetatable(L, STAGE);
	luaL_openlib(L, 0, Stage_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);
	
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
