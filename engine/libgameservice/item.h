#ifndef _ITEM_H_
#define _ITEM_H_

#include <string>
#include "libgameservice.h"
namespace libgameservice {


class Item {
public:

	Item() { }

	Item(const std::string& nick) : nick_(nick) { }

	Item(const std::string& role, Affiliation affiliation, const std::string& jid)
	: role_(role), affiliation_(affiliation), jid_(jid) { }

	const std::string& nick() const { return nick_; }
	void set_nick(const std::string& str) { nick_ = str; }

	const std::string& role() const { return role_; }
	void set_role(const std::string& str) { role_ = str; }

	Affiliation affiliation() const { return affiliation_; }
	void set_affiliation(Affiliation affiliation) { affiliation_ = affiliation; }

	const std::string& jid() const { return jid_; }
	void set_jid(const std::string& jid) { jid_ = jid; }

	std::string Str() const {
		return std::string("{ nick: " + nick() +
				", role: " + role() +
				", affiliation: " + affiliationToString(affiliation()) +
				", jid: " + jid() +
				"}"
				);
	}

private:
	std::string nick_;
	std::string role_;
	Affiliation affiliation_;
	std::string jid_;
	static std::string affiliationList[];
};

}

#endif /* _ITEM_H_ */
