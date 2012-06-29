#ifndef _GAMESERVICE_INTERFACE_H_
#define _GAMESERVICE_INTERFACE_H_

#include <string>
#include <vector>
#include "libgameservice.h"
#include "game.h"
#include "status.h"
#include "matchrequest.h"
#include "matchstate.h"
#include "turn.h"
#include "participant.h"
#include "item.h"

namespace libgameservice {

class OpenAppResponse {
public:
	OpenAppResponse(const AppId& appId) : app_id_(app_id) {}

	const AppId& app_id() const { return app_id_; }
	std::vector<GameId>& game_list() { return game_list_; }
private:
	std::vector<GameId> game_list_;
	AppId app_id_;
};


class ListGamesResponse {
public:
	std::vector<GameId>& game_list() { return game_list_; }
private:
	std::vector<GameId> game_list_;
};


class JoinMatchResponse {
public:

	JoinMatchResponse(const std::string& match_id, const Participant& from, const Item& item)
	: match_id_(match_id), from_(from), item_(item) { }

	const std::string& match_id() const { return match_id_; }
	const Participant& from() const { return participant_; }
	const Item& item() const { return item_; }
private:
	std::string match_id_;
	Participant from_;
	Item item_;
};

class AssignMatchResponse {
public:
	AssignMatchResponse(const std::string& match_id, const MatchRequest& mr)
	: match_id_(match_id), match_request_(mr) { }

	MatchRequest& match_request() const { return match_request_; }
	const std::string& match_id() const { return match_id_; }
private:
	std::string match_id_;
	MatchRequest match_request_;
};

class MatchDataResponse {
public:

};




}

#endif /* _GAMESERVICE_INTERFACE_H_ */
