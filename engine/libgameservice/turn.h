#ifndef _TURN_H_
#define _TURN_H_

#include <string>

namespace libgameservice {

class Turn {
public:

	const std::string& new_state() const { return new_state_; }
	void set_new_state(const std::string& str) { new_state_ = str; }

	bool terminate() const { return terminate_; }
	void set_terminate(bool newval) { terminate_ = newval; }

	const std::string& next_turn() const { return next_turn_; }
	void set_next_turn(const std::string& next) { next_turn_ = next; }

private:
	std::string new_state_;
	bool terminate_;
	std::string next_turn_;
};
}

#endif /* _TURN_H_ */
