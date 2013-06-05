/*
 * gameservice_util.cpp
 *
 */
#include <iostream>
#include <string>
#include <vector>
#include "gameservice_util.h"
#include "lb.h"

namespace TPGameServiceUtil
{

/*
 * input is a lua table of the following format:
 * {
 *      game_id = "xyz",
 *      free_role = "true",
 *      role = "p1",
 *      new_match = "true",
 *      nick = "best_gamer"
 *  }
 *
 */
int populate_match_request( lua_State* L, int index, libgameservice::MatchRequest& match_request )
{
    if ( lua_type( L, index ) != LUA_TTABLE )
    {
        return luaL_error( L, "Incorrect argument, table expected" );
    }

    lua_getfield( L, index, "game_id" );

    const char* cname = lua_tostring( L, -1 );

    if ( !cname )
    {
        return luaL_error( L, "Incorrect argument, failed to set \'game_id\' : string expected" );
    }

    match_request.set_game_id( cname );
    lua_pop( L, 1 );

    // free_role
    lua_getfield( L, index, "free_role" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isboolean( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'free_role\' : boolean expected" );
        }

        match_request.set_free_role( lua_toboolean( L, -1 ) );
    }

    lua_pop( L, 1 );


    // role
    lua_getfield( L, index, "role" );

    if ( !lua_isnil( L, -1 ) )
    {
        cname = lua_tostring( L, -1 );

        if ( !cname )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'role\' : string expected" );
        }

        match_request.set_role( cname );
    }

    lua_pop( L, 1 );


    // new_match
    lua_getfield( L, index, "new_match" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isboolean( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'new_match\' : boolean expected" );
        }

        match_request.set_new_match( lua_toboolean( L, -1 ) );
    }

    lua_pop( L, 1 );


    // nick
    lua_getfield( L, index, "nick" );

    if ( !lua_isnil( L, -1 ) )
    {
        cname = lua_tostring( L, -1 );

        if ( !cname )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'nick\' : string expected" );
        }

        match_request.set_nick( cname );
    }

    lua_pop( L, 1 );

    return 0;
}

/*
 * input is a lua table of the following format:
 *  {
 *      app_id = { name = "com.trickplay.games", version = 1 },
 *      name = "indy_car_race",
 *      description = "American style open-wheel car racing",
 *      category = "Car Racing",
 *      turn_policy = "roundrobin",
 *      game_type = "correspondence|specifiedRole",
 *      join_after_start = "true",
 *      min_players_for_start = "2",
 *      max_duration_per_turn = "1000", // in seconds
 *      abort_when_player_leaves = "true",
 *      roles = {
 *          {   name = "p1", cannot_start = "false", first_role = "true" },
 *          {   name = "p2", cannot_start = "true", first_role = "false" }
 *      }
 *  }
 */
