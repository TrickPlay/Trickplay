#ifndef _TURN_H_
#define _TURN_H_

#include <string>

namespace libgameservice {

class Turn {
public:

	Turn() :
		new_state_(), terminate_(false), next_turn_(), only_update_(false) { }

	const std::string& new_state() const { return new_state_; }
	void set_new_state(const std::string& str) { new_state_ = str; }

	bool terminate() const { return terminate_; }
	void set_terminate(bool newval) { terminate_ = newval; }

	const std::string& next_turn() const { return next_turn_; }
	void set_next_turn(const std::string& next) { next_turn_ = next; }

	bool only_update() const { return only_update_; }
	void set_only_update(bool newval) { only_update_ = newval; }

private:
	std::string new_state_;
	bool terminate_;
	std::string next_turn_;
	bool only_update_;
};
}

#endif /* _TURN_H_ */
