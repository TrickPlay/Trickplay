#include "UI-stage.h"
#include "UI-timeline.h"

#include <math.h>

ClutterActor **pushstage(lua_State *L, ClutterActor *stage)
{
	ClutterActor **pstage = (ClutterActor **)lua_newuserdata(L, sizeof(ClutterActor *));
	*pstage = stage;
	luaL_getmetatable(L, STAGE);
	lua_setmetatable(L, -2);

	return pstage;
}

ClutterActor *tostage(lua_State *L, int index)
{
	ClutterActor **pstage = (ClutterActor **)lua_touserdata(L, index);
	if (NULL == pstage) luaL_typerror(L, index, STAGE);

	return *pstage;
}

ClutterActor *checkstage(lua_State *L, int index)
{
	ClutterActor **pstage;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pstage = (ClutterActor **)luaL_checkudata(L, index, STAGE);
	if (NULL == pstage) luaL_typerror(L, index, STAGE);
	if (NULL == *pstage) luaL_error(L, "null stage");

	return *pstage;
}

static int Stage_new(lua_State *L)
{
	int x = luaL_checkint(L, 1);
	int y = luaL_checkint(L, 2);
	int r = luaL_checkint(L, 3);
	int g = luaL_checkint(L, 4);
	int b = luaL_checkint(L, 5);

	ClutterColor *bg_color = clutter_color_new(r, g, b, 0xff);

	ClutterActor *stage = clutter_stage_get_default();
	clutter_actor_set_size(stage, x, y);
	clutter_stage_set_color(CLUTTER_STAGE(stage), bg_color);
	clutter_color_free(bg_color);

	pushstage(L, stage);
	return 1;
}

#ifndef CLUTTER_ANGLE_FROM_RAD
static double CLUTTER_ANGLE_FROM_RAD(double x)
{
	return x * 180.0 / M_PI;
}
#endif

static void
circle_paint_cb(ClutterActor *actor)
{
	const CoglColor fill_color = { 0xff, 0xff, 0xff, 0x80 };
	gint i;
	gdouble angle;
	gint circle_width, circle_segments;
	guint radius = clutter_actor_get_width(actor)/2;

	cogl_set_source_color(&fill_color);

	angle = *((gdouble *)g_object_get_data(G_OBJECT(actor), "angle"));
	circle_width = *((gint *)g_object_get_data(G_OBJECT(actor), "circle_width"));
	circle_segments = *((gint *)g_object_get_data(G_OBJECT(actor), "circle_segments"));
	for (i = 0; i < circle_segments; i++, angle += (2.0*M_PI)/(gdouble)circle_segments)
	{
		gdouble angle2 = angle + ((2.0*M_PI)/(gdouble)circle_segments)/2.0;
		cogl_path_move_to(((radius - circle_width) * cos(angle)) + radius,
		                  ((radius - circle_width) * sin(angle)) + radius);
		cogl_path_arc(radius, radius, radius, radius,
		              CLUTTER_ANGLE_FROM_RAD(angle),
		              CLUTTER_ANGLE_FROM_RAD(angle2));
		cogl_path_line_to(((radius - circle_width) * cos(angle2)) + radius,
		                  ((radius - circle_width) * sin(angle2)) + radius);
		cogl_path_arc(radius, radius, radius - circle_width, radius - circle_width,
		              CLUTTER_ANGLE_FROM_RAD(angle2),
		              CLUTTER_ANGLE_FROM_RAD(angle));
		cogl_path_close();
		cogl_path_fill();
	}
}



static int Stage_circles(lua_State *L)
{
	ClutterTimeline *timeline;
	ClutterActor *stage;
	gfloat width, height;

	const ClutterColor transp = { 0xe0, 0xf2, 0xfc, 0x00 };


	stage = checkstage(L, 1);
	timeline = checktimeline(L, 2);
	int n_circles = luaL_checkint(L, 3);
	int circle_width = luaL_checkint(L, 4);
	int circle_gap = luaL_checkint(L, 5);
	int circle_segments = luaL_checkint(L, 6);

	clutter_actor_get_size(CLUTTER_ACTOR(stage), &width, &height);

	gint i;

	for (i = 0; i < n_circles; i++)
	{
		gint size;
		gdouble *angle;
		ClutterActor *actor;
		ClutterAlpha *alpha;
		ClutterBehaviour *behaviour;

		actor = clutter_rectangle_new_with_color(&transp);

		size = (i+1) * (circle_width + circle_gap) * 2;
		clutter_actor_set_size(actor, size, size);
		clutter_actor_set_position(actor, width - size/2,
		                           height - size/2);

		clutter_container_add_actor(CLUTTER_CONTAINER(stage), actor);

		angle = g_slice_new(gdouble);
		*angle = g_random_double_range(0.0, 90.0);
		g_object_set_data(G_OBJECT(actor), "angle", angle);

		gint *segments = g_slice_new(gint);
		*segments = circle_segments;
		g_object_set_data(G_OBJECT(actor), "circle_segments", segments);

		gint *widths = g_slice_new(gint);
		*widths = circle_width;
		g_object_set_data(G_OBJECT(actor), "circle_width", widths);

		g_signal_connect(actor, "paint", G_CALLBACK(circle_paint_cb), NULL);

		/* Animate */
		alpha = clutter_alpha_new_full(timeline, CLUTTER_LINEAR);
		behaviour = clutter_behaviour_rotate_new(alpha, CLUTTER_Z_AXIS,
		                                         (i % 2) ? CLUTTER_ROTATE_CW
		                                         : CLUTTER_ROTATE_CCW,
		                                         0.0, 0.0);
		clutter_behaviour_rotate_set_center(CLUTTER_BEHAVIOUR_ROTATE(behaviour),
		                                    size/2, size/2, 0);
		clutter_behaviour_apply(behaviour, actor);
	}

	clutter_actor_show_all(stage);

	clutter_timeline_start(timeline);

	clutter_main();

	return 0;
}

static int Stage_gc(lua_State *L)
{
	printf("goodbye Stage (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int Stage_tostring(lua_State *L)
{
	lua_pushfstring(L, "Stage: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg Stage_meta[] =
{
	{"__gc",       Stage_gc},
	{"__tostring", Stage_tostring},
	{0, 0}
};

const luaL_reg Stage_methods[] =
{
	{"new",      Stage_new},
	{"circles",  Stage_circles},
	{0,0}
};

int clutter_stage_register(lua_State *L)
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

	return 1;
}