int populate_game( lua_State* L, int index, libgameservice::Game& game )
{
    if ( lua_type( L, index ) != LUA_TTABLE )
    {
        return luaL_error( L, "Incorrect argument, table expected" );
    }

    // app_id
    lua_getfield( L, index, "app_id" );

    if ( !lua_istable( L, -1 ) )
    {
        return luaL_error( L, "Incorrect argument, fail to set \'app_id\' : table expected" );
    }

    int pt = lua_gettop( L );

    // app_name
    lua_getfield( L, pt, "name" );
    const char* cname = lua_tostring( L, -1 );

    if ( !cname )
    {
        return luaL_error( L, "Incorrect argument, failed to set \'app_id.name\' : string expected" );
    }

    String app_name = cname;
    lua_pop( L, 1 );

    // app_version
    int app_version = 1;
    lua_getfield( L, pt, "version" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isnumber( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'app_id.version\' : number expected" );
        }

        if ( lua_tointeger( L, -1 ) <= 0 )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'app_id.version\' : positive non-zero number expected" );
        }

        app_version =  lua_tointeger( L, -1 );
    }

    lua_pop( L, 1 );

    // pop app_id table
    lua_pop( L, 1 );

    // game name
    lua_getfield( L, index, "name" );
    cname = lua_tostring( L, -1 );

    if ( !cname )
    {
        return luaL_error( L, "Incorrect argument, failed to set \'name\' : string expected" );
    }

    lua_pop( L, 1 );

    game.set_game_id( libgameservice::GameId( libgameservice::AppId( app_name, app_version ), cname ) );

    // description
    lua_getfield( L, index, "description" );
    cname = lua_tostring( L, -1 );

    if ( cname != NULL )
    {
        game.set_description( cname );
    }

    lua_pop( L, 1 );

    // category
    lua_getfield( L, index, "category" );
    cname = lua_tostring( L, -1 );

    if ( cname != NULL )
    {
        game.set_category( cname );
    }

    lua_pop( L, 1 );


    // turn_policy
    lua_getfield( L, index, "turn_policy" );
    cname = lua_tostring( L, -1 );

    if ( cname != NULL )
    {
        game.set_turn_policy( libgameservice::Game::turn_policy_from_string( cname ) );
    }

    lua_pop( L, 1 );


    // game_type
    lua_getfield( L, index, "game_type" );
    cname = lua_tostring( L, -1 );

    if ( cname != NULL )
    {
        game.set_game_type( libgameservice::Game::game_type_from_string( cname ) );
    }

    lua_pop( L, 1 );


    // join_after_start
    lua_getfield( L, index, "join_after_start" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isboolean( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'join_after_start\' : boolean expected" );
        }

        game.set_join_after_start( lua_toboolean( L, -1 ) );
    }

    lua_pop( L, 1 );

    // abort_when_player_leaves
    lua_getfield( L, index, "abort_when_player_leaves" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isboolean( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'abort_when_player_leaves\' : boolean expected" );
        }

        game.set_abort_when_player_leaves( lua_toboolean( L, -1 ) );
    }

    lua_pop( L, 1 );

    //min_players_to_start
    lua_getfield( L, index, "min_players_to_start" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isnumber( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'min_players_to_start\' : number expected" );
        }

        if ( lua_tointeger( L, -1 ) <= 0 )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'min_players_to_start\' : positive non-zero number expected" );
        }

        game.set_min_players_for_start( lua_tointeger( L, -1 ) );
    }

    lua_pop( L, 1 );

    // max_duration_per_turn
    lua_getfield( L, index, "max_duration_per_turn" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isnumber( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'max_duration_per_turn\' : number expected" );
        }

        if ( lua_tointeger( L, -1 ) < 0 )
        {
            return luaL_error( L, "Incorrect argument, failed to extract \'max_duration_per_turn\' : non negative number expected" );
        }

        game.set_max_duration_per_turn( lua_tointeger( L, -1 ) );
    }

    lua_pop( L, 1 );

    // roles
    lua_getfield( L, index, "roles" );

    if ( !lua_istable( L, -1 ) )
    {
        return luaL_error( L, "Incorrect argument, failed to find \'roles\' : table expected" );
    }

    pt = lua_gettop( L );

    lua_pushnil( L );

    while ( lua_next( L, pt ) != 0 )
    {
        //  std::cout << "extracting role info" << std::endl;
        if ( !lua_istable( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to access properties table for a role" );
        }

        String role_name;
        lua_getfield( L, -1, "name" );

        if ( !lua_isnil( L, -1 ) )
        {
            if ( !lua_isstring( L, -1 ) )
            {
                return luaL_error( L, "Incorrect argument, fail to set \'role.name\' : string expected" );
            }

            role_name = lua_tostring( L, -1 );
        }
        else
        {
            return luaL_error( L, "Incorrect argument, fail to set \'role.name\' : string expected" );
        }

        lua_pop( L, 1 );

        bool cannot_start = false;

        // cannot_start
        lua_getfield( L, -1, "cannot_start" );

        if ( !lua_isnil( L, -1 ) )
        {
            if ( !lua_isboolean( L, -1 ) )
            {
                return luaL_error( L, "Incorrect argument, failed to set \'cannot_start\' : boolean expected" );
            }

            cannot_start = lua_toboolean( L, -1 );
        }

        lua_pop( L, 1 );

        // first_role
        bool first_role = false;
        lua_getfield( L, index, "first_role" );

        if ( !lua_isnil( L, -1 ) )
        {
            if ( !lua_isboolean( L, -1 ) )
            {
                return luaL_error( L, "Incorrect argument, failed to set \'first_role\' : boolean expected" );
            }

            first_role = lua_toboolean( L, -1 );
        }

        lua_pop( L, 1 );

        //  std::cout << "finished extracting role" << std::endl;
        game.roles().push_back( libgameservice::Role( role_name, cannot_start, first_role ) );

        lua_pop( L, 1 ); // pop the role table
    }

    // pop the roles table
    lua_pop( L, 1 );

    return 0;
}

