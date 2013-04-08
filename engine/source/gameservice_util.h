#ifndef _TRICKPLAY_GAMESERVCIE_UTIL_H
#define _TRICKPLAY_GAMESERVCIE_UTIL_H

#include "common.h"
#include "gameserviceclient.h"

namespace TPGameServiceUtil
{


// Converts lua match request to C++ match request.
int populate_match_request( lua_State* L, int index, libgameservice::MatchRequest& match_request );

int populate_game( lua_State* L, int index, libgameservice::Game& game );

int populate_game_id( lua_State* L, int index, libgameservice::GameId& game_id );

void push_registered_games( lua_State* L );

void push_response_status_arg( lua_State* L, const libgameservice::ResponseStatus& rs );

void push_response_status_arg( lua_State* L, const libgameservice::StatusCode sc );

void push_app_id_arg( lua_State* L, const libgameservice::AppId& app_id );

void push_match_request_arg( lua_State* L, const libgameservice::MatchRequest& match_request );

void push_string_arg( lua_State* L, const std::string& str );

void push_participant_arg( lua_State* L, const libgameservice::Participant& participant );

void push_match_state_arg( lua_State* L, const libgameservice::MatchState& match_state );

void push_match_status_arg( lua_State* L, const libgameservice::MatchStatus& match_status );

void push_item_arg( lua_State* L, const libgameservice::Item& item );

void push_turn_arg( lua_State* L, const libgameservice::Turn& turn_message );

void push_match_data_arg( lua_State* L, const libgameservice::MatchData& match_data );

void push_user_game_data_arg( lua_State* L, const libgameservice::UserGameData& user_game_data );

};


#endif // _TRICKPLAY_GAMESERVCIE_UTIL_H
