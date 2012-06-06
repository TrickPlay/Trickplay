#ifndef _TRICKPLAY_GAMESERVCIE_UTIL_H
#define _TRICKPLAY_GAMESERVCIE_UTIL_H

#include "common.h"
#include "gameserviceclient.h"

namespace TPGameServiceUtil
{


    // Converts lua match request to C++ match request.
    int populate_match_request( lua_State * L, int index, libgameservice::MatchRequest& match_request );

    int populate_game( lua_State * L, int index, libgameservice::Game& game );

    void push_registered_games( lua_State * L );

    void push_response_status_arg( lua_State * L, const libgameservice::ResponseStatus& rs );

    void push_app_id_arg( lua_State * L, const libgameservice::AppId& app_id );

    void push_match_request_arg( lua_State * L, const libgameservice::MatchRequest& match_request );

    void push_match_id_arg( lua_State * L, const std::string& match_id );

};


#endif // _TRICKPLAY_GAMESERVCIE_UTIL_H
