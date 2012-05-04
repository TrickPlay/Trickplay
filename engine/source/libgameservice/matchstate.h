#ifndef _MATCHSTATE_H_
#define _MATCHSTATE_H_

#include <vector>
#include <string>

namespace libgameservice {

class MatchState {
public:

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
	MatchInfo(const std::string& id, const MatchState& state)
	: id_(id), state_(state) { }

	const std::string& id() const { return id_; }
	void set_id(std::string& str) { id_ = str; }

	MatchState& state() { return state_; }
	void set_state(const MatchState& state) { state_ = state; }
private:
	std::string id_;
	MatchState state_;
};
}

#endif /* _MATCHSTATE_H_ */