int populate_game_id( lua_State* L, int index, libgameservice::GameId& game_id )
{
    if ( lua_type( L, index ) != LUA_TTABLE )
    {
        return luaL_error( L, "Incorrect argument, table expected" );
    }

    // app_id
    lua_getfield( L, index, "app_id" );

    if ( !lua_istable( L, -1 ) )
    {
        return luaL_error( L, "Incorrect argument, fail to set \'app_id\' : table expected" );
    }

    int pt = lua_gettop( L );

    // app_name
    lua_getfield( L, pt, "name" );
    const char* cname = lua_tostring( L, -1 );

    if ( !cname )
    {
        return luaL_error( L, "Incorrect argument, failed to set \'app_id.name\' : string expected" );
    }

    String app_name = cname;
    lua_pop( L, 1 );

    // app_version
    int app_version = 1;
    lua_getfield( L, pt, "version" );

    if ( !lua_isnil( L, -1 ) )
    {
        if ( !lua_isnumber( L, -1 ) )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'app_id.version\' : number expected" );
        }

        if ( lua_tointeger( L, -1 ) <= 0 )
        {
            return luaL_error( L, "Incorrect argument, failed to set \'app_id.version\' : positive non-zero number expected" );
        }

        app_version =  lua_tointeger( L, -1 );
    }

    lua_pop( L, 1 );

    // pop app_id table
    lua_pop( L, 1 );

    // game name
    lua_getfield( L, index, "name" );
    cname = lua_tostring( L, -1 );

    if ( !cname )
    {
        return luaL_error( L, "Incorrect argument, failed to set \'name\' : string expected" );
    }

    lua_pop( L, 1 );

    game_id = libgameservice::GameId( libgameservice::AppId( app_name, app_version ), cname );

    return 0;
}


void push_registered_games( lua_State* L )
{

    LSG;
    lua_newtable( L );
    /*

    */

    ( void )LSG_END( 1 );
}

void push_response_status_arg( lua_State* L, const libgameservice::ResponseStatus& rs )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "status" );
    lua_pushinteger( L, rs.status_code() );
    lua_rawset( L , t );

    const char* status_as_str = libgameservice::statusToString( rs.status_code() );
    lua_pushliteral( L , "status_as_string" );
    lua_pushstring( L ,  status_as_str );
    lua_rawset( L , t );

    if ( rs.status_code() != libgameservice::OK )
    {
        lua_pushliteral( L , "error_message" );
        lua_pushstring( L , !( rs.error_message().empty() ) ? rs.error_message().c_str() : status_as_str );
        lua_rawset( L , t );
    }
}

void push_response_status_arg( lua_State* L, const libgameservice::StatusCode sc )
{
    libgameservice::ResponseStatus rs( sc, std::string() );
    push_response_status_arg( L, rs );
}


void push_app_id_arg( lua_State* L, const libgameservice::AppId& app_id )
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

/*
 * match_request table of the following format:
 * {
 *      game_id = "xyz",
 *      free_role = "true",
 *      role = "p1",
 *      new_match = "true",
 *      nick = "best_gamer"
 *  }
 *
 */
void push_match_request_arg( lua_State* L, const libgameservice::MatchRequest& match_request )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L , "game_id" );
    lua_pushstring( L , match_request.game_id().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L , "free_role" );
    lua_pushboolean( L , match_request.free_role() );
    lua_rawset( L , t );

    lua_pushliteral( L , "role" );
    lua_pushstring( L , match_request.role().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L , "new_match" );
    lua_pushboolean( L , match_request.new_match() );
    lua_rawset( L , t );

    lua_pushliteral( L , "nick" );
    lua_pushstring( L , match_request.nick().c_str() );
    lua_rawset( L , t );

}

void push_string_arg( lua_State* L, const std::string& str )
{
    lua_pushstring( L, str.c_str() );
}

void push_participant_arg( lua_State* L, const libgameservice::Participant& participant )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L , "id" );
    lua_pushstring( L , participant.id().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L , "nick" );
    lua_pushstring( L , participant.nick().c_str() );
    lua_rawset( L , t );
}

/*
 * match_state =
 * {
 *  string opaque,
    bool terminate,
    string first;
    string next;
    string last;
    table players;
 *
 * }
 */
