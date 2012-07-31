#ifndef _USERDATA_H_
#define _USERDATA_H_

#include <string>
#include <vector>
#include "matchstate.h"

namespace libgameservice {

class MatchData {

public:

	const std::vector<MatchInfo>& const_match_infos() const { return match_infos_; }
	std::vector<MatchInfo>& match_infos() { return match_infos_; }
	void set_match_infos(std::vector<MatchInfo>& other) { match_infos_ = other; }

	const std::string& game_id() const { return game_id_; }
	void set_game_id(const std::string& newval) { game_id_ = newval; }

private:
	std::vector<MatchInfo> match_infos_;
	std::string game_id_;
};

}

#endif /* _USERDATA_H_ */
