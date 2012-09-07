#ifndef _PARTICIPANT_H_
#define _PARTICIPANT_H_

#include <string>

namespace libgameservice {

class Participant {

public:
	Participant(const std::string& id, const std::string& nick) : id_(id), nick_(nick) { }

	Participant() { }

	const std::string& id() const { return id_; }

	void set_id(const std::string& id) {
		id_ = id;
	}


	const std::string& nick() const { return nick_; }

	void set_nick(const std::string& nick) {
		nick_ = nick;
	}

	static Participant parseParticipant(const std::string& resource) {
		Participant p;
		if (resource.empty())
			return p;
		size_t underscoreLoc = resource.find("_");
        std::string id = resource.substr(0, underscoreLoc);
        p.set_id(id);
        p.set_nick(resource.substr(underscoreLoc+1));
		return p;
	}

	std::string Str() const {
		return std::string("{ id: " + id() +
				", nick: " + nick() +
				" }"
				);
	}
private:
	std::string id_;
	std::string nick_;
};

}
#endif /* _PARTICIPANT_H_ */
