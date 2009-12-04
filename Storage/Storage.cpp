#include "Storage.h"

#include "Storage-local.h"
#include "Storage-cloud.h"
#include "Storage-remote.h"


int Storage_register(lua_State *L)
{
	local_db_register(L);
	cloud_db_register(L);
	remote_db_register(L);
	return 1;
}
