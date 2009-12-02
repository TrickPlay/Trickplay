#include "UI.h"

#include "UI-timeline.h"
#include "UI-stage.h"


int UI_register(lua_State *L)
{
	clutter_init(0, NULL);
	clutter_stage_register(L);
	clutter_timeline_register(L);
	return 1;
}
