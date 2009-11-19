#include "UI.h"

int UI_register(lua_State *L)
{
	clutter_stage_register(L);
	clutter_timeline_register(L);
	return 1;
}
