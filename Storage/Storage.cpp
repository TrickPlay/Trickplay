#include "Storage.h"

int Storage_register(lua_State *L)
{
	local_hash_register(L);
	cloud_hash_register(L);
	remote_hash_register(L);
	return 1;
}
