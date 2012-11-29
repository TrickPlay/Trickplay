#ifndef _JOINMATCHREQUEST_H_
#define _JOINMATCHREQUEST_H_

#include <string>

namespace libgameservice {

class JoinMatchRequest {
public:

	JoinMatchRequest() : free_role_(false) { }

	JoinMatchRequest(const std::string& match_id, bool freerole, const std::string& role, const std::string& nick) :
		match_id_(match_id), free_role_(freerole), role_(role), nick_(nick) {
	}

	const std::string& role() const {
		return role_;
	}
	void set_role(const std::string& str) {
		role_ = str;
	}

	const std::string& match_id() const {
		return match_id_;
	}
	void set_match_id(const std::string& newval) {
		match_id_ = newval;
	}

	bool free_role() const { return free_role_; }
	void set_free_role(bool val) { free_role_ = val; }

	const std::string& nick() const { return nick_; }
	void set_nick(const std::string& val) { nick_ = val; }

	std::string Str() const {
		return std::string(
				"{ match_id:" + match_id()
				+ ", free_role:" + (free_role() ? "true" : "false")
				+ ", role:" + role()
				+ ", nick:" + nick()
				+ "}"
				);
	}
private:
	std::string match_id_;
	bool free_role_;
	std::string role_;
	std::string nick_;

};

}

#endif /* _JOINMATCHREQUEST_H_ */