void push_match_state_arg( lua_State* L, const libgameservice::MatchState& match_state )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "opaque" );
    lua_pushstring( L , match_state.opaque().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "terminate" );
    lua_pushboolean( L , match_state.terminate() );
    lua_rawset( L , t );

    lua_pushliteral( L, "first" );
    lua_pushstring( L , match_state.first().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "next" );
    lua_pushstring( L , match_state.next().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "last" );
    lua_pushstring( L , match_state.last().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "players" );
    lua_newtable( L );

    //std::vector<String> players = match_state.const_players();
    int i = 1;
    std::vector<String>::const_iterator it;

    for ( it = match_state.const_players().begin() ; it < match_state.const_players().end(); it++ )
    {
        lua_pushstring( L, ( *it ).c_str() );
        lua_rawseti( L, -2, i++ );
    }

    lua_rawset( L, t );

}

void push_match_status_arg( lua_State* L, const libgameservice::MatchStatus& match_status )
{
    lua_pushstring( L , libgameservice::matchStatusToString( match_status ).c_str() );
}

/*
 * item =
 * {
 *  string nick;
    string role;
    string affiliation;
    string jid;
    }
 */
void push_item_arg( lua_State* L, const libgameservice::Item& item )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "nick" );
    lua_pushstring( L , item.nick().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "role" );
    lua_pushstring( L , item.role().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "affiliation" );
    lua_pushstring( L , libgameservice::affiliationToString( item.affiliation() ).c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "jid" );
    lua_pushstring( L , item.jid().c_str() );
    lua_rawset( L , t );


}

/*
 * turn =
 * {
 *  string new_state;
    bool terminate;
    string next_turn;
 * }
 */
void push_turn_arg( lua_State* L, const libgameservice::Turn& turn_message )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "new_state" );
    lua_pushstring( L , turn_message.new_state().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "terminate" );
    lua_pushboolean( L , turn_message.terminate() );
    lua_rawset( L , t );

    lua_pushliteral( L, "next_turn" );
    lua_pushstring( L , turn_message.next_turn().c_str() );
    lua_rawset( L , t );
}

/*
{
  game_id = "xx",
  match_infos = {
      { match_id = "xx", match_status = "xx", nickname = "xx", in_room_id = "xx", match_state = { } }
      ...
  }
}
*/

void push_match_data_arg( lua_State* L, const libgameservice::MatchData& match_data )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "game_id" );
    lua_pushstring( L , match_data.game_id().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "match_infos" );
    lua_newtable( L );

    int match_infos_t = lua_gettop( L );

    int i = 1;
    std::vector<libgameservice::MatchInfo>::const_iterator it;

    for ( it = match_data.const_match_infos().begin(); it < match_data.const_match_infos().end(); it++ )
    {

        //  std::cout << "populating lua table for match_id= " << (*it).id() <<  std::endl;
        lua_newtable( L );
        int match_info_t = lua_gettop( L );

        lua_pushliteral( L, "match_id" );
        lua_pushstring( L , ( *it ).id().c_str() );
        lua_rawset( L ,  match_info_t );

        lua_pushliteral( L, "match_status" );
        push_match_status_arg( L , ( *it ).status() );
        lua_rawset( L ,  match_info_t );

        lua_pushliteral( L, "nickname" );
        lua_pushstring( L , ( *it ).nickname().c_str() );
        lua_rawset( L ,  match_info_t );

        lua_pushliteral( L, "in_room_id" );
        lua_pushstring( L , ( *it ).in_room_id().c_str() );
        lua_rawset( L ,  match_info_t );

        lua_pushliteral( L, "match_state" );
        push_match_state_arg( L, ( *it ).const_state() );
        lua_rawset( L, match_info_t );

        //std::cout << "the top of the stack is " << lua_gettop( L ) << ". match_info table is at index " << match_info_t << std::endl;
        lua_rawseti( L, match_infos_t, i++ );
    }

    /*std::cout << "finished populating match_info into match_infos. the top of the stack is " << lua_gettop( L )
            << ". match_data table is at index " << t << std::endl;*/
    lua_rawset( L, t );
}

void push_user_game_data_arg( lua_State* L, const libgameservice::UserGameData& user_game_data )
{
    lua_newtable( L );
    int t = lua_gettop( L );

    lua_pushliteral( L, "game_id" );
    lua_pushstring( L , user_game_data.game_id().c_str() );
    lua_rawset( L , t );

    lua_pushliteral( L, "version" );
    lua_pushinteger( L , user_game_data.version() );
    lua_rawset( L , t );

    lua_pushliteral( L, "opaque" );
    lua_pushstring( L , user_game_data.opaque().c_str() );
    lua_rawset( L , t );
}

}
