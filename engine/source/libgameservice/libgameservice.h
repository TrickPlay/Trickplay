#ifndef _LIBGAMESERVICE_H_
#define _LIBGAMESERVICE_H_

#include <string>
#include <map>
#include <list>
#include <vector>
#include "../../basictypes.h"
#include "../../xmlconstants.h"
#include "xmppmugconstants.h"

namespace libgameservice {

/**
 * A list of strings.
 */
typedef std::list<std::string> StringList;

/**
 * A list of pointers to strings.
 */
typedef std::list<std::string*> StringPList;

/**
 * A map of strings.
 */
typedef std::map<std::string, std::string> StringMap;

/**
 * A multimap of strings.
 */
typedef std::multimap<std::string, std::string> StringMultiMap;

class StanzaExtension;
/**
 * A list of StanzaExtensions.
 */
typedef std::list<const StanzaExtension*> StanzaExtensionList;

extern std::string intToString(int val);
extern std::string longToString(long val);
extern std::string booleanToString(bool val);

enum StatusCode {
	OK,
	FAILED,
	APP_OPEN,
	APP_ALREADY_OPEN,
	APP_NOT_OPEN,
	INVALID_GAME_ID,
	INVALID_APP_ID,
	INVALID_ROLE,
	INVALID_MATCH_REQUEST,
};

enum MatchStatus { unknown = -1, created, active, paused, inactive, completed, aborted };

enum Affiliation { owner, member, none };

extern const char* statusToString(StatusCode sc);
extern const std::string& affiliationToString(Affiliation affiliation);
extern Affiliation stringToAffiliation(const std::string& str);
extern const std::string& matchStatusToString(MatchStatus status);
extern MatchStatus stringToMatchStatus(const std::string& str);
inline bool isValidMatchStatus(MatchStatus status) {
	return status >= created && status <= aborted;
}

class ResponseStatus {
public:
	ResponseStatus(StatusCode status_code, const std::string& error_msg) : status_code_(status_code), error_msg_(error_msg) { }
	ResponseStatus() : status_code_(OK) { }

	StatusCode status_code() const { return status_code_; }

	const std::string& error_message() const { return error_msg_; }

private:
	StatusCode status_code_;
	std::string error_msg_;

};

}

#endif
