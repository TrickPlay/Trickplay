#ifndef _USERDATA_H_
#define _USERDATA_H_

#include <string>

namespace libgameservice {

class UserData {

public:

	UserData() { };
	UserData(const std::string& game_id, const std::string& opaque, int version)
	: game_id_(game_id), opaque_(opaque), version_(version) { }

	const std::string& opaque() const { return opaque_; }
	void set_opaque(const std::string& opaque) { opaque_ = opaque; }

	int version() const { return version_; }
	void set_version(int version) { version_ = version; }

	const std::string& game_id() const { return game_id_; }
	void set_game_id(const std::string& newval) { game_id_ = newval; }
private:
	std::string opaque_;
	int version_;
	std::string game_id_;
};

}

#endif /* _USERDATA_H_ */
