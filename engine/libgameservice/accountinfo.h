#ifndef _LIBGAMESERVICE_ACCOUNTINFO_H_
#define _LIBGAMESERVICE_ACCOUNTINFO_H_

#include <string>

namespace libgameservice {

class AccountInfo {
public:

	AccountInfo() {
	}

	AccountInfo(const std::string& user_id, const std::string& full_name, const std::string& password, const std::string& email) :
		user_id_(user_id), full_name_(full_name), password_(password), email_(email) {
	}

	const std::string& user_id() const {
		return user_id_;
	}
	void set_user_id(const std::string& str) {
		user_id_ = str;
	}

	const std::string& full_name() const {
		return full_name_;
	}
	void set_full_name(const std::string& newval) {
		full_name_ = newval;
	}

	const std::string& password() const {
		return password_;
	}
	void set_password(const std::string& password) {
		password_ = password;
	}

	const std::string& email() const {
		return email_;
	}
	void set_email(const std::string& email) {
		email_ = email;
	}


	std::string Str() const {
		return std::string(
				"{ user_id=" + user_id()
				+ ", full_name=" + full_name()
				+ ", password=" + password()
				+ ", email=" + email()
				+ "}"
				);
	}
private:
	std::string user_id_;
	std::string full_name_;
	std::string password_;
	std::string email_;

};

}

#endif /* _LIBGAMESERVICE_ACCOUNTINFO_H_ */
