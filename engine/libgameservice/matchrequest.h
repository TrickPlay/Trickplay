#ifndef _MATCHREQUEST_H_
#define _MATCHREQUEST_H_

#include <string>

namespace libgameservice {

class MatchRequest {
public:

	MatchRequest() :
		free_role_(false), new_match_(false) {
	}

	MatchRequest(const std::string& game_id) :
		game_id_(game_id), free_role_(false), new_match_(false) {
	}

	const std::string& role() const {
		return role_;
	}
	void set_role(const std::string& str) {
		role_ = str;
	}

	const std::string& game_id() const {
		return game_id_;
	}
	void set_game_id(const std::string& newval) {
		game_id_ = newval;
	}

	bool free_role() const { return free_role_; }
	void set_free_role(bool val) { free_role_ = val; }

	bool new_match() const { return new_match_; }
	void set_new_match(bool val) { new_match_ = val; }

	const std::string& nick() const {
		return nick_;
	}
	void set_nick(const std::string& nick) {
		nick_ = nick;
	}

	bool is_valid() const {
		if (game_id_.empty())
			return false;
		bool acquire_role = free_role_ || !role_.empty();
		if (acquire_role && nick_.empty())
			return false;
		if (!acquire_role && !new_match_)
			return false;
		return true;
	}

	std::string Str() const {
		return std::string(
				"{ game_id:" + game_id()
				+ ", free_role:" + (free_role() ? "true" : "false")
				+ ", role:" + role()
				+ ", new_match:" + (new_match() ? "true" : "false")
				+ ", nick:" + nick()
				+ "}"
				);
	}
private:
	std::string game_id_;
	bool free_role_;
	std::string role_;
	bool new_match_;
	std::string nick_;

};

}

#endif /* _MATCHREQUEST_H_ */
