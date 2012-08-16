#include <iostream>
#include <sstream>
#include <cassert>
#include <string>
#include "libgameservice.h"
#include "xmppmugconstants.h"
#include "game.h"

extern "C" int atoi(const char*);

namespace libgameservice {

static std::string kCorrespondence("correspondence");
static std::string kOnline("online");
static std::string kRoundRobin("roundrobin");
static std::string kSimultaneous("simultaneous");
static std::string kSpecifiedRole("specifiedRole");
static std::string kAppIdPrefix("urn:xmpp:mug:tp:");

static bool isValidGameIdString(const std::string& game_id_str) {
	if (game_id_str.size() <= kAppIdPrefix.size())
		return false;
	size_t pos = game_id_str.find(kAppIdPrefix);
	if (pos != 0)
		return false;

	int ntokens = 0;
	for(size_t i=kAppIdPrefix.size(); i<game_id_str.size(); i++) {
		if (game_id_str[i] == ':') {
			ntokens++;
		}
	}
	if (ntokens != 2 || game_id_str[game_id_str.size()-1] == ':')
		return false;

	return true;
}

GameId GameId::parseGameId(const std::string& game_id_str) {
	if (!isValidGameIdString(game_id_str))
		return GameId();
	std::string game_id_suffix = game_id_str.substr(kAppIdPrefix.size());
	size_t app_name_delim_pos = game_id_suffix.find(':');
	std::string app_name = game_id_suffix.substr(0, app_name_delim_pos);
	game_id_suffix = game_id_suffix.substr(app_name_delim_pos+1);
	size_t version_delim_pos = game_id_suffix.find(':');
	std::string version_str = game_id_suffix.substr(0, version_delim_pos);

	int version = atoi(version_str.c_str());

	std::string game_name = game_id_suffix.substr(version_delim_pos+1);

	return GameId(AppId(app_name, version), game_name);
}

std::string Game::game_type_to_string(GameType gt) {
	switch (gt) {
	case correspondence:
		return kCorrespondence;
	case online:
		return kOnline;
	}
	std::cerr << gt << " is not a valid GameType. Returning default correspondence gametype" << std::endl;
	return kCorrespondence;
}

std::string Game::turn_policy_to_string(TurnPolicy tp) {
	switch (tp) {
	case roundrobin:
		return kRoundRobin;
	case simultaneous:
		return kSimultaneous;
	case specifiedRole:
		return kSpecifiedRole;
	}

	std::cerr << tp << " is not a valid TurnPolicy. Returning default roundrobin policy" << std::endl;

	return kRoundRobin;
}

Game::GameType Game::game_type_from_string(const std::string& str) {
	if (kCorrespondence == str)
		return correspondence;
	else if (kOnline == str)
		return online;

	std::cerr << str << " is not a valid GameType. Returning default correspondence gametype" << std::endl;

	return correspondence;

}

Game::TurnPolicy Game::turn_policy_from_string(const std::string& str) {
	if (kRoundRobin == str)
		return roundrobin;
	else if (kSimultaneous == str)
		return simultaneous;
	else if (kSpecifiedRole == str)
		return specifiedRole;
	std::cerr << str << " is not a valid TurnPolicy. Returning default roundrobin policy" << std::endl;
	return roundrobin;

}

}
