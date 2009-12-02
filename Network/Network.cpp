#include "Network.h"
#include "Network-curl.h"

int Network_register(lua_State *L)
{
	url_fetcher_register(L);
	return 1;
}
