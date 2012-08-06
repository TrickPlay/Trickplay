#ifndef _ROLE_H_
#define _ROLE_H_

#include <string>

namespace libgameservice {

class Role {
public:
	Role(const std::string& name) : name_(name), cannot_start_(false), first_role_(false) {
		//Role(name, false, false);
	}
	Role(const std::string& name, bool cannot_start, bool first_role) :
		name_(name), cannot_start_(cannot_start), first_role_(first_role) {
	}

	const std::string& name() const {
		return name_;
	}
	bool cannot_start() const {
		return cannot_start_;
	}
	bool first_role() const {
		return first_role_;
	}
private:
	std::string name_;
	bool cannot_start_;
	bool first_role_;
};

}

#endif /* _ROLE_H_ */
