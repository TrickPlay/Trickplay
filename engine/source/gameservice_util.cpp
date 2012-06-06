/*
 * gameservice_util.cpp
 *
 */
#include <iostream>
#include "gameservice_util.h"
#include "lb.h"

namespace TPGameServiceUtil {

/*
 * input is a lua table of the following format:
 * {
 * 		game_id = "xyz",
 * 		free_role = "true",
 * 		role = "p1",
 * 		new_match = "true",
 * 		nick = "best_gamer"
 * 	}
 *
 */
int populate_match_request( lua_State * L, int index, libgameservice::MatchRequest& match_request )
{
    if (lua_type(L, index) != LUA_TTABLE)
    {
		return luaL_error(L, "Incorrect argument, table expected");
	}

	lua_getfield(L, index, "game_id");

	const char * cname = lua_tostring(L,-1);
	if (!cname)
	{
		return luaL_error(L, "Incorrect argument, failed to set \'game_id\' : string expected");
	}
	match_request.set_game_id(cname);
	lua_pop(L,1);

	// free_role
	lua_getfield(L, index, "free_role");
	if (!lua_isnil(L, -1))
	{
		if (!lua_isboolean(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'free_role\' : boolean expected");
		}
		match_request.set_free_role(lua_toboolean(L, -1));
	}
	lua_pop(L,1);


	// role
	lua_getfield(L, index, "role");
	if(!lua_isnil(L, -1))
	{
		cname = lua_tostring(L, -1);
		if (!cname)
		{
			return luaL_error(L, "Incorrect argument, failed to set \'role\' : string expected");
		}
		match_request.set_role(cname);
	}
    lua_pop(L, 1);


// new_match
	lua_getfield(L, index, "new_match");
	if (!lua_isnil(L, -1))
	{
		if (!lua_isboolean(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'new_match\' : boolean expected");
		}
		match_request.set_new_match(lua_toboolean(L, -1));
	}
	lua_pop(L,1);


// nick
	lua_getfield(L, index, "nick");
	if(!lua_isnil(L, -1))
	{
		cname = lua_tostring(L, -1);
		if (!cname)
		{
			return luaL_error(L, "Incorrect argument, failed to set \'nick\' : string expected");
		}
		match_request.set_nick(cname);
	}
	lua_pop(L, 1);

     return 0;
}

/*
 * input is a lua table of the following format:
 *  {
 *  	app_id = { name = "com.trickplay.games", version = 1 },
 *  	name = "indy_car_race",
 *  	description = "American style open-wheel car racing",
 *	    category = "Car Racing",
 *	    turn_policy = "roundrobin",
 *	    game_type = "correspondence|specifiedRole",
 *	    join_after_start = "true",
 *      min_players_for_start = "2",
 *      max_duration_per_turn = "1000", // in seconds
 *      abort_when_player_leaves = "true",
 *      roles = {
 *      	{	name = "p1", cannot_start = "false", first_role = "true" },
 *      	{   name = "p2", cannot_start = "true", first_role = "false" }
 *      }
 *  }
 */
int populate_game( lua_State * L, int index, libgameservice::Game& game )
{
    if (lua_type(L, index) != LUA_TTABLE)
    {
		return luaL_error(L, "Incorrect argument, table expected");
	}

    // app_id
	lua_getfield(L, index, "app_id");

	if (!lua_istable(L, -1))
	{
		return luaL_error(L, "Incorrect argument, fail to set \'app_id\' : table expected");
	}

	int pt = lua_gettop(L);

	// app_name
	lua_getfield(L, pt, "name");
	const char * cname = lua_tostring(L,-1);
	if (!cname)
	{
		return luaL_error(L, "Incorrect argument, failed to set \'app_id.name\' : string expected");
	}
	String app_name = cname;
	lua_pop(L,1);

	// app_version
	int app_version = 1;
	lua_getfield(L, pt, "version");
	if (!lua_isnil(L, -1)) {
		if(!lua_isnumber(L, -1))
			{
				return luaL_error(L, "Incorrect argument, failed to set \'app_id.version\' : number expected");
			}
			if ( lua_tointeger(L, -1) <= 0 )
			{
				return luaL_error(L, "Incorrect argument, failed to set \'app_id.version\' : positive non-zero number expected");
			}
			app_version =  lua_tointeger(L, -1);
	}
	lua_pop(L,1);

	// pop app_id table
	lua_pop(L, 1);

	// game name
	lua_getfield(L, index, "name");
	cname = lua_tostring(L,-1);
	if (!cname)
	{
		return luaL_error(L, "Incorrect argument, failed to set \'name\' : string expected");
	}
	lua_pop(L,1);

	game.set_game_id(libgameservice::GameId(libgameservice::AppId(app_name, app_version), cname));

	// description
	lua_getfield(L, index, "description");
	cname = lua_tostring(L,-1);
	if (cname != NULL)
	{
		game.set_description(cname);
	}
	lua_pop(L,1);

	// category
	lua_getfield(L, index, "category");
	cname = lua_tostring(L,-1);
	if (cname != NULL)
	{
		game.set_category(cname);
	}
	lua_pop(L,1);


	// turn_policy
	lua_getfield(L, index, "turn_policy");
	cname = lua_tostring(L, -1);
	if (cname != NULL)
	{
		game.set_turn_policy(libgameservice::Game::turn_policy_from_string(cname));
	}
	lua_pop(L, 1);


	// game_type
	lua_getfield(L, index, "game_type");
	cname = lua_tostring(L, -1);
	if (cname != NULL)
	{
		game.set_game_type(libgameservice::Game::game_type_from_string(cname));
	}
	lua_pop(L, 1);


	// join_after_start
	lua_getfield(L, index, "join_after_start");
	if (!lua_isnil(L, -1))
	{
		if (!lua_isboolean(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'join_after_start\' : boolean expected");
		}
		game.set_join_after_start(lua_toboolean(L, -1));
	}
	lua_pop(L,1);

	// abort_when_player_leaves
	lua_getfield(L, index, "abort_when_player_leaves");
	if (!lua_isnil(L, -1))
	{
		if (!lua_isboolean(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'abort_when_player_leaves\' : boolean expected");
		}
		game.set_abort_when_player_leaves(lua_toboolean(L, -1));
	}
	lua_pop(L,1);

	//min_players_to_start
	lua_getfield(L, index, "min_players_to_start");
	if (!lua_isnil(L, -1))
	{
		if(!lua_isnumber(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'min_players_to_start\' : number expected");
		}
		if ( lua_tointeger(L, -1) <= 0 )
		{
			return luaL_error(L, "Incorrect argument, failed to set \'min_players_to_start\' : positive non-zero number expected");
		}
		game.set_min_players_for_start(lua_tointeger(L, -1));
	}
	lua_pop(L,1);

	// max_duration_per_turn
	lua_getfield(L, index, "max_duration_per_turn");
	if (!lua_isnil(L, -1))
	{
		if(!lua_isnumber(L, -1))
		{
			return luaL_error(L, "Incorrect argument, failed to set \'max_duration_per_turn\' : number expected");
		}
		if ( lua_tointeger(L, -1) <= 0 )
		{
			return luaL_error(L, "Incorrect argument, failed to set \'max_duration_per_turn\' : positive non-zero number expected");
		}
		game.set_max_duration_per_turn(lua_tointeger(L, -1));
	}
	lua_pop(L,1);

	// roles
	lua_getfield(L, index, "roles");
	if (!lua_istable(L, -1))
	{
		return luaL_error(L, "Incorrect argument, fail to set \'roles\' : table expected");
	}

	pt = lua_gettop(L);

	lua_pushnil(L);
	while(lua_next(L, pt) != 0)
	{
		if (!lua_istable(L, -1))
		{
			return luaL_error(L, "Incorrect argument, fail to set \'properties\' elements : table expected");
		}

		String role_name;
		lua_getfield(L, -1, "name");
		if (!lua_isnil(L, -1))
		{
			if (!lua_isstring(L, -1))
			{
				return luaL_error(L, "Incorrect argument, fail to set \'role.name\' : string expected");
			}

			role_name = lua_tostring(L, -1);
		}
		else
		{
			return luaL_error(L, "Incorrect argument, fail to set \'role.name\' : string expected");
		}
		lua_pop(L, 1);

		bool cannot_start = false;

		// cannot_start
		lua_getfield(L, -1, "cannot_start");
		if (!lua_isnil(L, -1))
		{
			if (!lua_isboolean(L, -1))
			{
				return luaL_error(L, "Incorrect argument, failed to set \'cannot_start\' : boolean expected");
			}
			cannot_start = lua_toboolean(L, -1);
		}
		lua_pop(L,1);

		// first_role
		bool first_role = false;
		lua_getfield(L, index, "first_role");
		if (!lua_isnil(L, -1))
		{
			if (!lua_isboolean(L, -1))
			{
				return luaL_error(L, "Incorrect argument, failed to set \'first_role\' : boolean expected");
			}
			first_role = lua_toboolean(L, -1);
		}
		lua_pop(L,1);

		game.roles().push_back(libgameservice::Role(role_name, cannot_start, first_role));

	}

	// pop the roles table
	lua_pop(L, 1);

	return 0;
}

void push_registered_games( lua_State * L )
{

	LSG;
	lua_newtable( L );
	/*

	*/

	(void)LSG_END( 1 );
}

void push_response_status_arg( lua_State * L, const libgameservice::ResponseStatus& rs )
{
	lua_newtable( L );
	int t = lua_gettop( L );

	lua_pushliteral( L , "status_code" );
	lua_pushstring( L , libgameservice::statusToString(rs.status_code()) );
	lua_rawset( L , t );

	if (rs.status_code() != libgameservice::OK)
	{
		lua_pushliteral( L , "error_message" );
		lua_pushstring( L , rs.error_message().c_str() );
		lua_rawset( L , t );
	}
}

void push_app_id_arg( lua_State * L, const libgameservice::AppId& app_id )
{
	std::cout << app_id.Str() << "versionAsString is: " << libgameservice::intToString( app_id.version() ).c_str() << std::endl;
	lua_newtable( L );
	int t = lua_gettop( L );

	lua_pushliteral( L , "name" );
	lua_pushstring( L , app_id.name().c_str() );
	lua_rawset( L , t );

	lua_pushliteral( L , "version" );
	lua_pushstring( L , libgameservice::intToString( app_id.version() ).c_str() );
	lua_rawset( L , t );
}

void push_match_request_arg( lua_State * L, const libgameservice::MatchRequest& match_request )
{

}

void push_match_id_arg( lua_State * L, const std::string& match_id )
{

}


}
