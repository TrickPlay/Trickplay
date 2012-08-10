#ifndef _MATCHSTATE_H_
#define _MATCHSTATE_H_

#include <vector>
#include <string>

namespace libgameservice {

class MatchState {
public:

	MatchState() : terminate_(false) { }

	const std::string& opaque() const { return opaque_; }
	void set_opaque(const std::string& str) { opaque_ = str; }

	bool terminate() const { return terminate_; }
	void set_terminate(bool newval) { terminate_ = newval; }

	const std::string& next() const { return next_; }
	void set_next(const std::string& next) { next_ = next; }

	const std::string& first() const { return first_; }
	void set_first(const std::string& first) { first_ = first; }

	const std::string& last() const { return last_; }
	void set_last(const std::string& last) { last_ = last; }

	std::vector<std::string>& players() { return players_; }
	void set_players(const std::vector<std::string>& players) { players_ = players; }

	const std::vector<std::string>& const_players() const { return players_; }

	MatchState& operator= (const MatchState& mstate) {
		set_opaque(mstate.opaque());
		set_terminate(mstate.terminate());
		set_next(mstate.next());
		set_first(mstate.first());
		set_last(mstate.last());
		set_players(mstate.players_);
		return *this;
	}

private:
	std::string opaque_;
	bool terminate_;
	std::string first_;
	std::string next_;
	std::string last_;
	std::vector<std::string> players_;

};

class MatchInfo {

public:
	MatchInfo() { }
	MatchInfo(const std::string& id, MatchStatus status, const std::string& nickname, const std::string& in_room_id, const MatchState& state)
	: id_(id), status_(status), nickname_(nickname), in_room_id_(in_room_id), state_(state) { }

	const std::string& id() const { return id_; }
	void set_id(const std::string& str) { id_ = str; }

	MatchStatus status() const { return status_; }
	void set_status(MatchStatus new_status) { status_ = new_status; }

	const MatchState& const_state() const { return state_; }
	MatchState& state() { return state_; }
	void set_state(const MatchState& state) { state_ = state; }

	const std::string& nickname() const { return nickname_; }
	void set_nickname(const std::string& nick) { nickname_ = nick; }

	const std::string& in_room_id() const { return in_room_id_; }
	void set_in_room_id(const std::string& in_room_id) { in_room_id_ = in_room_id; }


private:
	std::string id_;
	MatchStatus status_;
	std::string nickname_;
	std::string in_room_id_;
	MatchState state_;
};
}

#endif /* _MATCHSTATE_H_ */
